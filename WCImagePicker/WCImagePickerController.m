//
//  WCImagePickerControllerController.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/13.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCImagePickerController.h"
#import "WCCollectionPickerController.h"
#import "WCCustomButton.h"
#import "WCAssetCell.h"
#import "UIView+WCExtension.h"

@implementation UICollectionView (WCExtension)

- (NSArray<NSIndexPath *> *)wc_indexPathsForElementsInRect:(CGRect)rect {
    __block NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    NSArray<UICollectionViewLayoutAttributes *> *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0 || allLayoutAttributes == nil) return nil;
    [allLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attribute, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:attribute.indexPath];
    }];
    return [indexPaths copy];
}

@end

@implementation NSIndexSet (WCExtension)

- (NSArray<NSIndexPath *> *)wc_indexPathsFromIndexes {
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray<NSIndexPath *> arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
    }];
    return [indexPaths copy];
}

@end

@implementation NSBundle (WCExtension)

+ (NSBundle *)wc_defaultBundle {
    return [NSBundle wc_bundleForClass:[WCImagePickerController class]];
}

+ (NSBundle *)wc_bundleForClass:(Class)aclass {
    NSBundle *bundle = [NSBundle bundleForClass:aclass];
    NSString *bundlePath = [NSBundle wc_bundlePathForResource:@"WCImagePicker"];
    if (bundlePath) {
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    return bundle;
}

+ (NSString *)wc_bundlePathForResource:(NSString *)name {
    return [[NSBundle mainBundle] pathForResource:name ofType:@"bundle"];
}

@end

static NSString * const WCImagePickerAssetsCellIdentifier = @"com.meetday.WCImagePickerAssetCell";

@interface WCImagePickerController () <PHPhotoLibraryChangeObserver, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) PHAuthorizationStatus authrizationStatus;
@property(nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, assign) CGRect previousPreheatRect;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) NSMutableOrderedSet<PHAsset *> *selectedAssets;
@property (nonatomic, strong) NSIndexPath *previousSelectedItemIndexPath;
@property (nonatomic, strong) NSIndexPath *previousTouchingItemIndexPath;

@property (weak, nonatomic) IBOutlet UIView *navigationBarView;
@property (weak, nonatomic) IBOutlet UIView *navigationBarBackgroundView;
@property (weak, nonatomic) IBOutlet WCCustomButton *assetCollectionTitleButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *finishedButton;
@property (weak, nonatomic) IBOutlet UIView *collectionBaseView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property(nonatomic, assign) CGSize thumbnailSize;

@property (nonatomic, strong) WCCollectionPickerController *collectionPicker;
@property(nonatomic, assign) BOOL isCollectionPickerVisible;

@end

@implementation WCImagePickerController

- (instancetype)init {
    if (self = [super initWithNibName:[NSString stringWithUTF8String:object_getClassName(self)] bundle:[NSBundle wc_defaultBundle]]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _previousSelectedItemIndexPath = nil;
    _previousTouchingItemIndexPath = nil;
    _allowsMultipleSelection = YES;
    _mediaType = WCImagePickerImageTypeImage;
    _maximumNumberOfSelectionAsset = 1;
    _maximumNumberOfSelectionAsset = 1;
    
    _minimumItemSpacing = 2.0;
    _numberOfColumnsInPortrait = 4;
    _numberOfColumnsInLandscape = 6;
    
    _showAssetMaskWhenMaximumLimitReached = YES;
    _showWarningAlertWhenMaximumLimitReached = YES;
    _showPhotoAlbumWithoutAssetResources = NO;
    _fingerMovingToAssetForSelectionEnable = NO;
    _shouldRemoveAllSelectedAssetWhenAlbumChanged = YES;
    _isCollectionPickerVisible = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addPanGestureRecognizer];
    [self setupNavigationBarView];
    [self setupCollectionView];
    [self requestUserAuthorization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateItemSize];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.view layoutIfNeeded];
    [self updateItemSize];
}

