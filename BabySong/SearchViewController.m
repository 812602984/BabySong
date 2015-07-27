//
//  SearchViewController.m
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "SearchViewController.h"
#import "Define.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>
#import "DetailViewController.h"

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    AFHTTPRequestOperationManager *_manager;
    AVAudioPlayer *_player;
}

@property (nonatomic)UITableView *tableView;
@property (nonatomic)BOOL isLoadMore;
@property (nonatomic)BOOL isRefreshing;
@property (nonatomic)NSMutableArray *dataArr;
@property (nonatomic,copy)NSString *searchUrl;
@property (nonatomic)NSInteger currentPage;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"搜索";
    [self dataInit];
    [self addSearchBar];
    
}

-(void)addSearchBar{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 66, kScreenSize.width, 40)];
    searchBar.delegate = self;
    searchBar.placeholder = @"请输入关键词";
    
    [self.view addSubview:searchBar];
}

#pragma mark - searchBar
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:NO];
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.dataArr removeAllObjects];
    [searchBar resignFirstResponder];
    [self creatTableView];
    [self creatRefreshView];
    
    _searchUrl = [NSString stringWithFormat:kSearchUrl,[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   [self loadDataWithPage:1 pageSize:10];
}


-(void)dataInit{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isRefreshing = self.isLoadMore = NO;
    _dataArr = [NSMutableArray array];
    _manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
}

-(void)creatTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 104,kScreenSize.width , kScreenSize.height-104) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 80;
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self hideExtraLine];
    [self.view addSubview:_tableView];
}

-(void)hideExtraLine{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
}

-(void)creatRefreshView{
    __weak typeof(self) weakSelf = self;
    
    //下拉刷新
    [_tableView addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        if (weakSelf.isRefreshing) {
            return;
        }
        weakSelf.isRefreshing = YES;
        weakSelf.currentPage = 1;
        [weakSelf loadDataWithPage:weakSelf.currentPage pageSize:10];
    }];
    
    //上拉加载更多
    [_tableView addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        if (weakSelf.isLoadMore) {
            return;
        }
        weakSelf.isLoadMore = YES;
        weakSelf.currentPage++;
        [weakSelf loadDataWithPage:weakSelf.currentPage pageSize:10];
        
    }];
}

//结束刷新
-(void)endRefresh{
    if (self.isRefreshing) {
        self.isRefreshing = NO;
        [_tableView headerEndRefreshingWithResult:JHRefreshResultSuccess];
    }
    if (self.isLoadMore) {
        self.isLoadMore = NO;
        [_tableView footerEndRefreshing];
    }
}


-(void)loadDataWithPage:(NSInteger)page pageSize:(NSInteger)pageSize{
    NSString *url = [self.searchUrl stringByAppendingString:[NSString stringWithFormat:@"page=%ld&pageSize=%ld",page,pageSize]];

    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleDrop];
    [MMProgressHUD showWithTitle:@"正在下载数据" status:@"loading..."];
    
    __weak typeof(self) weakSelf = self;
    [_manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            if (page == 1) {
                [weakSelf.dataArr removeAllObjects];
            }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray *dataList = json[@"dataList"];
            for (NSDictionary *dataDict in dataList) {
                PlayModel *model = [[PlayModel alloc] init];
                [model setValuesForKeysWithDictionary:dataDict];
                [weakSelf.dataArr addObject:model];
            }
        }
        if (weakSelf.dataArr.count == 0) {
            [MMProgressHUD dismissWithError:@"没有找到" title:@"Sorry"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"不好意思" message:@"没有找到你想要的资源" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];

        }else{
            [weakSelf.tableView reloadData];
            [MMProgressHUD dismissWithSuccess:@"数据加载成功" title:@"恭喜你"];
        }
        [weakSelf endRefresh];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf endRefresh];
        [MMProgressHUD dismissWithError:@"加载失败" title:@"警告"];
    }];
}


#pragma mark - tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PlayModel *model = _dataArr[indexPath.row];
    
    static NSString *cellId = @"displayCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //修改cell的imageView的宽和高
    CGSize imageSize = CGSizeMake(60, 60);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.coverSmall]]];   //比较耗时，应在子线程中操作,目前未解决
    [image drawInRect:imageRect];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.imageView.image = image;
    
    //[cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.coverSmall] placeholderImage:[UIImage imageNamed:@"default.png"]];
    
    cell.textLabel.text = model.title;
    cell.textLabel.font = [UIFont fontWithName:nil size:14];
    cell.textLabel.numberOfLines = 0;
    
    if(model.duration){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"时长:%.2fs",model.duration];
    }
    if (model.size != nil) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"章节:%@",model.size];
    }
    cell.detailTextLabel.textColor = [UIColor purpleColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PlayModel *model = _dataArr[indexPath.row];

    DetailViewController *detailVc = [[DetailViewController alloc] init];
    NSString *url = [NSString stringWithFormat:kDetailUrl,model.id];
    detailVc.detailUrl = url;
    detailVc.model = model;
    detailVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVc animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
