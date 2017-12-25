//
//  WCDisplayImageViewController.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/25.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCDisplayImageViewController.h"
#import "WCTextView.h"
#import "WCPhotoBrowser.h"

#define SCREEN_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface WCDisplayImageViewController () <WCPhotoBrowserAnimatorDelegate>

@property (nonatomic, strong) NSArray<UIImage *> *images;
@property (weak, nonatomic) IBOutlet UIView *imagesView;

@end

@implementation WCDisplayImageViewController

- (instancetype)initWithImages:(NSArray<UIImage *> *)images {
    self = [super initWithNibName:[NSString stringWithUTF8String:object_getClassName(self)] bundle:nil];
    if (self) {
        _images = images;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"图片选择";
    [self setupImagesView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupImagesView {
    CGFloat imagePadding = 8.0;
    NSInteger numberOfColumns = 4;
    CGFloat imageWidth = (self.imagesView.bounds.size.width - imagePadding * (numberOfColumns - 1)) / numberOfColumns;
    for (NSInteger index = 0; index < self.images.count; index ++) {
        NSInteger colum = index % numberOfColumns;
        NSInteger row = index / numberOfColumns;
        CGFloat imageX = colum * (imageWidth + imagePadding);
        CGFloat imageY = row * (imageWidth + imagePadding);
        CGRect frame = CGRectMake(imageX, imageY, imageWidth, imageWidth);
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[self.images objectAtIndex:index]];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = frame;
        imageView.tag = index;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [imageView addGestureRecognizer:tapGesture];
        [self.imagesView addSubview:imageView];
    }
}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    WCPhotoBrowserViewController *photoBrowser = [[WCPhotoBrowserViewController alloc] initWithLocalImages:self.images];
    photoBrowser.displayPhotoOrderInfo = YES;
    photoBrowser.firstDisplayPhotoIndex = gestureRecognizer.view.tag;
    WCPhotoBrowserAnimator *animator = [[WCPhotoBrowserAnimator alloc] init];
    animator.animatorDelegate = self;
    photoBrowser.transitioningDelegate = animator;
    [photoBrowser show];
}

#pragma mark - WCPhotoBrowserAnimatorDelegate

/**
 根据下标返回将要展示的图片
 
 @param willDisplayImageIndex 将要展示图片的下标
 @return 返回将要展示的图片
 */
- (UIImage *)willDisplayImageInPhotoBrowserAtIndex:(NSInteger)willDisplayImageIndex {
    return self.images[willDisplayImageIndex];
}

/**
 根据图片下标返回将要展示图片相对屏幕的开始位置
 
 @param willDisplayImageIndex 将要展示图片的下标
 @return 将要展示图片的开始位置
 */
- (CGRect)willDisplayImageOfStartRectAtIndex:(NSInteger)willDisplayImageIndex {
    UIImageView *currentImageView = nil;
    for (UIImageView *subView in self.imagesView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]] && (subView.tag == willDisplayImageIndex)) {
            currentImageView = (UIImageView *)subView; break;
        }
    }
    return [currentImageView convertRect:currentImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
}

/**
 根据图片下标返回将要展示图片相对屏幕的结束位置
 
 @param willDisplayImageIndex 将要展示图片的下标
 @return 将要展示图片动画结束后的位置
 */
- (CGRect)willDisplayImageOfEndRectAtIndex:(NSInteger)willDisplayImageIndex {
    UIImage *image = [self.images objectAtIndex:willDisplayImageIndex];
    CGFloat height = (SCREEN_WIDTH / image.size.width) * image.size.height;
    CGFloat y = 0;
    if (height < SCREEN_HEIGHT) {
        y = (SCREEN_HEIGHT - height) / 2.0;
    }
    return CGRectMake(0, y, SCREEN_WIDTH, height);
}

@end
