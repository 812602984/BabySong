//
//  BaseViewController.m
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "BaseViewController.h"
#import "AFNetworking.h"
#import "JHRefresh.h"
#import "PlayModel.h"
#import "HomeViewController.h"
#import "SortViewController.h"
#import "DetailViewController.h"
#import "Define.h"
#import "MyCell.h"
#import "DisplayViewController.h"

@interface BaseViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    AFHTTPRequestOperationManager *_manager;
    NSInteger _flag;
}

@property (nonatomic)UICollectionView *collectionView;
@property (nonatomic)NSMutableArray *dataArr;
@property (nonatomic)BOOL isLoadMore;
@property (nonatomic)BOOL isRefreshing;
@property (nonatomic)NSInteger currentPage;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self dataInit];
    [self creatCollectionView];
    [self creatRefreshView];
    [self loadDataWithPage:1 pageSize:10];
}

#pragma mark - 数据初始化
-(void)dataInit{
    self.isLoadMore = self.isRefreshing = NO;
    _currentPage = 1;
    _dataArr = [NSMutableArray array];
    _manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _flag = [self classType];
}

-(void)creatCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    if(_flag == 0){
        layout.itemSize = CGSizeMake(kScreenSize.width/3.0-7, 120);
        layout.sectionInset = UIEdgeInsetsMake(3, 5, 3, 5);
        layout.minimumLineSpacing = 2;
        layout.minimumInteritemSpacing = 2;
    }
    else{
        layout.itemSize = CGSizeMake(kScreenSize.width/2.0-30, 180);
        layout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);
        layout.minimumLineSpacing = 2;
        layout.minimumInteritemSpacing = 2;
    }
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
   
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, kScreenSize.height-64-49) collectionViewLayout: layout] ;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[MyCell class] forCellWithReuseIdentifier:@"MyCell"];
    [self.view addSubview:self.collectionView];
}

-(void)creatRefreshView{
    __weak typeof(self) weakSelf = self;
    
    //下拉刷新
    [_collectionView addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        if (weakSelf.isRefreshing) {
            return;
        }
        weakSelf.isRefreshing = YES;
        weakSelf.currentPage = 1;
        [weakSelf loadDataWithPage:weakSelf.currentPage pageSize:10];
    }];
    
    //上拉加载更多
    [_collectionView addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
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
        [_collectionView headerEndRefreshingWithResult:JHRefreshResultSuccess];
    }
    if (self.isLoadMore) {
        self.isLoadMore = NO;
        [_collectionView footerEndRefreshing];
    }
}

-(NSInteger)classType{
    if ([self isMemberOfClass:[HomeViewController class]]) {
        return 0;
    }
    if ([self isMemberOfClass:[SortViewController class]]) {
        return 1;
    }
    if([self isMemberOfClass:[DetailViewController class]]){
        return 2;
    }
    return 100;
}

//下载数据
-(void)loadDataWithPage:(NSInteger)page pageSize:(NSInteger)pageSize{
    NSString *url = nil;
    switch (_flag) {
        case 0:
        {
            url = [NSString stringWithFormat:kRecommendUrl,page,pageSize];

        }
            break;
        case 1:{
            url = kSortUrl;
        }
        break;
        default:
            break;
    }
    
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
        [weakSelf.collectionView reloadData];
        [weakSelf endRefresh];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf endRefresh];
    }];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell"forIndexPath:indexPath];
    PlayModel *model = _dataArr[indexPath.row];
    if (_flag==0) {
        [cell showDataWithModel:model];
    }
    if (_flag==1) {
        [cell showCellWithModel:model];
    }
    return cell;
}

//单个cell 大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_flag == 0)
        return CGSizeMake(kScreenSize.width/3.0-8, 140);
    else
        return CGSizeMake(kScreenSize.width/2.0-30, 160);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PlayModel *model = _dataArr[indexPath.row];
    DisplayViewController *displayVc = [[DisplayViewController alloc] init];
    if (_flag == 0) {
        displayVc.displayUrl = [NSString stringWithFormat:kHomeDisplaylUrl,model.id];
    }
    if (_flag == 1) {
        displayVc.displayUrl = [NSString stringWithFormat:kSortDisplayUrl,model.id];

    }
    displayVc.model = model;
    displayVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:displayVc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