+ (void)setupImagePickerAppearance:(WCImagePickerAppearance *)imagePickerAppearance {
    WCImagePickerAppearance *appearance = [WCImagePickerAppearance sharedAppearance];
    appearance.navigationBarBackgroundColor = imagePickerAppearance.navigationBarBackgroundColor;
    
    appearance.cancelButtonText = imagePickerAppearance.cancelButtonText;
    appearance.cancelButtonTextColor = imagePickerAppearance.cancelButtonTextColor;
    appearance.cancelButtonBackgroundColor = imagePickerAppearance.cancelButtonBackgroundColor;
    
    appearance.finishedButtonTextColor = imagePickerAppearance.finishedButtonTextColor;
    appearance.finishedButtonEnableBackgroundColor = imagePickerAppearance.finishedButtonEnableBackgroundColor;
    appearance.finishedButtonDisableBackgroundColor = imagePickerAppearance.finishedButtonDisableBackgroundColor;
    
    appearance.albumButtonTextColor = imagePickerAppearance.albumButtonTextColor;
    appearance.albumButtonTextFont = imagePickerAppearance.albumButtonTextFont;
}

#pragma mark - UI

- (void)requestUserAuthorization {
    void (^authorizationStatusAuthrizedBlock)(void) = ^() {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        self.authrizationStatus = PHAuthorizationStatusAuthorized;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.fetchResult == nil) {
                PHFetchOptions *options = [PHFetchOptions new];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                if (self.mediaType == WCImagePickerImageTypeImage) {
                    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                } else if (self.mediaType == WCImagePickerImageTypeVideo){
                    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
                }
                self.fetchResult = [PHAsset fetchAssetsWithOptions:options];
            }
            [self.collectionView reloadData];
        });
    };
    void (^authrizationStatusDeniedBlock)(void) = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionBaseView wc_showCoverViewForState:WCImagePickerCoverViewDenied];
        });
    };
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                authorizationStatusAuthrizedBlock();
            } else {
                authrizationStatusDeniedBlock();
            }
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        authorizationStatusAuthrizedBlock();
    } else {
        authrizationStatusDeniedBlock();
    }
}

- (void)setupNavigationBarView {
    WCImagePickerAppearance *imagePickerAppearance = [WCImagePickerAppearance sharedAppearance];
    if (imagePickerAppearance.navigationBarBackgroundColor) {
        self.navigationBarBackgroundView.backgroundColor = imagePickerAppearance.navigationBarBackgroundColor;
    } else {
        self.navigationBarBackgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:.85];
    }
    if (imagePickerAppearance.finishedButtonDisableBackgroundColor) {
        self.finishedButton.backgroundColor = imagePickerAppearance.finishedButtonDisableBackgroundColor;
    } else {
        self.finishedButton.backgroundColor = WCUIColorFromHexValue(0xDCDCDC);
    }
    if (imagePickerAppearance.finishedButtonTextColor) {
        [self.finishedButton.titleLabel setTextColor:imagePickerAppearance.finishedButtonTextColor];
    }
    
    if (imagePickerAppearance.albumButtonTextColor) {
        [self.assetCollectionTitleButton.titleLabel setTextColor:imagePickerAppearance.albumButtonTextColor];
    }
    if (imagePickerAppearance.albumButtonTextFont) {
        [self.assetCollectionTitleButton.titleLabel setFont:imagePickerAppearance.albumButtonTextFont];
    }
    
    UIImage *triangle  = [UIImage imageNamed:@"imagepicker_navigationbar_triangle_white" inBundle:[NSBundle wc_defaultBundle] compatibleWithTraitCollection:nil];
    [self.assetCollectionTitleButton wc_setImage:triangle];
    
    self.finishedButton.enabled = (self.selectedAssets.count > 0);
    self.finishedButton.layer.cornerRadius = 5.0f;
    self.finishedButton.layer.masksToBounds = YES;
    [self.finishedButton setTitle:@"完成(0)" forState:UIControlStateNormal];
}

- (void)setupCollectionView {
    self.collectionView.contentInset = UIEdgeInsetsMake(44.0, 0, 0, 0);
    [self.collectionView registerNib:[UINib nibWithNibName:@"WCAssetCell" bundle:[NSBundle wc_defaultBundle]] forCellWithReuseIdentifier:WCImagePickerAssetsCellIdentifier];
    self.collectionView.allowsMultipleSelection = self.allowsMultipleSelection;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
}

- (void)updateFinishedButtonAppearance {
    WCImagePickerAppearance *imagePickerAppearance = [WCImagePickerAppearance sharedAppearance];
    self.finishedButton.enabled = [self minimumNumberOfSelectionFulfilled];
    if ([self minimumNumberOfSelectionFulfilled]) {
        if (imagePickerAppearance.finishedButtonEnableBackgroundColor) {
            self.finishedButton.backgroundColor = imagePickerAppearance.finishedButtonEnableBackgroundColor;
        } else {
            self.finishedButton.backgroundColor = WCUIColorFromHexValue(0x1EB400);
        }
    } else {
        if (imagePickerAppearance.finishedButtonDisableBackgroundColor) {
            self.finishedButton.backgroundColor = imagePickerAppearance.finishedButtonDisableBackgroundColor;
        } else {
            self.finishedButton.backgroundColor = WCUIColorFromHexValue(0xDCDCDC);
        }
    }
    [self.finishedButton setTitle:[NSString stringWithFormat:@"完成(%td)", self.selectedAssets.count] forState:UIControlStateNormal];
}

