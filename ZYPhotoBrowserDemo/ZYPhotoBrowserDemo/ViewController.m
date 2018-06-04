//
//  ViewController.m
//  ZYPhotoBrowserDemo
//
//  Created by ZYSu on 2018/5/29.
//  Copyright © 2018年 ZYSu. All rights reserved.
//

#import "ViewController.h"
#import "ZYPhotoBrowser.h"
#import <UIImageView+WebCache.h>
@interface ViewController ()<ZYPhotoBrowserDelegate>
@property (nonatomic, strong) NSArray *photos;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.photos = @[@"http://i3.17173cdn.com/2fhnvk/YWxqaGBf/outcms/bWKFdgbklrEknib.jpg",@"http://img5.duitang.com/uploads/item/201509/06/20150906092728_jaNtw.jpeg", @"http://imgs.shougongke.com/Public/data/hand/201605/21/step/03/1463805165340.jpg", @"http://img.zcool.cn/community/01c8fb5894a2bea801219c77043ee4.jpg", @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528087743690&di=11918e26566be8cec4a55ff86dd66e98&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201412%2F10%2F20141210234807_vP2YM.jpeg", @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528682481&di=a6e904bcd22446f084cbaaad662a1008&imgtype=jpg&er=1&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201407%2F07%2F20140707225000_4WJLs.jpeg"];
    for (int i = 0; i < self.photos.count; i++) {
        UIImageView *view = [self.view viewWithTag:i + 1];
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        [view addGestureRecognizer:tapGes];
        [view sd_setImageWithURL:[NSURL URLWithString:self.photos[i]]];
    }
}

- (void)tapGes:(UITapGestureRecognizer *)tapGes
{
    ZYPhotoBrowser *vc = [[ZYPhotoBrowser alloc] init];
    vc.delegate = self;
    vc.selectedIndex = tapGes.view.tag - 1;
    [vc showWithViewController:self];
}

- (NSInteger)numberOfPhotosInPhotoBrowser:(ZYPhotoBrowser *)photoBrowser
{
    return self.photos.count;
}

- (NSURL *)photoBrowser:(ZYPhotoBrowser *)photoBrowser imageURLForIndex:(NSInteger)index
{
    return [NSURL URLWithString:self.photos[index]];
}

- (UIImage *)photoBrowser:(ZYPhotoBrowser *)photoBrowser placeholderImageForIndex:(NSInteger)index
{
    return [[self.view viewWithTag:index + 1] image];
}

- (UIImageView *)photoBrowser:(ZYPhotoBrowser *)photoBrowser sourceViewForIndex:(NSInteger)index
{
    return [self.view viewWithTag:index + 1];
}

@end
