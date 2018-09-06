//
//  LSPostCommentView.m
//  LittleSix
//
//  Created by Jim huang on 17/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPostCommentView.h"
#import "LSTimeLineTableListModel.h"
#import "UIView+HUD.h"

@interface LSPostCommentView ()
@property (nonatomic,strong) UIButton * BGBtn;
@property (nonatomic,strong) UIView * commentView;

@property (nonatomic,strong)UIButton *sendBtn;

@end

@implementation LSPostCommentView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setConstraints];

    }
    return self;
}

-(void)setConstraints{
    
    UIButton * bgBtn = [UIButton new];
    bgBtn.backgroundColor = [UIColor blackColor];
    [bgBtn addTarget:self action:@selector(bgBtnAction) forControlEvents:UIControlEventTouchUpInside];
    bgBtn.alpha = 0.1;
    [self addSubview:bgBtn];
    
    [bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    UIView * commentView = [UIView new];
    
    commentView.backgroundColor = HEXRGB(0xf3f3f3);
    commentView.layer.borderColor  = HEXRGB(0xdddddd).CGColor;
    commentView.layer.borderWidth = 1;
    [self addSubview:commentView];
    
    [commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.mas_offset(50);
    }];

    self.commentTextField = [UITextField new];
    self.commentTextField.font = [UIFont systemFontOfSize:16];
    self.commentTextField.backgroundColor = HEXRGB(0xFFFFFF);
    self.commentTextField.layer.cornerRadius = 4.5;
    self.commentTextField.layer.masksToBounds = YES;
    self.commentTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    self.commentTextField.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    self.commentTextField.leftViewMode = UITextFieldViewModeAlways;
    self.commentTextField.rightViewMode = UITextFieldViewModeAlways;
    self.commentTextField.layer.borderColor  = HEXRGB(0xdddddd).CGColor;
    self.commentTextField.layer.borderWidth = 1;
    [commentView addSubview:self.commentTextField];

    self.sendBtn = [UIButton new];
    self.sendBtn.backgroundColor = HEXRGB(0xFD2741);
    [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;

    [commentView addSubview:self.sendBtn];
    [self.sendBtn addTarget:self action:@selector(sendNewComment) forControlEvents:UIControlEventTouchUpInside];


    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(commentView).with.offset(-10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];

    [self.commentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(commentView).with.offset(7.5);
        make.bottom.equalTo(commentView).with.offset(-7.5);
        make.right.equalTo (self.sendBtn.mas_left).with.offset(-10);
    }];
    
}


-(void)bgBtnAction{
    [self endEditing:YES];
    self.hidden = YES;
    
}



-(void)setModel:(LSTimeLineTableListModel *)model{
    _model = model;
    self.commentTextField.placeholder = @"";
}


-(void)setCommentModel:(LSTimeLineCommentModel *)commentModel{
    _commentModel = commentModel;
    self.commentTextField.placeholder = [NSString stringWithFormat:@"回复%@",commentModel.uid_from_name];
}

-(void)sendNewComment{
    [LSKeyWindow showLoading];
    if (self.type == postCommentTypeNew) {
        
        [LSTimeLineTableListModel addTimeLineCommentWithfeed_id:self.model.feed_id content:self.commentTextField.text pid:0 uid_to:0 success:^(NSString *string) {
            [self getNewContent];

        } failure:^(NSError *error) {
            [LSKeyWindow hideHUDAnimated:YES];


        }];

    }else{
        [LSTimeLineTableListModel addTimeLineCommentWithfeed_id:self.commentModel.feed_id content:self.commentTextField.text pid:self.commentModel.comm_id uid_to:self.commentModel.uid_from success:^(NSString *string) {
            
            [self getNewContent];
        } failure:^(NSError *error) {
            [LSKeyWindow hideHUDAnimated:YES];


        }];
    }
    

}

-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    self.commentTextField.text = @"";
}

-(void)getNewContent{
    int feedid ;
    if (self.type ==postCommentTypeNew)
        feedid = self.model.feed_id;
    else
        feedid = self.commentModel.feed_id;
    [LSTimeLineTableListModel loadTimeLineDetailWithfeed_id:feedid success:^(LSTimeLineTableListModel *model) {
        [LSKeyWindow hideHUDAnimated:YES];
        self.commentTextField.text = @"";
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:model forKey:@"newModel"];
        [dic setObject:[NSNumber numberWithInt:self.index] forKey:@"index"];
        [[NSNotificationCenter defaultCenter]postNotificationName:TimeLineReloadCellNoti object:nil userInfo:dic];
    } failure:^(NSError *error) {
        [LSKeyWindow hideHUDAnimated:YES];

    }];
}

@end
