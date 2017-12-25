//
//  WCPhotoBrowserViewController.m
//  PhotoBrowserDemo
//
//  Created by 王超 on 2017/11/28.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCPhotoBrowserViewController.h"
#import "WCPhotoBrowserView.h"
#import "WCPhotoModel.h"
#import "WCPhotoView.h"
#import "UIImage+Bundle.h"
#import "UIViewController+TopViewController.h"
#import "WCMaskAnimatedTransition.h"

#define STATUS_BAR_HEIGHT 20
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREENT_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_X (IS_IPHONE && SCREENT_MAX_LENGTH == 812.0)

@interface WCPhotoBrowserViewController () <WCPhotoBrowserDelegate> {
    UILongPressGestureRecognizer *_longPressGesture;
    WCMaskAnimatedTransition *_maskAnimatedTransition;
    UIImage *_currentDisplayImage;
    NSInteger _currentDisplayImageIndex;
}
@property (nonatomic, assign) BOOL photoBrowserDismissedFromUpToDown;
@property (weak, nonatomic) IBOutlet WCPhotoBrowserView *photoBrowserView;
@property (weak, nonatomic) IBOutlet UIView *navigationBarView;
@property (weak, nonatomic) IBOutlet UIButton *cancleButton;
@property (weak, nonatomic) IBOutlet UILabel *photoOrderLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *photoPageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarViewTopConstraint;


@end

