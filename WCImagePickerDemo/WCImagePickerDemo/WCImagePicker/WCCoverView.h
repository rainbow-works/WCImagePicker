//
//  WCCoverView.h
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/16.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WCImagePickerCoverViewState) {
    WCImagePickerCoverViewLoading = 0,
    WCImagePickerCoverViewDenied,
    WCImagePickerCoverViewUnknown
};

@interface WCCoverView : UIView

@property (nonatomic, assign) WCImagePickerCoverViewState currentState;

- (void)willRemoveFromSuperView;

@end
