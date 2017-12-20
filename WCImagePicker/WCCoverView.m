//
//  WCCoverView.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/16.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCCoverView.h"
#import "WCImagePickerController.h"

@interface WCCoverView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *coverLoadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *coverActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *coverLoadingTextLabel;

@property (weak, nonatomic) IBOutlet UIView *coverAuthrizationView;
@property (weak, nonatomic) IBOutlet UILabel *coverAuthrizationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *coverAuthrizationDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *coverOpenAuthrization;

@end

@implementation WCCoverView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.coverViewState = WCImagePickerCoverViewLoading;
    self.coverLoadingView.hidden = YES;
    self.coverActivityIndicator.hidesWhenStopped = YES;
    self.coverAuthrizationView.hidden = YES;
    [self.coverOpenAuthrization setTitleColor:WCUIColorFromHexValue(0x1EB400) forState:UIControlStateNormal];
    self.coverOpenAuthrization.layer.borderWidth = 1.0f;
    self.coverOpenAuthrization.layer.borderColor = WCUIColorFromHexValue(0x1EB400).CGColor;
}

+ (WCCoverView *)coverView {
    return (WCCoverView *)[[[NSBundle bundleForClass:[self class]] loadNibNamed:@"WCCoverView" owner:nil options:nil] firstObject];
}

- (IBAction)openAuthrizationButtonDidClicked:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)setCoverViewState:(WCImagePickerCoverViewState)coverViewState {
    _coverViewState = coverViewState;
    if (coverViewState == WCImagePickerCoverViewLoading) {
        [self.coverAuthrizationView setHidden:YES];
        [self.coverActivityIndicator startAnimating];
        [UIView animateWithDuration:0.25 animations:^{
            [self.coverLoadingView setHidden:NO];
        }];
    } else if (coverViewState == WCImagePickerCoverViewDenied) {
        [self.coverLoadingView setHidden:YES];
        [UIView animateWithDuration:0.25 animations:^{
            [self.coverAuthrizationView setHidden:NO];
        }];
    }
}

@end
