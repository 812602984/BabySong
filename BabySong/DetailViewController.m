//
//  DetailViewController.m
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "DetailViewController.h"
#import "AFNetworking.h"
#import <AVFoundation/AVFoundation.h>

@interface DetailViewController ()<UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate>
{
    AFHTTPRequestOperationManager *_manager;
    AVAudioPlayer *_player;
    NSInteger _currentCount;   //当前cell的标号
    UILabel *_promptLabel;
    UILabel *_label;
    UILabel *_textLabel;
}

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic)BOOL isRefreshing;
@property (nonatomic)BOOL isLoadMore;
@property (nonatomic)NSInteger currentPage;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.model.title;
    [self dataInit];
    [self loadDataWithPage:1 pageSize:10];
}

-(void)dataInit{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isRefreshing = self.isLoadMore = NO;
  
    _dataArr = [NSMutableArray array];
    _manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self creatPrompt];
    [self creatTableView];
    [self initLabel:@""];
    [self creatRefreshView];
}

-(void)creatPrompt{
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, 20)];
    _promptLabel.backgroundColor = [UIColor orangeColor];
    _promptLabel.text = @"温馨提示:选中一行即可播放";
    _promptLabel.font = [UIFont fontWithName:nil size:13];
    _promptLabel.textColor = [UIColor redColor];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_promptLabel];
}

-(void)creatTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 84,kScreenSize.width , kScreenSize.height-84-49) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor purpleColor];
    //_tableView.showsVerticalScrollIndicator = NO;   //隐藏滚动条
    //_tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;      //修改滚动条的颜色
    _tableView.rowHeight = 70;    //设置每个cell的行高
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self hideExtraLine];
    [self.view addSubview:_tableView];
}

//隐藏多余的分割线
-(void)hideExtraLine{
    UIView *view  = [[UIView alloc] init];
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
    
    NSString *url = [self.detailUrl stringByAppendingString:[NSString stringWithFormat:@"page=%ld&pageSize=%ld",page,pageSize]];
    
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleDrop];
    [MMProgressHUD showWithTitle:@"正在下载数据" status:@"loading..."];
    
    __weak typeof(self) weakSelf = self;
    [_manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            if (page == 1 && weakSelf.isRefreshing) {
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
        [weakSelf.tableView reloadData];
        [MMProgressHUD dismissWithSuccess:@"数据加载成功" title:@"恭喜你"];
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
    cell.selectedBackgroundView.backgroundColor = [UIColor greenColor];
    
//    //修改cell的imageView的宽和高
//    CGSize imageSize = CGSizeMake(60, 60);
//    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
//    CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
//    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.coverSmall]]];   //比较耗时，应在子线程中操作,目前未解决
//    [image drawInRect:imageRect];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    cell.imageView.image = image;
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.coverSmall] placeholderImage:[UIImage imageNamed:@"default.png"]];
    
    cell.textLabel.text = model.title;
    cell.textLabel.font = [UIFont fontWithName:nil size:14];
    cell.textLabel.numberOfLines = 0;
    
    if(model.duration){
        cell.detailTextLabel.text = [NSString stringWithFormat:@" 时长:%.2fs",model.duration];
    }

    cell.detailTextLabel.textColor = [UIColor purpleColor];
    return cell;
}

//选中cell时调用
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor redColor];

    _currentCount = indexPath.row;
    
    PlayModel *model = _dataArr[indexPath.row];
    _textLabel.text = [NSString stringWithFormat:@"当前收听:%@",model.title];

    [self playSong:model.playUrl32];
    [_player play];
}

-(void)playSong:(NSString *)url{
    [[NSNotificationCenter defaultCenter] removeObserver:nil];
    NSURL *urlStr = [[NSURL alloc] initWithString:url];
    AVURLAsset *assert = [[AVURLAsset alloc] initWithURL:urlStr options:nil];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:assert];
    
//    [self setSelectedCell:self];
    
    _player = [AVPlayer playerWithPlayerItem:item];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
}

//-(void)setSelectedCell:(id)sender{
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    cell.selected = YES;
//    cell.textLabel.textColor = [UIColor redColor];
//}

//视频播放完成后调用
-(void)moviePlayDidEnd:(NSNotification *)notification{
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor blackColor];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];   //取消选中状态
    
    if(_currentCount < _dataArr.count-1){  //播放下一个cell对应的音频
        _currentCount++;
        
        [self playSong:[_dataArr[_currentCount] playUrl32]];
        _textLabel.text = [NSString stringWithFormat:@"当前收听:%@",[_dataArr[_currentCount] title]];
        [_player play];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提醒" message:@"没有播放内容了" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

-(void)initLabel:(NSString *)str{
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, kScreenSize.height-49, kScreenSize.width, 49);
    _label.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_label];
    
    //播放/暂停按钮
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    playBtn.frame = CGRectMake(12, kScreenSize.height-45, 40, 40);
    playBtn.tag = 100;
    [playBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    playBtn.clipsToBounds = YES;
    playBtn.layer.cornerRadius = 20;
    [self.view addSubview:playBtn];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, kScreenSize.height-49, kScreenSize.width-100, 49)];
    _textLabel.text = [NSString stringWithFormat:@"当前收听:%@",str];
    _textLabel.textColor = [UIColor redColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.font = [UIFont fontWithName:nil size:13];
    _textLabel.numberOfLines = 2;
    [self.view addSubview:_textLabel];
    
    //下一篇按钮
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.tag = 101;
    nextBtn.frame = CGRectMake(kScreenSize.width-50, kScreenSize.height-45, 40, 40);
    [nextBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [self.view addSubview:nextBtn];
}

//按钮点击事件
-(void)btnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    switch (btn.tag) {
        case 100:{
            if (btn.selected) {
                [_player pause];
                [btn setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            }else{
                [_player play];
                [btn setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
                
            }
        }
            break;
        case 101:{
            [self performSelector:@selector(moviePlayDidEnd:) withObject:nil];
        }
            break;
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
