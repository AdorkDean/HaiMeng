//
//  LSAboutUsViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSAboutUsViewController.h"
#import "NSString+Util.h"

@interface LSAboutUsViewController () {

    UIScrollView *bg_scrollView;
}

@end

@implementation LSAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于我们";
    
    [self setupUI];
}

#pragma mark - 设置内容
- (void)setupUI{
    
    self.view.backgroundColor = [UIColor whiteColor];
    //滚动
    bg_scrollView = [[UIScrollView alloc] init];
    
    [self.view addSubview:bg_scrollView];
    [bg_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // 底部view， 用于计算scrollview高度
    UIView* contentView = [[UIView alloc] init];
    [bg_scrollView addSubview:contentView];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bg_scrollView);
    }];
    
     
    UIImageView * headerImage = [UIImageView new];
    headerImage.image = [UIImage imageNamed:@"IconMe-60"];
    headerImage.layer.cornerRadius = 10;
    headerImage.clipsToBounds = YES;
    [bg_scrollView  addSubview:headerImage];
    [headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(70);
        make.top.equalTo(bg_scrollView.mas_top).offset(40);
        make.centerX.equalTo(bg_scrollView);
    }];
    
    UILabel * englistLabel = [UILabel new];
    englistLabel.text = @"HAIMENG";
    englistLabel.font = [UIFont systemFontOfSize:18];
    englistLabel.textAlignment = UITextAlignmentCenter;
    [bg_scrollView addSubview:englistLabel];
    [englistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(headerImage.mas_bottom).offset(10);
        make.centerX.equalTo(bg_scrollView);
        make.width.offset(100);
        make.height.offset(20);
    }];
    
    UILabel * titleLabel = [UILabel new];
    titleLabel.text = @"嗨萌";
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textAlignment = UITextAlignmentCenter;
    [bg_scrollView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(englistLabel.mas_bottom).offset(5);
        make.centerX.equalTo(bg_scrollView);
        make.width.offset(100);
        make.height.offset(20);
    }];
    
    UILabel * commonLabel = [UILabel new];
    commonLabel.textColor = [UIColor lightGrayColor];
    commonLabel.font = [UIFont systemFontOfSize:15];
    commonLabel.numberOfLines = 0;
    NSString * str = @"       嗨萌是佛山市老板六六科技有限公司于2016年开始打造，2017年推向市场的一款社交软件，通过云计算、大数据技术自动推荐同事、同学、同乡，让你找到失联多年的好友，同时嗨萌拥有丰富的表情包，可以不打一个字进行沟通。满足现代人快速的生活节奏，除此之外它还可以玩游戏消磨时间。";
    commonLabel.text = str;
    [bg_scrollView addSubview:commonLabel];
    CGFloat commonHeight = [NSString countingSize:str fontSize:16 width:kScreenWidth-15].height;
    [commonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.centerX.equalTo(bg_scrollView);
        make.width.offset(kScreenWidth-40);
        make.height.offset(commonHeight);
    }];
    
    UILabel * commonLabel2 = [UILabel new];
    commonLabel2.textColor = [UIColor lightGrayColor];
    commonLabel2.font = [UIFont systemFontOfSize:15];
    commonLabel2.numberOfLines = 0;
    NSString * str1 = @"       嗨萌一直以来本着从用户需求出发，摒弃多余功能、简单易用为核心设计理念，致力于打造一款符合现代年轻人使用习惯的社交软件，力争给用户带来最好的沟通体验。";
    commonLabel2.text = str1;
    [bg_scrollView addSubview:commonLabel2];
    CGFloat commonHeight2 = [NSString countingSize:str1 fontSize:16 width:kScreenWidth-15].height;
    [commonLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(commonLabel.mas_bottom).offset(0);
        make.centerX.equalTo(bg_scrollView);
        make.width.offset(kScreenWidth-40);
        make.height.offset(commonHeight2);
    }];
    
     //自动scrollview高度
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(commonLabel2.mas_bottom).with.offset(40);
    }];
    
}

@end
