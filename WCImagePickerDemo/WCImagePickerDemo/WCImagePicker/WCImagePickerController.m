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
#define SCALE ([[UIScreen mainScreen] scale])

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
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) NSMutableOrderedSet *selectedAssets;
@property (nonatomic, strong) NSBundle *assetBundle;

@property (nonatomic, assign) CGRect previousPreheatRect;
@property(nonatomic, assign) CGSize thumbnailSize;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *navigationBarView;
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
        _mediaType = WCImagePickerImageTypeImage;
        _allowsMultipleSelection = YES;
        _maximumNumberOfSelectionPhoto = 1;
        _minimumNumberOfSelectionPhoto = 1;
        _maximumNumberOfSelectionVideo = 1;
        _minimumNumberOfSelectionVideo = 1;
        
        _minimumItemSpacing = 2.0;
        _numberOfColumnsInPortrait = 3;
        _numberOfColumnsInLandscape = 5;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateItemSize];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.view layoutIfNeeded];
    [self updateItemSize];
}

#pragma mark - UI

- (void)requestUserAuthorization {
    void (^authorizationStatusAuthrizedBlock)(void) = ^() {
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

- (void)handleAssetPath {
    self.assetBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [self.assetBundle pathForResource:@"WCImagePicker" ofType:@"bunlde"];
    if (bundlePath) {
        self.assetBundle = [NSBundle bundleWithPath:bundlePath];
    }
}

- (void)setupNavigationBarView {
    self.navigationBarView.backgroundColor = self.navigationBarBackgroundColor;
    self.view.backgroundColor = self.navigationBarBackgroundColor;
    UIImage *triangle  = [UIImage imageNamed:@"imagepicker_navigationbar_triangle_white" inBundle:self.assetBundle compatibleWithTraitCollection:nil];
    [self.assetCollectionTitleButton wc_setImage:triangle];
}

- (void)setupCollectionView {
    [self.collectionView registerNib:[UINib nibWithNibName:@"WCAssetCell" bundle:nil] forCellWithReuseIdentifier:WCImagePickerAssetsCellIdentifier];
    self.collectionView.allowsMultipleSelection = self.allowsMultipleSelection;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCachedAssets];
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
    return assetCell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)updateFetchResult {
    if (self.assetCollection) {
        PHFetchOptions *options = [PHFetchOptions new];
        if (self.mediaType == WCImagePickerImageTypeImage) {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        } else if (self.mediaType == WCImagePickerImageTypeVideo) {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
        self.fetchResult = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:options];
    } else {
        self.fetchResult = nil;
    }
}

- (void)updateItemSize {
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    NSInteger numberOfColumns = isPortrait ? self.numberOfColumnsInPortrait : self.numberOfColumnsInLandscape;
    CGFloat collectionViewWidth = self.collectionView.bounds.size.width;
    CGFloat itemWidth = floor((collectionViewWidth - (numberOfColumns - 1) * self.minimumItemSpacing) / numberOfColumns);
    self.thumbnailSize = CGSizeMake(itemWidth * SCALE, itemWidth * SCALE);
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
    [self.contentView wc_showCoverViewForState:WCImagePickerCoverViewLoading];
}

- (IBAction)assetCollectionTitleButtonDidClicked:(UIButton *)sender {
    [self.collectionPicker collectionPickerTrigger];
    [sender setSelected:self.collectionPicker.isVisible];
}

#pragma mark - getter and setter

- (void)setAssetCollection:(PHAssetCollection *)assetCollection {
    _assetCollection = assetCollection;
    [self updateFetchResult];
    [self.collectionView reloadData];
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
        _collectionPicker.view.hidden = YES;
        _collectionPicker.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addChildViewController:_collectionPicker];
        [self.view insertSubview:_collectionPicker.view belowSubview:self.navigationBarView];
        NSLayoutConstraint *topCons = [NSLayoutConstraint constraintWithItem:_collectionPicker.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottomCons = [NSLayoutConstraint constraintWithItem:_collectionPicker.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *leadingCons = [NSLayoutConstraint constraintWithItem:_collectionPicker.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        NSLayoutConstraint *trailingCons = [NSLayoutConstraint constraintWithItem:_collectionPicker.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        [NSLayoutConstraint activateConstraints:@[topCons, bottomCons, leadingCons, trailingCons]];
    }
    return _collectionPicker;
}

@end
