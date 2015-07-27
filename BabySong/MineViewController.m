//
//  MineViewController.m
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "MineViewController.h"

@interface MineViewController ()

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"更多";
    [self loadDataWithPage:0 pageSize:10];
}

-(void)loadDataWithPage:(NSInteger)page pageSize:(NSInteger)pageSize{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
