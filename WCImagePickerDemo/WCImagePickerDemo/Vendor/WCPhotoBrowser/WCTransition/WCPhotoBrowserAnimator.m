//
//  WCPhotoBrowserAnimator.m
//  PhotoBrowserDemo
//
//  Created by 王超 on 2017/12/11.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCPhotoBrowserAnimator.h"

@implementation WCPhotoBrowserAnimator

#pragma mark - View Controller Transition Delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - View Controller Animated Transition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = transitionContext.containerView;
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (fromVC == nil || toVC == nil) return;
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    if (toVC.isBeingPresented) {
        toView.alpha = 0.0;
        toView.frame = containerView.bounds;
        [containerView addSubview:toView];
        
        NSInteger currentDisplayImageIndex = [self.animatorDismissDelegate currentDisplayImageIndexInPhotoBrowser];
        UIImage *image = [self.animatorDelegate willDisplayImageInPhotoBrowserAtIndex:currentDisplayImageIndex];
        CGRect startRect = [self.animatorDelegate willDisplayImageOfStartRectAtIndex:currentDisplayImageIndex];
        CGRect endRect = [self.animatorDelegate willDisplayImageOfEndRectAtIndex:currentDisplayImageIndex];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = startRect;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [containerView addSubview:imageView];
        
        containerView.backgroundColor = [UIColor blackColor];
        containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [UIView animateWithDuration:duration animations:^{
            imageView.frame = endRect;
            containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0];
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            toView.alpha = 1.0;
            containerView.backgroundColor = [UIColor clearColor];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else if (fromVC.isBeingDismissed) {
        [fromView removeFromSuperview];
        if (![self.animatorDismissDelegate photoBrowserDismissedFromUpToDown]) {
            NSInteger currentDisplayImageIndex = [self.animatorDismissDelegate currentDisplayImageIndexInPhotoBrowser];
            UIImage *image = [self.animatorDismissDelegate currentDisplayImageInPhotoBrowser];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = [self.animatorDelegate willDisplayImageOfEndRectAtIndex:currentDisplayImageIndex];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [containerView addSubview:imageView];
            
            containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0];
            [UIView animateWithDuration:duration animations:^{
                imageView.frame = [self.animatorDelegate willDisplayImageOfStartRectAtIndex:currentDisplayImageIndex];
                containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
                containerView.backgroundColor = [UIColor clearColor];
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        } else {
            [UIView animateWithDuration:duration animations:^{
                fromView.alpha = 0;
            } completion:^(BOOL finished) {
                [fromView removeFromSuperview];
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        }
    }
}

@end
