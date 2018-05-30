//
//  ZYPhotoCell.m
//  ZYPhotoBrowserDemo
//
//  Created by ZYSu on 2018/5/30.
//  Copyright © 2018年 ZYSu. All rights reserved.
//

#import "ZYPhotoCell.h"
#import <UIImageView+WebCache.h>

@interface ZYPhotoCell()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;
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
    self.backgroundColor = [UIColor clearColor];
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
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

    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    tapGes.numberOfTapsRequired = 2;
    [self.imageView addGestureRecognizer:tapGes];
}

- (void)tapGes:(UITapGestureRecognizer *)tapGes
{
    if (tapGes.state == UIGestureRecognizerStateEnded) {
//        [self.scrollView setZoomScale:self.scrollView.zoomScale==3.0?1.0:3.0 animated:NO];
//        [self.scrollView setContentOffset:CGPointMake(20, 20) animated:YES];
        
        CGPoint point = [tapGes locationInView:tapGes.view];
        
        CGFloat xscale = point.x / self.imageView.bounds.size.width;
        CGFloat yscale = point.y / self.imageView.bounds.size.height;
        
        CGFloat touchX = 0, touchY = 0;
        if (self.scrollView.zoomScale == 1) {
            touchX = xscale * 3 * self.imageView.bounds.size.width;
            touchY = yscale * 3 * self.imageView.bounds.size.height;
        }else{
            touchX = xscale / 3.0 * self.imageView.bounds.size.width;;
            touchY = yscale / 3.0 * self.imageView.bounds.size.height;;
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.zoomScale = self.scrollView.zoomScale==3.0?1.0:3.0;
            [self.scrollView scrollRectToVisible:CGRectMake(touchX, touchY, 200, 200) animated:NO];
        }];
    }
}

- (void)setPlaceHolderImage:(UIImage *)placeHolderImage
{
    _placeHolderImage = placeHolderImage;
    self.imageView.image = placeHolderImage;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self.imageView sd_setImageWithURL:imageURL placeholderImage:self.placeHolderImage];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
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

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale animated:YES];
}

@end
