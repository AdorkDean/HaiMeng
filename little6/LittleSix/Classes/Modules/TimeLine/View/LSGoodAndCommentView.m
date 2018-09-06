//
//  LSGoodAndCommentView.m
//  LittleSix
//
//  Created by Jim huang on 17/2/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSGoodAndCommentView.h"
#import "LSTimeLineTableListModel.h"
#import "LSOptionsView.h"
#import "UIView+HUD.h"

#define textFont [UIFont boldSystemFontOfSize:14]
#define textwidth kScreenWidth - 76
#define margin 4

@interface LSGoodAndCommentView ()

@property(nonatomic,strong) YYLabel *goodLabel;

@property(nonatomic,strong) UIView *commentView;
@property(nonatomic,strong) NSMutableArray *goodArr;
@property(nonatomic,strong) NSMutableArray *commentArr;
@property(nonatomic,weak) LSOptionsView * commentOptionsView;
@end

@implementation LSGoodAndCommentView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.goodArr = [NSMutableArray array];
        self.commentArr = [NSMutableArray array];
        [self makeConstraints];
        
    }
    return self;
}

//subView布局
-(void)makeConstraints{
    
    self.goodLabel = [YYLabel new];
    self.goodLabel.numberOfLines = 0;
    self.goodLabel.preferredMaxLayoutWidth = textwidth;
    self.goodLabel.font = textFont;
    self.goodLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:self.goodLabel];
    
    UIView *marginView =[UIView new];
    [marginView setBackgroundColor:HEXRGB(0xdddddd)];
    self.marginView = marginView;
    [self addSubview:marginView];
    
    self.commentView = [UIView new];
    [self addSubview:self.commentView];
    
    [self.goodLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).with.offset(margin);
        make.right.equalTo(self).with.offset(-margin);
    }];
    
    [marginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.goodLabel.mas_bottom);
        make.left.right.equalTo(self);
    }];


    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(marginView.mas_bottom);
        make.left.right.equalTo(self.goodLabel);
    }];

}

-(void)setModel:(LSTimeLineTableListModel *)model{
    _model = model;
    
    self.goodArr = [NSMutableArray arrayWithArray:model.praise_list];
    self.commentArr = [NSMutableArray arrayWithArray:model.comment_list];
    
    if (self.goodArr.count>0&& self.commentArr.count>0) {
        [self.marginView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
        }];
    }else{
        [self.marginView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);

        }];
    }
    
    [self setGoodList];
    [self setCommentList];
}

