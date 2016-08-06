//
//  XYHBigCollectionViewCell.h
//  XYHCollectionViewLayout
//
//  Created by Administrator on 16/8/6.
//  Copyright © 2016年 XuYouhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYHBigCollectionViewCell : UICollectionViewCell
@property (nonatomic,assign)float scanleX,scanleY;

- (void)updateBigCell:(NSDictionary *)dic;
@end
