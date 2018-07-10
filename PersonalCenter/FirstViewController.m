//
//  FirstViewController.m
//  PersonalCenter
//
//  Created by yuexun on 2018/7/3.
//  Copyright © 2018年 xjl. All rights reserved.
//

#import "FirstViewController.h"
#define segmentMenuHeight 41 //分页菜单栏的高度
@interface FirstViewController ()< UITableViewDelegate, UITableViewDataSource>

@property (nonatomic , strong) UITableView  * tableView;
@property (nonatomic , assign) NSInteger        page;
@property (nonatomic , assign) BOOL             isHeader;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    [self creatTableView];
   
}

- (void)creatTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-self.topHeight-segmentMenuHeight)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
}

#pragma mark - TableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"FirstVCcell";
    UITableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"快点我%ld -> 进入我的消息",indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
