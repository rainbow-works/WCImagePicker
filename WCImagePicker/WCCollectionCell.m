//
//  WCCollectionCell.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/15.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCCollectionCell.h"
#import "WCImagePickerController.h"
#import "WCCollectionPickerController.h"

@interface WCCollectionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *assetImageView;
@property (weak, nonatomic) IBOutlet UILabel *assetCollectionTitle;
@property (weak, nonatomic) IBOutlet UILabel *assetCollectionCount;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, strong) UIImage *placeholderImage;

@end

@implementation WCCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIImage *arrowImage = [UIImage imageNamed:@"imagepicker_arrow_right" inBundle:[NSBundle wc_defaultBundle] compatibleWithTraitCollection:nil];
    [self.arrowImageView setImage:arrowImage];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.assetCollectionTitle.text = nil;
    self.assetCollectionCount.text = nil;
}

- (void)updateAssetImageViewAppearance {
    if (_album.fetchResult.count > 0) {
        PHAsset *asset = [_album.fetchResult objectAtIndex:0];
        CGFloat assetImageViewWidth = 60.0 * [UIScreen mainScreen].scale;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(assetImageViewWidth, assetImageViewWidth) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [self.assetImageView setImage:result ?: self.placeholderImage];
        }];
    } else {
        [self.assetImageView setImage:self.placeholderImage];
    }
}

- (void)setAlbum:(WCAlbum *)album {
    _album = album;
    if (_album) {
        [self.assetCollectionTitle setText:album.title];
        [self.assetCollectionCount setText:[NSString stringWithFormat:@"(%td)", album.fetchResult.count]];
        [self updateAssetImageViewAppearance];
    }
}

- (UIImage *)placeholderImage {
    if (_placeholderImage == nil) {
        _placeholderImage = [UIImage imageNamed:@"imagepicker_image_placeholder" inBundle:[NSBundle wc_defaultBundle] compatibleWithTraitCollection:nil];
    }
    return _placeholderImage;
}

@end
