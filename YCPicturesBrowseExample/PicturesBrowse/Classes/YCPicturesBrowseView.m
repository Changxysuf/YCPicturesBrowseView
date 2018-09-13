//
//  YCPicturesBrowseView.m
//  RingtonesWallpapers
//
//  Created by 常兴宇 on 2018/9/6.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

#import "YCPicturesBrowseView.h"
#import "UIImageView+WebCache.h"


#pragma mark -
#pragma mark - YCPicturesBrowseModel
@implementation YCPicturesBrowseModel

@end



#pragma mark -
#pragma mark - YCPicturesBrowseView

static NSString *KCollectionViewCellId = @"CollectionViewCellId";


@interface YCPicturesBrowseView ()<UICollectionViewDelegate, UICollectionViewDataSource, YCPicturesBrowseCellDelegate>

@end

@implementation YCPicturesBrowseView {
    
    UICollectionView            *_collectionView;
    YCPicturesBrowseViewLayout  *_collectionViewLayout;
    YCPictureShowType           _pictureShowType;
    
    NSArray     *_pictureArray;
    NSInteger   _index;
    
    UIColor *_backgroundColor;
    BOOL    _showAnimation;
    
    UIView *_toolBarContainerView;
}

#pragma mark - Lifecycle 生命周期
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)browseViewPictureArray:(NSArray<YCPicturesBrowseModel *> *)pictureArray
                                 index:(NSInteger)index {
    YCPicturesBrowseView *pictureShowView = [[YCPicturesBrowseView alloc] initWithPictureArray:pictureArray index:index backgroundColor:nil];
    return pictureShowView;
}


- (instancetype)initWithPictureArray:(NSArray<YCPicturesBrowseModel *> *)pictureArray
                               index:(NSInteger)index
                     backgroundColor:(UIColor *)backgroundColor {
    
    self = [super init];
    if (self) {
        _pictureShowType  = YCPictureBrowseTypeOfZoomOut;
        _index            = index;
        _pictureArray     = [NSArray arrayWithArray:pictureArray];
        _backgroundColor  = backgroundColor;
        
        [self createSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateDisPlay];
}


- (void)showOnView:(UIView *)basicView fromView:(UIView *)fromView animation:(BOOL)animation {
    _showAnimation = animation;

    [basicView addSubview:self];
    self.frame = basicView.bounds;
    [self configCollectionInitialStateWithFromeView:fromView];
    [self zoomInLayout];
}

- (void)showOnViewKeyWindowFromView:(UIView *)fromView animation:(BOOL)animation {
    UIWindow *windown = [UIApplication sharedApplication].keyWindow;
    [self showOnView:windown fromView:fromView animation:animation];
}


#pragma mark - User Interaction 用户交互

#pragma mark - Private method 私有方法
- (void)configCollectionInitialStateWithFromeView:(UIView *)fromView {
    _collectionView.frame = self.bounds;
    _collectionView.contentOffset = CGPointMake(_index * _collectionView.bounds.size.width, _collectionView.bounds.size.height);
    
    _collectionViewLayout.collectionViewBounds = self.bounds;
    //默认
    CGRect zoomOutFrame = CGRectMake(self.bounds.size.width / 2, self.bounds.size.height / 2, 0, 0);
    if (fromView) {
        zoomOutFrame = [fromView convertRect:fromView.bounds toView:[UIApplication sharedApplication].keyWindow];
    }
    _collectionViewLayout.zoomOutFrame = zoomOutFrame;

}
- (void)createSubViews {
    
    _collectionViewLayout = [[YCPicturesBrowseViewLayout alloc] init];
    _collectionViewLayout.showType = _pictureShowType;
    _collectionViewLayout.currentPageIndex = _index;


    _collectionView                                = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
    _collectionView.showsVerticalScrollIndicator   = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    
    if (!_backgroundColor) {
        _backgroundColor = [UIColor colorWithRed:26.0 / 255.0 green:26.0 / 255.0 blue:26.0 / 255.0 alpha:1];
    }
    _collectionView.backgroundColor                = [_backgroundColor colorWithAlphaComponent:0];
    _collectionView.delegate                       = self;
    _collectionView.dataSource                     = self;
    _collectionView.pagingEnabled                  = YES;
    _collectionView.contentInset = UIEdgeInsetsZero;
    [_collectionView registerClass:[YCPicturesBrowseCell class] forCellWithReuseIdentifier:KCollectionViewCellId];
    
    [self addSubview:_collectionView];
    
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}
// 更新视图(主要是更新pageview)
- (void)updateDisPlay {
    if (!_pictureArray || _pictureArray.count == 0) {
        NSLog(@"数组不能为空");
        return;
    }
    if (_pictureArray.count < _index + 1) {
        NSLog(@"索引大于数组的个数");
        return;
    }
    
    
    YCPicturesBrowseModel *showModel = _pictureArray[_index];
    
    if (![showModel isKindOfClass:[YCPicturesBrowseModel class]]) {
        return;
    }
    if ([self.toolbar respondsToSelector:@selector(setCurrentPage:totalPage:)]) {
        [self.toolbar setCurrentPage:_index + 1 totalPage:_pictureArray.count];
    }
    if ([self.toolbar respondsToSelector:@selector(setPictureTitle:)]) {
        [self.toolbar setPictureTitle:showModel.pictureTitle];
    }
    if ([self.toolbar respondsToSelector:@selector(setPictureDesc:)]) {
        [self.toolbar setPictureDesc:showModel.pictureContent];
    }
    if ([self.toolbar respondsToSelector:@selector(updatePictureBrowseModel:)]) {
        [self.toolbar updatePictureBrowseModel:_pictureArray[_index]];
    }
    [self updateToolBarFrame];
}
//更新ToolBar
- (void)updateToolBarFrame {
    if (!self.toolbar) {
        return;
    }
    if ([self.toolbar respondsToSelector:@selector(updateDisplayWithPicturesBrowseSize:safeArea:)]) {
        UIEdgeInsets insets = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            insets = self.superview.safeAreaInsets;
        }
        [self.toolbar updateDisplayWithPicturesBrowseSize:_collectionView.bounds.size safeArea:insets];
        _toolBarContainerView.frame = self.toolbar.frame;
        self.toolbar.frame = _toolBarContainerView.bounds;
    }
    
}

