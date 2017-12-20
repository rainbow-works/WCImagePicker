//
//  WCCustomButton.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/14.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCCustomButton.h"

@implementation WCCustomButton

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat adjustOffset = 6.0;
    CGRect imageViewFrame = self.imageView.frame;
    CGRect titleLabelFrame = self.titleLabel.frame;
    titleLabelFrame.origin.x = imageViewFrame.origin.x;
    imageViewFrame.origin.x = titleLabelFrame.origin.x + titleLabelFrame.size.width + adjustOffset;
    self.imageView.frame = imageViewFrame;
    self.titleLabel.frame = titleLabelFrame;
}

- (void)setSelected:(BOOL)selected {
    if (self.selected == selected) return;
    [super setSelected:selected];
    [UIView animateWithDuration:0.35 animations:^{
        self.imageView.transform = selected ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
    }];
}

- (void)wc_setImage:(UIImage *)image {
    self.adjustsImageWhenHighlighted = NO;
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateHighlighted];
    [self setImage:image forState:UIControlStateSelected];
}

@end
