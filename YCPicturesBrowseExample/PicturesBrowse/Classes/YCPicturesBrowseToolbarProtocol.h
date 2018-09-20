//
//  YCPicturesBrowseToolbarProtocol.h
//  RingtonesWallpapers
//
//  Created by 常兴宇 on 2018/9/6.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

@class YCPicturesBrowseModel;

@protocol YCPicturesBrowseToolbarProtocol <NSObject>

@optional
- (void)setPictureTitle:(NSString *)pictureTitle;
- (void)setPictureDesc:(NSString *)pictureDesc;
- (void)setCurrentPage:(NSInteger)currentPage totalPage:(NSInteger)totalPage;
- (void)updatePictureBrowseModel:(YCPicturesBrowseModel *)browseModel;
- (void)updateContentOffset:(CGPoint)offset forScrollView:(UIScrollView *)scrollView;

@required
//需要在这个方法中返回自己的frame
- (CGRect)frameForToolbarWithPicturesBrowseSize:(CGSize)size safeArea:(UIEdgeInsets)safeArea;

@end
