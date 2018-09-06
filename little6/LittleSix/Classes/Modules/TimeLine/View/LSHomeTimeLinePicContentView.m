//
//  LSHomeTimeLineDetailContentView.m
//  LittleSix
//
//  Created by Jim huang on 17/3/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSHomeTimeLinePicContentView.h"
#import "LSTimeLineTableListModel.h"

@interface LSHomeTimeLinePicContentView ()

@property(nonatomic,strong) UILabel *contentLabel;
@property(nonatomic,strong) UIButton *goodBtn;
@property(nonatomic,strong) UIButton *commentBtn;
@property(nonatomic,strong) UIButton *goodCommentDetailBtn;

@end

@implementation LSHomeTimeLinePicContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setConstrains];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setConstrains{
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.5;
    [self addSubview:bgView];
    
    self.contentLabel = [UILabel new];
    self.contentLabel.textColor = [UIColor whiteColor];
    self.contentLabel.font = [UIFont systemFontOfSize:13];
    self.contentLabel.preferredMaxLayoutWidth = kScreenWidth;
    self.contentLabel.numberOfLines =0;

    [self addSubview:self.contentLabel];
    
    self.goodBtn = [UIButton new];
    [self.goodBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.goodBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self addSubview:self.goodBtn];
    
    self.commentBtn = [UIButton new];
    [self.commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.commentBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self addSubview:self.commentBtn];
    
    self.goodCommentDetailBtn = [UIButton new];
    [self.goodCommentDetailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.goodCommentDetailBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.goodCommentDetailBtn addTarget:self action:@selector(clickDetailBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.goodCommentDetailBtn];
    
    [self.goodBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(5);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(40);
    }];
    
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.goodBtn.mas_right);
        make.bottom.width.height.equalTo(self.goodBtn);
    }];
    
    [self.goodCommentDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self);
        make.height.equalTo(self.goodBtn);
        make.width.mas_equalTo(80);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.goodBtn.mas_top);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self);
    }];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.contentLabel);
    }];
}

-(void)setModel:(LSTimeLineTableListModel *)model{
    _model = model;
    self.contentLabel.text =model.content;
    [self.goodBtn setTitle:[NSString stringWithFormat:@"%lu赞",(unsigned long)model.praise_list.count] forState:UIControlStateNormal];
    [self.commentBtn setTitle:[NSString stringWithFormat:@"%lu评论",(unsigned long)model.comment_list.count] forState:UIControlStateNormal];
    [self.goodCommentDetailBtn setTitle:@"详情" forState:UIControlStateNormal];

}


-(void)clickDetailBtn{
    if ([self.delegate respondsToSelector:@selector(TimeLinePicContentViewClickDetailBtnWithView:)]) {
        [self.delegate TimeLinePicContentViewClickDetailBtnWithView:self];
    }
}
@end
