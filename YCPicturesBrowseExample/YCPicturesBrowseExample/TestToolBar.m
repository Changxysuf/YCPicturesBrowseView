//
//  TestToolBar.m
//  YCPicturesBrowseExample
//
//  Created by 常兴宇 on 2018/9/19.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

#import "TestToolBar.h"

@implementation TestToolBar {
    UILabel *_label;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        
        _label = [UILabel new];
        _label.backgroundColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:20];
        [self addSubview:_label];
    }
    return self;
}

- (void)setPictureTitle:(NSString *)pictureTitle {
//    NSLog(@"%s--->:%@", __func__, pictureTitle);
}
- (void)setPictureDesc:(NSString *)pictureDesc {
//    NSLog(@"%s--->:%@", __func__, pictureDesc);
}
- (void)setCurrentPage:(NSInteger)currentPage totalPage:(NSInteger)totalPage {
    NSLog(@"%s--->:%@  %@", __func__, @(currentPage), @(totalPage));
    _label.text = [NSString stringWithFormat:@"%@", @(currentPage)];
    [_label sizeToFit];
    _label.frame = CGRectMake((self.bounds.size.width - _label.bounds.size.width) / 2, 50, _label.bounds.size.width, 50);
}
- (void)updatePictureBrowseModel:(YCPicturesBrowseModel *)browseModel {
    NSLog(@"%s--->:%@", __func__, browseModel);
}
- (void)updateContentOffset:(CGPoint)offset forScrollView:(UIScrollView *)scrollView {
    NSLog(@"%@--->:%@ :%@", @">>>", @(offset), @"MMMMMM");
}



//需要在这个方法中设置自己的frame
- (CGRect)frameForToolbarWithPicturesBrowseSize:(CGSize)size safeArea:(UIEdgeInsets)safeArea {
    _label.frame = CGRectMake((size.width - _label.bounds.size.width) / 2, 50, _label.bounds.size.width, 50);

    return CGRectMake(0, 0, size.width, 100);
}

@end
