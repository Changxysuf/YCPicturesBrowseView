//
//  ViewController.m
//  Example
//
//  Created by 常兴宇 on 2018/9/11.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

#import "ViewController.h"
#import "YCPicturesBrowseView.h"
#import <UIImageView+WebCache.h>
#import "UIView+Extension.h"
#import "TestToolBar.h"

@interface ViewController ()<YCPicturesBrowseViewDelegate, YCPicturesBrowseViewDataScource>

@end

@implementation ViewController {
    NSMutableArray *_resultArray;
    NSMutableArray *_imageViewArray;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor blackColor];
    NSArray *array = @[@"http://a.hiphotos.baidu.com/image/h%3D300/sign=381f7e282b9759ee555066cb82fa434e/0dd7912397dda1449dd17697bfb7d0a20cf4863e.jpg",
                       @"http://f.hiphotos.baidu.com/image/h%3D300/sign=4d7d010c4c34970a5873162fa5cbd1c0/d043ad4bd11373f067aca6bca90f4bfbfbed0406.jpg",
                       @"http://d.hiphotos.baidu.com/image/h%3D300/sign=7c44c70b723e6709a10043ff0bc69fb8/faedab64034f78f02cf4a1df74310a55b3191c1a.jpg",
                       @"http://g.hiphotos.baidu.com/image/h%3D300/sign=187605ea9d5298221a333fc3e7ca7b3b/77094b36acaf2eddfd9970c4801001e9390193b6.jpg",
                       @"http://e.hiphotos.baidu.com/image/pic/item/f9dcd100baa1cd11c6724309b412c8fcc2ce2dd6.jpg",
                       @"http://f.hiphotos.baidu.com/image/pic/item/203fb80e7bec54e7538a2132b4389b504fc26ab3.jpg",
                       @"http://f.hiphotos.baidu.com/image/pic/item/54fbb2fb43166d22b2e30eb14b2309f79052d27b.jpg",
                       @"http://e.hiphotos.baidu.com/image/pic/item/5243fbf2b2119313e455ce9968380cd791238d80.jpg",
                       @"https://cdn.pixabay.com/photo/2018/09/01/04/15/boy-3646046__480.jpg",
                       @"https://cdn.pixabay.com/photo/2015/09/05/20/07/log-924958__480.jpg",
                       @"https://cdn.pixabay.com/photo/2017/03/29/11/45/dunes-2184976__480.jpg",
                       @"https://cdn.pixabay.com/photo/2018/08/31/19/16/fan-3645379__480.jpg",
                       @"https://wx1.sinaimg.cn/mw690/aa27cfb9gy1fveot8si8dj20gf28z45e.jpg"];
    
    NSArray *hdUrlArray = @[@"http://a.hiphotos.baidu.com/image/h%3D300/sign=381f7e282b9759ee555066cb82fa434e/0dd7912397dda1449dd17697bfb7d0a20cf4863e.jpg",
                            @"http://f.hiphotos.baidu.com/image/h%3D300/sign=4d7d010c4c34970a5873162fa5cbd1c0/d043ad4bd11373f067aca6bca90f4bfbfbed0406.jpg",
                            @"http://d.hiphotos.baidu.com/image/h%3D300/sign=7c44c70b723e6709a10043ff0bc69fb8/faedab64034f78f02cf4a1df74310a55b3191c1a.jpg",
                            @"http://g.hiphotos.baidu.com/image/h%3D300/sign=187605ea9d5298221a333fc3e7ca7b3b/77094b36acaf2eddfd9970c4801001e9390193b6.jpg",
                            @"http://e.hiphotos.baidu.com/image/pic/item/f9dcd100baa1cd11c6724309b412c8fcc2ce2dd6.jpg",
                            @"http://f.hiphotos.baidu.com/image/pic/item/203fb80e7bec54e7538a2132b4389b504fc26ab3.jpg",
                            @"http://f.hiphotos.baidu.com/image/pic/item/54fbb2fb43166d22b2e30eb14b2309f79052d27b.jpg",
                            @"http://e.hiphotos.baidu.com/image/pic/item/5243fbf2b2119313e455ce9968380cd791238d80.jpg",
                            @"https://cdn.pixabay.com/photo/2018/09/01/04/15/boy-3646046_1280.jpg",
                            @"https://cdn.pixabay.com/photo/2015/09/05/20/07/log-924958_1280.jpg",
                            @"https://cdn.pixabay.com/photo/2017/03/29/11/45/dunes-2184976_1280.jpg",
                            @"https://cdn.pixabay.com/photo/2018/08/31/19/16/fan-3645379_1280.jpg",
                            @"https://wx1.sinaimg.cn/mw690/aa27cfb9gy1fveot8si8dj20gf28z45e.jpg"];
    
    _resultArray = [NSMutableArray array];
    _imageViewArray = [NSMutableArray array];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.yc_width, self.view.yc_height - 100)];
    [self.view addSubview:containerView];
    
    NSInteger numberOfLine = 3;
    float gap = 8;
    float width = (self.view.yc_width - (numberOfLine + 1) * gap) / numberOfLine;
    UIImageView *tempImageView = nil;
    int i = 0;
    for (NSString *string in array) {
        YCPicturesBrowseModel *model = [YCPicturesBrowseModel new];
        model.pictureThumbUrl = string;//[string stringByAppendingString:@"1"];
        model.pictureHDUrl = hdUrlArray[i];
        //        model.placeholderImage = MacroImageNamed(@"icon_setting_wallpaper");
        model.pictureTitle = @"title";
        model.pictureContent = [NSString stringWithFormat:@"%@", @(i)];
        [_resultArray addObject:model];
        
        float originX = tempImageView ? tempImageView.yc_rightX + gap : gap;
        
        float originY = tempImageView ? tempImageView.yc_y : gap;
        
        if (tempImageView.yc_rightX + gap + gap > self.view.yc_width) {
            originX = gap;
            originY = tempImageView.yc_bottomY + gap;
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, originY, width, width)];
        imageView.userInteractionEnabled = YES;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [containerView addSubview:imageView];
        [imageView sd_setImageWithURL:[NSURL URLWithString:string] placeholderImage:[UIImage imageNamed:@"yc_image_placeholder@2x.png"]];
        [_imageViewArray addObject:imageView];
        tempImageView = imageView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [imageView addGestureRecognizer:tap];
        i ++;
    }

}
- (void)tapped:(UITapGestureRecognizer *)recognizer {
    
    
    UIView *tapView = recognizer.view;
    NSInteger index = [_imageViewArray indexOfObject:tapView];
    
    
    
    TestToolBar *toolBar = [[TestToolBar alloc] init];
    
    
    
    YCPicturesBrowseView *pictureBrowseView = [YCPicturesBrowseView browseViewPictureArray:_resultArray index:index];
    pictureBrowseView.delegate = self;
    pictureBrowseView.dataSource = self;
    pictureBrowseView.toolbar = toolBar;
    [pictureBrowseView showOnViewKeyWindowFromView:tapView animation:YES];
}


- (void)picturesBrowseView:(YCPicturesBrowseView *)picturesBrowseView didLongPressImageModel:(YCPicturesBrowseModel *)picturesBrowseModel {
    NSLog(@"didLongPressImageModel:%@", picturesBrowseModel);
}
- (void)picturesBrowseView:(YCPicturesBrowseView *)picturesBrowseView willChangeToShowType:(YCPictureShowType)showType {
    NSLog(@"willChangeToShowType:%@", @(showType));
}
- (void)picturesBrowseView:(YCPicturesBrowseView *)picturesBrowseView didChangeToShowType:(YCPictureShowType)showType {
    NSLog(@"didChangeToShowType:%@", @(showType));
}
- (void)picturesBrowseView:(YCPicturesBrowseView *)picturesBrowseView didSwipImageWithScale:(float)scale {
    
}
- (void)picturesBrowseView:(YCPicturesBrowseView *)picturesBrowseView willSwipImageAtIndex:(NSInteger)index {
    
}
- (UIView *)picturesBrowseView:(YCPicturesBrowseView *)picturesBrowseView targetViewAtIndex:(NSInteger)index {
    return _imageViewArray[index];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
