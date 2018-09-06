//
//  LSDevelopmentsView.m
//  LittleSix
//
//  Created by Jim huang on 17/2/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSDevelopmentsView.h"
#import "LSTimeLineTableListModel.h"
@interface LSDevelopmentsView ()

@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) UILabel *msgCountLabel;
@property (nonatomic,strong) UIImageView * arrowView;

@end

@implementation LSDevelopmentsView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self makeConstrains];
    }
    return self;
}


-(void)makeConstrains{
    self.backgroundColor = [UIColor blackColor];
    self.iconView = [UIImageView new];
    [self addSubview:self.iconView];
    self.iconView.backgroundColor = [UIColor whiteColor];
    
    self.msgCountLabel = [UILabel new];
    [self addSubview:self.msgCountLabel];
    self.msgCountLabel.textColor = [UIColor whiteColor];
    self.msgCountLabel.font = [UIFont systemFontOfSize:12];
    self.msgCountLabel.text = @"你有1条新消息";
    self.msgCountLabel.textAlignment =NSTextAlignmentRight;
    
    self.arrowView =[UIImageView new];
    [self addSubview:self.arrowView];
    [self.arrowView setImage:[UIImage imageNamed:@"right_arrows"]];
    self.arrowView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).with.offset(-4);
        make.top.left.equalTo(self).with.offset(4);
        make.width.mas_equalTo(31);
    }];
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self).with.offset(-8);
        make.top.equalTo(self).with.offset(10);
        make.width.mas_equalTo(15);
    }];
    [self.msgCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.right.equalTo(self.arrowView.mas_left);
        make.height.mas_equalTo(25);
    }];
    

}


-(void)setModel:(LSGetNewMsgModel *)model{
    _model = model;
    self.msgCountLabel.text = [NSString stringWithFormat:@"你有%@条新消息",model.count];
    LSGetNewMsgFirstModel* firstModel = model.frist_user;
    [self.iconView setImageWithURL:[NSURL URLWithString:firstModel.avatar] placeholder:timeLineSmallPlaceholderName];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter]postNotificationName:TimeLineMessageNoti object:nil];
}
@end
