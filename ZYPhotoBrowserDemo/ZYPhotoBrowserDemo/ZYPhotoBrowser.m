//
//  ZYPhotoBrowser.m
//  ZYPhotoBrowserDemo
//
//  Created by ZYSu on 2018/5/29.
//  Copyright © 2018年 ZYSu. All rights reserved.
//

#import "ZYPhotoBrowser.h"
#import "ZYPhotoCell.h"
#import <SDWebImageManager.h>

@interface ZYPhotoBrowser ()
<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL sourceNavigationBarHidden;
@property (nonatomic, assign) BOOL sourceStatusBarHidden;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, strong) UIPageControl *pageControl;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];

    [self.view addSubview:self.bgView];
    self.bgView.image = self.bgImage;
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.collectionView];
    
    NSInteger count = [self.delegate numberOfPhotosInPhotoBrowser:self];
    if (count > 1 && count < 10){
        [self.view addSubview:self.pageControl];
        self.pageControl.numberOfPages = count;
        [self.pageControl setFrame:CGRectMake(0, self.view.bounds.size.height - 30, self.view.bounds.size.width, 20)];
    }
    
    // 切换到选中的index
    if (self.selectedIndex) {
        self.currentIndex = self.selectedIndex;
        self.pageControl.currentPage = self.selectedIndex;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
}

- (void)orientationChange
{
    NSLog(@"orientationChange---%ld", [UIDevice currentDevice].orientation);
}

- (void)statusBarChange
{
    NSLog(@"statusBarChange---%ld", [UIApplication sharedApplication].statusBarOrientation);
}

- (void)startShowAnimation
{
    UIImage *image = [self.delegate photoBrowser:self placeholderImageForIndex:self.selectedIndex];
    
    NSAssert(image != nil, @"ZYPhotoBrowser必须设置占位图！！！");
    
    self.collectionView.hidden = YES;

    UIImageView *sourceView = [self.delegate photoBrowser:self sourceViewForIndex:self.selectedIndex];
    NSAssert([sourceView isKindOfClass:[UIImageView class]] == YES, @"sourceView必须是UIImageView类型");
    UIImageView *animationView = [[UIImageView alloc] init];
    animationView.contentMode = sourceView.contentMode;
    animationView.layer.masksToBounds = sourceView.layer.masksToBounds;
    animationView.clipsToBounds = sourceView.clipsToBounds;
    if (sourceView == nil) {
        animationView.frame = CGRectMake(self.view.bounds.size.width*0.5-150, self.view.bounds.size.height*0.5-150, 300, 300);
        animationView.backgroundColor = [UIColor whiteColor];
    }else{
        animationView.frame = [sourceView convertRect:sourceView.bounds toView:self.view];
    }
    
    NSURL *imageURL = [self.delegate photoBrowser:self imageURLForIndex:self.selectedIndex];
    if ([imageURL isFileURL]) {
        animationView.image = [[UIImage alloc] initWithContentsOfFile:imageURL.path];
    }else{
        UIImage *originImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:imageURL.absoluteString];
        animationView.image = originImage?originImage:image;
    }
    [self.view addSubview:animationView];
    
    CGRect destFrame = [self adjustFrameWithImage:animationView.image];
    self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.3 animations:^{
        animationView.frame = destFrame;
        self.contentView.backgroundColor = [UIColor blackColor];
    }completion:^(BOOL finished) {
        self.collectionView.hidden = NO;
        [animationView removeFromSuperview];
    }];
}

- (CGRect)adjustFrameWithImage:(UIImage *)image
{
    CGFloat imageW = image.size.width;
    CGFloat imageH = image.size.height;
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = width / imageW * imageH;
    
    if (height > self.view.bounds.size.height) {
        return CGRectMake(0, 0, width, height);
    }else{
        return CGRectMake((self.view.bounds.size.width-width)*0.5, (self.view.bounds.size.height-height)*0.5, width, height);
    }
}

- (void)showWithViewController:(UIViewController *)viewController
{
    if (self.animationType == ZYAnimationTypeScale) {
        [self shotcutScreen:viewController];
        [viewController presentViewController:self animated:NO completion:^{
            [self startShowAnimation];
        }];
    }
    else if (self.animationType == ZYAnimationTypePush){
        NSAssert(viewController.navigationController != nil, @"ZYPhotoBrowser的animationType设置为ZYAnimationTypePush时，viewController必须有navigationCotnroller才可以");
        [self shotcutScreen:viewController];
        [viewController.navigationController pushViewController:self animated:YES];
    }
}

- (void)shotcutScreen:(UIViewController *)vc
{
    UIView *view = vc.navigationController?vc.navigationController.view:vc.view; UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
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
    cell.index = indexPath.item;
    cell.browser = self;
    cell.imageURL = [self.delegate photoBrowser:self imageURLForIndex:indexPath.item];
    cell.placeHolderImage = [self.delegate photoBrowser:self placeholderImageForIndex:indexPath.item];
    if ([self.delegate respondsToSelector:@selector(photoBrowser:sourceViewForIndex:)]) {
        UIImageView *sourceView = [self.delegate photoBrowser:self sourceViewForIndex:indexPath.item];
        NSAssert([sourceView isKindOfClass:[UIImageView class]] == YES, @"sourceView必须是UIImageView类型");
        cell.sourceView = sourceView;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.delegate numberOfPhotosInPhotoBrowser:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentIndex = scrollView.contentOffset.x / scrollView.bounds.size.width;
    _pageControl.currentPage = self.currentIndex;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height);
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.bounds.size.width + 20, self.view.bounds.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        if (self.cellClass) {
            NSAssert([self.cellClass isSubclassOfClass:[ZYPhotoCell class]], @"自定义cell必须继承ZYPhotoCell");
            [_collectionView registerClass:self.cellClass forCellWithReuseIdentifier:CellID];
        }else{
            [_collectionView registerClass:[ZYPhotoCell class] forCellWithReuseIdentifier:CellID];
        }
    }
    return _collectionView;
}

- (UIImageView *)bgView
{
    if (_bgView == nil) {
        _bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    }
    return _bgView;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIPageControl *)pageControl
{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

@end
