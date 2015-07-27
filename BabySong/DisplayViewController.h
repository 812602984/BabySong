//
//  DisplayViewController.h
//  BabySong
//
//  Created by qianfeng on 15/7/2.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayModel.h"
#import "JHRefresh.h"
#import "AFNetworking.h"
#import "Define.h"
#import "UIImageView+WebCache.h"
#import "MMProgressHUD.h"

@interface DisplayViewController : UIViewController

@property (nonatomic,copy)NSString *displayUrl;
@property (nonatomic,strong)PlayModel *model;

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic)BOOL isRefreshing;
@property (nonatomic)BOOL isLoadMore;
@property (nonatomic)NSInteger currentPage;
@property (nonatomic)AFHTTPRequestOperationManager *manager;

-(void)dataInit;
-(void)loadDataWithPage:(NSInteger)page pageSize:(NSInteger)pageSize;

-(void)creatRefreshView;
-(void)endRefresh;

@end
