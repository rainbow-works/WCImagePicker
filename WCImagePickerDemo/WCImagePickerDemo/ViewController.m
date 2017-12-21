//
//  ViewController.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/13.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "ViewController.h"
#import <WCImagePicker/WCImagePicker.h>

@interface ViewController () <WCImagePickerControllerDelegate>

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
    WCImagePickerController *imagePicker = [[WCImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaType = WCImagePickerImageTypeImage;
    imagePicker.maximumNumberOfSelectionAsset = 100;
    imagePicker.fingerMovingToAssetForSelectionEnable = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - ImagePicker Delegate

- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didFinishPickingAssets:(NSArray<PHAsset *> *)assets {
    NSMutableArray *images = [NSMutableArray array];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = NO;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    for (PHAsset *asset in assets) {
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [images addObject:result];
        }];
    }
}

- (void)wc_imagePickerControllerDidCancel:(WCImagePickerController *)imagePicker {
    
}

- (BOOL)wc_imagePickerController:(WCImagePickerController *)imagePicker shouldSelectAsset:(PHAsset *)asset {
    return YES;
}

@end
