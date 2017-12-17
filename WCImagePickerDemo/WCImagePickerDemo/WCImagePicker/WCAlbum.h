//
//  WCAlbum.h
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/15.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface WCAlbum : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

- (instancetype)initWithTitle:(NSString *)title fetchResult:(PHFetchResult *)fetchResult;
- (instancetype)initWithTitle:(NSString *)title assetCollection:(PHAssetCollection *)assetCollection;


@end
