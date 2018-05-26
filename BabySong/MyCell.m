//  MyCell.m
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "MyCell.h"
#import "UIImageView+WebCache.h"

@implementation MyCell
{
    UIImageView *_imageView;
    UILabel *_label;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self creatViewWithFrame:frame];
    }
    return self;
}

-(void)creatViewWithFrame:(CGRect)frame{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, frame.size.width, frame.size.height-25)];
    [self.contentView addSubview:_imageView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, _imageView.frame.size.height, frame.size.width, 25)];
    _label.numberOfLines = 1;
    _label.font = [UIFont systemFontOfSize:13];
    
    [self.contentView addSubview:_label];
}

//填充cell
-(void)showDataWithModel:(PlayModel *)model{
    [_imageView sd_setImageWithURL:[NSURL URLWithString:model.coverLarge]];
    _label.text = model.title;
}

-(void)showCellWithModel:(PlayModel *)model{
    [_imageView sd_setImageWithURL:[NSURL URLWithString:model.cover]];
    _label.text = model.name;
}

@end
