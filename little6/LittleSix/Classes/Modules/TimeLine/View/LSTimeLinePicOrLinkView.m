//
//  LSTimeLinePicOrLinkView.m
//  LittleSix
//
//  Created by Jim huang on 17/2/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTimeLinePicOrLinkView.h"
#import "NSArray+layoutNineSubViews.h"
#import "LSTimeLineTableListModel.h"
#import "LSPlayerVideoView.h"
#import "YYPhotoGroupView.h"

@interface LSTimeLinePicOrLinkView ()
@property (nonatomic,strong) UIView *picView;
@property (nonatomic,strong) UIView *linkView;

@property (nonatomic,strong) NSMutableArray *file_thumbArr;
@property (nonatomic,strong) NSMutableArray *file_urlArr;

@property(nonatomic,strong) NSArray *picArr;

@property (nonatomic,weak) UIImageView * videoImageView;


@end

@implementation LSTimeLinePicOrLinkView


-(void)setPicArr:(NSArray *)picArr{
    _picArr = picArr;
    
    self.file_urlArr = [NSMutableArray array];
    self.file_thumbArr = [NSMutableArray array];
    for (LSTimeLineImageModel * imageModel in picArr) {
        
        if(![imageModel.file_url isEqualToString:@""] && ![imageModel.file_thumb isEqualToString:@""]){
            [self.file_urlArr addObject:imageModel.file_url];
            [self.file_thumbArr addObject:imageModel.file_thumb];
        }
    }
    for (UIView * view in self.subviews) {
        [view removeFromSuperview];
    }
    if (self.file_urlArr.count>0 && self.file_thumbArr.count>0) {
        [self setPicView];
    }else{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

-(void)setModel:(LSTimeLineTableListModel *)model{
    _model = model;
    if (model.feed_type == 1) {
        self.type = LSPicOrLinkTypePic;
    }else if (model.feed_type == 2){
        self.type = LSPicOrLinkTypeVideo;
    }
    self.picArr = model.files;
}

-(void)setPicView{
    for (int i = 0; i < self.file_thumbArr.count; i++) {
        UIView *view = [UIView new];
        [self addSubview:view];
        
        UIImageView *picView = [[UIImageView alloc] init];
        [view addSubview:picView];

        picView.contentMode = UIViewContentModeScaleAspectFill;
        
        picView.layer.masksToBounds = YES;
        if(self.type == LSPicOrLinkTypeVideo){
            self.videoImageView = picView;
        }
        
        [picView setImageWithURL:self.file_thumbArr[i] placeholder:timeLineSmallPlaceholderName];

        picView.tag = 1000+i;
        
        UIControl * control = [UIControl new];
        control.tag = i;
        [control addTarget:self action:@selector(openPhotoWithIndex:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:control];
        

        [picView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(view);
        }];
        [control mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(view);
        }];
        
    }
    
        CGFloat count = self.file_urlArr.count;
        CGFloat picViewHeight;

        if (count == 1 ||self.type == LSPicOrLinkTypeVideo) {

            picViewHeight = 180;
            
        }else if (count>1&&count<4){
    
            picViewHeight = 90;
    
        }else if (count>=4&&count<7){
    
            picViewHeight = 175;
        }else if(count>=7){
    
            picViewHeight = 257;
        }else if(count == 0){
            picViewHeight = 0;
        }
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(picViewHeight);
    }];
//     执行九宫格布局
    
    if (count>1) {
        [self.subviews mas_distributeSudokuViewsWithFixedItemWidth:0 fixedItemHeight:0 fixedLineSpacing:5 fixedInteritemSpacing:5 warpCount:3 topSpacing:5 bottomSpacing:5 leadSpacing:5 tailSpacing:5];
    }else if(self.type == LSPicOrLinkTypeVideo){
        
        for (UIView * view in self.subviews) {
            UIImageView * playIconImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"video_mn_play"]];
            
            [view addSubview:playIconImageView];
            
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.bottom.equalTo(self);
                make.width.mas_equalTo(112);
            }];
            
            [playIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.centerY.equalTo(view);
                make.width.height.mas_equalTo(30);
            }];
        }
        
    }else{
        for (UIView * view in self.subviews) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.bottom.equalTo(self);
                make.width.equalTo(self.mas_height).multipliedBy(1);
            }];
        }
    }

}


-(void)openPhotoWithIndex:(UIControl *)control{
    if (self.type == LSPicOrLinkTypePic) {
        
        NSMutableArray<YYPhotoGroupItem *> *items = [NSMutableArray array];
        
        for (int i = 0; i<self.file_thumbArr.count; i++) {
            YYPhotoGroupItem *item = [YYPhotoGroupItem new];
            item.largeImageURL = [NSURL URLWithString:self.file_urlArr[i]];
            item.thumbView = [self viewWithTag:1000+i];
            [items addObject:item];
        }

        YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
        UIView *fromView = [self viewWithTag:1000+control.tag];
        [v presentFromImageView:fromView toContainer:LSKeyWindow animated:YES completion:nil];
        
    }else if (self.type == LSPicOrLinkTypeVideo){
        
        if (self.file_urlArr.count>0 && self.file_thumbArr.count>0) {
            NSString * UrlStr = self.file_urlArr[0];
            NSDictionary * dic = @{@"UrlStr":UrlStr};
            [[NSNotificationCenter defaultCenter] postNotificationName:TimeLinePlayVideoNoti object:self.videoImageView.image userInfo:dic];
            
//            [LSPlayerVideoView showFromView:self withCoverImage:self.videoImageView.image playURL:[NSURL URLWithString:UrlStr]];
        }
    }
}


-(void)setLinkViewWithCotent:(NSString *)content{
    self.linkView =[UIView new];
    [self addSubview:self.linkView];
    [self.linkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
}

@end
