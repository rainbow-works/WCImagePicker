//
//  WCImagePickerControllerController.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/13.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCImagePickerController.h"

@interface WCImagePickerController ()

@end

@implementation WCImagePickerController

- (instancetype)init {
    if (self = [super init]) {
        _mediaType = WCImagePickerImageTypeImage;
        _allowMultipleSelections = YES;
        _maximumNumberOfSelections = 1;
        _minimumNumberOfSelections = 1;
        _numberOfColumnsInPortrait = 4;
        _numberOfColumnsInLandscape = 7;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
