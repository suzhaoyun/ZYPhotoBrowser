//
//  ZYPhotoCell.h
//  ZYPhotoBrowserDemo
//
//  Created by ZYSu on 2018/5/30.
//  Copyright © 2018年 ZYSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZYPhotoBrowser;
@interface ZYPhotoCell : UICollectionViewCell

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *placeHolderImage;
@property (nonatomic, weak) UIImageView *sourceView;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) ZYPhotoBrowser *browser;

@end
