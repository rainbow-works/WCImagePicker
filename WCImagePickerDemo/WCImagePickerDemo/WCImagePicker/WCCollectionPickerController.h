//
//  WCCollectionPickerController.h
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/15.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@class WCImagePickerController;

@interface WCCollectionPickerController : UIViewController

@property (nonatomic, weak) WCImagePickerController *imagePickerController;

- (void)dismissCollectionPicker;
- (void)showCollectionPicker:(void(^)(BOOL willShowCollectionPicker))showCollectionPicker
     dismissCollectionPicker:(void(^)(BOOL willDismissCollectionPicker))dismissCollectionPicker
                  completion:(void(^)(NSString *assetCollectionTitle, PHFetchResult *fetchResult))completion;

@end

@interface WCAlbum : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) PHFetchResult *fetchResult;

- (instancetype)initWithTitle:(NSString *)title
              assetCollection:(PHAssetCollection *)assetCollection
                  fetchResult:(PHFetchResult *)fetchResult;

@end
