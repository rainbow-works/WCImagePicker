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
    [self assetCheckButtonNormalAppearance];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.representedAssetIdentifier = nil;
    self.assetImageView.image = nil;
    [self assetCheckButtonNormalAppearance];
}

- (void)assetCheckButtonNormalAppearance {
    self.selectedOrderNumber = 0;
    self.shouldAnimationWhenSelectedOrderNumberUpdate = YES;
    self.assetCheckButton.backgroundColor = [UIColor clearColor];
    [self.assetCheckButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.assetCheckButton setImage:[UIImage imageNamed:@"imagepicker_asset_check"] forState:UIControlStateNormal];
    [self.assetCheckButton setTitle:nil forState:UIControlStateNormal];
}

- (void)assetCheckButtonSelectedAppearance {
    [self.assetCheckButton setImage:nil forState:UIControlStateNormal];
    [self.assetCheckButton setBackgroundImage:[UIImage imageNamed:@"imagepicker_asset_button_background"] forState:UIControlStateNormal];
    [self.assetCheckButton setTitle:[NSString stringWithFormat:@"%td", self.selectedOrderNumber] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
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

- (void)setSelectedOrderNumber:(NSUInteger)selectedOrderNumber {
    _selectedOrderNumber = selectedOrderNumber;
    if (selectedOrderNumber > 0) {
        [self assetCheckButtonSelectedAppearance];
    }
}

@end
