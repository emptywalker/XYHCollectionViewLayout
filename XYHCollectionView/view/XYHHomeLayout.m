//
//  XYHHomeLayout.m
//  XYHCollectionViewLayout
//
//  Created by Administrator on 16/8/6.
//  Copyright © 2016年 XuYouhong. All rights reserved.
//

#import "XYHHomeLayout.h"

static float lastOffset = 0.0f;

#define getCellHeight(width) (900 / 600.0 * width)

#define getCellWidth(height) (600 * height / 900.0)
#define SCR_WIDTH  [UIScreen mainScreen].bounds.size.width

@implementation XYHHomeLayout
- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}
/**
 *只要显示的边界发生改变就重新布局：内部就会重新调用prepareLayout和layoutAttributesForElementsInRect方法获得所有cell的布局属性
 */

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

/**
 *实现一些初始化工作
 */
- (void)prepareLayout{
    lastOffset = self.collectionView.contentOffset.x;
    //    设置每一个cell的尺寸
    float itemWidth = SCR_WIDTH - 134;
    //设置每一个cell的尺寸
    self.itemSize = CGSizeMake(itemWidth, getCellHeight(itemWidth));
    self.minimumLineSpacing = 38;
    
    //滑动方向
    [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    CGFloat inset = (self.collectionView.bounds.size.width - itemWidth) / 2.0;
    
    //把item的左右边切掉,让item处在屏幕中间位置
    //  UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
    
}
/**
 * 所有item的布局属性
 */

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    //计算可见的矩形框
    CGRect visiableRect;
    visiableRect.size = self.collectionView.frame.size;
    visiableRect.origin = self.collectionView.contentOffset;
    //1.取得cell原来的UICollectionViewLayoutAttributes
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    //屏幕中间的X
    CGFloat screenCenterX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width/2.0;
    //2.遍历所有的布局属性
    [array enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(visiableRect, obj.frame)) {
            //每个item的centerX
            CGFloat itemCenterX = obj.center.x;
            //差距越小，缩放越大
            //计算缩放比例
            CGFloat scale = 1 + 0.25 * (1 - ABS(itemCenterX - screenCenterX) / (self.collectionView.bounds.size.width/2));
            obj.transform3D = CATransform3DMakeScale(scale, scale, 1);
        }
    }];
    return array;
}
/**
 *用来设置collectionView停止滚动的那一刻的位置
 proposedContentOffset: collectionView停止滚动的位置
 velocity : 滚动速度
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    
    // 判断是否为第一个
    if (proposedContentOffset.x<self.collectionView.bounds.size.width/2) {
        return CGPointZero;
    }
    // 判断是否为最后一个
    if (proposedContentOffset.x>self.collectionViewContentSize.width-SCR_WIDTH*1.5+self.sectionInset.right) {
        return CGPointMake(self.collectionViewContentSize.width-SCR_WIDTH, 0);
    }
    //1.获取collectionView最后停留的范围
    CGRect lastRect;
    lastRect.origin = proposedContentOffset;
    lastRect.size = self.collectionView.frame.size;
    //2.取出这个范围类所有布局属性
    NSArray *array = [self layoutAttributesForElementsInRect:lastRect];
    //3.遍历所有布局的属性
    //停止滑动时item应该在的位置
    __block CGFloat adjustOffsetX = MAXFLOAT;
    //屏幕中间的X
    CGFloat screenCenterX = proposedContentOffset.x + self.collectionView.bounds.size.width/2.0;
    [array enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (ABS(obj.center.x - screenCenterX) < ABS(adjustOffsetX)) {
            adjustOffsetX = obj.center.x - screenCenterX;
        }
    }];
    return CGPointMake(proposedContentOffset.x + adjustOffsetX, proposedContentOffset.y);
}

@end
