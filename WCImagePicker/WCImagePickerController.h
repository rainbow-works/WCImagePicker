//
//  WCImagePickerControllerController.h
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/13.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@class WCImagePickerController, WCImagePickerAppearance;

#define WCUIColorFromHexValue(hexValue) \
[UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((hexValue & 0x00FF00) >> 8))/255.0 \
                 blue:((float)((hexValue & 0x0000FF) >> 0))/255.0 \
                alpha:1.0]

@interface UICollectionView (WCExtension)

- (NSArray<NSIndexPath *> *)wc_indexPathsForElementsInRect:(CGRect)rect;

@end

@interface NSIndexSet (WCExtension)

- (NSArray<NSIndexPath *> *)wc_indexPathsFromIndexes;

@end

@interface NSBundle (WCExtension)

+ (NSBundle *)wc_defaultBundle;
+ (NSBundle *)wc_bundleForClass:(Class)aclass;
+ (NSString *)wc_bundlePathForResource:(NSString *)name;

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

@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) WCImagePickerImageType mediaType;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelectionAsset;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelectionAsset;

@property (nonatomic, assign) CGFloat minimumItemSpacing;
@property (nonatomic, assign) NSUInteger numberOfColumnsInPortrait;
@property (nonatomic, assign) NSUInteger numberOfColumnsInLandscape;

@property (nonatomic, assign) BOOL showAssetMaskWhenMaximumLimitReached;
@property (nonatomic, assign) BOOL showWarningAlertWhenMaximumLimitReached;
@property (nonatomic, assign) BOOL showPhotoAlbumWithoutAssetResources;
@property (nonatomic, assign) BOOL fingerMovingToAssetForSelectionEnable;
@property (nonatomic, assign) BOOL shouldRemoveAllSelectedAssetWhenAlbumChanged;

+ (void)setupImagePickerAppearance:(WCImagePickerAppearance *)imagePickerAppearance;

@end

@interface WCImagePickerAppearance : NSObject

@property (nonatomic, strong) UIColor *navigationBarBackgroundColor;

@property (nonatomic, copy) NSString *cancelButtonText;
@property (nonatomic, strong) UIColor *cancelButtonTextColor;
@property (nonatomic, strong) UIColor *cancelButtonBackgroundColor;

@property (nonatomic, strong) UIColor *finishedButtonTextColor;
@property (nonatomic, strong) UIColor *finishedButtonEnableBackgroundColor;
@property (nonatomic, strong) UIColor *finishedButtonDisableBackgroundColor;

@property (nonatomic, strong) UIColor *albumButtonTextColor;
@property (nonatomic, strong) UIFont *albumButtonTextFont;

+ (instancetype)sharedAppearance;

@end
