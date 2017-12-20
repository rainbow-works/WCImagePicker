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
    imagePicker.maximumNumberOfSelectionAsset = 4;
    imagePicker.numberOfColumnsInPortrait = 4;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

#pragma mark - ImagePicker Delegate

- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didFinishPickingAssets:(NSArray<PHAsset *> *)assets {
    
}

- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didFinishPickingImages:(NSArray<UIImage *> *)images {
    
}

- (void)wc_imagePickerControllerDidCancel:(WCImagePickerController *)imagePicker {
    
}

- (BOOL)wc_imagePickerController:(WCImagePickerController *)imagePicker shouldSelectAsset:(PHAsset *)asset {
    return YES;
}

@end
