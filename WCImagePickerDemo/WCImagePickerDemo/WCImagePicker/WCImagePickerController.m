//
//  WCImagePickerControllerController.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/13.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCImagePickerController.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCALE ([[UIScreen mainScreen] scale])

@interface WCImagePickerController ()

@property(nonatomic, strong) PHCachingImageManager *imageManager;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property(nonatomic, assign) CGSize thumbnailSize;

@end

@implementation WCImagePickerController

- (instancetype)init {
    if (self = [super init]) {
        _mediaType = WCImagePickerImageTypeImage;
        _allowMultipleSelections = YES;
        _maximumNumberOfSelections = 1;
        _minimumNumberOfSelections = 1;
        _numberOfColumnsInPortrait = 4;
        _numberOfColumnsInLandscape = 7;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [self updateItemSize];
}


- (void)updateItemSize {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSInteger numberOfColumns = orientation == UIDeviceOrientationPortrait ? self.numberOfColumnsInPortrait : self.numberOfColumnsInLandscape;
    CGFloat itemWidth = floor((SCREEN_WIDTH - (numberOfColumns + 1) * self.minimumItemSpacing) / numberOfColumns);
    self.flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    [self.flowLayout invalidateLayout];
    self.thumbnailSize = CGSizeMake(itemWidth * SCALE, itemWidth * SCALE);
}

- (void)calculateDifferenceBetweenRect:(CGRect)previouseRect andRect:(CGRect)preheatRect addHandler:(void(^)(CGRect addRect))addHandler removeHandler:(void(^)(CGRect removeRect))removeHandler {
    CGFloat previousRectMaxY = CGRectGetMaxY(previouseRect);
    CGFloat previousRectMinY = CGRectGetMinY(previouseRect);
    CGFloat preheatRectMaxY = CGRectGetMaxY(preheatRect);
    CGFloat preheatRectMinY = CGRectGetMinY(preheatRect);
    if (preheatRectMaxY > previousRectMaxY) {
        addHandler(CGRectMake(preheatRect.origin.x, previousRectMaxY, preheatRect.size.width, preheatRectMaxY - previousRectMaxY));
    }
    if (preheatRectMinY < previousRectMinY) {
        addHandler(CGRectMake(preheatRect.origin.x, preheatRectMinY, preheatRect.size.width, previousRectMinY - preheatRectMinY));
    }
    
    if (preheatRectMaxY < previousRectMaxY) {
        removeHandler(CGRectMake(preheatRect.origin.x, preheatRectMaxY, preheatRect.size.width, previousRectMaxY - preheatRectMaxY));
    }
    if (preheatRectMinY > previousRectMinY) {
        removeHandler(CGRectMake(previouseRect.origin.x, previousRectMinY, preheatRect.size.width, preheatRectMinY - previousRectMinY));
    }
}

#pragma mark - getter and setter

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

@end
