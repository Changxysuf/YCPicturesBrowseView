//
//  UIView+Extension.m
//  ChangxyPodLib_Example
//
//  Created by 常兴宇 on 2018/9/3.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (void)setYc_x:(CGFloat)yc_x {
    CGRect frame = self.frame;
    frame.origin.x = yc_x;
    self.frame = frame;
}
- (CGFloat)yc_x {
    return self.frame.origin.x;
}

- (void)setYc_y:(CGFloat)yc_y {
    CGRect frame = self.frame;
    frame.origin.y = yc_y;
    self.frame = frame;
}
- (CGFloat)yc_y {
    return self.frame.origin.y;
}

- (void)setYc_width:(CGFloat)yc_width {
    CGRect frame = self.frame;
    frame.size.width = yc_width;
    self.frame = frame;
}
- (CGFloat)yc_width {
    return self.frame.size.width;
}

- (void)setYc_height:(CGFloat)yc_height {
    CGRect frame = self.frame;
    frame.size.height = yc_height;
    self.frame = frame;
}
- (CGFloat)yc_height {
    return self.frame.size.height;
}

- (void)setYc_size:(CGSize)yc_size {
    CGRect frame = self.frame;
    frame.size = yc_size;
    self.frame = frame;
}
- (CGSize)yc_size {
    return self.frame.size;
}

- (void)setYc_origin:(CGPoint)yc_origin {
    CGRect frame = self.frame;
    frame.origin = yc_origin;
    self.frame = frame;
}
- (CGPoint)yc_origin {
    return self.frame.origin;
}

- (void)setYc_rightX:(CGFloat)yc_rightX {
    CGRect frame = self.frame;
    frame.origin.x = yc_rightX - self.frame.size.width;
    self.frame = frame;
}
- (CGFloat)yc_rightX {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setYc_bottomY:(CGFloat)yc_bottomY {
    CGRect frame = self.frame;
    frame.origin.y = yc_bottomY - self.frame.size.height;
    self.frame = frame;
}
- (CGFloat)yc_bottomY {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGSize)yc_sizeWithMaxWidth:(float)maxWidth {
    if ([self isKindOfClass:UILabel.class]) {
        CGSize size = [self sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
        size = CGSizeMake(MIN(maxWidth, size.width), size.height);
        return size;
    } else if ([self isKindOfClass:UIButton.class]) {
        UIButton *button = (UIButton *)self;
        UILabel *titleLabel = button.titleLabel;
        CGSize size = [titleLabel sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
        size = CGSizeMake(MIN(maxWidth, size.width), size.height);
        return size;
    } else if ([self isKindOfClass:UIImageView.class]) {
        UIImageView *imageView = (UIImageView *)self;
        float width = MIN(maxWidth, imageView.image.size.width);
        float height = (imageView.image.size.height / imageView.image.size.width) * width;
        return CGSizeMake(width, height);
    }
    
    return CGSizeZero;
}


@end
