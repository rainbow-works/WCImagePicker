//
//  WCCollectionCell.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/15.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCCollectionCell.h"
#import "WCCollectionPickerController.h"

@interface WCCollectionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *assetImageView;
@property (weak, nonatomic) IBOutlet UILabel *assetCollectionTitle;
@property (weak, nonatomic) IBOutlet UILabel *assetCollectionCount;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end

@implementation WCCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSBundle *assetBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [assetBundle pathForResource:@"WCImagePicker" ofType:@"bunlde"];
    if (bundlePath) {
        assetBundle = [NSBundle bundleWithPath:bundlePath];
    }
    
//    NSString *collectionCountFormat = NSLocalizedStringFromTableInBundle(@"imagepicker.collectionpicker.collectioncount", @"WCImagePicker", assetBundle, nil);
//    [self.assetCollectionCount setText:[NSString stringWithFormat:collectionCountFormat, 120]];
}

- (void)setAlbum:(WCAlbum *)album {
    _album = album;
    if (_album) {
        [self.assetCollectionTitle setText:album.title];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.assetCollectionCount setText:[NSString stringWithFormat:@"(%td)", album.fetchResult.count]];
            if (album.fetchResult.count > 0) {
                PHAsset *asset = [album.fetchResult objectAtIndex:0];
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(60, 60) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    [self.assetImageView setImage:result];
                }];
            }
        });
    }
}

@end
