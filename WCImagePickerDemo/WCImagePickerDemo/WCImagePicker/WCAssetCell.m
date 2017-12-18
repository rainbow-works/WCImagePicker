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

@property (weak, nonatomic) IBOutlet UIButton *assetCheckedButton;

@end

@implementation WCAssetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.assetCheckedButton.layer.cornerRadius = 12;
    self.assetCheckedButton.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self.assetCheckedButton setImage:nil forState:UIControlStateNormal];
        [self.assetCheckedButton setTitle:@"1" forState:UIControlStateNormal];
        self.assetCheckedButton.backgroundColor = [UIColor blueColor];
        
        self.assetCheckedButton.transform = CGAffineTransformScale(self.assetCheckedButton.transform, 0.3, 0.3);
        [UIView animateWithDuration:1.25 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:8.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.assetCheckedButton.transform = CGAffineTransformIdentity;
        } completion:nil];
    } else {
        [self.assetCheckedButton setImage:[UIImage imageNamed:@"imagepicker_asset_check"] forState:UIControlStateNormal];
        self.assetCheckedButton.backgroundColor = [UIColor clearColor];
    }
}

@end
