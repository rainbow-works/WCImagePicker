//
//  WCAssetCell.h
//  WCImagePickerDemo
//
//  Created by 王超 on 2017/12/14.
//  Copyright © 2017年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCAssetCell : UICollectionViewCell

@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) NSUInteger selectedOrderNumber;
@property (nonatomic, assign) BOOL shouldAnimationWhenSelectedOrderNumberUpdate;

@property (weak, nonatomic) IBOutlet UIImageView *assetImageView;
@property (weak, nonatomic) IBOutlet UILabel *assetTimeLabel;

- (void)updateAssetCellAppearanceIfNeeded;
- (void)shouldShowAssetCoverView:(BOOL)shouldShowAssetCoverView;

@end

