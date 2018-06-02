//
//  ZYPhotoCell.m
//  ZYPhotoBrowserDemo
//
//  Created by ZYSu on 2018/5/30.
//  Copyright © 2018年 ZYSu. All rights reserved.
//

#import "ZYPhotoCell.h"
#import "ZYPhotoBrowser.h"
#import <UIImageView+WebCache.h>

@interface ZYPhotoLoadingView : UIView

@property (nonatomic, assign) BOOL loading;

@end

@interface ZYPhotoCell()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *browserContentView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) BOOL dragMode;
@property (nonatomic, assign) CGRect sourceFrame;
@property (nonatomic, strong) ZYPhotoLoadingView *loadingView;
@end

@implementation ZYPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI
{
    self.lastPoint = CGPointZero;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 3.0;
    scrollView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:imageView];
    self.imageView = imageView;
    
    self.scrollView.frame = CGRectMake(10, 0, self.bounds.size.width-20, self.bounds.size.height);
    self.imageView.frame = self.scrollView.bounds;
    
    [self.contentView addSubview:self.loadingView];
    [self.loadingView setFrame:self.contentView.bounds];

    UITapGestureRecognizer *sigleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTap:)];
    sigleTap.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:sigleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.imageView addGestureRecognizer:doubleTap];
    
    [sigleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)sigleTap:(UITapGestureRecognizer *)tapGes
{
    [self startCloseAnimation];
}

- (void)doubleTap:(UITapGestureRecognizer *)tapGes
{
    if (tapGes.state == UIGestureRecognizerStateEnded) {
        if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
            [self.scrollView setZoomScale:1.0 animated:YES];
        }else{
            CGPoint point = [tapGes locationInView:tapGes.view];
            [self.scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
        }
    }
}

- (void)setSourceView:(UIImageView *)sourceView
{
    _sourceView = sourceView;
    self.imageView.contentMode = sourceView.contentMode;
    self.imageView.layer.masksToBounds = sourceView.layer.masksToBounds;
    self.imageView.clipsToBounds = sourceView.clipsToBounds;
}

- (void)setPlaceHolderImage:(UIImage *)placeHolderImage
{
    _placeHolderImage = placeHolderImage;
    self.imageView.image = placeHolderImage;
    [self adjustImageViewFrame];
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    
    [self.scrollView setZoomScale:1];
    
    if ([imageURL isFileURL]) {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imageURL.path];
        if (image){
            self.imageView.image = image;
        }
        self.loadingView.loading = NO;
    }else{
        
        UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:imageURL.absoluteString];
        if (image) {
            self.imageView.image = image;
            self.loadingView.loading = NO;
        }else{
            self.loadingView.loading = YES;
            [self.imageView sd_setImageWithURL:imageURL placeholderImage:self.placeHolderImage options:0 progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                self.loadingView.loading = NO;
                [self adjustImageViewFrame];
            }];
        }
    }
}

- (void)setBrowser:(ZYPhotoBrowser *)browser
{
    _browser = browser;
    _browserContentView = [browser valueForKey:@"contentView"];
}

