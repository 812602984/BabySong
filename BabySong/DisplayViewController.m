//  DisplayViewController.m
//  BabySong
//
//  Created by qianfeng on 15/7/2.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "DisplayViewController.h"
#import "DetailViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface DisplayViewController ()<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>
{
    NSInteger _flag;
    NSInteger _currentCount;
    UILabel *_label;
    UILabel *_promptLabel;
    UILabel *_textlabel;
}

@property (nonatomic)AVAudioPlayer *player;

@end

@implementation DisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //_player.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.model.title;
    [self dataInit];
    [self loadDataWithPage:1 pageSize:10];
}

-(void)dataInit{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isRefreshing = self.isLoadMore = NO;
    _label = [[UILabel alloc] init];
    _flag = -1;
    _dataArr = [NSMutableArray array];
    _manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self creatTableView];
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
//    [self creatPrompt];
  
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,64,kScreenSize.width , kScreenSize.height-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    //_tableView.showsVerticalScrollIndicator = NO;   //隐藏滚动条
    //_tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;      //修改滚动条的颜色
    _tableView.rowHeight = 70;
    _tableView.separatorColor = [UIColor purpleColor];   //设置分割线为紫色
    
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

//下载数据
-(void)loadDataWithPage:(NSInteger)page pageSize:(NSInteger)pageSize{
    NSString *url = [self.displayUrl stringByAppendingString:[NSString stringWithFormat:@"page_id=%ld&pageSize=%ld",page,pageSize]];
    
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleDrop];
    [MMProgressHUD showWithTitle:@"正在下载数据" status:@"loading..."];
    
    __weak typeof(self) weakSelf = self;
    [_manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            if (page == 1) {
                [weakSelf.dataArr removeAllObjects];
            }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray *dataList = json[list];
            for (NSDictionary *dataDict in dataList) {
                PlayModel *model = [[PlayModel alloc] init];
                [model setValuesForKeysWithDictionary:dataDict];
                model.duration = 150.f;
                model.size = @"8";
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
    _currentCount = indexPath.row;
    PlayModel *model = _dataArr[indexPath.row];
    
    static NSString *cellId = @"displayCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
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
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;
    CGRect frame = self.tableView.frame;
    if(model.duration){
        [self creatPrompt];
        frame.origin.y = 84;
        frame.size.height = kScreenSize.height-84-49;
        self.tableView.frame = frame;
        _flag = 0;
        cell.detailTextLabel.text = [NSString stringWithFormat:@" 时长:%.2fs",model.duration];
        static int flag = 1;
        flag = !flag;
        if (flag) {
            [self initLabel:@""];
            flag = !flag;
        }
    }
    if (model.size != nil) {
        _promptLabel.hidden = YES;
        frame.size.height = kScreenSize.height-64;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _flag = 1;
        cell.detailTextLabel.text = [NSString stringWithFormat:@" 章节:%@",model.size];
    }
    cell.detailTextLabel.textColor = [UIColor purpleColor];
    return cell;
}

-(void)initLabel:(NSString *)str{
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, kScreenSize.height-49, kScreenSize.width, 49);
    _label.backgroundColor = [UIColor orangeColor];
//    _label.textAlignment = NSTextAlignmentCenter;
//    _label.textColor = [UIColor redColor];
//    
//    _label.font = [UIFont fontWithName:nil size:13];
    //创建NSMutableAttributeString
//    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
//    //添加属性
//    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, str.length)];
   // _label.text = [NSString stringWithFormat:@"当前收听:%@",attributeStr];
    [self.view addSubview:_label];
    
    //播放/暂停按钮
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    playBtn.frame = CGRectMake(10, kScreenSize.height-45, 40, 40);
    playBtn.tag = 100;
    [playBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    playBtn.clipsToBounds = YES;
    playBtn.layer.cornerRadius = 20;
    [self.view addSubview:playBtn];
    
    _textlabel = [[UILabel alloc] initWithFrame:CGRectMake(50, kScreenSize.height-49, kScreenSize.width-100, 49)];
    _textlabel.text = [NSString stringWithFormat:@"当前收听:%@",str];
    _textlabel.textColor = [UIColor redColor];
    _textlabel.textAlignment = NSTextAlignmentCenter;
    _textlabel.font = [UIFont systemFontOfSize:13];
    _textlabel.numberOfLines = 2;
    [self.view addSubview:_textlabel];
    
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

-(void)setBtnBgImg:(UIButton *)sender{
    if (_player.play) {
        [sender setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }else{
        [sender setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }

}

-(void)playSong:(NSString *)url{
    [[NSNotificationCenter defaultCenter] removeObserver:nil];
    NSURL *urlStr = [[NSURL alloc] initWithString:url];
    AVURLAsset *assert = [[AVURLAsset alloc] initWithURL:urlStr options:nil];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:assert];

    _player = [AVPlayer playerWithPlayerItem:item];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _currentCount = indexPath.row;
    PlayModel *model = _dataArr[indexPath.row];
    if (_flag == 0) {
        _textlabel.text = [NSString stringWithFormat:@"当前收听:%@",model.title];
        [self playSong:model.playUrl32];
        [_player play];
      
    }
    if (_flag == 1) {
        DetailViewController *detailVc = [[DetailViewController alloc] init];
//        NSString *url = [NSString stringWithFormat:kDetailUrl,model.id];
        
        NSString *url = @"http://api.ximalaya.com/openapi-gateway-app/albums/browse?app_key=4bcb469d55cb527702077ee7911f3d79&client_os_type=4&nonce=20180506100252&timestamp=1525572172444.300293&album_id=14501623&page=1&sort=asc&sig=d7a56448c4b644e981ee7c6354ba1156";
        
        detailVc.detailUrl = url;
        detailVc.model = model;
        [self.navigationController pushViewController:detailVc animated:YES];
    }
}

-(void)moviePlayDidEnd:(NSNotification *)notification{
    
    //视频播放完成
    if(_currentCount < _dataArr.count-1){
        _currentCount++;
        [self playSong:[_dataArr[_currentCount] playUrl32]];
        _textlabel.text = [NSString stringWithFormat:@"当前收听:%@",[_dataArr[_currentCount] title]];
        [_player play];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提醒" message:@"没有播放内容了" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
