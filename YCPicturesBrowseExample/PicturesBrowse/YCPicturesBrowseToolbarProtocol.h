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

@required
//需要在这个方法中设置自己的frame
- (void)updateDisplayWithPicturesBrowseSize:(CGSize)size safeArea:(UIEdgeInsets)safeArea;

@end
