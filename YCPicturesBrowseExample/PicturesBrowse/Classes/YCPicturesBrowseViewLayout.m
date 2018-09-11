//
//  YCPicturesBrowseViewLayout.m
//  RingtonesWallpapers
//
//  Created by 常兴宇 on 2018/9/6.
//  Copyright © 2018年 常兴宇. All rights reserved.
//

#import "YCPicturesBrowseViewLayout.h"

@implementation YCPicturesBrowseViewLayout {
    NSMutableArray *_attributesArray;
}

- (void)prepareLayout {
    [super prepareLayout];
    _attributesArray = [NSMutableArray array];
    NSInteger count  = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        NSIndexPath *               indexPath  = [NSIndexPath indexPathForRow:i inSection:0];
        YCPicturesLayoutAttributes *attributes = (YCPicturesLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:indexPath];
        [_attributesArray addObject:attributes];
    }
}

- (CGSize)collectionViewContentSize {
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    CGSize    size  = CGSizeMake(_collectionViewBounds.size.width * count, _collectionViewBounds.size.height);
    return size;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return _attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    YCPicturesLayoutAttributes *attributes = [YCPicturesLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    if (_showType == YCPictureBrowseTypeOfZoomIn) { //放大
        attributes.frame = CGRectMake(_collectionViewBounds.size.width * indexPath.row, 0, _collectionViewBounds.size.width, _collectionViewBounds.size.height);
    } else if (_showType == YCPictureBrowseTypeOfZoomOut) { //缩小
        if (indexPath.row == _currentPageIndex) {
            attributes.frame = CGRectMake(indexPath.row * _collectionViewBounds.size.width + _zoomOutFrame.origin.x, _zoomOutFrame.origin.y, _zoomOutFrame.size.width, _zoomOutFrame.size.height);
            
        } else {
            attributes.frame = CGRectMake(_collectionViewBounds.size.width * indexPath.row, 0, _collectionViewBounds.size.width, _collectionViewBounds.size.height);
        }
    }
    attributes.showType = _showType;
    
    return attributes;
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}



@end




@implementation YCPicturesLayoutAttributes

- (id)copyWithZone:(NSZone *)zone {
    YCPicturesLayoutAttributes *attributes = [super copyWithZone:zone];
    attributes.showType                    = self.showType;
    return attributes;
}
- (BOOL)isEqual:(id)object {
    YCPicturesLayoutAttributes *attributes = (YCPicturesLayoutAttributes *)object;
    if (self.showType == attributes.showType) {
        return [super isEqual:object];
    }
    return NO;
}
@end
