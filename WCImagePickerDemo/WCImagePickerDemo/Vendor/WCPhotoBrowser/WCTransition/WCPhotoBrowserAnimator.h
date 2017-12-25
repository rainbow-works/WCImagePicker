//
//  WCPhotoBrowserAnimator.h
//  PhotoBrowserDemo
//
//  Created by 王超 on 2017/12/11.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WCPhotoBrowserAnimatorDelegate <NSObject>

@required

/**
 根据下标返回将要展示的图片

 @param willDisplayImageIndex 将要展示图片的下标
 @return 返回将要展示的图片
 */
- (UIImage *)willDisplayImageInPhotoBrowserAtIndex:(NSInteger)willDisplayImageIndex;

/**
 根据图片下标返回将要展示图片相对屏幕的开始位置

 @param willDisplayImageIndex 将要展示图片的下标
 @return 将要展示图片的开始位置
 */
- (CGRect)willDisplayImageOfStartRectAtIndex:(NSInteger)willDisplayImageIndex;

/**
 根据图片下标返回将要展示图片相对屏幕的结束位置

 @param willDisplayImageIndex 将要展示图片的下标
 @return 将要展示图片动画结束后的位置
 */
- (CGRect)willDisplayImageOfEndRectAtIndex:(NSInteger)willDisplayImageIndex;

@end

@protocol WCPhotoBrowserAnimatorDismissDelegate <NSObject>

@required
- (UIImage *)currentDisplayImageInPhotoBrowser;
- (NSInteger)currentDisplayImageIndexInPhotoBrowser;
- (BOOL)photoBrowserDismissedFromUpToDown;

@end

@interface WCPhotoBrowserAnimator : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) id<WCPhotoBrowserAnimatorDelegate> animatorDelegate;
@property (nonatomic, weak) id<WCPhotoBrowserAnimatorDismissDelegate> animatorDismissDelegate;

@end
