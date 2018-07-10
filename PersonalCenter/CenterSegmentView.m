//
//  CenterSegmentView.m
//  PersonalCenter
//
//  Created by yuexun on 2018/7/3.
//  Copyright © 2018年 xjl. All rights reserved.
//

#import "CenterSegmentView.h"
#define kWidth self.frame.size.width
#define segmentScrollVHeight  41     //分页控制器button的高度
#define smallFont [UIFont systemFontOfSize:17.]
#define largeFont [UIFont systemFontOfSize:19.]
#define normalColor [UIColor grayColor]
#define selectedColor [UIColor orangeColor]
#define downColor [UIColor lightGrayColor] //分割线颜色

@interface CenterSegmentView () <UIScrollViewDelegate>

@property ( nonatomic, strong) NSArray  * controllers;

@end
@implementation CenterSegmentView
-(instancetype)initWithFrame:(CGRect)frame controllers:(NSArray *)controllers titleArray:(NSArray *)titleArray ParentController:(UIViewController *)parentC selectBtnIndex:(NSInteger)index lineWidth:(float)lineW lineHeight:(float)lineH{
    self=[super initWithFrame:frame];
    if (self) {
        float avgWidth = (frame.size.width/controllers.count);
        self.controllers = controllers;
        self.nameArray = titleArray;
        
        self.segmentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, segmentScrollVHeight)];
        self.segmentView.tag = 50;
        [self addSubview:self.segmentView];
        
        self.segmentScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, segmentScrollVHeight, frame.size.width, frame.size.height-segmentScrollVHeight)];
        self.segmentScrollV.contentSize = CGSizeMake(frame.size.width*self.controllers.count, 0);
        self.segmentScrollV.delegate = self;
        self.segmentScrollV.showsHorizontalScrollIndicator = NO;
        self.segmentScrollV.pagingEnabled = YES;
        self.segmentScrollV.bounces = NO;
        [self addSubview:self.segmentScrollV];
        
        for (int i=0; i<self.controllers.count; i++)
        {
            UIViewController * controller = self.controllers[i];
            [self.segmentScrollV addSubview:controller.view];
            controller.view.frame = CGRectMake(i*frame.size.width, 0, frame.size.width,frame.size.height);
            [parentC addChildViewController:controller];
            [controller didMoveToParentViewController:parentC];
        }
        
        for (int i=0; i<self.controllers.count; i++)
        {
            UIButton * btn = [ UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(i*(frame.size.width/self.controllers.count), 0, frame.size.width/self.controllers.count, segmentScrollVHeight);
            btn.backgroundColor = [UIColor whiteColor];
            btn.tag = i;
            [btn setTitle:self.nameArray[i] forState:(UIControlStateNormal)];
            [btn setTitleColor:normalColor forState:(UIControlStateNormal)];
            [btn setTitleColor:selectedColor forState:(UIControlStateSelected)];
            [btn addTarget:self action:@selector(Click:) forControlEvents:(UIControlEventTouchUpInside)];
            
            if (index) {
                if (index == i) {
                    btn.selected=YES;
                    self.seleBtn = btn;
                    btn.titleLabel.font = largeFont;
                    //初始化选中的控制器
                    [self.segmentScrollV setContentOffset:CGPointMake((btn.tag)*kWidth, 0) animated:YES ];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectVC" object:btn userInfo:nil];
                }else{
                    btn.selected=NO;
                    btn.titleLabel.font = smallFont;
                }
            }else{
                if (i==0){
                    btn.selected = YES ;
                    self.seleBtn = btn;
                    btn.titleLabel.font = largeFont;
                } else {
                    btn.selected = NO;
                    btn.titleLabel.font = smallFont;
                }
            }
            [self.segmentView addSubview:btn];
        }
        
        //分割线
        self.down = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, frame.size.width, 1)];
        self.down.backgroundColor = downColor;
        [self.segmentView addSubview:self.down];
        //选中线
        self.line = [[UILabel alloc]initWithFrame:CGRectMake((avgWidth-lineW)/2, segmentScrollVHeight-lineH, lineW, lineH)];
        self.line.backgroundColor = selectedColor;
        self.line.tag = 100;
        //初始化线的位置
        if (index) {
            CGPoint  frame = self.line.center;
            frame.x = kWidth/(self.controllers.count*2) + (kWidth/self.controllers.count) * (self.seleBtn.tag);
            self.line.center = frame;
        }
        [self.segmentView addSubview:self.line];
        
    }
    return self;
}
//点击菜单按钮的事件处理
- (void)Click:(UIButton*)sender
{
    //先改变上一次选中button的字体大小和状态(颜色)
    self.seleBtn.titleLabel.font = smallFont;
    self.seleBtn.selected = NO;
    
    self.seleBtn = sender;
    //回调
    if (self.pageBlock){
        self.pageBlock(sender.tag);
    }
    //再改变当前选中button的字体大小和状态(颜色)
    self.seleBtn.selected = YES;
    self.seleBtn.titleLabel.font = largeFont;
    [UIView animateWithDuration:0.1 animations:^{
        CGPoint  point = self.line.center;
        point.x = (kWidth/self.controllers.count)* (sender.tag) + kWidth/(self.controllers.count*2);
        self.line.center = point;
    }];
    
    [self.segmentScrollV setContentOffset:CGPointMake((sender.tag)*kWidth, 0) animated:YES ];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectVC" object:sender userInfo:nil];
}
//segmentScrollV左右滑动时和外层tableView上下滑动需要做互斥处理
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isScroll" object:nil userInfo:@{@"canScroll":@"0"}];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isScroll" object:nil userInfo:@{@"canScroll":@"1"}];
}

//滑动下方分页View时的事件处理
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.1 animations:^{
        CGPoint  point = self.line.center;
        point.x = (kWidth/self.controllers.count) * (self.segmentScrollV.contentOffset.x/kWidth) + kWidth/(self.controllers.count*2);
        self.line.center = point;
    }];
    
    UIButton *btn = (UIButton*)[self.segmentView viewWithTag:(self.segmentScrollV.contentOffset.x/kWidth)];
    self.seleBtn.selected = NO;
    self.seleBtn.titleLabel.font = smallFont;
    self.seleBtn = btn;
    self.seleBtn.selected = YES;
    self.seleBtn.titleLabel.font = largeFont;
    if (self.pageBlock){
        self.pageBlock(btn.tag);
    }
}
@end
