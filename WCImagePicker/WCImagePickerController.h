//
//  WCImagePickerControllerController.h
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/13.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
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

@optional

/**
 选择完图片或视频后回调并回传选中的资源

 @param imagePicker 资源选择器
 @param assets 选中的资源
 */
- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didFinishPickingAssets:(NSArray<PHAsset *> *)assets;

/**
 点击取消后调用

 @param imagePicker 资源选择器
 */
- (void)wc_imagePickerControllerDidCancel:(WCImagePickerController *)imagePicker;

/**
 判断是否选中该资源

 @param imagePicker 资源选择器
 @param asset 是否选中的资源
 @return 是否选中，YES:选中该资源，NO:不选中该资源
 */
- (BOOL)wc_imagePickerController:(WCImagePickerController *)imagePicker shouldSelectAsset:(PHAsset *)asset;

@end

typedef NS_ENUM(NSUInteger, WCImagePickerImageType) {
    WCImagePickerImageTypeAny = 0,  // 任意资源
    WCImagePickerImageTypeImage,    // 图片资源
    WCImagePickerImageTypeVideo     // 视频资源
};

@interface WCImagePickerController : UIViewController

/**
 ImagePicker 代理
 */
@property (nonatomic, weak) id<WCImagePickerControllerDelegate> delegate;

/**
 是否允许多选，默认YES。
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

/**
 选择资源的类型，默认：WCImagePickerImageTypeImage。
 */
@property (nonatomic, assign) WCImagePickerImageType mediaType;

/**
 选择资源的最大数量，默认：9。
 */
@property (nonatomic, assign) NSUInteger maximumNumberOfSelectionAsset;

/**
 选择资源的最小数量，默认：1。
 */
@property (nonatomic, assign) NSUInteger minimumNumberOfSelectionAsset;

/**
 资源之间的最小间隙，默认：2。
 */
@property (nonatomic, assign) CGFloat minimumItemSpacing;

/**
 竖屏显示多少列，默认：4。
 */
@property (nonatomic, assign) NSUInteger numberOfColumnsInPortrait;

/**
 横屏显示多少列，默认：7。
 */
@property (nonatomic, assign) NSUInteger numberOfColumnsInLandscape;

/**
 选中数量达到最大数量时未选中资源是否显示遮罩，默认：YES。
 */
@property (nonatomic, assign) BOOL showAssetMaskWhenMaximumLimitReached;

/**
 选中数量达到最大数量时是否显示警示弹窗，默认：YES。
 */
@property (nonatomic, assign) BOOL showWarningAlertWhenMaximumLimitReached;

/**
 是否显示没有资源的相册，默认：NO。
 */
@property (nonatomic, assign) BOOL showPhotoAlbumWithoutAssetResources;

/**
 更换相册时是否移除已选中的资源，默认：YES。
 */
@property (nonatomic, assign) BOOL shouldRemoveAllSelectedAssetWhenAlbumChanged;

/**
 手指划过资源时选中，默认：NO。
 */
@property (nonatomic, assign) BOOL fingerMovingToAssetForSelectionEnable;

/**
 设置ImagePicker的外观

 @param imagePickerAppearance imagePickerAppearance
 */
+ (void)setupImagePickerAppearance:(WCImagePickerAppearance *)imagePickerAppearance;

@end

@interface WCImagePickerAppearance : NSObject

/**
 导航栏的背景颜色
 */
@property (nonatomic, strong) UIColor *navigationBarBackgroundColor;

/**
 取消按钮的文字内容
 */
@property (nonatomic, copy) NSString *cancelButtonText;

/**
 取消按钮的文字颜色
 */
@property (nonatomic, strong) UIColor *cancelButtonTextColor;

/**
 取消按钮的背景颜色
 */
@property (nonatomic, strong) UIColor *cancelButtonBackgroundColor;

/**
 完成按钮的字体颜色
 */
@property (nonatomic, strong) UIColor *finishedButtonTextColor;

/**
 完成按钮enable时背景颜色
 */
@property (nonatomic, strong) UIColor *finishedButtonEnableBackgroundColor;

/**
 完成按钮Disable时的背景颜色
 */
@property (nonatomic, strong) UIColor *finishedButtonDisableBackgroundColor;

/**
 选中相册名称的字体颜色
 */
@property (nonatomic, strong) UIColor *albumButtonTextColor;

/**
 选中相册名称的字体
 */
@property (nonatomic, strong) UIFont *albumButtonTextFont;

/**
 WCImagePickerAppearance的单例方法

 @return WCImagePickerAppearance的单例
 */
+ (instancetype)sharedAppearance;

@end
