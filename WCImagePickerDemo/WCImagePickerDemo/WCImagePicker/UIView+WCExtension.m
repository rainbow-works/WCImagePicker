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
static NSString * const kWCImagePickerCoverViewState = @"com.meetday.WCImagePickerCoverViewState";

@interface UIView ()

@property (nonatomic, strong, readwrite) WCCoverView *coverView;
@property (nonatomic, assign) WCImagePickerCoverViewState coverViewState;

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
    self.coverViewState = state;
}

- (void)wc_removeCoverView {
    [self.coverView willRemoveFromSuperView];
    [self.coverView removeFromSuperview];
}

- (WCCoverView *)coverView {
    WCCoverView *coverView = objc_getAssociatedObject(self, &kWCImagePickerCoverView);
    if (!coverView) {
        WCCoverView *coverView = [[[NSBundle mainBundle] loadNibNamed:@"WCCoverView" owner:nil options:nil] firstObject];
        coverView.backgroundColor = [UIColor whiteColor];
        objc_setAssociatedObject(self, &kWCImagePickerCoverView, coverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return coverView;
}

- (void)setCoverView:(WCCoverView *)coverView {
    objc_setAssociatedObject(self, &kWCImagePickerCoverView, coverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WCImagePickerCoverViewState)coverViewState {
    return [objc_getAssociatedObject(self, &kWCImagePickerCoverViewState) integerValue];
}

- (void)setCoverViewState:(WCImagePickerCoverViewState)coverViewState {
    [self.coverView setCurrentState:coverViewState];
    objc_setAssociatedObject(self, &kWCImagePickerCoverViewState, @(coverViewState), OBJC_ASSOCIATION_ASSIGN);
}

@end
