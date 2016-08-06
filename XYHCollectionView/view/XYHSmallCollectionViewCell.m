//
//  XYHSmallCollectionViewCell.m
//  XYHCollectionViewLayout
//
//  Created by Administrator on 16/8/6.
//  Copyright © 2016年 XuYouhong. All rights reserved.
//

#import "XYHSmallCollectionViewCell.h"

@interface XYHSmallCollectionViewCell ()
@property (nonatomic, strong)UILabel *textLabel;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UIImageView *hotCityTag;//热门城市标签
@end

@implementation XYHSmallCollectionViewCell
#pragma mark --init
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        
        //阴影
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity =  0.7;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        [self addSubview:self.imageView];
    }
    return self;
}

#pragma mark --public Method

- (void)updateSmallCell:(NSDictionary *)dic{
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:dic[@"cardImage"]]]];
}

#pragma mark --getter/setter
- (UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _textLabel.font = [UIFont systemFontOfSize:100];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _textLabel;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"960_3"]];
        _imageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        _imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _imageView.layer.borderWidth = 5;
    }
    return _imageView;
}

- (UIImageView *)hotCityTag{
    if (!_hotCityTag) {
        _hotCityTag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hotCityLabel"]];
        _hotCityTag.frame = CGRectMake(0, 0, 40, 40);
        _hotCityTag.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _hotCityTag;
}
@end
