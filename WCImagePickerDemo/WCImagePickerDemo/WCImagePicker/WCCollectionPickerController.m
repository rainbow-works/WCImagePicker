//
//  WCCollectionPickerController.m
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/15.
//  Copyright © 2017年 王超. All rights reserved.
//

#import "WCCollectionPickerController.h"
#import "WCImagePickerController.h"
#import "WCCollectionCell.h"

#define COLLECTION_PICKER_WIDTH (self.view.bounds.size.width)
#define COLLECTION_PICKER_HEIGHT (self.view.bounds.size.height * 2/3.0)
static NSString * const WCImagePickerCollectionCellIdentifier = @"com.meetday.WCImagePickerCollectionCell";

@interface WCCollectionPickerController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, copy) void(^showCollectionPickerBlock)(BOOL willShowCollectionPicker);
@property (nonatomic, copy) void(^dismissCollectionPickerBlock)(BOOL willDismissCollectionPicker);
@property (nonatomic, copy) void(^completionBlock)(NSString *assetCollectionTitle, PHFetchResult * fetchResult);

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<WCAlbum *> *albums;

@end

@implementation WCCollectionPickerController

- (instancetype)init {
    if (self = [super init]) {
        _isAnimating = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
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
    tableViewFrame.size.width = COLLECTION_PICKER_WIDTH;
    tableViewFrame.size.height = COLLECTION_PICKER_HEIGHT;
    self.tableView.frame = tableViewFrame;
}

- (void)handleTapGesture:(UIGestureRecognizer *)gesture {
    [self dismissCollectionPicker];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc]
                      initWithFrame:CGRectMake(0, -COLLECTION_PICKER_HEIGHT, COLLECTION_PICKER_WIDTH, COLLECTION_PICKER_HEIGHT)
                      style:UITableViewStylePlain];
    [self.tableView registerNib:[UINib nibWithNibName:@"WCCollectionCell" bundle:nil] forCellReuseIdentifier:WCImagePickerCollectionCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollsToTop = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60.0;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

- (void)getAllAssetCollection {
    __weak typeof(self) weakSelf = self;
    void (^convertAssetCollectionToAlbumInfo)(PHFetchResult *) = ^(PHFetchResult *fetchResult) {
        [fetchResult enumerateObjectsUsingBlock:^(PHCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchOptions *options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            if (weakSelf.imagePickerController.mediaType == WCImagePickerImageTypeImage) {
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            } else if (weakSelf.imagePickerController.mediaType == WCImagePickerImageTypeVideo) {
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            }
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            WCAlbum *album = [[WCAlbum alloc] initWithTitle:assetCollection.localizedTitle assetCollection:assetCollection fetchResult:fetchResult];
            [weakSelf.albums addObject:album];
        }];
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        convertAssetCollectionToAlbumInfo(smartAlbums);
        PHFetchResult *userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        convertAssetCollectionToAlbumInfo(userAlbums);
        [self.albums sortUsingComparator:^NSComparisonResult(WCAlbum *obj1, WCAlbum *obj2) {
            return obj1.fetchResult.count < obj2.fetchResult.count;
        }];
        [self.tableView reloadData];
    });
}

#pragma mark - TapGesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return !CGRectContainsPoint(self.tableView.bounds, [touch locationInView:self.tableView]);
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WCCollectionCell *collectionCell = [tableView dequeueReusableCellWithIdentifier:WCImagePickerCollectionCellIdentifier forIndexPath:indexPath];
    collectionCell.album = [self.albums objectAtIndex:indexPath.row];
    return collectionCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissCollectionPicker];
    WCAlbum *album = [self.albums objectAtIndex:indexPath.row];
    self.completionBlock(album.title, album.fetchResult);
}

- (void)showCollectionPicker:(void (^)(BOOL))showCollectionPicker dismissCollectionPicker:(void (^)(BOOL))dismissCollectionPicker completion:(void (^)(NSString *assetCollectionTitle, PHFetchResult *fetchResult))completion {
    if (self.isAnimating) return;
    self.showCollectionPickerBlock = showCollectionPicker;
    self.dismissCollectionPickerBlock = dismissCollectionPicker;
    self.completionBlock = completion;
    if (self.tableView.frame.origin.y < 0) {
        [self showCollectionPicker];
    } else {
        [self dismissCollectionPicker];
    }
}

- (void)showCollectionPicker {
    if (self.showCollectionPickerBlock) {
        self.showCollectionPickerBlock(YES);
    }
    self.view.hidden = NO;
    self.isAnimating = !self.isAnimating;
    [UIView animateWithDuration:.6 delay:0.0 usingSpringWithDamping:.85 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.frame = CGRectMake(0, 0, COLLECTION_PICKER_WIDTH, COLLECTION_PICKER_HEIGHT);
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.4];
    } completion:^(BOOL finished) {
        self.isAnimating = !self.isAnimating;
    }];
}

- (void)dismissCollectionPicker {
    if (self.dismissCollectionPickerBlock) {
        self.dismissCollectionPickerBlock(YES);
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.frame = CGRectMake(0, 8.0, COLLECTION_PICKER_WIDTH, COLLECTION_PICKER_HEIGHT);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.tableView.frame = CGRectMake(0, -COLLECTION_PICKER_HEIGHT, COLLECTION_PICKER_WIDTH, COLLECTION_PICKER_HEIGHT);
        }];
    }];
    
    self.isAnimating = !self.isAnimating;
    [UIView animateWithDuration:0.6 animations:^{
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
        self.isAnimating = !self.isAnimating;
    }];
}

#pragma mark getter and setter

- (NSMutableArray<WCAlbum *> *)albums {
    if (_albums == nil) {
        _albums = [NSMutableArray<WCAlbum *> array];
    }
    return _albums;
}

@end

@implementation WCAlbum

- (instancetype)initWithTitle:(NSString *)title assetCollection:(PHAssetCollection *)assetCollection fetchResult:(PHFetchResult *)fetchResult {
    if (self = [super init]) {
        _title = title;
        _assetCollection = assetCollection;
        _fetchResult = fetchResult;
    }
    return self;
}

@end

