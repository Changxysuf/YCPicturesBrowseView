//
//  YCPicturesBrowseCell.m
//  YCPicturesBrowseExample
//
//  Created by 常兴宇 on 2018/9/18.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

#import "YCPicturesBrowseCell.h"
#import "UIImageView+WebCache.h"
#import "YCPicturesBrowseViewLayout.h"
#import "YCPicturesBrowseView.h"

#pragma mark - LGPicturesShowCollectionViewCell

@interface YCPicturesBrowseCell ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end


@implementation YCPicturesBrowseCell {
    //放大用的scrollView;
    UIScrollView    *_scaleScrollView;
    //展示的imageView
    UIImageView     *_imageView;
    
    //展示方式: 放大/缩小
    YCPictureShowType   _showType;
    //图片的frame
    CGRect              _imageViewFrame;
    //图片原始的frame 用于回位
    CGRect              _imageOriginFrame;
    
    //拖拽手势
    UIPanGestureRecognizer *_panGestureRecognizer;
}

#pragma mark - Lifecycle 生命周期
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViews];
    }
    return self;
}

#pragma mark - Private method 私有方法
- (void)createSubViews {
    _scaleScrollView               = [[UIScrollView alloc] init];
    _scaleScrollView.clipsToBounds = YES;
    _scaleScrollView.delegate      = self;
    _scaleScrollView.zoomScale     = 1;
    //设置最大伸缩比例
    _scaleScrollView.maximumZoomScale = 4.0;
    //设置最小伸缩比例
    _scaleScrollView.minimumZoomScale = 1;
    if (@available(iOS 11.0, *)) {
        _scaleScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.contentView addSubview:_scaleScrollView];
    
    
    _imageView             = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_resume_pic_placeholder.png"]];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.userInteractionEnabled = YES;
    [_scaleScrollView addSubview:_imageView];
    
    //点击
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGestureRecognizer:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    //双击
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    //拖拽
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    _panGestureRecognizer.delegate = self;
    //长按
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    longPressGestureRecognizer.minimumPressDuration = 1.0;
    
    [self addGestureRecognizer:tapGestureRecognizer];
    [self addGestureRecognizer:doubleTapGestureRecognizer];
    [self addGestureRecognizer:longPressGestureRecognizer];
    [_scaleScrollView addGestureRecognizer:_panGestureRecognizer];
    
}
- (void)resetImageViewFrame {
    CGSize imageSize = _imageView.image.size;
    if (CGSizeEqualToSize(imageSize, CGSizeZero)) return;
    
    if (_showType == YCPictureBrowseTypeOfZoomIn) {
        //        if (_imageOriginFrame) return;
        
        float scale             = imageSize.width / imageSize.height;
        float newImageWidth     = self.bounds.size.width;
        float newImageHeight    = newImageWidth / scale;
        float imageViewOriginY  = 0;
        if (newImageHeight < self.bounds.size.height) {
            imageViewOriginY = (self.bounds.size.height - newImageHeight) / 2;
        }
        _imageView.frame = CGRectMake(0, imageViewOriginY, newImageWidth, newImageHeight);
        if (_scaleScrollView.contentSize.height < newImageHeight) {
            _scaleScrollView.contentSize = CGSizeMake(newImageWidth, newImageHeight);
        }
        
    } else if (_showType == YCPictureBrowseTypeOfZoomOut) {
        _imageView.frame = _scaleScrollView.bounds;
    }
    _imageViewFrame = _imageView.frame;
    _imageOriginFrame = _imageView.frame;
}
#pragma mark - Public Interface 公有方法
- (void)updateDisplayWithPicturesBrowseModel:(YCPicturesBrowseModel *)browseModel {
    _picturesBrowseModel = browseModel;
    
    UIImage *placeholderImage   = browseModel.placeholderImage ?: [UIImage imageNamed:@"yc_image_placeholder@3x.png"];
    _imageView.image            = placeholderImage;
    _imageView.contentMode      = UIViewContentModeCenter;
    
    
    if (browseModel.pictureThumbUrl) {
        [_imageView sd_setImageWithURL:[NSURL URLWithString:browseModel.pictureThumbUrl]
                      placeholderImage:placeholderImage
                             completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                 if (image) {
                                     self->_imageView.contentMode = UIViewContentModeScaleAspectFill;
                                 }
                                 if (browseModel.pictureHDUrl) {
                                     [self->_imageView sd_setImageWithURL:[NSURL URLWithString:browseModel.pictureHDUrl]
                                                         placeholderImage:image ?: placeholderImage
                                                                  options:SDWebImageRetryFailed
                                                                 progress:nil
                                                                completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                                    if (image) {
                                                                        self->_imageView.contentMode = UIViewContentModeScaleAspectFill;
                                                                    }
                                                                }];
                                 }
                             }];
    }
    [self resetImageViewFrame];
}
- (void)resetScale {
    if (_scaleScrollView.zoomScale != 1) {
        _scaleScrollView.zoomScale = 1;
        _imageView.frame           = _imageViewFrame;
    }
}


//Override 方法
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    YCPicturesLayoutAttributes *attributes = (YCPicturesLayoutAttributes *)layoutAttributes;
    _scaleScrollView.frame                 = layoutAttributes.bounds;
    _scaleScrollView.contentSize           = layoutAttributes.bounds.size;
    _showType                              = attributes.showType;
    [self resetImageViewFrame];
}

