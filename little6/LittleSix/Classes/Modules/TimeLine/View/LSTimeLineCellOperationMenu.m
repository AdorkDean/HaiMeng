//
//  LSTimeLineCellOperationMenu.m
//  LittleSix
//
//  Created by Jim huang on 17/3/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTimeLineCellOperationMenu.h"
#import "LSTimeLineTableListModel.h"
#import "UIView+HUD.h"

@interface LSTimeLineCellOperationMenu ()

@property(nonatomic,strong) UIButton *goodBtn;
@property(nonatomic,strong) UIButton *commentBtn;

@end

@implementation LSTimeLineCellOperationMenu

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self makeConstraints];
    }
    return self;
}

-(void)makeConstraints{
    
    self.backgroundColor = HEXRGB(0x4c5153);
        self.layer.cornerRadius = 4.5;
    self.layer.borderColor  = HEXRGB(0xdddddd).CGColor;
    self.layer.borderWidth = 1;
    
    self.goodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.goodBtn];
    [self.goodBtn setTitle:@"赞" forState:UIControlStateNormal];
    [self.goodBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.goodBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.goodBtn addTarget:self action:@selector(goodBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.commentBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.commentBtn];
    [self.commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    [self.commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.commentBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];

    UIView * marginView = [UIView new];
    marginView.backgroundColor = [UIColor blackColor];
    [self addSubview:marginView];
    
    [self.goodBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self);
        make.width.equalTo(self.mas_width).multipliedBy(0.5);
    }];
    
    [marginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(7.5);
        make.bottom.equalTo(self).offset(-7.5);
        make.width.mas_equalTo(1);
        make.left.equalTo(self.goodBtn.mas_right);
    }];
    
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(marginView.mas_right);
        make.width.equalTo(self.goodBtn);
    }];
}

- (void)setShow:(BOOL)show
{
    _show = show;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (!show) {
            self.alpha = 0;
            
        } else {
           
            self.alpha = 1;
        }
       
    }];
}

-(void)setModel:(LSTimeLineTableListModel *)model{
    if (model.is_praise ==timeLinePriseTypeIs) {
        [self.goodBtn setTitle:@"取消" forState:UIControlStateNormal];
    }else{
        [self.goodBtn setTitle:@"赞" forState:UIControlStateNormal];
    }
    
    _model = model;
}

#pragma mark -action
-(void)commentBtnClick{

    NSMutableDictionary *indexdic =[NSMutableDictionary dictionary];

    [indexdic setObject:self.model forKey:@"commentModel"];
    [indexdic setObject:[NSNumber numberWithInt:self.index] forKey:@"index"];

    [[NSNotificationCenter defaultCenter]postNotificationName:addCommentViewNoti object:nil userInfo:indexdic];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.show = NO;
    }];

}

-(void)goodBtnClick{
    
    [LSTimeLineTableListModel PriseToTimeLineWithfeed_id:self.model.feed_id type:!self.model.is_praise success:^(void) {
        
        
        [self getNewContent];
        
    } failure:^(NSError *error) {
        
    }];
}

-(void)getNewContent{
    
    [LSTimeLineTableListModel loadTimeLineDetailWithfeed_id:self.model.feed_id success:^(LSTimeLineTableListModel *model) {
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:model forKey:@"newModel"];
        [dic setObject:[NSNumber numberWithInt:self.index] forKey:@"index"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:TimeLineReloadCellNoti object:nil userInfo:dic];
        
    } failure:^(NSError *error) {
        
    }];
}



@end
