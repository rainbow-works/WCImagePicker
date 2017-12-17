//
//  WCAlbum.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/15.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCAlbum.h"

@implementation WCAlbum

- (instancetype)initWithTitle:(NSString *)title fetchResult:(PHFetchResult *)fetchResult {
    if (self = [super init]) {
        _title = title;
        _fetchResult = fetchResult;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title assetCollection:(PHAssetCollection *)assetCollection {
    if (self = [super init]) {
        _title = title;
        _assetCollection = assetCollection;
    }
    return self;
}

@end