//更新layout
- (void)updatePictureShowViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[YCPicturesBrowseViewLayout alloc] init];
    }
    _collectionViewLayout.collectionViewBounds = self.bounds;
    _collectionViewLayout.currentPageIndex     = _index;
    _collectionViewLayout.showType             = _pictureShowType;
    
    UIView *basicView = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(picturesBrowseView:targetViewAtIndex:)]) {
        basicView = [self.dataSource picturesBrowseView:self targetViewAtIndex:_index];
    }
    if (basicView) {
        CGRect  currentFrame               = [basicView convertRect:basicView.bounds toView:[UIApplication sharedApplication].keyWindow];
        _collectionViewLayout.zoomOutFrame = currentFrame;
    } else {
        _collectionViewLayout.zoomOutFrame = CGRectMake(self.bounds.size.width / 2, self.bounds.size.height / 2, 0, 0);
    }
}
//放大
- (void)zoomInLayout {
    _pictureShowType = YCPictureBrowseTypeOfZoomIn;
    _toolBarContainerView.alpha = 0;
    
    if (_delegate && [_delegate respondsToSelector:@selector(picturesBrowseView:willChangeToShowType:)]) {
        [_delegate picturesBrowseView:self willChangeToShowType:_pictureShowType];
    }
    [UIView animateWithDuration: _showAnimation ? 0.2 : 0
                     animations:^{
                         _collectionView.backgroundColor = _backgroundColor;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 animations:^{
                             _toolBarContainerView.alpha = 1;                             
                         }];
                     }];
    [self updateCollectionLayoutCompletion:^(BOOL complete) {
        if (_delegate && [_delegate respondsToSelector:@selector(picturesBrowseView:didChangeToShowType:)]) {
            [_delegate picturesBrowseView:self didChangeToShowType:_pictureShowType];
        }
    }];
}
//缩小
- (void)zoomOutLayout {
    _pictureShowType         = YCPictureBrowseTypeOfZoomOut;
    _toolBarContainerView.hidden     = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(picturesBrowseView:willChangeToShowType:)]) {
        [_delegate picturesBrowseView:self willChangeToShowType:_pictureShowType];
    }

    [UIView animateWithDuration:0.2 animations:^{
        _collectionView.backgroundColor = [_backgroundColor colorWithAlphaComponent:0];
    }];
    [self updateCollectionLayoutCompletion:^(BOOL complete) {
        if (_delegate && [_delegate respondsToSelector:@selector(picturesBrowseView:didChangeToShowType:)]) {
            [_delegate picturesBrowseView:self didChangeToShowType:_pictureShowType];
        }
        [self removeFromSuperview];
    }];
}
//更新collectionView的layout
- (void)updateCollectionLayoutCompletion:(void (^)(BOOL complete))completion {
    if (_showAnimation) {
        [_collectionView performBatchUpdates:^{
            [self updatePictureShowViewLayout];
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [UIView performWithoutAnimation:^{
            [_collectionView performBatchUpdates:^{
                [self updatePictureShowViewLayout];
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }];
    }
}

#pragma mark - Public Interface 公有方法
- (void)setToolbar:(UIView<YCPicturesBrowseToolbarProtocol> *)toolbar {
    _toolbar = toolbar;
    if (_toolbar && !_toolBarContainerView) {
        _toolBarContainerView = [UIView new];
        [self addSubview:_toolBarContainerView];
    }
    [_toolBarContainerView addSubview:_toolbar];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    _collectionView.backgroundColor = [_backgroundColor colorWithAlphaComponent:0];
}

#pragma mark - Notification of <> 通知


#pragma mark - Delegate of <LGPicturesShowCollectionViewCellDelegate> 图片点击回调
- (void)collectionViewCell:(YCPicturesBrowseCell *)cell tappedImageView:(UIImageView *)imageView {
    [self zoomOutLayout];
}
- (void)collectionViewCell:(YCPicturesBrowseCell *)cell didSwipImageWithScale:(float)scale {
    if (_toolBarContainerView.alpha) {
        _toolBarContainerView.alpha = 0;
    }
    _collectionView.backgroundColor = [_backgroundColor colorWithAlphaComponent:1 - (scale * 0.8)];
}

- (BOOL)collectionViewCell:(YCPicturesBrowseCell *)cell didEndSwipImageWithVelocity:(CGPoint)velocity {
    
    BOOL hasZoomOut = NO;
    if (velocity.y > 100) {
        [self zoomOutLayout];
        hasZoomOut = YES;
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            _collectionView.backgroundColor = _backgroundColor;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                _toolBarContainerView.alpha = 1;
            }];
        }];
    }
    return hasZoomOut;
}
- (void)collectionViewCell:(YCPicturesBrowseCell *)cell didLongPressForImage:(UIImage *)image {
    if (_delegate && [_delegate respondsToSelector:@selector(picturesBrowseView:didLongPressImageModel:)]) {
        [_delegate picturesBrowseView:self didLongPressImageModel:cell.picturesBrowseModel];
    }
}


