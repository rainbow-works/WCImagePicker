//
//  WCTextView.m
//  TextViewDemo
//
//  Created by 王超 on 2017/11/14.
//  Copyright © 2017年 Wang Chao. All rights reserved.
//

#import "WCTextView.h"

IB_DESIGNABLE
@interface WCTextView ()

/**
 展示占位符的Label
 */
@property(nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation WCTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}


- (void)commonInit {
    [self addSubview:self.placeholderLabel];
    [self updatePlaceholderLabelConstraints];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewTextDidChange)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.placeholderLabel.preferredMaxLayoutWidth = self.bounds.size.width - (self.textContainerInset.left + self.textContainerInset.right) - self.textContainer.lineFragmentPadding * 2.0f;
    [self updatePlaceholderLabelConstraints];
}

/**
 当textView的内容改变时，动态设置placeholderLabel的显示与隐藏
 */
- (void)textViewTextDidChange {
    self.placeholderLabel.hidden = self.text.length > 0;
}

- (void)updatePlaceholderLabelConstraints {
    [self removeConstraints:self.constraints];
    NSDictionary *views = @{@"placeholderLabel": self.placeholderLabel};
    CGFloat placeholderLabelWidth = self.bounds.size.width - (self.textContainer.lineFragmentPadding * 2.0f + self.textContainerInset.left + self.textContainerInset.right);
    NSDictionary *horizontalMetrics = @{@"padding": @(self.textContainer.lineFragmentPadding + self.textContainerInset.left), @"placeholderLabelWidth": @(placeholderLabelWidth)};
    NSDictionary *verticalMetrics = @{@"insetTop": @(self.textContainerInset.top), @"insetBottom": @(self.textContainerInset.bottom)};
    // 设置placeholderLabel水平方向上的约束
    NSString *placeholderLabelHorizontalVFL = [NSString stringWithFormat:@"H:|-padding-[placeholderLabel(placeholderLabelWidth)]"];
    NSArray *placeholderLabelHorizontalContraints = [NSLayoutConstraint constraintsWithVisualFormat:placeholderLabelHorizontalVFL options:0 metrics:horizontalMetrics views:views];
    [self addConstraints:placeholderLabelHorizontalContraints];
    // 设置placeholderLable垂直方向上的约束
    NSString *placeholderVerticalVFL = [NSString stringWithFormat:@"V:|-insetTop-[placeholderLabel]-(>=insetBottom)-|"];
    NSArray *placeholderLabelVerticalContrainsts = [NSLayoutConstraint constraintsWithVisualFormat:placeholderVerticalVFL options:0 metrics:verticalMetrics views:views];
    [self addConstraints:placeholderLabelVerticalContrainsts];
}

#pragma mark - getter and setter

/**
 设置textView的textContainerInset时，更新placeholderLbale的约束
 */
- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    [self updatePlaceholderLabelConstraints];
}

/**
 设置textView的富文本时，主动判断placeholderLabel的显示隐藏
 当给textView设置富文本时，不会发送UITextViewTextDidChangeNotification需重新判断placeholderLabel的状态
 */
- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self textViewTextDidChange];
}

/**
 设置textView的占位字符
 */
- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
}

- (void)setPlaceholderAttributedText:(NSAttributedString *)placeholderAttributedText {
    _placeholderAttributedText = placeholderAttributedText;
    self.placeholderLabel.attributedText = placeholderAttributedText;
}

/**
 设置textView的占位字符的颜色
 */
- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = placeholderColor;
}

/**
 设置textView占位字符的字体
 */
- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    _placeholderFont = placeholderFont;
    self.placeholderLabel.font = placeholderFont;
}

/**
 设置textView占位字符最多显示多好行
 */
- (void)setPlaceholderNumberOfLines:(NSUInteger)placeholderNumberOfLines {
    _placeholderNumberOfLines = placeholderNumberOfLines;
    self.placeholderLabel.numberOfLines = placeholderNumberOfLines;
}

/**
 设置textView占位字符的对齐方式
 */
- (void)setPlaceholderTextAlignment:(NSTextAlignment)placeholderTextAlignment {
    _placeholderTextAlignment = placeholderTextAlignment;
    self.placeholderLabel.textAlignment = placeholderTextAlignment;
}

/**
 设置textView占位字符的换行模式
 */
- (void)setPlaceholderLineBreakMode:(NSLineBreakMode)placeholderLineBreakMode {
    _placeholderLineBreakMode = placeholderLineBreakMode;
    self.placeholderLabel.lineBreakMode = placeholderLineBreakMode;
}

- (UILabel *)placeholderLabel {
    if (_placeholderLabel == nil) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.backgroundColor = [UIColor whiteColor];
        _placeholderLabel.font = [UIFont systemFontOfSize:14.0f];
        _placeholderLabel.numberOfLines = 0;
        [_placeholderLabel setTextColor:[UIColor colorWithRed:0.78 green:0.78 blue:0.80 alpha:1.0]];
        _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _placeholderLabel;
}

@end
