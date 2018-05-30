//
//  ZYPhoto.h
//  ZYPhotoBrowserDemo
//
//  Created by ZYSu on 2018/5/30.
//  Copyright © 2018年 ZYSu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYPhotoBrowser.h"

@interface ZYPhoto : NSObject <ZYPhotoProtocol>

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *placeHolderImage;
@property (nonatomic, strong) UIView *sourceView;

@end