- (void)showImagePickerWarningAlertWhenMaximumLimitReached {
    if (self.showWarningAlertWhenMaximumLimitReached) {
        NSString *title = [NSString stringWithFormat:@"你最多只能选择 %td 张图片", self.maximumNumberOfSelectionAsset];
        if (self.mediaType == WCImagePickerImageTypeVideo) {
            title = [NSString stringWithFormat:@"你最多只能选择 %td 个视频", self.maximumNumberOfSelectionAsset];
        } else if (self.mediaType == WCImagePickerImageTypeAny) {
            title = [NSString stringWithFormat:@"你最多只能选择 %td 个资源", self.maximumNumberOfSelectionAsset];
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];;
        [alertController addAction:action];
        if (self.presentedViewController == nil) {
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [self dismissViewControllerAnimated:NO completion:^{
                [self presentViewController:alertController animated:YES completion:nil];
            }];
        }
    }
}

#pragma mark - Photo Library Change Observer

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchResultChangeDetails *fetchChangeDetails = [changeInstance changeDetailsForFetchResult:self.fetchResult];
        if (fetchChangeDetails) {
            self.fetchResult = [fetchChangeDetails fetchResultAfterChanges];
            if (![fetchChangeDetails hasIncrementalChanges] || [fetchChangeDetails hasMoves]) {
                [self.collectionView reloadData];
            } else {
                [self.collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes= [fetchChangeDetails removedIndexes];
                    if ([removedIndexes count] > 0) {
                        [self.collectionView deleteItemsAtIndexPaths:[removedIndexes wc_indexPathsFromIndexes]];
                    }
                    NSIndexSet *insertedIndexes = [fetchChangeDetails insertedIndexes];
                    if ([insertedIndexes count] > 0) {
                        [self.collectionView insertItemsAtIndexPaths:[insertedIndexes wc_indexPathsFromIndexes]];
                    }
                    NSIndexSet *changedIndexes = [fetchChangeDetails changedIndexes];
                    if ([changedIndexes count] > 0) {
                        [self.collectionView reloadItemsAtIndexPaths:[changedIndexes wc_indexPathsFromIndexes]];
                    }
                } completion: nil];
            }
            [self resetCachedAssets];
        }
    });
}

#pragma mark - PanGesture

- (void)addPanGestureRecognizer {
    if (self.fingerMovingToAssetForSelectionEnable && self.allowsMultipleSelection) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self.view addGestureRecognizer:panGesture];
    }
}

