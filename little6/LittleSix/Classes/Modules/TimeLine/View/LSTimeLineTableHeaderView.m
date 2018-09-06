//
//  LSTimeLineTableHeaderView.m
//  LittleSix
//
//  Created by Jim huang on 17/2/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTimeLineTableHeaderView.h"
#import "LSUserModel.h"
#import "LSAppManager.h"
@interface LSTimeLineTableHeaderView ()

@property (nonatomic,strong) UIImageView *BGImageView;
@property (nonatomic,strong) UIImageView *MyIconImageView;
@property (nonatomic,strong) UILabel *MyNameLabel;
@property (nonatomic,strong) UILabel * introduceLabel;

@end

@implementation LSTimeLineTableHeaderView



-(instancetype)initWithFrame:(CGRect)frame{
    if (self =[super initWithFrame:frame]) {
        [self makeConstraints];
        [self setNotification];
    }
    return self;
}


-(void)makeConstraints{
    
    UIView * BGView =[UIButton new];
    [self addSubview:BGView];
    
    UIImageView *BGImageView = [UIImageView new];
    self.BGImageView = BGImageView;
    [BGView addSubview:BGImageView];
    BGImageView.contentMode =UIViewContentModeScaleAspectFill;
    BGImageView.backgroundColor = [UIColor blackColor];
    BGImageView.clipsToBounds = YES;
    UIControl *BGControl = [UIControl new];
    [BGView addSubview:BGControl];
    [BGControl addTarget:self action:@selector(myBGImageClick) forControlEvents:UIControlEventTouchUpInside];

    UIView *MyIconView  = [UIView new];
    [self addSubview:MyIconView];
    [self bringSubviewToFront:MyIconView];
    
    
    self.MyIconImageView = [UIImageView new];
    [MyIconView addSubview:self.MyIconImageView];
    
    UIControl * iconControl = [UIControl new];
    [self addSubview:iconControl];
    [iconControl addTarget:self action:@selector(myIconClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.MyNameLabel = [UILabel new];
    self.MyNameLabel.numberOfLines = 1;
    self.MyNameLabel.font = [UIFont systemFontOfSize:17];
    self.MyNameLabel.textColor =[UIColor whiteColor];
    self.MyNameLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.MyNameLabel];
    
    self.introduceLabel = [UILabel new];
    self.introduceLabel.numberOfLines = 2;
    self.introduceLabel.font = [UIFont systemFontOfSize:13];
    self.introduceLabel.textColor =HEXRGB(0x999999);
    self.introduceLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.introduceLabel];
    
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(BGImageheight);

    }];
    [self.BGImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(BGView);
    }];
    [BGControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(BGView);
    }];
    
    [MyIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-10);
        make.top.offset(200);
        make.width.height.mas_equalTo(70);
    }];
    
    [self.MyIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.top.bottom.equalTo(MyIconView);
    }];
   
    [iconControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.top.bottom.equalTo(MyIconView);
    }];
    
    [self.introduceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(MyIconView.mas_bottom).offset(5);
        make.centerX.equalTo(MyIconView);
        make.right.equalTo(self).offset(-2);
    }];
    
    [self.MyNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(MyIconView).with.offset(-5);
        make.right.equalTo(MyIconView.mas_left).with.offset(-10);
        make.left.equalTo(self.mas_left).offset(20);
        make.height.mas_equalTo(25);
    }];
    
    self.MyDevelopmentsView = [LSDevelopmentsView new];
    self.MyDevelopmentsView.hidden = YES;
    ViewRadius(self.MyDevelopmentsView, 10);
    [self addSubview:self.MyDevelopmentsView];
    
    [self.MyDevelopmentsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).with.offset(-10);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(39);
    }];
}
-(void)setNotification{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reSetHeaderBGImage) name:TimeLineDoneBGImageNoti object:nil];

}
-(void)myIconClick{
    [[NSNotificationCenter defaultCenter] postNotificationName:TimeLineMyIconNoti object:nil];
}
-(void)myBGImageClick{
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary];
    infoDic[@"type"] = self.type;
    [[NSNotificationCenter defaultCenter] postNotificationName:TimeLineBGImageNoti object:nil userInfo:infoDic];
}

-(void)setModel:(LSUserModel *)model{
    _model = model;
    self.MyNameLabel.text = model.user_name;
    [self.BGImageView setImageWithURL:[NSURL URLWithString:model.cover_pic] placeholder:timeLineBigPlaceholderName];
    self.introduceLabel.text = model.signature;
    [self.MyIconImageView setImageWithURL:[NSURL URLWithString:model.avatar]  placeholder:timeLineSmallPlaceholderName];
    
}

-(void)reSetHeaderBGImage{
    NSURL * imageUrl = [NSURL URLWithString:[LSAppManager sharedAppManager].loginUser.cover_pic];
    [self.BGImageView setImageWithURL:imageUrl placeholder:timeLineBigPlaceholderName];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
