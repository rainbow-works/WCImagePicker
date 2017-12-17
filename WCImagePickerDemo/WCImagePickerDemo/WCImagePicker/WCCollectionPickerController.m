//
//  WCCollectionPickerController.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/15.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCCollectionPickerController.h"
#import <Photos/Photos.h>
#import "WCCollectionCell.h"
#import "WCAlbum.h"
#import "UIView+WCExtension.h"

static NSString * const WCImagePickerCollectionCellIdentifier = @"com.meetday.WCImagePickerCollectionCell";
static const CGFloat WCImagePickerCollectionCellRowHeight = 60.0;
#define WCCOLLECTION_PICKER_OFFSET (8.0)
#define WCCOLLECTION_PICKER_WIDTH (self.view.bounds.size.width)
#define WCCOLLECTION_PICKER_HEIGHT (self.view.bounds.size.height * 2/3.0)

@interface WCCollectionPickerController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign, readwrite) BOOL isVisible;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<WCAlbum *> *albums;
@end

@implementation WCCollectionPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.isAnimating = NO;
    [self setupTableView];
    [self getAllAssetCollection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.view layoutIfNeeded];
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.width = WCCOLLECTION_PICKER_WIDTH;
    tableViewFrame.size.height = WCCOLLECTION_PICKER_HEIGHT;
    self.tableView.frame = tableViewFrame;
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc]
                      initWithFrame:CGRectMake(0, -WCCOLLECTION_PICKER_HEIGHT, WCCOLLECTION_PICKER_WIDTH, WCCOLLECTION_PICKER_HEIGHT)
                      style:UITableViewStylePlain];
    [self.tableView registerNib:[UINib nibWithNibName:@"WCCollectionCell" bundle:nil] forCellReuseIdentifier:WCImagePickerCollectionCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollsToTop = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = WCImagePickerCollectionCellRowHeight;    
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

- (void)getAllAssetCollection {
    __weak typeof(self) weakSelf = self;
    void (^convertAssetCollectionToAlbumInfo)(PHFetchResult *) = ^(PHFetchResult *fetchResult) {
        [fetchResult enumerateObjectsUsingBlock:^(PHCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf.albums addObject:[[WCAlbum alloc] initWithTitle:collection.localizedTitle assetCollection:(PHAssetCollection *)collection]];
        }];
    };
    
    [self.view wc_showCoverViewForState:WCImagePickerCoverViewLoading];
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        convertAssetCollectionToAlbumInfo(smartAlbums);
        PHFetchResult *userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        convertAssetCollectionToAlbumInfo(userAlbums);
        [self.tableView reloadData];
        [self.view wc_removeCoverView];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WCCollectionCell *collectionCell = [tableView dequeueReusableCellWithIdentifier:WCImagePickerCollectionCellIdentifier forIndexPath:indexPath];
    collectionCell.album = [self.albums objectAtIndex:indexPath.row];
    return collectionCell;
}

- (void)showCollectionPicker {
    self.isVisible = YES;
    self.isAnimating = YES;
    self.view.hidden = NO;
    [UIView animateWithDuration:.6 delay:0.0 usingSpringWithDamping:.85 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.frame = CGRectMake(0, 0, WCCOLLECTION_PICKER_WIDTH, WCCOLLECTION_PICKER_HEIGHT);
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.2];
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
}

- (void)dismissCollectionPicker {
    self.isVisible = NO;
    self.isAnimating = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.frame = CGRectMake(0, WCCOLLECTION_PICKER_OFFSET, WCCOLLECTION_PICKER_WIDTH, WCCOLLECTION_PICKER_HEIGHT);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.tableView.frame = CGRectMake(0, -WCCOLLECTION_PICKER_HEIGHT, WCCOLLECTION_PICKER_WIDTH, WCCOLLECTION_PICKER_HEIGHT);
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
        }];
    }];
    
    [UIView animateWithDuration:0.8 animations:^{
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
    }];
}

- (void)collectionPickerTrigger {
    if (self.isAnimating) return;
    if (self.tableView.frame.origin.y < 0) {
        [self showCollectionPicker];
    } else {
        [self dismissCollectionPicker];
    }
}

#pragma mark getter and setter

- (NSMutableArray<WCAlbum *> *)albums {
    if (_albums == nil) {
        _albums = [NSMutableArray<WCAlbum *> array];
    }
    return _albums;
}

@end
