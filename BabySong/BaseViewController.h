//
//  BaseViewController.h
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic,copy)NSString *pid;
@property (nonatomic,copy)NSString *url;

-(void)loadDataWithPage:(NSInteger)page pageSize:(NSInteger)pageSize;


@end
