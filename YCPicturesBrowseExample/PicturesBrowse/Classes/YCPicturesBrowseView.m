//
//  YCPicturesBrowseView.m
//  RingtonesWallpapers
//
//  Created by 常兴宇 on 2018/9/6.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

#import "YCPicturesBrowseView.h"
#import "YCPicturesBrowseCell.h"


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
    BOOL _didCreateSubViews;
    
    //图片model的数组
    NSArray     *_pictureArray;
    
    UICollectionView            *_collectionView;
    YCPicturesBrowseViewLayout  *_collectionViewLayout;
    
    YCPictureShowType _pictureShowType;
    
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
    [self updateToolBar];
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
- (void)createSubViews {
    if (_didCreateSubViews) {
        return;
    }
    if (!_backgroundColor) {
        _backgroundColor = [UIColor colorWithRed:26.0 / 255.0 green:26.0 / 255.0 blue:26.0 / 255.0 alpha:1];
    }

    _collectionViewLayout = [[YCPicturesBrowseViewLayout alloc] init];
    _collectionViewLayout.showType = _pictureShowType;
    _collectionViewLayout.currentPageIndex = _index;

    _collectionView                                = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
    _collectionView.showsVerticalScrollIndicator   = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor                = [_backgroundColor colorWithAlphaComponent:0];
    _collectionView.delegate                       = self;
    _collectionView.dataSource                     = self;
    _collectionView.pagingEnabled                  = YES;
    _collectionView.contentInset                   = UIEdgeInsetsZero;
    [_collectionView registerClass:[YCPicturesBrowseCell class] forCellWithReuseIdentifier:KCollectionViewCellId];
    [self addSubview:_collectionView];
    
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _didCreateSubViews = YES;
}
- (void)configCollectionInitialStateWithFromeView:(UIView *)fromView {
    _collectionView.frame = self.bounds;
    _collectionView.contentOffset = CGPointMake(_index * _collectionView.bounds.size.width, 0);
    _collectionViewLayout.collectionViewBounds = self.bounds;
    
    //默认
    CGRect zoomOutFrame = CGRectMake(self.bounds.size.width / 2, self.bounds.size.height / 2, 0, 0);
    if (fromView) {
        zoomOutFrame = [fromView convertRect:fromView.bounds toView:[UIApplication sharedApplication].keyWindow];
    }
    _collectionViewLayout.zoomOutFrame = zoomOutFrame;
}

// 更新视图(主要是更新pageview)
- (void)updateToolBar {
    if (!self.toolbar) {
        return;
    }
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
    if ([self.toolbar respondsToSelector:@selector(frameForToolbarWithPicturesBrowseSize:safeArea:)]) {
        UIEdgeInsets insets = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            insets = self.superview.safeAreaInsets;
        }
        _toolBarContainerView.frame = [self.toolbar frameForToolbarWithPicturesBrowseSize:_collectionView.bounds.size safeArea:insets];
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
    if (_pictureShowType == YCPictureBrowseTypeOfZoomOut && self.dataSource && [self.dataSource respondsToSelector:@selector(picturesBrowseView:targetViewAtIndex:)]) {
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
                         self->_collectionView.backgroundColor = self->_backgroundColor;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 animations:^{
                             self->_toolBarContainerView.alpha = 1;
                         }];
                     }];
    [self updateCollectionLayoutCompletion:^(BOOL complete) {
        if (self->_delegate && [self->_delegate respondsToSelector:@selector(picturesBrowseView:didChangeToShowType:)]) {
            [self->_delegate picturesBrowseView:self didChangeToShowType:self->_pictureShowType];
        }
    }];
}
//缩小
- (void)zoomOutLayout {
    _pictureShowType = YCPictureBrowseTypeOfZoomOut;
    _toolBarContainerView.hidden = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(picturesBrowseView:willChangeToShowType:)]) {
        [_delegate picturesBrowseView:self willChangeToShowType:_pictureShowType];
    }

    [UIView animateWithDuration:0.2 animations:^{
        self->_collectionView.backgroundColor = [self->_backgroundColor colorWithAlphaComponent:0];
    }];
    [self updateCollectionLayoutCompletion:^(BOOL complete) {
        if (self->_delegate && [self->_delegate respondsToSelector:@selector(picturesBrowseView:didChangeToShowType:)]) {
            [self->_delegate picturesBrowseView:self didChangeToShowType:self->_pictureShowType];
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
            [self->_collectionView performBatchUpdates:^{
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
    if (_delegate && [_delegate respondsToSelector:@selector(picturesBrowseView:swipingImageWithScale:)]) {
        [_delegate picturesBrowseView:self swipingImageWithScale:scale];
    }
}

- (BOOL)collectionViewCell:(YCPicturesBrowseCell *)cell didEndSwipImageWithVelocity:(CGPoint)velocity {
    
    BOOL hasZoomOut = NO;
    if (velocity.y > 100) {
        [self zoomOutLayout];
        hasZoomOut = YES;
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self->_collectionView.backgroundColor = self->_backgroundColor;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                self->_toolBarContainerView.alpha = 1;
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
- (void)collectionViewCellWillSwipImage {
    if (_delegate && [_delegate respondsToSelector:@selector(picturesBrowseView:willSwipImageAtIndex:)]) {
        [_delegate picturesBrowseView:self willSwipImageAtIndex:_index];
    }
}

#pragma mark - Delegate of <UICollectionViewDelegate> 回调
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        if (self.toolbar && [self.toolbar respondsToSelector:@selector(updateContentOffset:forScrollView:)]) {
            [self.toolbar updateContentOffset:scrollView.contentOffset forScrollView:scrollView];
        }
    }
}
             
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView != _collectionView) {
        return;
    }

    CGFloat pageWidth = scrollView.frame.size.width;
    CGPoint point = *targetContentOffset;
    _index = floor((point.x - pageWidth / 2) / pageWidth) + 1;
    [self updateToolBar];
    if (_delegate && [_delegate respondsToSelector:@selector(picturesBrowseView:didScrollToIndex:)]) {
        [_delegate picturesBrowseView:self didScrollToIndex:_index];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self zoomOutLayout];
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