- (void)handlePanGesture:(UIGestureRecognizer *)gestureRecognizer {
    if ([self maximumNumberOfSelectionReached]) return;
    CGPoint fingerPoint = [gestureRecognizer locationInView:self.collectionView];
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        if (CGRectContainsPoint(cell.frame, fingerPoint)) {
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            if (self.previousTouchingItemIndexPath != indexPath) {
                if ([self.collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
                    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
                    [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
                } else {
                    if ([self collectionView:self.collectionView shouldSelectItemAtIndexPath:indexPath]) {
                        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
                    }
                }
            }
            self.previousTouchingItemIndexPath = indexPath;
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.previousTouchingItemIndexPath = nil;
    }
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WCAssetCell *assetCell = [collectionView dequeueReusableCellWithReuseIdentifier:WCImagePickerAssetsCellIdentifier forIndexPath:indexPath];
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
    assetCell.representedAssetIdentifier = asset.localIdentifier;
    [self.imageManager requestImageForAsset:asset targetSize:self.thumbnailSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if ([assetCell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            assetCell.assetImageView.image = result;
        }
    }];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        NSInteger minutes = (NSInteger)floor((asset.duration / 60.0));
        NSInteger seconds = (NSInteger)ceil(asset.duration - (double)minutes*60.0);
        assetCell.assetTimeLabel.hidden = NO;
        assetCell.assetTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    return assetCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    WCAssetCell *assetCell = (WCAssetCell *)cell;
    if (assetCell.selected) {
        assetCell.shouldAnimationWhenSelectedOrderNumberUpdate = NO;
        assetCell.selectedOrderNumber = [self.selectedAssets indexOfObject:[self.fetchResult objectAtIndex:indexPath.item]] + 1;
        [assetCell updateAssetCellAppearanceIfNeeded];
    } else {
        if (self.showAssetMaskWhenMaximumLimitReached) {
            [assetCell shouldShowAssetCoverView:([self maximumNumberOfSelectionReached] && ![self autoDeselectEnabled])];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self autoDeselectEnabled]) return YES;
    BOOL maxmumNumberOfSelectionReached = [self maximumNumberOfSelectionReached];
    if (maxmumNumberOfSelectionReached) {
        [self showImagePickerWarningAlertWhenMaximumLimitReached];
    }
    if (!maxmumNumberOfSelectionReached && [self.delegate respondsToSelector:@selector(wc_imagePickerController:shouldSelectAsset:)]) {
        return [self.delegate wc_imagePickerController:self shouldSelectAsset:[self.fetchResult objectAtIndex:indexPath.item]];
    }
    return !maxmumNumberOfSelectionReached;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.allowsMultipleSelection) {
        if ([self autoDeselectEnabled] && self.selectedAssets.count > 0) {
            [self.selectedAssets removeObjectAtIndex:0];
            if (self.previousSelectedItemIndexPath) {
                [collectionView deselectItemAtIndexPath:self.previousSelectedItemIndexPath animated:NO];
                [self collectionView:collectionView didDeselectItemAtIndexPath:self.previousSelectedItemIndexPath ];
            }
        }
        PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
        [self.selectedAssets addObject:asset];
        self.previousSelectedItemIndexPath = indexPath;
        [self updateFinishedButtonAppearance];
        [self updateAssetCellAppearanceAtIndexpath:indexPath selected:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.allowsMultipleSelection) return;
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
    [self.selectedAssets removeObject:asset];
    self.previousSelectedItemIndexPath = nil;
    [self updateFinishedButtonAppearance];
    [self updateAssetCellAppearanceAtIndexpath:indexPath selected:NO];
}

- (void)updateAssetCellAppearanceAtIndexpath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    WCAssetCell *assetCell = (WCAssetCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    assetCell.shouldAnimationWhenSelectedOrderNumberUpdate = selected;
    assetCell.selectedOrderNumber = self.selectedAssets.count;
    [assetCell updateAssetCellAppearanceIfNeeded];
    selected ?: [self updateAllSelectedAssetCellAppearance];
    if (self.showAssetMaskWhenMaximumLimitReached) {
        BOOL shouldUpdateNonSelectCell = (!selected && (self.maximumNumberOfSelectionAsset - self.selectedAssets.count) == 1);
        if ([self maximumNumberOfSelectionReached] || shouldUpdateNonSelectCell) {
            [self updateAllNonSelectedAssetCellAppearance];
        }
    }
}

- (void)updateAllSelectedAssetCellAppearance {
    __weak typeof(self) weakSelf = self;
    [self.selectedAssets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[weakSelf.fetchResult indexOfObject:obj] inSection:0];
        WCAssetCell *assetCell = (WCAssetCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
        assetCell.shouldAnimationWhenSelectedOrderNumberUpdate = NO;
        assetCell.selectedOrderNumber = index + 1;
        [assetCell updateAssetCellAppearanceIfNeeded];
    }];
}

- (void)updateAllNonSelectedAssetCellAppearance {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (WCAssetCell *assetCell in self.collectionView.visibleCells) {
            assetCell.selected ?: [assetCell shouldShowAssetCoverView:([self maximumNumberOfSelectionReached] && ![self autoDeselectEnabled])];
        }
    });
}

#pragma mark -

- (BOOL)minimumNumberOfSelectionFulfilled {
    NSUInteger minimumNumberOfSelection = MAX(1, self.minimumNumberOfSelectionAsset);
    return (minimumNumberOfSelection <= self.selectedAssets.count);
}

- (BOOL)maximumNumberOfSelectionReached {
    self.minimumNumberOfSelectionAsset = MAX(1, self.minimumNumberOfSelectionAsset);
    self.maximumNumberOfSelectionAsset = MAX(1, self.maximumNumberOfSelectionAsset);
    if (self.maximumNumberOfSelectionAsset < self.minimumNumberOfSelectionAsset) {
        self.minimumNumberOfSelectionAsset = self.maximumNumberOfSelectionAsset;
    }
    return (self.maximumNumberOfSelectionAsset <= self.selectedAssets.count);
}

