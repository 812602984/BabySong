//
//  PlayModel.h
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "MyModel.h"

@interface PlayModel : MyModel

@property (nonatomic)float duration;
@property (nonatomic,copy)NSString *playUrl32;
@property (nonatomic,copy)NSString *playUrl64;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *cover;

@end
