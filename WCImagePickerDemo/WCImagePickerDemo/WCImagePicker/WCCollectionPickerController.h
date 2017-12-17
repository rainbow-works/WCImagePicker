//
//  WCCollectionPickerController.h
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/15.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCCollectionPickerController : UIViewController

@property (nonatomic, assign, readonly) BOOL isVisible;

- (void)collectionPickerTrigger;

@end
