//
//  WCImagePickerControllerController.h
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/13.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@class WCImagePickerController;

@interface UICollectionView (WCExtension)

- (NSArray<NSIndexPath *> *)wc_indexPathsForElementsInRect:(CGRect)rect;

@end

@protocol WCImagePickerControllerDelegate <NSObject>

- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didFinishPickingAssets:(NSArray<PHAsset *> *)assets;
- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didFinishPickingImages:(NSArray<UIImage *> *)images;
- (void)wc_imagePickerControllerDidCancel:(WCImagePickerController *)imagePicker;

@end

typedef NS_ENUM(NSUInteger, WCImagePickerImageType) {
    WCImagePickerImageTypeAny = 0,
    WCImagePickerImageTypeImage,
    WCImagePickerImageTypeVideo
};


@interface WCImagePickerController : UIViewController

@property (nonatomic, strong) PHAssetCollection *assetCollection;

@property (nonatomic, assign) WCImagePickerImageType mediaType;
@property (nonatomic, assign) BOOL allowMultipleSelections;
@property (nonatomic, assign) NSInteger maximumNumberOfSelections;
@property (nonatomic, assign) NSInteger minimumNumberOfSelections;
@property (nonatomic, assign) CGFloat minimumItemSpacing;
@property (nonatomic, assign) NSInteger numberOfColumnsInPortrait;
@property (nonatomic, assign) NSInteger numberOfColumnsInLandscape;

@property (nonatomic, strong) UIColor *navigationBarBackgroundColor;

@end
