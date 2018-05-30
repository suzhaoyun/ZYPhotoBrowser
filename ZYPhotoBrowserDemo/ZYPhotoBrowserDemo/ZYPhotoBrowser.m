//
//  ZYPhotoBrowser.m
//  ZYPhotoBrowserDemo
//
//  Created by ZYSu on 2018/5/29.
//  Copyright © 2018年 ZYSu. All rights reserved.
//

#import "ZYPhotoBrowser.h"
#import "ZYPhotoCell.h"

@interface ZYPhotoBrowser ()
<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL sourceNavigationBarHidden;
@property (nonatomic, assign) BOOL sourceStatusBarHidden;
@property (nonatomic, strong) UIPanGestureRecognizer *panGes;
@end

static NSString *CellID = @"ZYPhotoBrowserCellID";

@implementation ZYPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 记录之前导航栏是否隐藏
    if (self.navigationController) {
        self.sourceNavigationBarHidden = self.navigationController.navigationBarHidden;
    }
    self.sourceStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    
    [self.view addSubview:self.bgImageView];
    self.contentView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.collectionView];
    
    // 切换到选中的index
    if (self.selectedIndex) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)setScreenShot
{
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, [UIScreen mainScreen].scale);
    [[UIColor blackColor] setFill];
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.bgImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)showWithViewController:(UIViewController *)viewController
{
    [self setScreenShot];
    
    [viewController presentViewController:self animated:NO completion:nil];
}

- (void)showWithNavigationController:(UINavigationController *)navigationController
{
    [self setScreenShot];
    
    [navigationController pushViewController:self animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:self.sourceStatusBarHidden];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:self.sourceNavigationBarHidden animated:animated];
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
    if (self.delegate) {
        cell.placeHolderImage = [self.delegate photoBrowser:self placeHolderImageForIndex:indexPath.item];
        cell.imageURL = [self.delegate photoBrowser:self imageURLForIndex:indexPath.item];
    }else{
        id<ZYPhotoProtocol> model = [self.photos objectAtIndex:indexPath.item];
        cell.placeHolderImage = model.placeHolderImage;
        cell.imageURL = model.imageURL;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.delegate) {
        return [self.delegate numberOfPhotosInPhotoBrowser:self];
    }
    return self.photos.count;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (void)panGes:(UIPanGestureRecognizer *)panGes
{
    switch (panGes.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [panGes translationInView:panGes.view];
            if (self.collectionView.center.y <= self.view.bounds.size.height * 0.5 && point.y < 0) {
                break;
            }
            
            NSLog(@"xxxxx---%@", NSStringFromCGPoint(point));
            
            if (panGes.state == UIGestureRecognizerStateBegan) {
                [[UIApplication sharedApplication] setStatusBarHidden:self.sourceStatusBarHidden];
                [self setNeedsStatusBarAppearanceUpdate];
            }
            CGFloat y = self.collectionView.center.y + point.y * 0.5;
            CGFloat x = self.collectionView.center.x + point.x * 0.5;
            
            // 边界检测
            if (y > self.view.bounds.size.height) {
                y = self.view.bounds.size.height;
            }
            
            if (x < 0) {
                x = 0;
            }
            
            if (x > self.view.bounds.size.width) {
                x = self.view.bounds.size.width;
            }
            self.collectionView.center = CGPointMake(x, y);
            
            /**
             缩放系数
             1. 从观察可以得知，imageView的中点y值距离底部越近控件就越小
             2. imageView控件需要有最小值限制 不能无限缩小
             推算公式：
             center.y = height * 0.5 时 scale为1
             center.y = height时 scale为0.2
             */
            
            CGFloat scale = (self.view.bounds.size.height-self.collectionView.center.y)/(self.view.bounds.size.height*0.5)*0.7+0.3;
            self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scale];
            self.collectionView.transform = CGAffineTransformMakeScale(scale, scale);
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [self setNeedsStatusBarAppearanceUpdate];
            
            // 处理松手判断
            [UIView animateWithDuration:0.25 animations:^{
                self.collectionView.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
                self.collectionView.transform = CGAffineTransformIdentity;
                self.contentView.backgroundColor = [UIColor blackColor];
            }];
            break;
        }
        default:
            break;
    }
    [panGes setTranslation:CGPointZero inView:panGes.view];
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        // 不支持横屏
        CGRect bounds = [UIScreen mainScreen].bounds;
        CGFloat width = MIN(bounds.size.width, bounds.size.height);
        CGFloat height = MAX(bounds.size.width, bounds.size.height);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(width + 20, height);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, width + 20, height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        if (self.customCell) {
            NSAssert( [self.customCell isSubclassOfClass:[ZYPhotoCell class]], @"自定义cell必须继承ZYPhotoCell");
            [_collectionView registerClass:self.customCell forCellWithReuseIdentifier:CellID];
        }else{
            [_collectionView registerClass:[ZYPhotoCell class] forCellWithReuseIdentifier:CellID];
        }
        
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)];
        panGes.delegate = self;
        [self.contentView addGestureRecognizer:panGes];
        self.panGes = panGes;
    }
    return _collectionView;
}

- (UIImageView *)bgImageView
{
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _bgImageView;
}

- (BOOL)prefersStatusBarHidden
{
    if (self.panGes.state == UIGestureRecognizerStateBegan || self.panGes.state == UIGestureRecognizerStateChanged) {
        return self.sourceStatusBarHidden;
    }
    return YES;
}

@end
