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

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

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

static NSString * const WCImagePickerAssetsCellIdentifier = @"com.meetday.WCImagePickerAssetCell";

@interface WCImagePickerController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property(nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) NSMutableOrderedSet *selectedAssets;
@property (nonatomic, strong) NSIndexPath *previousSelectedItemIndexPath;

@property (nonatomic, strong) NSBundle *assetBundle;

@property (nonatomic, assign) CGRect previousPreheatRect;
@property(nonatomic, assign) CGSize thumbnailSize;

@property (weak, nonatomic) IBOutlet UIView *navigationBarView;
@property (weak, nonatomic) IBOutlet UIView *navigationBarBackgroundView;

@property (weak, nonatomic) IBOutlet WCCustomButton *assetCollectionTitleButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *finishedButton;
@property (weak, nonatomic) IBOutlet UIView *collectionBaseView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) WCCollectionPickerController *collectionPicker;

@end

@implementation WCImagePickerController

- (instancetype)init {
    if (self = [super init]) {
        _previousSelectedItemIndexPath = nil;
        _allowsMultipleSelection = YES;
        _mediaType = WCImagePickerImageTypeImage;
        _maximumNumberOfSelectionAsset = 1;
        _maximumNumberOfSelectionAsset = 1;

        _minimumItemSpacing = 2.0;
        _numberOfColumnsInPortrait = 4;
        _numberOfColumnsInLandscape = 6;
        
        _showNumberOfSelectedAssets = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self handleAssetPath];
    [self setupNavigationBarView];
    [self setupCollectionView];
    
    [self requestUserAuthorization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateItemSize];
    CGPoint bottomOffset = CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height);
    NSLog(@"%f -- %f -- %@", self.collectionView.contentSize.height, self.collectionView.bounds.size.height, NSStringFromCGPoint(bottomOffset));
    [self.collectionView setContentOffset:bottomOffset];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.view layoutIfNeeded];
    [self updateItemSize];
}

#pragma mark - UI

+ (void)setupImagePickerAppearance:(WCImagePickerAppearance *)imagePickerAppearance {
    WCImagePickerAppearance *appearance = [WCImagePickerAppearance sharedAppearance];
    appearance.navigationBarBackgroundColor = imagePickerAppearance.navigationBarBackgroundColor;
    
    appearance.cancelButtonText = imagePickerAppearance.cancelButtonText;
    appearance.cancelButtonTextColor = imagePickerAppearance.cancelButtonTextColor;
    appearance.cancelButtonBackgroundColor = imagePickerAppearance.cancelButtonBackgroundColor;
    
    appearance.finishedButtonTextColor = imagePickerAppearance.finishedButtonTextColor;
    appearance.finishedButtonEnableBackgroundColor = imagePickerAppearance.finishedButtonEnableBackgroundColor;
    appearance.finishedButtonDisableBackgroundColor = imagePickerAppearance.finishedButtonDisableBackgroundColor;
    
    appearance.assetCollectionButtonTextColor = imagePickerAppearance.assetCollectionButtonTextColor;
}

- (void)requestUserAuthorization {
    void (^authorizationStatusAuthrizedBlock)(void) = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.fetchResult == nil) {
                PHFetchOptions *options = [PHFetchOptions new];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
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

- (void)handleAssetPath {
    self.assetBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [self.assetBundle pathForResource:@"WCImagePicker" ofType:@"bunlde"];
    if (bundlePath) {
        self.assetBundle = [NSBundle bundleWithPath:bundlePath];
    }
}

- (void)setupNavigationBarView {
    
    WCImagePickerAppearance *imagePickerAppearance = [WCImagePickerAppearance sharedAppearance];
    if (imagePickerAppearance.navigationBarBackgroundColor) {
        self.navigationBarBackgroundView.backgroundColor = imagePickerAppearance.navigationBarBackgroundColor;
    } else {
        self.navigationBarBackgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:.8];
    }
    
    if (imagePickerAppearance.finishedButtonDisableBackgroundColor) {
        self.finishedButton.backgroundColor = imagePickerAppearance.finishedButtonDisableBackgroundColor;
    } else {
        self.finishedButton.backgroundColor = WCUIColorFromHexValue(0xDCDCDC);
    }
    
    
    UIImage *triangle  = [UIImage imageNamed:@"imagepicker_navigationbar_triangle_white" inBundle:self.assetBundle compatibleWithTraitCollection:nil];
    [self.assetCollectionTitleButton wc_setImage:triangle];
    
    
    [self.finishedButton setTitle:@"完成(0)" forState:UIControlStateNormal];
    if (imagePickerAppearance.finishedButtonTextColor) {
        [self.finishedButton.titleLabel setTextColor:imagePickerAppearance.finishedButtonTextColor];
    } else {
        [self.finishedButton.titleLabel setTextColor:[UIColor whiteColor]];
    }
}

