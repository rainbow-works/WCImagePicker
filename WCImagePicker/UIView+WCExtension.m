//
//  UIView+WCExtension.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/16.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "UIView+WCExtension.h"
#import <objc/runtime.h>

static NSString * const kWCImagePickerCoverView = @"com.meetday.WCImagePickerCoverView";

@interface UIView ()

@property (nonatomic, strong, readwrite) WCCoverView *coverView;

@end

@implementation UIView (WCExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self wc_swizzleInstanceMethod:@selector(layoutSubviews) swizzleSelector:@selector(wc_layoutSubViews)];
    });
}

- (void)wc_layoutSubViews {
    [self wc_layoutSubViews];
    if (objc_getAssociatedObject(self, &kWCImagePickerCoverView)) {
        self.coverView.frame = self.bounds;
    }
}

+ (void)wc_swizzleInstanceMethod:(SEL)originalSelector swizzleSelector:(SEL)swizzleSelector {
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzleMethod = class_getInstanceMethod(class, swizzleSelector);
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzleMethod),
                                        method_getTypeEncoding(swizzleMethod));
    if (didAddMethod) {
        class_replaceMethod(class, swizzleSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
}

- (void)wc_showCoverViewForState:(WCImagePickerCoverViewState)state {
    [self.coverView willMoveToSuperview:self];
    [self addSubview:self.coverView];
    [self.coverView didMoveToSuperview];
    [self.coverView setCoverViewState:state];
}

- (void)wc_removeCoverView {
    [self.coverView removeFromSuperview];
    self.coverView = nil;
}

- (WCCoverView *)coverView {
    WCCoverView *coverView = objc_getAssociatedObject(self, &kWCImagePickerCoverView);
    if (!coverView) {
        WCCoverView *coverView = [WCCoverView coverView];
        coverView.backgroundColor = [UIColor whiteColor];
        objc_setAssociatedObject(self, &kWCImagePickerCoverView, coverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return coverView;
}

- (void)setCoverView:(WCCoverView *)coverView {
    objc_setAssociatedObject(self, &kWCImagePickerCoverView, coverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
