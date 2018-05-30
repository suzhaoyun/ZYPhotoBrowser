//
//  ViewController.m
//  ZYPhotoBrowserDemo
//
//  Created by ZYSu on 2018/5/29.
//  Copyright © 2018年 ZYSu. All rights reserved.
//

#import "ViewController.h"
#import "ZYPhotoBrowser.h"
#import "ZYPhoto.h"
@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *photos;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.photos = [NSMutableArray array];
    NSArray *urls = @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1527663217944&di=d7561230a5689968f82ce3b39f010370&imgtype=0&src=http%3A%2F%2Fwww.taopic.com%2Fuploads%2Fallimg%2F140320%2F235013-14032020515270.jpg", @"https://timgsa.baidu.com/timg?image&quality=80&size=b10000_10000&sec=1527653153&di=a1e9d15623f9b1be1f9e391d268a5598&src=http://pic30.nipic.com/20130625/7447430_172916192000_2.jpg", @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1527663255129&di=3788ba22abe5613dba0e5ca93814bc22&imgtype=0&src=http%3A%2F%2Fimage.tianjimedia.com%2FuploadImages%2F2014%2F348%2F58%2F69HYFVT5E6TE.jpg", @"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=3241453398,1176683744&fm=27&gp=0.jpg", @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1527663277203&di=095915f7901afef8728de8f246d9996f&imgtype=0&src=http%3A%2F%2Fpic32.photophoto.cn%2F20140821%2F0005018361912554_b.jpg", @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1527663291914&di=ffd4f47d2d1fde5d42d3d8042c6b3e2e&imgtype=0&src=http%3A%2F%2Fpic26.photophoto.cn%2F20130308%2F0006019087786698_b.jpg"];
    for (int i = 0; i < urls.count; i++) {
        ZYPhoto *model = [ZYPhoto new];
        model.imageURL = [NSURL URLWithString:urls[i]];
        model.placeHolderImage = nil;
        model.sourceView = [self.view viewWithTag:i+1];
        [self.photos addObject:model];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    ZYPhotoBrowser *vc = [[ZYPhotoBrowser alloc] init];
    vc.photos = self.photos;
    [vc showWithViewController:self];
}

@end