- (void)setupCollectionView {
    self.collectionView.contentInset = UIEdgeInsetsMake(44.0, 0, 0, 0);
    [self.collectionView registerNib:[UINib nibWithNibName:@"WCAssetCell" bundle:nil] forCellWithReuseIdentifier:WCImagePickerAssetsCellIdentifier];
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
    
    if (self.showNumberOfSelectedAssets) {
        if (self.selectedAssets.count > 0) {
            [self.finishedButton setTitle:[NSString stringWithFormat:@"完成(%td)", self.selectedAssets.count] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WCAssetCell *assetCell = [collectionView dequeueReusableCellWithReuseIdentifier:WCImagePickerAssetsCellIdentifier forIndexPath:indexPath];
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
    
    if ([self.selectedAssets containsObject:asset]) {
    }
    assetCell.representedAssetIdentifier = asset.localIdentifier;
    [self.imageManager requestImageForAsset:asset targetSize:self.thumbnailSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if ([assetCell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            assetCell.assetImageView.image = result;
        }
    }];
    return assetCell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(wc_imagePickerController:shouldSelectAsset:)]) {
        return [self.delegate wc_imagePickerController:self shouldSelectAsset:[self.fetchResult objectAtIndex:indexPath.item]];
    }
    if ([self autoDeselectEnabled]) return YES;
    return ![self maximumNumberOfSelectionReached];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
    if (self.allowsMultipleSelection) {
        if ([self autoDeselectEnabled] && self.selectedAssets.count > 0) {
            [self.selectedAssets removeObjectAtIndex:0];
            if (self.previousSelectedItemIndexPath) {
                [collectionView deselectItemAtIndexPath:self.previousSelectedItemIndexPath animated:NO];
            }
        }
        [self.selectedAssets addObject:asset];
        self.previousSelectedItemIndexPath = indexPath;
        [self updateFinishedButtonAppearance];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.allowsMultipleSelection) return;
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
    [self.selectedAssets removeObject:asset];
    self.previousSelectedItemIndexPath = nil;
    [self updateFinishedButtonAppearance];
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
    if (!self.isViewLoaded || self.view == nil) return;
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)finishedButtonDidClicked:(UIButton *)sender {
//    [self.contentView wc_showCoverViewForState:WCImagePickerCoverViewLoading];
}

- (IBAction)assetCollectionTitleButtonDidClicked:(UIButton *)sender {
    self.collectionPicker.imagePickerController = self;
    __weak typeof(self)weakSelf = self;
    [self.collectionPicker showCollectionPicker:^(BOOL willShowCollectionPicker) {
        [sender setSelected:willShowCollectionPicker];
    } dismissCollectionPicker:^(BOOL willDismissCollectionPicker) {
        [sender setSelected:!willDismissCollectionPicker];
    } completion:^(NSString *assetCollectionTitle, PHFetchResult *fetchResult) {
        [weakSelf.assetCollectionTitleButton setTitle:assetCollectionTitle forState:UIControlStateNormal];
        weakSelf.fetchResult = fetchResult;
        [weakSelf.collectionView reloadData];
    }];
}

#pragma mark - getter and setter

- (NSMutableOrderedSet *)selectedAssets {
    if (_selectedAssets == nil) {
        _selectedAssets = [NSMutableOrderedSet orderedSet];
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