//设置点赞列表
-(void)setGoodList{
    
    YYTextBorder *highlightBorder = [YYTextBorder new];
    highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = [UIColor lightGrayColor];
    
    
    self.goodLabel.attributedText = [[NSAttributedString alloc]initWithString:@""];

    NSMutableArray * goodList = [NSMutableArray array];


    for (int num = 0; num<self.goodArr.count; num++) {
        LSTimeLinePraiseModel *praiseModel = self.goodArr[num];
        if (num == 0){
            NSString *firstStr = [NSString stringWithFormat:@"♡%@",praiseModel.user_name];
            [goodList addObject:firstStr];

        }else{
            [goodList addObject:praiseModel.user_name];
        }
    
    }
    
    if (self.goodArr.count>0)
        self.goodLabel.textContainerInset = UIEdgeInsetsMake(2, 2, 2, 2);
    else
        self.goodLabel.textContainerInset = UIEdgeInsetsZero;

    NSString *goodListStr = [goodList componentsJoinedByString:@","];
    NSMutableAttributedString *ATTtext =[[NSMutableAttributedString alloc]initWithString:goodListStr];
    for (LSTimeLinePraiseModel *praiseModel in self.goodArr) {
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setBackgroundBorder:highlightBorder];
        @weakify(self)
        [highlight setTapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
            @strongify(self)
            self.pushUserIDBlock(praiseModel.user_id);
            
            NSLog(@"%@", praiseModel.user_name);
        }];
        NSRange range = [goodListStr rangeOfString:praiseModel.user_name options:NSCaseInsensitiveSearch];
        if (range.location == 1) {
            range.location = 0;
            range.length = range.length+1;
        }

        [ATTtext setColor:[UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000] range:range];
        [ATTtext setTextHighlight:highlight range:range];
        self.goodLabel.attributedText = ATTtext ;
    }
        

}
//设置评论列表
-(void)setCommentList{
    YYLabel *lastLabel;
    
    [self.commentView removeAllSubviews];
    for (LSTimeLineCommentModel *comentModel in self.commentArr) {

        LSCommentLabel *Tlabel = [[LSCommentLabel alloc]init];
        Tlabel.textContainerInset = UIEdgeInsetsMake(2, 2, 2, 2);
        Tlabel.font = textFont;
        Tlabel.numberOfLines =0;
        Tlabel.preferredMaxLayoutWidth = textwidth;
        Tlabel.lineBreakMode = NSLineBreakByCharWrapping;
        Tlabel.commentModel = comentModel;
        Tlabel.cellIndex = self.index;
        UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 0.15;
        [Tlabel addGestureRecognizer:longPressGr];
        
        [self.commentView addSubview:Tlabel];
        
        
        if (lastLabel) {
            [Tlabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastLabel.mas_bottom);
                make.left.equalTo(self.commentView);
                make.right.equalTo(self.commentView);
            }];
        }else{
            [Tlabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self.commentView);
            }];
        }
        YYTextBorder *highlightBorder = [YYTextBorder new];
        highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
        highlightBorder.cornerRadius = 3;
        highlightBorder.fillColor = [UIColor lightGrayColor];
        NSString * commentStr;

        if (comentModel.uid_to_name.length>0&&comentModel.uid_to!=comentModel.uid_from ) {
            commentStr = [NSString stringWithFormat:@"%@回复%@:%@",comentModel.uid_from_name,comentModel.uid_to_name,comentModel.content];
        }else{
           commentStr = [comentModel.uid_from_name stringByAppendingString:[NSString stringWithFormat:@":%@",comentModel.content]];
        }
        
        NSMutableAttributedString *ATTtext =[[NSMutableAttributedString alloc]initWithString:commentStr];
        //评论人
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setBackgroundBorder:highlightBorder];
        @weakify(self)
        
        [highlight setTapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
            @strongify(self)

            self.pushUserIDBlock(comentModel.uid_from);
            NSLog(@"%d",comentModel.uid_from);
        }];
        

        NSRange range = [commentStr rangeOfString:comentModel.uid_from_name options:NSLiteralSearch];
        [ATTtext setColor:[UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000] range:range];
        [ATTtext setTextHighlight:highlight range:range];
        
        
        if (comentModel.uid_to_name.length>0&&comentModel.uid_to!=comentModel.uid_from ) {

            YYTextHighlight *toUserHighlight = [YYTextHighlight new];
            [toUserHighlight setBackgroundBorder:highlightBorder];
            
            [toUserHighlight setTapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                @strongify(self)

                self.pushUserIDBlock(comentModel.uid_to);

                NSLog(@"%d",comentModel.uid_to);
                
            }];
            NSRange toRange = [commentStr rangeOfString:comentModel.uid_to_name options:NSLiteralSearch range:NSMakeRange(range.length, commentStr.length-range.length)];
            [ATTtext setColor:[UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000] range:toRange];
            [ATTtext setTextHighlight:toUserHighlight range:toRange];
        }
        

        Tlabel.attributedText = ATTtext;
        lastLabel = Tlabel;
    }
    [lastLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.commentView.mas_bottom);
    }];
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.commentView.mas_bottom);
    }];

}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture{
   LSCommentLabel *Tlabel  = (LSCommentLabel *) gesture.self.view;
    LSTimeLineCommentModel * model = Tlabel.commentModel;
    if (model.uid_from == ShareAppManager.loginUser.user_id.intValue) {
        
        if (self.commentOptionsView == nil) {
            LSOptionsView * optionsView = [[LSOptionsView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.frame WithData:@[@"删除"]];
            self.commentOptionsView =optionsView;
            @weakify(self)
            [optionsView setSelectCellBlock:^(NSString *title){
                @strongify(self)
                if ([title isEqualToString:@"删除"]) {
                    [LSKeyWindow showLoading];
                    [LSTimeLineTableListModel deleteTimeLineCommentWithcomm_id:model.comm_id success:^{
                        for (LSTimeLineCommentModel * commentModel in self.model.comment_list) {
                            if (commentModel.comm_id == model.comm_id) {
                                [self.model.comment_list removeObject:commentModel];
                                [LSKeyWindow showSucceed:@"删除成功" hideAfterDelay:1];
                                break;
                            }
                        }
                        
                        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                        [dic setObject:self.model forKey:@"newModel"];
                        [dic setObject:[NSNumber numberWithInt:self.index] forKey:@"index"];
                        [[NSNotificationCenter defaultCenter]postNotificationName:TimeLineReloadCellNoti object:nil userInfo:dic];
                    } failure:^(NSError *error) {
                        [LSKeyWindow showError:@"删除失败" hideAfterDelay:1];
                    }];
                }
            }];
            [[UIApplication sharedApplication].keyWindow addSubview:optionsView];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(CommentViewLongPressWithCommentModel:cellIndex:)]) {
            [self.delegate CommentViewLongPressWithCommentModel:Tlabel.commentModel cellIndex:Tlabel.cellIndex];
        }
    }
}

@end

@implementation LSCommentLabel


@end
