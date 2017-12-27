//
//  ViewController.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/13.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <WCImagePicker/WCImagePicker.h>
#import "WCDisplayImageViewController.h"
#import "WCPlayVideoViewController.h"

@interface ViewController () <WCImagePickerControllerDelegate>
@property (nonatomic, assign) WCImagePickerImageType mediaType;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonDidClicked:(UIButton *)sender {
    WCImagePickerAppearance *imagePickerAppearance = [[WCImagePickerAppearance alloc] init];
    imagePickerAppearance.cancelButtonText = @"退出";
    [WCImagePickerController setupImagePickerAppearance:imagePickerAppearance];
    
    WCImagePickerController *imagePicker = [[WCImagePickerController alloc] init];
    imagePicker.delegate = self;
    NSInteger index = sender.tag % 1000;
    switch (index) {
        case 0:
            imagePicker.maximumNumberOfSelectionAsset = 1;
            break;
        case 1:
            imagePicker.maximumNumberOfSelectionAsset = 9;
            imagePicker.fingerMovingToAssetForSelectionEnable = YES;
            break;
        case 2:
            imagePicker.mediaType = WCImagePickerImageTypeVideo;
            imagePicker.maximumNumberOfSelectionAsset = 1;
            break;
        default:
            break;
    }
    self.mediaType = imagePicker.mediaType;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - ImagePicker Delegate

- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didFinishPickingAssets:(NSArray<PHAsset *> *)assets {
    if (self.mediaType == WCImagePickerImageTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        [[PHImageManager defaultManager] requestPlayerItemForVideo:[assets objectAtIndex:0] options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            WCPlayVideoViewController *playVideoVC = [[WCPlayVideoViewController alloc] initWithPlayerItem:playerItem];
            [self.navigationController pushViewController:playVideoVC animated:YES];
        }];
    } else {
        NSMutableArray *images = [NSMutableArray array];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        for (PHAsset *asset in assets) {
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                [images addObject:result];
            }];
        }
        WCDisplayImageViewController *displayImageVC = [[WCDisplayImageViewController alloc] initWithImages:[images copy]];
        [self.navigationController pushViewController:displayImageVC animated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)wc_imagePickerControllerDidCancel:(WCImagePickerController *)imagePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didSelectAsset:(PHAsset *)asset {
    NSLog(@"%s ---- %td", __func__, asset.mediaType);
}

- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didDeselectAsset:(PHAsset *)asset {
    NSLog(@"%s ---- %td", __func__, asset.mediaType);
}

@end
