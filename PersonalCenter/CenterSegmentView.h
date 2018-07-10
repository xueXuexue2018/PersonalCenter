//
//  CenterSegmentView.h
//  PersonalCenter
//
//  Created by yuexun on 2018/7/3.
//  Copyright © 2018年 xjl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CenterSegmentView : UIView
@property ( nonatomic, strong) NSArray       * nameArray;
@property ( nonatomic, strong) UIView        * segmentView;
@property ( nonatomic, strong) UIScrollView  * segmentScrollV;
@property ( nonatomic, strong) UILabel       * line;
@property ( nonatomic, strong) UIButton      * seleBtn;
@property ( nonatomic, strong) UILabel       * down;
@property ( nonatomic,   copy) void (^pageBlock)(NSInteger);//页面切换的回调，依次是 0 1 2 。。。

- (instancetype)initWithFrame:(CGRect)frame controllers:(NSArray *)controllers titleArray:(NSArray *)titleArray ParentController:(UIViewController *)parentC selectBtnIndex:(NSInteger)index lineWidth:(float)lineW lineHeight:(float)lineH;
@end