- (void)adjustImageViewFrame
{
    if (self.imageView.image == nil) {
        return;
    }
    CGFloat imageW = self.imageView.image.size.width;
    CGFloat imageH = self.imageView.image.size.height;
    CGFloat width = self.scrollView.bounds.size.width;
    CGFloat height = width / imageW * imageH;

    if (height > self.scrollView.bounds.size.height) {
        [self.imageView setFrame:CGRectMake(0, 0, width, height)];
    }else{
        [self.imageView setBounds:CGRectMake(0, 0, width, height)];
        [self.imageView setCenter:CGPointMake(self.scrollView.bounds.size.width*0.5, self.scrollView.bounds.size.height*0.5)];
    }
    self.sourceFrame = self.imageView.frame;
    [self.scrollView setContentSize:CGSizeMake(0, height)];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.panGestureRecognizer.numberOfTouches != 1) {
        return;
    }
   
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView];
    
    CGPoint point = CGPointMake(translation.x - self.lastPoint.x, translation.y - self.lastPoint.y);
    
    self.lastPoint = translation;
   
    if (scrollView.contentOffset.y < 0) {
        [scrollView setContentOffset:CGPointZero];
        self.dragMode = YES;
    }
    
    if (self.dragMode == NO) {
        return;
    }
    
    CGFloat effectDistance = self.scrollView.bounds.size.height - self.sourceFrame.origin.y;
    CGFloat scale = ((effectDistance - (self.imageView.frame.origin.y - self.sourceFrame.origin.y)) / effectDistance) * 0.8 + 0.2;
    if (scale > 1) {
        scale = 1;
    }
    
    CGFloat width = self.sourceFrame.size.width * scale;
    CGFloat height = self.sourceFrame.size.height * scale;
    self.browserContentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scale];
    
    self.imageView.frame = CGRectMake(self.imageView.center.x + point.x - width * 0.5, self.imageView.frame.origin.y + point.y, width, height);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.lastPoint = CGPointZero;
    if (self.dragMode) {
        
        CGFloat panVelocity = [scrollView.panGestureRecognizer velocityInView:scrollView].y;
        // 判定为关闭手势
        if (panVelocity > 1000) {
            [self startCloseAnimation];
        }else{
            // 如果缩小了0.7以下
            if (self.imageView.bounds.size.width / self.sourceFrame.size.width < 0.7) {
                [self startCloseAnimation];
            }else{
                // 还原imageView
                [UIView animateWithDuration:0.25 animations:^{
                    self.imageView.frame = self.sourceFrame;
                    self.browserContentView.backgroundColor = [UIColor blackColor];
                }];
            }
        }
        self.dragMode = NO;
    }
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat scrollW = CGRectGetWidth(scrollView.frame);
    CGFloat scrollH = CGRectGetHeight(scrollView.frame);
    
    CGSize contentSize = scrollView.contentSize;
    CGFloat offsetX = scrollW > contentSize.width ? (scrollW - contentSize.width) * 0.5 : 0;
    CGFloat offsetY = scrollH > contentSize.height ? (scrollH - contentSize.height) * 0.5 : 0;
    
    CGFloat centerX = contentSize.width * 0.5 + offsetX;
    CGFloat centerY = contentSize.height * 0.5 + offsetY;
    
    self.imageView.center = CGPointMake(centerX, centerY);

}

- (void)startCloseAnimation
{
    // 隐藏collectionView
    [[self.browser valueForKey:@"collectionView"] setHidden:YES];
    
    if (self.scrollView.zoomScale != 1) {
        self.scrollView.zoomScale = 1;
    }
    
    UIImageView *animationView = [[UIImageView alloc] init];
    animationView.contentMode = self.imageView.contentMode;
    animationView.layer.masksToBounds = self.imageView.layer.masksToBounds;
    animationView.clipsToBounds = self.imageView.clipsToBounds;
    animationView.image = self.imageView.image;
    animationView.frame = [self.imageView convertRect:self.imageView.bounds toView:self.browser.view];
    [self.browser.view addSubview:animationView];
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self.sourceView == nil) {
            animationView.alpha = 0;
        }else{
            animationView.frame = [self.sourceView convertRect:self.sourceView.bounds toView:self.browser.view];
        }
        self.browserContentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    }completion:^(BOOL finished) {
        if (self.browser.animationType == ZYAnimationTypeScale) {
            [self.browser dismissViewControllerAnimated:NO completion:nil];
        }else{
            [self.browser.navigationController popViewControllerAnimated:NO];
        }
    }];
}

@end

@implementation ZYPhotoLoadingView
{
    UILabel *_label;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.backgroundColor = [UIColor greenColor];
        label.text = @"加载中...";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
    }
    return self;
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    _label.hidden = !loading;
}

@end