- (BOOL)autoDeselectEnabled {
    return (self.maximumNumberOfSelectionAsset == 1 && self.minimumNumberOfSelectionAsset <= self.maximumNumberOfSelectionAsset);
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCachedAssets];
}

#pragma mark Assets

- (void)updateItemSize {
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    NSInteger numberOfColumns = isPortrait ? self.numberOfColumnsInPortrait : self.numberOfColumnsInLandscape;
    CGFloat collectionViewWidth = self.collectionView.bounds.size.width;
    CGFloat itemWidth = floor((collectionViewWidth - (numberOfColumns - 1) * self.minimumItemSpacing) / numberOfColumns);
    CGFloat scale = [[UIScreen mainScreen] scale];
    self.thumbnailSize = CGSizeMake(itemWidth*scale, itemWidth*scale);
    self.flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
}

- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    if (!self.isViewLoaded || self.view == nil || self.authrizationStatus != PHAuthorizationStatusAuthorized) return;
    CGFloat collectionViewWidth = self.collectionView.bounds.size.width;
    CGFloat collectionViewHeight = self.collectionView.bounds.size.height;
    CGFloat offsetX = self.collectionView.contentOffset.x;
    CGFloat offsetY = self.collectionView.contentOffset.y;
    CGRect visibleRect = CGRectMake(offsetX, offsetY, collectionViewWidth, collectionViewHeight);
    CGRect preheatRect = CGRectInset(visibleRect, 0, -0.5 * visibleRect.size.height);
    CGFloat delta = fabs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta < self.view.bounds.size.height / 3.0) return;
    [self calculateDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect addHandler:^(CGRect addRect) {
        NSArray<NSIndexPath *> *indexPaths = [self.collectionView wc_indexPathsForElementsInRect:addRect];
        NSArray *assetsNeedToStartCache = [self assetsAtIndexPath:indexPaths];
        [self.imageManager startCachingImagesForAssets:assetsNeedToStartCache targetSize:self.thumbnailSize contentMode:PHImageContentModeAspectFill options:nil];
    } removeHandler:^(CGRect removeRect) {
        NSArray<NSIndexPath *> *indexPaths = [self.collectionView wc_indexPathsForElementsInRect:removeRect];
        NSArray *assetsNeedToStopCache = [self assetsAtIndexPath:indexPaths];
        [self.imageManager stopCachingImagesForAssets:assetsNeedToStopCache targetSize:self.thumbnailSize contentMode:PHImageContentModeAspectFill options:nil];
    }];
    self.previousPreheatRect = preheatRect;
}

- (NSArray<PHAsset *> *)assetsAtIndexPath:(NSArray<NSIndexPath *> *)indexPaths {
    if (indexPaths == nil || indexPaths.count == 0) return nil;
    NSMutableArray<PHAsset *> *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.item < self.fetchResult.count) {
            [assets addObject:[self.fetchResult objectAtIndex:indexPath.item]];
        }
    }
    return [assets copy];
}

- (void)calculateDifferenceBetweenRect:(CGRect)previouseRect andRect:(CGRect)preheatRect addHandler:(void(^)(CGRect addRect))addHandler removeHandler:(void(^)(CGRect removeRect))removeHandler {
    CGFloat previousRectMaxY = CGRectGetMaxY(previouseRect);
    CGFloat previousRectMinY = CGRectGetMinY(previouseRect);
    CGFloat preheatRectMaxY = CGRectGetMaxY(preheatRect);
    CGFloat preheatRectMinY = CGRectGetMinY(preheatRect);
    CGFloat preheatRectOriginX = preheatRect.origin.x;
    CGFloat preheatRectWidth = preheatRect.size.width;
    if (preheatRectMaxY > previousRectMaxY) {
        addHandler(CGRectMake(preheatRectOriginX, previousRectMaxY, preheatRectWidth, preheatRectMaxY - previousRectMaxY));
    }
    if (preheatRectMinY < previousRectMinY) {
        addHandler(CGRectMake(preheatRectOriginX, preheatRectMinY, preheatRectWidth, previousRectMinY - preheatRectMinY));
    }
    
    if (preheatRectMaxY < previousRectMaxY) {
        removeHandler(CGRectMake(preheatRectOriginX, preheatRectMaxY, preheatRectWidth, previousRectMaxY - preheatRectMaxY));
    }
    if (preheatRectMinY > previousRectMinY) {
        removeHandler(CGRectMake(previouseRect.origin.x, previousRectMinY, preheatRectWidth, preheatRectMinY - previousRectMinY));
    }
    addHandler = nil;
    removeHandler = nil;
}

