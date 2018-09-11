//
//  YCPicturesBrowseViewLayout.h
//  RingtonesWallpapers
//
//  Created by 常兴宇 on 2018/9/6.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YCPictureShowType) {
    /** 缩小 */
    YCPictureBrowseTypeOfZoomOut,
    /** 放大 */
    YCPictureBrowseTypeOfZoomIn,
};


@interface YCPicturesBrowseViewLayout : UICollectionViewLayout

/**
 * 当前展示的索引
 */
@property(nonatomic, assign) NSInteger currentPageIndex;


/**
 * 显示类型(放大, 缩小)
 */
@property(nonatomic, assign) YCPictureShowType showType;


/**
 * collectionView的大小
 */
@property(nonatomic, assign) CGRect collectionViewBounds;


/**
 * 缩小时的frame
 */
@property(nonatomic, assign) CGRect zoomOutFrame;

@end




@interface YCPicturesLayoutAttributes : UICollectionViewLayoutAttributes

/**
 * 显示类型(放大, 缩小)
 */
@property(nonatomic, assign) YCPictureShowType showType;

@end
