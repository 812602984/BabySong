//
//  MyCell.h
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayModel.h"

@interface MyCell : UICollectionViewCell

-(void)showDataWithModel:(PlayModel *)model;
-(void)showCellWithModel:(PlayModel *)model;

@end
