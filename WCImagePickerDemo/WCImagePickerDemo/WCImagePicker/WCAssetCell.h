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
@property (weak, nonatomic) IBOutlet UIImageView *assetImageView;

@end