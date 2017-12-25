//
//  WCMaskAnimatedTransition.m
//  PhotoBrowserDemo
//
//  Created by 王超 on 2017/12/2.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCMaskAnimatedTransition.h"

@implementation WCMaskAnimatedTransition

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContet {
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
        toView.frame = [transitionContext finalFrameForViewController:toVC];
        [containerView addSubview:toView];
        toView.alpha = 0;
        [UIView animateWithDuration:duration animations:^{
            toView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
    if (fromVC.isBeingDismissed) {
        [UIView animateWithDuration:duration animations:^{
            fromView.alpha = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}


@end
