//
//  UIViewController+TopViewController.m
//  PhotoBrowserDemo
//
//  Created by 王超 on 2017/12/3.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "UIViewController+TopViewController.h"

@implementation UIViewController (TopViewController)

+ (UIViewController *)topViewController {
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
        if ([topViewController isKindOfClass:[UINavigationController class]]) {
            topViewController = [(UINavigationController *)topViewController visibleViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            topViewController = [(UITabBarController *)topViewController selectedViewController];
        }
    }
    return topViewController;
}

@end
