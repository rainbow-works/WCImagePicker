//
//  WCPlayVideoViewController.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/26.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCPlayVideoViewController.h"

@interface WCPlayVideoViewController ()

@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation WCPlayVideoViewController

- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem {
    if (self = [super init]) {
        _playerItem = playerItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AVPlayer *player = [AVPlayer playerWithPlayerItem:self.playerItem];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    layer.frame = self.view.bounds;
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.player = player;
    playerVC.view.frame = self.view.bounds;
    [self.view addSubview:playerVC.view];
    [playerVC.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