#pragma mark - Delegate of <UICollectionViewDelegate> 回调
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self zoomOutLayout];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        CGFloat page      = scrollView.contentOffset.x / scrollView.bounds.size.width;
        int     pageIndex = page + 0.5;
        
        if (pageIndex >= 0 && pageIndex < _pictureArray.count) {
            if (pageIndex != _index) {
                _index = pageIndex;
                [self updateDisPlay];
            }
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    YCPicturesBrowseCell *displayCell = (YCPicturesBrowseCell *)cell;
    [displayCell resetScale];
}

#pragma mark - DataSource of <UICollectionViewDataSource> 数据源
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _pictureArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YCPicturesBrowseModel *showModel = _pictureArray[indexPath.row];
    YCPicturesBrowseCell  *cell      = [collectionView dequeueReusableCellWithReuseIdentifier:KCollectionViewCellId forIndexPath:indexPath];
    [cell updateDisplayWithPicturesBrowseModel:showModel];
    cell.delegate = self;
    return cell;
}

#pragma mark -

@end


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
                                        _imageView.contentMode = UIViewContentModeScaleAspectFill;
                                    }
                                    if (browseModel.pictureHDUrl) {
                                        [_imageView sd_setImageWithURL:[NSURL URLWithString:browseModel.pictureHDUrl]
                                                      placeholderImage:image ?: placeholderImage
                                                               options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                                        NSLog(@">>>>>>>>>>>>:%@", @((float)receivedSize / (float)expectedSize));
                                                               }
                                                             completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                                    if (image) {
                                                                        _imageView.contentMode = UIViewContentModeScaleAspectFill;
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
                         if (_scaleScrollView.zoomScale <= 1) {
                             _scaleScrollView.zoomScale     = MAX(scale, 2);
                             _imageView.frame               = CGRectMake(0, 0, _scaleScrollView.contentSize.width, _scaleScrollView.contentSize.height);
                             //双击放大跟谁点击位置放大
                             float pointX                   = (_scaleScrollView.contentSize.width - _scaleScrollView.bounds.size.width) * tapHorizontalScale;
                             float pointY                   = (_scaleScrollView.contentSize.height - _scaleScrollView.bounds.size.height) * tapVerticalScale;
                             _scaleScrollView.contentOffset = CGPointMake(pointX, pointY);
                         } else {
                             _scaleScrollView.zoomScale = 1;
                             _imageView.frame           = _imageViewFrame;
                         }
                     } completion:^(BOOL finished) {
                         _imageOriginFrame = _imageView.frame;
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
        float scale = (centerY / (self.bounds.size.height / 2)) - 1.2;
        
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
                _imageView.frame = _imageOriginFrame;
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
