//
//  DetailViewController.h
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "BaseViewController.h"
#import "DisplayViewController.h"
#import "PlayModel.h"

@interface DetailViewController : UIViewController

@property (nonatomic,copy)NSString *detailUrl;
@property (nonatomic)PlayModel *model;

@end
