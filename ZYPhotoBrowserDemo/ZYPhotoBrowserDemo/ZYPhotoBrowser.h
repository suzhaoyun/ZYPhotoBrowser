//
//  ZYPhotoBrowser.h
//  ZYPhotoBrowserDemo
//
//  Created by ZYSu on 2018/5/29.
//  Copyright © 2018年 ZYSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZYPhotoProtocol <NSObject>

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *placeHolderImage;

@optional
@property (nonatomic, strong) UIView *sourceView;

@end

@class ZYPhotoBrowser;
@protocol ZYPhotoBrowserDelegate <NSObject>

- (NSInteger)numberOfPhotosInPhotoBrowser:(ZYPhotoBrowser *)photoBrowser;

- (UIImage *)photoBrowser:(ZYPhotoBrowser *)photoBrowser placeHolderImageForIndex:(NSInteger)index;

- (NSURL *)photoBrowser:(ZYPhotoBrowser *)photoBrowser imageURLForIndex:(NSInteger)index;

@optional

- (UIView *)photoBrowser:(ZYPhotoBrowser *)photoBrowser sourceViewWithIndex:(NSInteger)index;

@end

@interface ZYPhotoBrowser : UIViewController

@property (nonatomic, weak) id<ZYPhotoBrowserDelegate> delegate;

@property (nonatomic, strong) NSArray<id<ZYPhotoProtocol>> *photos;

@property (nonatomic, assign) NSInteger selectedIndex;

/**
 支持自定义cell 但必须继承ZYPhotoCell
 @discussion default：ZYPhotoCell
 * 注意不支持xib
 */
@property (nonatomic, assign) Class customCell;

- (void)showWithViewController:(UIViewController *)viewController;

- (void)showWithNavigationController:(UINavigationController *)navigationController;

@end
