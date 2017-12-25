//
//  UIImage+bundle.m
//  PhotoBrowserDemo
//
//  Created by 王超 on 2017/11/28.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "UIImage+Bundle.h"

@implementation UIImage (Bundle)

+ (UIImage *)wc_imageNamed:(NSString *)name bundleName:(NSString *)bundleName {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    NSBundle *photoBrowserBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imagePath = [photoBrowserBundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:imagePath];
}

@end