#pragma mark - IBAction

- (IBAction)cancelButtonDidClicked:(UIButton *)sender {
    if (self.isCollectionPickerVisible) {
        [self.collectionPicker dismissCollectionPicker];
    } else {
        if ([self.delegate respondsToSelector:@selector(wc_imagePickerControllerDidCancel:)]) {
            [self.delegate wc_imagePickerControllerDidCancel:self];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)finishedButtonDidClicked:(UIButton *)sender {
    if (self.isCollectionPickerVisible) {
        [self.collectionPicker dismissCollectionPicker];
    } else {
        if ([self.delegate respondsToSelector:@selector(wc_imagePickerController:didFinishPickingAssets:)]) {
            [self.delegate wc_imagePickerController:self didFinishPickingAssets:[self.selectedAssets array]];
        }
        if (self.mediaType == WCImagePickerImageTypeImage && [self.delegate respondsToSelector:@selector(wc_imagePickerController:didFinishPickingImages:)]) {
            NSMutableArray *images = [NSMutableArray array];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            for (PHAsset *asset in self.selectedAssets) {
                [self.imageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    [images addObject:result];
                }];
            }
            [self.delegate wc_imagePickerController:self didFinishPickingImages:[images copy]];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)assetCollectionTitleButtonDidClicked:(UIButton *)sender {
    if (self.authrizationStatus != PHAuthorizationStatusAuthorized) return;
    self.collectionPicker.imagePickerController = self;
    __weak typeof(self)weakSelf = self;
    [self.collectionPicker showCollectionPicker:^(BOOL willShowCollectionPicker) {
        [sender setSelected:willShowCollectionPicker];
        weakSelf.isCollectionPickerVisible = YES;
    } dismissCollectionPicker:^(BOOL willDismissCollectionPicker) {
        [sender setSelected:!willDismissCollectionPicker];
        weakSelf.isCollectionPickerVisible = NO;
    } completion:^(NSString *assetCollectionTitle, PHFetchResult *fetchResult) {
        [weakSelf resetCachedAssets];
        if (weakSelf.shouldRemoveAllSelectedAssetWhenAlbumChanged) {
            [weakSelf.selectedAssets removeAllObjects];
        }
        [weakSelf.assetCollectionTitleButton setTitle:assetCollectionTitle forState:UIControlStateNormal];
        weakSelf.fetchResult = fetchResult;
        [weakSelf.collectionView reloadData];
    }];
}

#pragma mark - getter and setter

- (NSMutableOrderedSet<PHAsset *> *)selectedAssets {
    if (_selectedAssets == nil) {
        _selectedAssets = [NSMutableOrderedSet<PHAsset *> orderedSet];
    }
    return _selectedAssets;
}

- (PHCachingImageManager *)imageManager {
    if (_imageManager == nil) {
        _imageManager = [PHCachingImageManager new];
    }
    return _imageManager;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (_flowLayout == nil) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = _minimumItemSpacing;
        _flowLayout.minimumInteritemSpacing = _minimumItemSpacing;
    }
    return _flowLayout;
}

- (WCCollectionPickerController *)collectionPicker {
    if (_collectionPicker == nil) {
        _collectionPicker = [[WCCollectionPickerController alloc] init];
        [self addChildViewController:_collectionPicker];
        _collectionPicker.view.hidden = YES;
        _collectionPicker.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view insertSubview:_collectionPicker.view belowSubview:self.navigationBarView];
        NSLayoutConstraint *topCons = [NSLayoutConstraint constraintWithItem:_collectionPicker.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.navigationBarView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *bottomCons = [NSLayoutConstraint constraintWithItem:_collectionPicker.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *leadingCons = [NSLayoutConstraint constraintWithItem:_collectionPicker.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        NSLayoutConstraint *trailingCons = [NSLayoutConstraint constraintWithItem:_collectionPicker.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        [NSLayoutConstraint activateConstraints:@[topCons, bottomCons, leadingCons, trailingCons]];
    }
    return _collectionPicker;
}

@end

@implementation WCImagePickerAppearance

+ (instancetype)sharedAppearance {
    static WCImagePickerAppearance *sharedAppearance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedAppearance = [[WCImagePickerAppearance alloc] init];
    });
    return sharedAppearance;
}

@end
