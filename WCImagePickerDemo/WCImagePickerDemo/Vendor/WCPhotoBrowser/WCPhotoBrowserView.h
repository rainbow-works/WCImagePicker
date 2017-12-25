//
//  WCPhotoBrowserView.h
//  PhotoBrowserDemo
//
//  Created by 王超 on 2017/11/28.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WCPhotoBrowserView, WCPhotoView, WCPhotoModel;

@protocol WCPhotoBrowserDelegate <NSObject>

@required

/**
 展示图片的总数

 @param photoBrowser 图片浏览器
 @return 返回图片张数
 */
- (NSInteger)numberOfPhotosInPhotoBrowser:(WCPhotoBrowserView *)photoBrowser;

/**
 根据指定索引返回数据

 @param photoBrowser 图片浏览器
 @param index 索引
 @return 数据
 */
- (WCPhotoModel *)photoBrowser:(WCPhotoBrowserView *)photoBrowser photoDataForIndex:(NSInteger)index;

@optional

/**
 返回图片浏览器的占位图

 @param photoBrowser 图片浏览器
 @return 占位图
 */
- (UIImage *)placeholderImageForPhotoBrowser:(WCPhotoBrowserView *)photoBrowser;

/**
 当展示图片改变时回调

 @param photoBrowser 图片浏览器
 @param index 当前展示图片的索引
 */
- (void)photoBrowser:(WCPhotoBrowserView *)photoBrowser currentDisplayPhotoIndex:(NSInteger)index;

/**
 当展示图片改变时回调

 @param photoBrowser 图片浏览器
 @param currentDisplayPhoto 当前展示图片
 @param currentDisplayPhotoIndex 当前展示图片的索引
 */
- (void)photoBrowser:(WCPhotoBrowserView *)photoBrowser currentDisplayPhoto:(UIImage *)currentDisplayPhoto currentDisplayPhotoIndex:(NSInteger)currentDisplayPhotoIndex;

/**
 设置各个图片之间的间隙，默认为20

 @param photoBrowser 图片浏览器
 @return 展示photo视图之间的间隙
 */
- (CGFloat)photoSpacingInPhotoBrowser:(WCPhotoBrowserView *)photoBrowser;

/**
 设置首次所展示的图片，默认为0

 @param photoBrowser 图片浏览器
 @return 首次展示图片的索引
 */
- (NSInteger)firstDisplayPhotoIndexInPhotoBrowser:(WCPhotoBrowserView *)photoBrowser;

@end

@interface WCPhotoBrowserView : UIView

/**
 photoBrowser的delegate
 */
@property (nonatomic, weak) id<WCPhotoBrowserDelegate> delegate;

/**
 当前展示图片的下标
 */
@property (nonatomic, assign) NSInteger displayPhotoIndex;

/**
 是否允许单击dimiss
 */
@property (nonatomic, assign) BOOL singleTapGestureEnabled;

// -------------------------- start --------------------------
// 以下个属性只针对ScrollView的panGesture下拉
/**
 图片浏览器即将显示（图片下拉距离不够，图片浏览器恢复初始状态）
 */
@property (nonatomic, copy) void(^photoBrowserWillAppear)(void);

/**
 图片浏览器即将消失（只要下拉预示着图片浏览器即将消失）
 */
@property (nonatomic, copy) void(^photoBrowserWillDisappear)(void);

/**
 图片浏览器已经消失（下拉距离到了临界值，图片浏览器消失）
 */
@property (nonatomic, copy) void(^photoBrowserDidDisappear)(BOOL photoBrowserDismissedFromUpToDown);

/**
 当背景颜色的alpha值改变时调用
 */
@property (nonatomic, copy) void(^photoBrowserBackgroundColorAlphaDidChange)(CGFloat photoBrowserBackgroundColorAlpha, CGFloat photoBrowserViewAlpha);

// -------------------------- end --------------------------

- (WCPhotoView *)currentDisplayPhotoView;

@end
