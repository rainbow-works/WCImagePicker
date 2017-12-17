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

@interface UIImage (WCExtension)

+ (UIImage *)wc_imageNamed:( NSString *)name bundle:(NSString *)bundleName;

@end

@interface UICollectionView (WCExtension)

- (NSArray<NSIndexPath *> *)wc_indexPathsForElementsInRect:(CGRect)rect;

@end

@protocol WCImagePickerControllerDelegate <NSObject>

- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didFinishPickingAssets:(NSArray<PHAsset *> *)assets;
- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didFinishPickingImages:(NSArray<UIImage *> *)images;
- (void)wc_imagePickerControllerDidCancel:(WCImagePickerController *)imagePicker;

- (BOOL)wc_imagePickerController:(WCImagePickerController *)imagePicker shouldSelectAsset:(PHAsset *)asset;

@end

typedef NS_ENUM(NSUInteger, WCImagePickerImageType) {
    WCImagePickerImageTypeAny = 0,
    WCImagePickerImageTypeImage,
    WCImagePickerImageTypeVideo
};

@interface WCImagePickerController : UIViewController

@property (nonatomic, weak) id<WCImagePickerControllerDelegate> delegate;

@property (nonatomic, assign) WCImagePickerImageType mediaType;
@property (nonatomic, strong) UIColor *navigationBarBackgroundColor;

@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionPhoto;
@property (nonatomic, assign) NSInteger minimumNumberOfSelectionPhoto;
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionVideo;
@property (nonatomic, assign) NSInteger minimumNumberOfSelectionVideo;

@property (nonatomic, assign) CGFloat minimumItemSpacing;
@property (nonatomic, assign) NSInteger numberOfColumnsInPortrait;
@property (nonatomic, assign) NSInteger numberOfColumnsInLandscape;

@end
