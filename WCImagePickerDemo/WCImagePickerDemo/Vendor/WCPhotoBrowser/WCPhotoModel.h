//
//  WCPhotoModel.h
//  PhotoBrowserDemo
//
//  Created by 王超 on 2017/11/29.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WCPhotoModel : NSObject

/**
 图片URL
 */
@property (nonatomic, copy) NSString *imageURL;

/**
 本地图片
 */
@property (nonatomic, strong) UIImage *localImage;

/**
 图片描述（暂时没有）
 */
//@property (nonatomic, copy) NSString *imageDescription;

- (instancetype)initWithImageURL:(NSString *)imageURL;
- (instancetype)initWithLocalImage:(UIImage *)localImage;
//- (instancetype)initWithImageURL:(NSString *)imageURL imageDescription:(NSString *)imageDescription;
//- (instancetype)initWithLocalImage:(UIImage *)localImage imageDescription:(NSString *)imageDescription;

@end
