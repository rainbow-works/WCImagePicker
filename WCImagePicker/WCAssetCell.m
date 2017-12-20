//
//  WCAssetCell.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/14.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCAssetCell.h"
#import "WCImagePickerController.h"

@interface WCAssetCell ()

@property (weak, nonatomic) IBOutlet UIButton *assetCheckButton;
@property (weak, nonatomic) IBOutlet UIView *assetCoverView;

@end

@implementation WCAssetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectedOrderNumber = 0;
    self.shouldAnimationWhenSelectedOrderNumberUpdate = YES;
    [self assetCheckButtonNormalAppearance];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.selected = NO;
    self.selectedOrderNumber = 0;
    self.shouldAnimationWhenSelectedOrderNumberUpdate = YES;
    self.representedAssetIdentifier = nil;
    self.assetImageView.image = nil;
    self.assetTimeLabel.hidden = YES;
    self.assetCoverView.hidden = YES;
    [self assetCheckButtonNormalAppearance];
}

- (void)assetCheckButtonNormalAppearance {
    self.assetCheckButton.backgroundColor = [UIColor clearColor];
    [self.assetCheckButton setBackgroundImage:nil forState:UIControlStateNormal];
    UIImage *assetCheckImage = [UIImage imageNamed:@"imagepicker_asset_check"
                                            inBundle:[NSBundle wc_defaultBundle]
                       compatibleWithTraitCollection:nil];
    [self.assetCheckButton setImage:assetCheckImage forState:UIControlStateNormal];
    [self.assetCheckButton setTitle:nil forState:UIControlStateNormal];
}

- (void)assetCheckButtonSelectedAppearance {
    [self.assetCheckButton setImage:nil forState:UIControlStateNormal];
    UIImage *assetCheckButtonBackgroundImage = [UIImage imageNamed:@"imagepicker_asset_button_background"
                                          inBundle:[NSBundle wc_defaultBundle]
                     compatibleWithTraitCollection:nil];
    [self.assetCheckButton setBackgroundImage:assetCheckButtonBackgroundImage forState:UIControlStateNormal];
    [self.assetCheckButton setTitle:[NSString stringWithFormat:@"%td", self.selectedOrderNumber] forState:UIControlStateNormal];
}

- (void)updateAssetCellAppearanceIfNeeded {
    if (self.selected) {
        [self assetCheckButtonSelectedAppearance];
        if (self.shouldAnimationWhenSelectedOrderNumberUpdate) {
            self.assetCheckButton.transform = CGAffineTransformScale(self.assetCheckButton.transform, 0.3, 0.3);
            [UIView animateWithDuration:1.25 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:8.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.assetCheckButton.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    } else {
        [self assetCheckButtonNormalAppearance];
    }
}

- (void)shouldShowAssetCoverView:(BOOL)shouldShowAssetCoverView {
    [UIView animateWithDuration:0.25 animations:^{
        self.assetCoverView.hidden = !shouldShowAssetCoverView;
    }];
}

@end
