//
//  ViewController.h
//  PersonalCenter
//
//  Created by yuexun on 2018/7/3.
//  Copyright © 2018年 xjl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
//默认上下左右放大
@property (nonatomic, assign) BOOL isEnlarge;//是否放大
@property (nonatomic, assign) BOOL isRefreshOfdownPull;//下拉操作下方tableView是否刷新
@property (nonatomic, assign) NSInteger selectIndex;//当前选中的分页视图

@end