@implementation WCPhotoBrowserViewController

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithImages:(NSArray<WCPhotoModel *> *)images {
    if (self = [super init]) {
        self.images = images;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithNetworkImages:(NSArray *)networkImages {
    if (self = [super init]) {
        self.networkImages = networkImages;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithLocalImages:(NSArray<UIImage *> *)localImages {
    if (self = [super init]) {
        self.localImages = localImages;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _showStatusBar = YES;
    _showNavigationBar = YES;
    _currentDisplayImage = nil;
    _displayPhotoOrderInfo = NO;
    _displayPageControl = NO;
    _longPressGestureEnabled = NO;
    _singleTapGestureEnabled = YES;
    _currentDisplayImageIndex = 0;
    _firstDisplayPhotoIndex = 0;
    _photoBrowserDismissedFromUpToDown = NO;
    _statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNavigationBar];
    [self setupPhotoOrderLabel];
    [self setupPhotoPageControl];
    [self setupPhotoBrowser];
    [self setupLongPressGesture];
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!IS_IPHONE_X && !self.showStatusBar) {
        self.navigationBarViewTopConstraint.constant -= STATUS_BAR_HEIGHT;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showNavigationBarView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideNavigationBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return !self.showStatusBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

- (void)show {
    if (self.transitioningDelegate) {
        if ([self.transitioningDelegate isKindOfClass:[WCPhotoBrowserAnimator class]]) {
            WCPhotoBrowserAnimator *animator = (WCPhotoBrowserAnimator *)self.transitioningDelegate;
            animator.animatorDismissDelegate = self;
        }
    } else {
        _maskAnimatedTransition = [[WCMaskAnimatedTransition alloc] init];
        self.transitioningDelegate = _maskAnimatedTransition;
    }
    
    /**
     In iOS7, there's actually a new property for UIViewController called modalPresentationCapturesStatusBarAppearance
     When you present a view controller by calling the presentViewController:animated:completion: method, status bar appearance control is transferred from the presenting to the presented view controller only if the presented controller’s modalPresentationStyle value is UIModalPresentationFullScreen. By setting this property to YES, you specify the presented view controller controls status bar appearance, even though presented non–fullscreen.
     网址链接:https://stackoverflow.com/questions/23615647/uiviewcontrollers-prefersstatusbarhidden-not-working
     */
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    [[UIViewController topViewController] presentViewController:self animated:YES completion:nil];
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI

- (void)setupPhotoBrowser {
    self.photoBrowserView.singleTapGestureEnabled = self.singleTapGestureEnabled;
    self.photoBrowserView.delegate = self;
    // 以下属性只针对图片下拉时视具体情况调用
    __weak typeof(self) weakSelf = self;
    self.photoBrowserView.photoBrowserWillAppear = ^{
        [weakSelf showNavigationBarView];
    };
    self.photoBrowserView.photoBrowserWillDisappear = ^{
        [weakSelf hideNavigationBarView];
    };
    self.photoBrowserView.photoBrowserDidDisappear = ^(BOOL photoBrowserDismissedFromUpToDown) {
        weakSelf.photoBrowserDismissedFromUpToDown = photoBrowserDismissedFromUpToDown;
        [weakSelf dismissViewController];
    };
    self.photoBrowserView.photoBrowserBackgroundColorAlphaDidChange = ^(CGFloat photoBrowserBackgroundColorAlpha, CGFloat photoBrowserViewAlpha) {
        weakSelf.view.backgroundColor = [UIColor colorWithWhite:0 alpha:photoBrowserBackgroundColorAlpha];
        weakSelf.view.alpha = MIN(weakSelf.view.alpha, photoBrowserViewAlpha);
    };
}

- (void)setupNavigationBar {
    self.navigationBarView.backgroundColor = [UIColor clearColor];
    [self.cancleButton setImage:[UIImage wc_imageNamed:@"wc_photobrowser_cancle" bundleName:@"WCPhotoBrowser"] forState:UIControlStateNormal];
    [self.cancleButton setImage:[UIImage wc_imageNamed:@"wc_photobrowser_cancle" bundleName:@"WCPhotoBrowser"] forState:UIControlStateHighlighted];
}

- (void)setupPhotoOrderLabel {
    if (self.displayPhotoOrderInfo) {
        [self.photoOrderLabel setHidden:NO];
        self.photoOrderLabel.textColor = [UIColor whiteColor];
    } else {
        [self.photoOrderLabel setHidden:YES];
    }
}

- (void)setupPhotoPageControl {
    // 若单张图片则不现实底部的pageControl
    if (self.displayPageControl && self.images.count > 1) {
        self.photoPageControl.hidden = NO;
        self.photoPageControl.hidesForSinglePage = YES;
        self.photoPageControl.defersCurrentPageDisplay = YES;
        self.photoPageControl.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor ? self.currentPageIndicatorTintColor: [UIColor whiteColor];
        self.photoPageControl.pageIndicatorTintColor = self.pageIndicatorTintColor ? self.pageIndicatorTintColor : [UIColor lightGrayColor];
        self.photoPageControl.numberOfPages = self.images.count;
    } else {
        self.photoPageControl.hidden = YES;
    }
}

- (void)showNavigationBarView {
    if (self.showNavigationBar && self.navigationBarView.hidden) {
        [UIView animateWithDuration:0.25 animations:^{
            self.navigationBarView.hidden = NO;
        }];
    }
}

- (void)hideNavigationBarView {
    if (!self.navigationBarView.hidden) {
        [UIView animateWithDuration:0.25 animations:^{
            self.navigationBarView.hidden = YES;
        }];
    }
}

#pragma mark - Long Press Gesture

- (void)setupLongPressGesture {
    if (self.longPressGestureEnabled) {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self.view addGestureRecognizer:longPressGesture];
        _longPressGesture = longPressGesture;
    } else {
        if (_longPressGesture) {
            [self.view removeGestureRecognizer:_longPressGesture];
        }
    }
}

- (void)handleLongPressGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (self.longPressGestureTriggerBlock) {
            self.longPressGestureTriggerBlock(self, _currentDisplayImage, _currentDisplayImageIndex);
        }
        if ([self.delegate respondsToSelector:@selector(photoBrowser:longPressGestureTriggerAtCurrentDisplayImage:)]) {
            [self.delegate photoBrowser:self longPressGestureTriggerAtCurrentDisplayImage:_currentDisplayImage];
        }
    }
}

#pragma mark - TapGesture

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    [UIView animateWithDuration:0.25 animations:^{
        self.navigationBarView.hidden = YES;
    } completion:^(BOOL finished) {
        [self dismissViewController];
    }];
}

#pragma mark PhotoBrowser Delegate

- (NSInteger)numberOfPhotosInPhotoBrowser:(WCPhotoBrowserView *)photoBrowser {
    return self.images.count;
}

- (WCPhotoModel *)photoBrowser:(WCPhotoBrowserView *)photoBrowser photoDataForIndex:(NSInteger)index {
    return [self.images objectAtIndex:index];
}

- (void)photoBrowser:(WCPhotoBrowserView *)photoBrowser currentDisplayPhotoIndex:(NSInteger)index {
    _currentDisplayImageIndex = index;
    if ([self.delegate respondsToSelector:@selector(photoBrowser:currentDisplayImageIndex:)]) {
        [self.delegate photoBrowser:self currentDisplayImageIndex:_currentDisplayImageIndex];
    }
    
    if (self.displayPhotoOrderInfo) {
        [self.photoOrderLabel setText:[NSString stringWithFormat:@"%td/%td", _currentDisplayImageIndex + 1, self.images.count]];
    }
    if (self.displayPageControl) {
        self.photoPageControl.currentPage = _currentDisplayImageIndex;
    }
}

- (void)photoBrowser:(WCPhotoBrowserView *)photoBrowser currentDisplayPhoto:(UIImage *)currentDisplayPhoto currentDisplayPhotoIndex:(NSInteger)currentDisplayPhotoIndex {
    _currentDisplayImage = currentDisplayPhoto;
    _currentDisplayImageIndex = currentDisplayPhotoIndex;
    if ([self.delegate respondsToSelector:@selector(photoBrowser:currentDisplayImage:currentDisplayImageIndex:)]) {
        [self.delegate photoBrowser:self currentDisplayImage:_currentDisplayImage currentDisplayImageIndex:_currentDisplayImageIndex];
    }
}

- (NSInteger)firstDisplayPhotoIndexInPhotoBrowser:(WCPhotoBrowserView *)photoBrowser {
    return MIN(MAX(0, self.firstDisplayPhotoIndex), self.images.count - 1);
}

- (UIImage *)placeholderImageForPhotoBrowser:(WCPhotoBrowserView *)photoBrowser {
    return self.placehoderImage;
}

#pragma mark - photo browser dimiss animator delegate

- (UIImage *)currentDisplayImageInPhotoBrowser {
    return _currentDisplayImage;
}

- (NSInteger)currentDisplayImageIndexInPhotoBrowser {
    return _currentDisplayImageIndex;
}

- (BOOL)photoBrowserDismissedFromUpToDown {
    return _photoBrowserDismissedFromUpToDown;
}

#pragma mark IBAction

- (IBAction)cancleButtonDidClicked:(id)sender {
    [self dismissViewController];
}

#pragma mark - getter and setter

- (void)setShowNavigationBar:(BOOL)showNavigationBar {
    _showNavigationBar = showNavigationBar;
    if (_showNavigationBar) {
        [self hideNavigationBarView];
    } else {
        [self showNavigationBarView];
    }
}

- (void)setNetworkImages:(NSArray *)networkImages {
    _networkImages = networkImages;
    if (_images == nil && networkImages.count > 0) {
        NSMutableArray<WCPhotoModel *> *images = [NSMutableArray arrayWithCapacity:networkImages.count];
        for (int i = 0; i < networkImages.count; i ++) {
            WCPhotoModel *photoModel = [[WCPhotoModel alloc] initWithImageURL:[networkImages objectAtIndex:i]];
            [images addObject:photoModel];
        }
        _images = [images copy];
    }
}

- (void)setLocalImages:(NSArray<UIImage *> *)localImages {
    _localImages = localImages;
    if (_images == nil && localImages.count > 0) {
        NSMutableArray<WCPhotoModel *> *images = [NSMutableArray arrayWithCapacity:localImages.count];
        for (int i = 0; i < _localImages.count; i ++) {
            id image = [_localImages objectAtIndex:i];
            if ([image isKindOfClass:[UIImage class]]) {
                WCPhotoModel *photoModel = [[WCPhotoModel alloc] initWithLocalImage:image];
                [images addObject:photoModel];
            }
        }
        _images = [images copy];
    }
}

- (void)setDisplayPhotoOrderInfo:(BOOL)displayPhotoOrderInfo {
    _displayPhotoOrderInfo = displayPhotoOrderInfo;
    [self setupPhotoOrderLabel];
}

- (void)setDisplayPageControl:(BOOL)displayPageControl {
    _displayPageControl = displayPageControl;
    [self setupPhotoPageControl];
}

- (void)setLongPressGestureTriggerBlock:(WCPhotoBrowserLongPressGestureTrigger)longPressGestureTriggerBlock {
    _longPressGestureTriggerBlock = longPressGestureTriggerBlock;
    if (_longPressGestureTriggerBlock) {
        _longPressGestureEnabled = YES;
    }
}

- (void)setAlertActions:(NSArray<UIAlertAction *> *)alertActions {
    _alertActions = alertActions;
    if (_alertActions.count > 0) {
        _longPressGestureEnabled = YES;
    }
}

@end
