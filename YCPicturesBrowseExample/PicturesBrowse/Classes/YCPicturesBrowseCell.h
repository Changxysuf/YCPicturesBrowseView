//
//  YCPicturesBrowseCell.h
//  YCPicturesBrowseExample
//
//  Created by 常兴宇 on 2018/9/18.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YCPicturesBrowseCell;
@class YCPicturesBrowseModel;

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

- (void)collectionViewCellWillSwipImage;

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

