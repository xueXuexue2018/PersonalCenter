//
//  ViewController.m
//  PersonalCenter
//
//  Created by yuexun on 2018/7/3.
//  Copyright © 2018年 xjl. All rights reserved.
//

#import "ViewController.h"
#import "PersonalCenterTable.h"
#import "CenterHeaderView.h"
#import "CenterCell.h"
#import "CenterSegmentView.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

#import <Masonry.h>
#define NaviBarHeight  self.view.frame.size.height == 812 ? 88 : 64

#define headimageHeight   240 //头部视图的高度
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
/** table */
@property (strong, nonatomic)  PersonalCenterTable *tableView;
/** 头部的view */
@property (strong, nonatomic)  CenterHeaderView *headerView;
/** 分段 */
@property (strong, nonatomic)  CenterSegmentView *segmentView;

@property (nonatomic, assign) BOOL canScroll;//mainTableView是否可以滚动
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;//到达顶部(临界点)不能移动mainTableView
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;//到达顶部(临界点)不能移动子控制器的tableView


@end

@implementation ViewController
{
    NSInteger _naviBarHeight;//导航栏的高度+状态栏的高度
    BOOL _isRefresh;//控制下拉放大时刷新数据的次数，做到下拉放大值刷新一次，避免重复刷新
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    
    [self.tableView addSubview:self.headerView];;
  
    
    
    [self.tableView registerClass:[CenterCell class] forCellReuseIdentifier:@"centerCell"];
    
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //注册允许外层tableView滚动通知-解决和分页视图的上下滑动冲突问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"leaveTop" object:nil];
    //注册允许外层tableView滚动通知-解决子视图左右滑动和外层tableView上下滑动的冲突问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsgOfSubView:) name:@"isScroll" object:nil];
    
    //接收宏定义的值，因为下面要做运算，这个宏含有三目运算不能直接拿来运算,会出错
    _naviBarHeight = NaviBarHeight;
    //如果使用自定义的按钮去替换系统默认返回按钮，会出现滑动返回手势失效的情况，解决方法如下：
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *centerCell=@"centerCell";
   
    CenterCell *cell=[tableView dequeueReusableCellWithIdentifier:centerCell forIndexPath:indexPath];
    [cell.contentView addSubview:self.segmentView];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.height-_naviBarHeight;
}
//接收通知
- (void)acceptMsg:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

- (void)acceptMsgOfSubView:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _tableView.scrollEnabled = YES;
    }else if([canScroll isEqualToString:@"0"]) {
        _tableView.scrollEnabled = NO;
    }
}

/**
 * 处理联动
 * 因为要实现下拉头部放大的问题，tableView设置了contentInset，所以试图刚加载的时候会调用一遍这个方法，所以要做一些特殊处理，
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _tableView) {
        
        //当前偏移量
        CGFloat yOffset  = scrollView.contentOffset.y;
        //临界点偏移量(吸顶临界点)
        CGFloat tabyOffset = [_tableView rectForSection:0].origin.y - _naviBarHeight;
        
        //第一部分：
        //更改导航栏的背景图的透明度
        CGFloat alpha = 0;
        if (-yOffset <= _naviBarHeight) {
            alpha = 1;
        }else if(_naviBarHeight < -yOffset && -yOffset < headimageHeight){
            alpha = (headimageHeight + yOffset)/(headimageHeight-_naviBarHeight);
        }else {
            alpha = 0;
        }
//        self.naviView.backgroundColor = kRGBA(255,126,15,alpha);
        
        //第二部分：
        //利用contentOffset处理内外层scrollView的滑动冲突问题
        if (yOffset >= tabyOffset) {
            //当分页视图滑动至导航栏时，禁止外层tableView滑动
            scrollView.contentOffset = CGPointMake(0, tabyOffset);
            _isTopIsCanNotMoveTabView = YES;
        }else{
            //当分页视图和顶部导航栏分离时，允许外层tableView滑动
            _isTopIsCanNotMoveTabView = NO;
        }
        
        //取反
        _isTopIsCanNotMoveTabViewPre = !_isTopIsCanNotMoveTabView;
        
        if (!_isTopIsCanNotMoveTabViewPre) {
            NSLog(@"分页选择部分滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goTop" object:nil userInfo:@{@"canScroll":@"1"}];
            _canScroll = NO;
        }else {
            NSLog(@"页面滑动到底部后开始下拉");
            if (!_canScroll) {
                NSLog(@"分页选择部分保持在顶端");
                _tableView.contentOffset = CGPointMake(0, tabyOffset);
            }
        }
        
        //第三部分：
        /**
         * 处理头部自定义背景视图 (如: 下拉放大)
         * 图片会被拉伸多出状态栏的高度
         */
        if(yOffset <= -headimageHeight) {
            if (_isEnlarge) {
                CGRect f = self.headerView.frame;
                //改变HeadImageView的frame
                //上下放大
                f.origin.y = yOffset;
                f.size.height =  -yOffset;
                //左右放大
                f.origin.x = (yOffset*self.view.frame.size.width/headimageHeight+self.view.frame.size.width)/2;
                f.size.width = -yOffset*self.view.frame.size.width/headimageHeight;
                //改变头部视图的frame
                self.headerView.frame = f;
                //刷新数据，保证刷新一次
                if (yOffset ==  - headimageHeight) {
                    _isRefresh = YES;
                }
                if (yOffset < -headimageHeight - 30 && _isRefresh) {
//                    [self requestData];
                    _isRefresh = NO;
                }
            }else{
                scrollView.bounces = NO;
                if (yOffset == -headimageHeight) {
                    //刷新数据
//                    [self requestData];
                }
            }
            //刷新数据
            if (_isRefreshOfdownPull) {
//                [self requestData];
            }
        }else {
            scrollView.bounces = YES;
        }
    }
}

-(PersonalCenterTable *)tableView
{
    if (!_tableView) {
        _tableView=[[PersonalCenterTable alloc]init];
        
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.showsVerticalScrollIndicator=NO;
       _tableView.contentInset=UIEdgeInsetsMake(headimageHeight, 0, 0, 0);
    }
    return _tableView;
}
-(CenterHeaderView *)headerView{
    if (_headerView==nil) {
        _headerView=[[CenterHeaderView alloc]initWithFrame:CGRectMake(0, -headimageHeight, self.view.frame.size.width, headimageHeight)];
        
    }
    return _headerView;
}
-(CenterSegmentView *)segmentView{
    if (_segmentView==nil) {
        //设置子控制器
        FirstViewController   * firstVC  = [[FirstViewController alloc]init];
        SecondViewController  * secondVC = [[SecondViewController alloc]init];
        ThirdViewController   * thirdVC  = [[ThirdViewController alloc]init];
        SecondViewController  * fourthVC = [[SecondViewController alloc]init];
        NSArray *controllers = @[firstVC,secondVC,thirdVC,fourthVC];
        NSArray *titleArray  = @[@"普吉岛",@"夏威夷",@"洛杉矶",@"新泽西"];
        _segmentView=[[CenterSegmentView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-_naviBarHeight) controllers:controllers titleArray:titleArray ParentController:self selectBtnIndex:(NSInteger)index lineWidth:self.view.frame.size.width/5 lineHeight:3];
        
    }
    
    return _segmentView;
}
@end
