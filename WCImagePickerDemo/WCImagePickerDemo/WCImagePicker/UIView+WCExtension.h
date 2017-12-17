//
//  UIView+WCExtension.h
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/16.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCCoverView.h"

@interface UIView (WCExtension)

@property (nonatomic, strong, readonly) WCCoverView *coverView;

- (void)wc_showCoverViewForState:(WCImagePickerCoverViewState)state;
- (void)wc_removeCoverView;

@end
