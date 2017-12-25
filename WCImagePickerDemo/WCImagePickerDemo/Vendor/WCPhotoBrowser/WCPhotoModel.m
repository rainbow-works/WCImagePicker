//
//  WCPhotoModel.m
//  PhotoBrowserDemo
//
//  Created by 王超 on 2017/11/29.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCPhotoModel.h"

@implementation WCPhotoModel

- (instancetype)initWithImageURL:(NSString *)imageURL {
    if (self = [super init]) {
        self.imageURL = imageURL;
    }
    return self;
}

- (instancetype)initWithLocalImage:(UIImage *)localImage {
    if (self = [super init]) {
        self.localImage = localImage;
    }
    return self;
}

//- (instancetype)initWithImageURL:(NSString *)imageURL imageDescription:(NSString *)imageDescription {
//    if (self = [super init]) {
//        self.imageURL = imageURL;
//        self.imageDescription = imageDescription;
//    }
//    return self;
//}
//
//- (instancetype)initWithLocalImage:(UIImage *)localImage imageDescription:(NSString *)imageDescription {
//    if (self = [super init]) {
//        self.localImage = localImage;
//        self.imageDescription = imageDescription;
//    }
//    return self;
//}

@end
