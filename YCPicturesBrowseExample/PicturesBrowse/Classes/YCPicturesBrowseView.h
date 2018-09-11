//
//  YCPicturesBrowseView.h
//  RingtonesWallpapers
//
//  Created by 常兴宇 on 2018/9/6.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCPicturesBrowseToolbarProtocol.h"
#import "YCPicturesBrowseViewLayout.h"

@class YCPicturesBrowseView;
@class YCPicturesBrowseCell;

@interface YCPicturesBrowseModel : NSObject

/**
 * 缩略图Url
 */
@property(nonatomic, copy) NSString *pictureThumbUrl;

/**
 * 高清图的url
 */
@property (nonatomic, copy) NSString *pictureHDUrl;

/**
 * 图片的标题
 */
@property(nonatomic, copy) NSString *pictureTitle;

/**
 * 图片的描述
 */
@property(nonatomic, copy) NSString *pictureContent;

/**
 * placeholder图片
 */
@property(nonatomic, strong) UIImage *placeholderImage;

@end






@protocol YCPicturesBrowseViewDelegate <NSObject>

@optional
- (void)picturesBrowseView:(YCPicturesBrowseView *)picturesBrowseView willChangeToShowType:(YCPictureShowType)showType;
- (void)picturesBrowseView:(YCPicturesBrowseView *)picturesBrowseView didChangeToShowType:(YCPictureShowType)showType;
- (void)picturesBrowseView:(YCPicturesBrowseView *)picturesBrowseView didLongPressImageModel:(YCPicturesBrowseModel *)picturesBrowseModel;

@end

@protocol YCPicturesBrowseViewDataScource <NSObject>

@optional
- (UIView *)picturesBrowseView:(YCPicturesBrowseView *)picturesBrowseView targetViewAtIndex:(NSInteger)index;

@end


#pragma mark -
#pragma mark - YCPicturesBrowseView

@interface YCPicturesBrowseView : UIView

@property (nonatomic, weak) id <YCPicturesBrowseViewDelegate> delegate;
@property (nonatomic, weak) id <YCPicturesBrowseViewDataScource> dataSource;


/** 页码的view 在整个视图的最底部 */
@property (nonatomic) UIView<YCPicturesBrowseToolbarProtocol> * toolbar;

@property (nonatomic, strong) UIColor *backgroundColor;

+ (instancetype)browseViewPictureArray:(NSArray<YCPicturesBrowseModel *> *)pictureArray
                                 index:(NSInteger)index;

/**
 初始化方法
 
 @param pictureArray 图片数组(数组元素类型: YCPicturesShowModel)
 @param index        当前要展示的图片的索引
 
 @return 实例
 */
- (instancetype)initWithPictureArray:(NSArray<YCPicturesBrowseModel *> *)pictureArray
                               index:(NSInteger)index
                     backgroundColor:(UIColor *)backgroundColor;

- (void)showOnView:(UIView *)basicView fromView:(UIView *)fromView animation:(BOOL)animation;

- (void)showOnViewKeyWindowFromView:(UIView *)fromView animation:(BOOL)animation;


@end






#pragma mark -
#pragma mark - YCPicturesBrowseCollectionViewCellDelegate
/**
 * 图片展示cell的代理
 */
@protocol YCPicturesBrowseCellDelegate<NSObject>

/**
 点击图片的回调
 
 @param cell      cell
 @param imageView 点击的ImageView
 */
- (void)collectionViewCell:(YCPicturesBrowseCell *)cell tappedImageView:(UIImageView *)imageView;

- (void)collectionViewCell:(YCPicturesBrowseCell *)cell didSwipImageWithScale:(float)scale;

- (BOOL)collectionViewCell:(YCPicturesBrowseCell *)cell didEndSwipImageWithVelocity:(CGPoint)velocity;

- (void)collectionViewCell:(YCPicturesBrowseCell *)cell didLongPressForImage:(UIImage *)image;

@end


#pragma mark -
#pragma mark - YCPicturesShowCollectionViewCell
/**
 * 图片展示的cell
 */
@interface YCPicturesBrowseCell : UICollectionViewCell


@property(nonatomic, weak) id<YCPicturesBrowseCellDelegate> delegate;

@property (nonatomic, strong) YCPicturesBrowseModel *picturesBrowseModel;

/**
 * 重置比例(当滑动图片的时候把scrollView的比例重置)
 */
- (void)resetScale;


/**
 更新显示
 
 @param browseModel YCPicturesBrowseModel
 */
- (void)updateDisplayWithPicturesBrowseModel:(YCPicturesBrowseModel *)browseModel;

@end

