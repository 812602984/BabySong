//
//  MyTabViewController.m
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.

#import "MyTabViewController.h"
#import "BaseViewController.h"

@interface MyTabViewController ()

@end

@implementation MyTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatViewControllers];
}

#pragma mark - 创建tabBar的子视图控制器
-(void)creatViewControllers{
    NSArray *vcNameArr = @[@"HomeViewController",@"SortViewController",@"SearchViewController"];
    NSArray *titlesArr = @[@"首页",@"儿歌库",@"搜索"];
    
    NSMutableArray *vcArr = [NSMutableArray array];
    
    for (NSInteger i=0; i<vcNameArr.count; i++) {
        Class vcCls = NSClassFromString(vcNameArr[i]);
        BaseViewController *vc = [[vcCls alloc] init];

        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.tabBarItem.image = [[UIImage imageNamed:[NSString stringWithFormat:@"tab_%ld.png",i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        nav.tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"tab_selected_%ld.png",i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        if (i==2) {
            nav.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
        }
        nav.tabBarItem.title = titlesArr[i];
        [vcArr addObject:nav];
    }
    self.viewControllers = vcArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
