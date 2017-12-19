//
//  ViewController.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/13.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "ViewController.h"
#import "WCImagePickerController.h"

@interface ViewController ()

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
    imagePicker.maximumNumberOfSelectionAsset = 2;
    imagePicker.numberOfColumnsInPortrait = 4;
//    imagePicker.navigationBarBackgroundColor = [UIColor whiteColor];
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

@end
