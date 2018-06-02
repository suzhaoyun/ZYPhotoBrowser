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

    self.photos = @[@"http://i3.17173cdn.com/2fhnvk/YWxqaGBf/outcms/bWKFdgbklrEknib.jpg",@"http://img5.duitang.com/uploads/item/201509/06/20150906092728_jaNtw.jpeg", @"http://imgs.shougongke.com/Public/data/hand/201605/21/step/03/1463805165340.jpg", @"http://img.zcool.cn/community/01c8fb5894a2bea801219c77043ee4.jpg", @"http://img3.imgtn.bdimg.com/it/u=743285241,3786552850&fm=27&gp=0.jpg", @"http://p3.gexing.com/G1/M00/36/6B/rBACFFH7QUSTRJcaAADPelTjHrA429.jpg"];
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
    vc.animationType = ZYAnimationTypePush;
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
