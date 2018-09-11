//
//  UIView+Extension.h
//  ChangxyPodLib_Example
//
//  Created by 常兴宇 on 2018/9/3.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

@property (assign, nonatomic) CGFloat yc_x;
@property (assign, nonatomic) CGFloat yc_y;
@property (assign, nonatomic) CGFloat yc_width;
@property (assign, nonatomic) CGFloat yc_height;
@property (assign, nonatomic) CGSize yc_size;
@property (assign, nonatomic) CGPoint yc_origin;

@property (assign, nonatomic, readonly) CGFloat yc_rightX;
@property (assign, nonatomic, readonly) CGFloat yc_bottomY;

/*
 * 控件的size
 * 通过给定的最大宽度限制获取控件的size
 * 支持 UILabel / UIButton / UIImageView
 */
- (CGSize)yc_sizeWithMaxWidth:(float)maxWidth;


@end
