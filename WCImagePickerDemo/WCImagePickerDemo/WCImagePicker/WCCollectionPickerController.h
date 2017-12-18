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

//@property (nonatomic, assign, readonly) BOOL isVisible;
@property (nonatomic, weak) WCImagePickerController *imagePickerController;

- (void)collectionPickerTriggerWithCompletionBlock:(void(^)(BOOL isCollectionPickerVisible))completion;

@end

@interface WCAlbum : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) PHFetchResult *fetchResult;

- (instancetype)initWithTitle:(NSString *)title
              assetCollection:(PHAssetCollection *)assetCollection
                  fetchResult:(PHFetchResult *)fetchResult;

@end
