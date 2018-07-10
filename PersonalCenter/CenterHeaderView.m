//
//  CenterHeaderView.m
//  PersonalCenter
//
//  Created by yuexun on 2018/7/3.
//  Copyright © 2018年 xjl. All rights reserved.
//

#import "CenterHeaderView.h"
#import <Masonry.h>

@implementation CenterHeaderView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
      
        [self createUI];
        
    }
    return self;
}
-(void)createUI{
    UIImageView *bgImg=[[UIImageView alloc]init];
    bgImg.image=[UIImage imageNamed:@"bg.jpg"];
    bgImg.contentMode=UIViewContentModeScaleAspectFill;
    [self addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
}
@end
