//
//  ZYPhotoCell.h
//  ZYPhotoBrowserDemo
//
//  Created by ZYSu on 2018/5/30.
//  Copyright © 2018年 ZYSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYPhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *placeHolderImage;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSURL *imageURL;

@end
