//
//  WCTextView.h
//  TextViewDemo
//
//  Created by 王超 on 2017/11/14.
//  Copyright © 2017年 Wang Chao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCTextView : UITextView

/**
 占位字符
 */
@property(nonatomic, copy) IBInspectable NSString *placeholder;

/**
 占位字符的字体颜色
 */
@property (nonatomic, strong) IBInspectable UIColor *placeholderColor;

/**
 占位字符(富文本)
 */
@property (nonatomic, strong) NSAttributedString *placeholderAttributedText NS_AVAILABLE_IOS(6_0);

/**
 占位字符的字体大小
 */
@property(nonatomic, assign) UIFont *placeholderFont;

/**
 占位字符最多能显示多少行
 */
@property(nonatomic, assign) NSUInteger placeholderNumberOfLines;

/**
 占位字符的对齐方式
 */
@property(nonatomic, assign) NSTextAlignment placeholderTextAlignment;

/**
 占位字符换行模式(lineBreakMode)
 */
@property(nonatomic, assign) NSLineBreakMode placeholderLineBreakMode;

@end