#pragma mark - Delegate of <UIScrollView> 回调

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView != _scaleScrollView) return;
    
    float imageViewOriginY = 0;
    if (_scaleScrollView.contentSize.height < self.bounds.size.height) {
        imageViewOriginY = (self.bounds.size.height - _scaleScrollView.contentSize.height) / 2;
    }
    _imageView.frame = CGRectMake(0, imageViewOriginY, _scaleScrollView.contentSize.width, _scaleScrollView.contentSize.height);
    _imageOriginFrame = _imageView.frame;
}

#pragma mark - 处理手势
- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    if (_delegate && [_delegate respondsToSelector:@selector(collectionViewCell:tappedImageView:)]) {
        [_delegate collectionViewCell:self tappedImageView:_imageView];
    }
}
- (void)handleDoubleTapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    float scale = self.bounds.size.height / _imageView.bounds.size.height;
    CGPoint point = [gestureRecognizer locationInView:_scaleScrollView];
    
    float tapHorizontalScale = (point.x - _imageView.frame.origin.x) / _imageView.bounds.size.width;
    float tapVerticalScale = (point.y - _imageView.frame.origin.y) / _imageView.bounds.size.height;;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         if (self->_scaleScrollView.zoomScale <= 1) {
                             self->_scaleScrollView.zoomScale     = MAX(scale, 2);
                             self->_imageView.frame               = CGRectMake(0, 0, self->_scaleScrollView.contentSize.width, self->_scaleScrollView.contentSize.height);
                             //双击放大跟谁点击位置放大
                             float pointX                   = (self->_scaleScrollView.contentSize.width - self->_scaleScrollView.bounds.size.width) * tapHorizontalScale;
                             float pointY                   = (self->_scaleScrollView.contentSize.height - self->_scaleScrollView.bounds.size.height) * tapVerticalScale;
                             self->_scaleScrollView.contentOffset = CGPointMake(pointX, pointY);
                         } else {
                             self->_scaleScrollView.zoomScale = 1;
                             self->_imageView.frame           = self->_imageViewFrame;
                         }
                     } completion:^(BOOL finished) {
                         self->_imageOriginFrame = self->_imageView.frame;
                     }
     ];
}
-(void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //        _imageOriginFrame = _imageView.frame;
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint point = [panGestureRecognizer translationInView:_scaleScrollView];
        
        CGFloat centerX = _imageView.center.x + point.x;
        CGFloat centerY = _imageView.center.y + point.y;
        

        
        //向下拖动的比例, 屏幕中间点是0, 最下方是1
        float scale = 0;
        if (_imageOriginFrame.size.height < self.bounds.size.height) {
            scale = (centerY / (self.bounds.size.height / 2)) - 1;
        } else {
            scale = ((centerY / _imageOriginFrame.size.height) - 0.5) * _scaleScrollView.zoomScale;
        }
        
        
        //当前拖动比例下的宽高
        float currentWidth = _imageViewFrame.size.width - (_imageViewFrame.size.width * scale);
        float currentHeight = _imageViewFrame.size.height - (_imageViewFrame.size.height * scale);
        CGSize size = CGSizeMake(currentWidth, currentHeight);
        //size limit
        if (size.width > _imageViewFrame.size.width || size.height > _imageViewFrame.size.height) {
            size = _imageViewFrame.size;
        }
        if (size.width < 200) {
            size.width = 200;
            size.height = size.width * (_imageViewFrame.size.height / _imageViewFrame.size.width);
        }
        centerY = _imageView.center.y + point.y / _scaleScrollView.zoomScale;
        
        NSLog(@"width :%@ height :%@ scale:%@", @(centerX), @(centerY), @(scale));

        //设置size 和center
        _imageView.bounds = CGRectMake(0, 0, size.width, size.height);
        _imageView.center = CGPointMake(centerX, centerY);
        
        //拖动完之后，每次都要用 setTranslation: 方法置零，这样被拖动的图片不会不受控制滑出屏幕
        [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:_scaleScrollView];
        //回调
        if (_delegate && [_delegate respondsToSelector:@selector(collectionViewCell:didSwipImageWithScale:)]) {
            [_delegate collectionViewCell:self didSwipImageWithScale:scale];
        }
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        //记录拖动结束时的速度
        CGPoint velocity = [panGestureRecognizer velocityInView:_scaleScrollView];   //手指离开时x和y方向速度，单位是points/second
        //如果在屏幕上半部分拖动 让速度变为0(不缩小)
        if (_imageView.center.y < _scaleScrollView.center.y) {
            velocity = CGPointZero;
        }
        
        //回调
        BOOL hasZoomOut = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(collectionViewCell:didEndSwipImageWithVelocity:)]) {
            hasZoomOut = [_delegate collectionViewCell:self didEndSwipImageWithVelocity:velocity];
        }
        if (!hasZoomOut) {
            //还原
            [UIView animateWithDuration:0.25 animations:^{
                self->_imageView.frame = self->_imageOriginFrame;
            }];
        }
    }
}
- (void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (_delegate && [_delegate respondsToSelector:@selector(collectionViewCell:didLongPressForImage:)]) {
            [_delegate collectionViewCell:self didLongPressForImage:_imageView.image];
        }
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (_scaleScrollView.contentOffset.y > 0) {
        return NO;
    }
    if (gestureRecognizer == _panGestureRecognizer) {
        CGPoint point = [_panGestureRecognizer translationInView:_scaleScrollView];
        CGPoint velocity = [_panGestureRecognizer velocityInView:_scaleScrollView];
        if (velocity.y > 0) {
            if (fabs(point.x) <= 0.5) {
                return YES;
            }
        }
        return NO;
    }
    return YES;
}

#pragma mark -

@end
