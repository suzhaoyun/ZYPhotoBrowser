//
//  ZYPhotoBrowser.h
//  ZYPhotoBrowserDemo
//
//  Created by ZYSu on 2018/5/29.
//  Copyright © 2018年 ZYSu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZYAnimationTypeScale,
    ZYAnimationTypePush
} ZYAnimationType;

@class ZYPhotoBrowser;
@protocol ZYPhotoBrowserDelegate <NSObject>

/**
 图片的个数
 */
- (NSInteger)numberOfPhotosInPhotoBrowser:(ZYPhotoBrowser *)photoBrowser;

/**
 图片的URL
 支持本地和远程两种URL
 */
- (NSURL *)photoBrowser:(ZYPhotoBrowser *)photoBrowser imageURLForIndex:(NSInteger)index;

/**
 设置占位图片
 @discussion 必须设置，不然在视图没加载出来之前无法显示
 */
- (UIImage *)photoBrowser:(ZYPhotoBrowser *)photoBrowser placeholderImageForIndex:(NSInteger)index;

@optional

/**
 如果需要缩放弹出 需要提供原来的view视图
 */
- (UIImageView *)photoBrowser:(ZYPhotoBrowser *)photoBrowser sourceViewForIndex:(NSInteger)index;

@end

@interface ZYPhotoBrowser : UIViewController

/**
 提供数据的代理
 */
@property (nonatomic, weak) id<ZYPhotoBrowserDelegate> delegate;

/**
 当前选中的索引页
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 支持自定义cell 但必须继承ZYPhotoCell
 @discussion 添加操作视图等等
 * 注意不支持xib
 */
@property (nonatomic, assign) Class cellClass;

/**
 弹出动画 默认为（ZYAnimationTypeScale）缩放
 */
@property (nonatomic, assign) ZYAnimationType animationType;

/**
 如果animationType设置为ZYAnimationTypePush时，viewController必须有navigationCotnroller才可以
 */
- (void)showWithViewController:(UIViewController *)viewController;

@end
