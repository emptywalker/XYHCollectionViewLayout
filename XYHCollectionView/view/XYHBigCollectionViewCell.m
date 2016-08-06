//
//  XYHBigCollectionViewCell.m
//  XYHCollectionViewLayout
//
//  Created by Administrator on 16/8/6.
//  Copyright © 2016年 XuYouhong. All rights reserved.
//

#import "XYHBigCollectionViewCell.h"

@interface XYHBigCollectionViewCell ()
@property (nonatomic, strong)UILabel *textLabel;
@property (nonatomic, strong)UIImageView *imageView;

@end
@implementation XYHBigCollectionViewCell
#pragma mark --init
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2.5);
        self.layer.shadowOpacity = 0.75;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.imageView];
    }
    return self;
}
#pragma mark --public Method

- (void)updateBigCell:(NSDictionary *)dic{
    
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:dic[@"image"]]]];
}

#pragma mark --getter/setter

- (UIImageView *)imageView{
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"960_2"]];
        _imageView.frame = CGRectMake(5, 5, self.bounds.size.width - 10, self.bounds.size.height - 10);
    }
    return _imageView;
}
@end
