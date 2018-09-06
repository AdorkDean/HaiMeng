//
//  LSLinkInDateilSchoolCell.m
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkInDateilSchoolCell.h"
#import "LSLinkInCellModel.h"
#import "UIView+SDAutoLayout.h"
#include "GlobalDefines.h"

#import "LSSchoolLinkInCellCommentView.h"
#import "LSPhotoContainerView.h"

const CGFloat contentLabelFontSize = 15;
CGFloat maxContentLabelHeight = 0; // 根据具体font而定

@interface LSLinkInDateilSchoolCell()<LSSchoolLinkInCellCommentDelegate,LSPhotoContainerViewDelegate> {
    
    UIImageView *_reportView;
    
    UIImageView *_iconView;
    UILabel *_nameLable;
    UILabel *_contentLabel;
    LSPhotoContainerView *_picContainerView;
    UILabel *_timeLabel;
    UIButton *_moreButton;
    UIButton *_operationButton;
    LSSchoolLinkInCellCommentView *_commentView;
    BOOL _shouldOpenContentLabel;
    
    UIButton * _delectBtn;
}

@end

@implementation LSLinkInDateilSchoolCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setup
{
    _shouldOpenContentLabel = NO;
    
    _reportView = [UIImageView new];
    _reportView.userInteractionEnabled = YES;
    UITapGestureRecognizer * reportTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reportTapClick:)];
    [_reportView addGestureRecognizer:reportTap];
    _reportView.image = [UIImage imageNamed:@"arrows_unfold"];
    [self addSubview:_reportView];
    [_reportView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(15);
        make.right.equalTo(self.mas_right).offset(-15);
        make.width.offset(17);
        make.height.offset(10);
    }];
    
    _iconView = [UIImageView new];
    _iconView.userInteractionEnabled = YES;
    UITapGestureRecognizer * iconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTapClick:)];
    [_iconView addGestureRecognizer:iconTap];
    
    _nameLable = [UILabel new];
    _nameLable.font = [UIFont systemFontOfSize:15];
    _nameLable.userInteractionEnabled = YES;
    _nameLable.textColor = [UIColor colorWithRed:(54 / 255.0) green:(71 / 255.0) blue:(121 / 255.0) alpha:0.9];
    
    UITapGestureRecognizer * nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTapClick:)];
    [_nameLable addGestureRecognizer:nameTap];
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
    _contentLabel.numberOfLines = 0;
    if (maxContentLabelHeight == 0) {
        maxContentLabelHeight = _contentLabel.font.lineHeight * 5;
    }
    
    _moreButton = [UIButton new];
    [_moreButton setTitle:@"全文" forState:UIControlStateNormal];
    [_moreButton setTitleColor:TimeLineCellHighlightedColor forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    _operationButton = [UIButton new];
    [_operationButton setImage:[UIImage imageNamed:@"AlbumOperateMore"] forState:UIControlStateNormal];
    [_operationButton addTarget:self action:@selector(operationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _picContainerView = [LSPhotoContainerView new];
    _picContainerView.delegate = self;
    
    
    _commentView = [LSSchoolLinkInCellCommentView new];
    _commentView.delegate = self;
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.textColor = [UIColor lightGrayColor];
    
    _delectBtn = [UIButton new];
    [_delectBtn setTitle:@"删除" forState:UIControlStateNormal];
    [_delectBtn setTitleColor:TimeLineCellHighlightedColor forState:UIControlStateNormal];
    
    [_delectBtn addTarget:self action:@selector(delectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _delectBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    
    
    NSArray *views = @[_iconView, _nameLable, _contentLabel, _moreButton, _picContainerView, _timeLabel, _operationButton, _commentView,_delectBtn];
    
    [self.contentView sd_addSubviews:views];

    UIView *contentView = self.contentView;
    CGFloat margin = 10;
    
    _iconView.sd_layout
    .leftSpaceToView(contentView, margin)
    .topSpaceToView(contentView, margin + 5)
    .widthIs(40)
    .heightIs(40);
    
    _nameLable.sd_layout
    .leftSpaceToView(_iconView, margin)
    .topEqualToView(_iconView)
    .heightIs(18);
    [_nameLable setSingleLineAutoResizeWithMaxWidth:200];
    
    _contentLabel.sd_layout
    .leftEqualToView(_nameLable)
    .topSpaceToView(_nameLable, margin)
    .rightSpaceToView(contentView, margin)
    .autoHeightRatio(0);
    
    // morebutton的高度在setmodel里面设置
    _moreButton.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_contentLabel, 0)
    .widthIs(30);
    
    
    _picContainerView.sd_layout
    .leftEqualToView(_contentLabel); // 已经在内部实现宽度和高度自适应所以不需要再设置宽度高度，top值是具体有无图片在setModel方法中设置
    
    _timeLabel.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_picContainerView, margin)
    .heightIs(15)
    .widthIs(100);
    
    _delectBtn.sd_layout
    .leftSpaceToView(_timeLabel,margin)
    .topSpaceToView(_picContainerView, margin)
    .widthIs(40)
    .heightIs(20);
    
    _operationButton.sd_layout
    .rightSpaceToView(contentView, margin)
    .centerYEqualToView(_timeLabel)
    .heightIs(25)
    .widthIs(25);
    
    _commentView.sd_layout
    .leftEqualToView(_contentLabel)
    .rightSpaceToView(self.contentView, margin)
    .topSpaceToView(_timeLabel, margin); // 已经在内部实现高度自适应所以不需要再设置高度
    
    UILongPressGestureRecognizer * contentLabelTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(contentClick:)];
    _contentLabel.userInteractionEnabled = YES;
    [_contentLabel addGestureRecognizer:contentLabelTap];
}


- (void)setModel:(LSLinkInCellModel *)model
{
    _model = model;
    
    _delectBtn.hidden = [model.user_id isEqualToString:ShareAppManager.loginUser.user_id] ? NO: YES;
    _reportView.hidden = [model.user_id isEqualToString:ShareAppManager.loginUser.user_id] ? YES: NO;
    
    _commentView.frame = CGRectZero;
    [_commentView setupWithLikeItemsArray:model.praise_list commentItemsArray:model.comment_list];
    
    _shouldOpenContentLabel = NO;
    
    [_iconView setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:timeLineSmallPlaceholderName];
    _nameLable.text = model.user_name;
    // 防止单行文本label在重用时宽度计算不准的问题
    [_nameLable sizeToFit];
    
    _contentLabel.text = model.content;
    
    _picContainerView.picPathStringsArray = model.files;
    _picContainerView.model = model;
    
    if (model.shouldShowMoreButton) { // 如果文字高度超过60
        _moreButton.sd_layout.heightIs(20);
        _moreButton.hidden = NO;
        if (model.isOpening) { // 如果需要展开
            _contentLabel.sd_layout.maxHeightIs(MAXFLOAT);
            [_moreButton setTitle:@"收起" forState:UIControlStateNormal];
        } else {
            _contentLabel.sd_layout.maxHeightIs(maxContentLabelHeight);
            [_moreButton setTitle:@"全文" forState:UIControlStateNormal];
        }
    } else {
        _moreButton.sd_layout.heightIs(0);
        _moreButton.hidden = YES;
    }
    
    CGFloat picContainerTopMargin = 0;
    if (model.files.count) {
        picContainerTopMargin = 10;
    }
    _picContainerView.sd_layout.topSpaceToView(_moreButton, picContainerTopMargin);
    
    UIView *bottomView;
    
    if (!model.comment_list.count && !model.praise_list.count) {
        _commentView.fixedWith = @0; // 如果没有评论或者点赞，设置commentview的固定宽度为0（设置了fixedWith的控件将不再在自动布局过程中调整宽度）
        _commentView.fixedHeight = @0; // 如果没有评论或者点赞，设置commentview的固定高度为0（设置了fixedHeight的控件将不再在自动布局过程中调整高度）
        _commentView.sd_layout.topSpaceToView(_timeLabel, 0);
        bottomView = _timeLabel;
    } else {
        
        _commentView.fixedHeight =nil; // 取消固定宽度约束
        _commentView.fixedWith = nil; // 取消固定高度约束
        _commentView.sd_layout.topSpaceToView(_timeLabel, 10);
        bottomView = _commentView;
    }
    
    NSInteger bottomH =  15;
    [self setupAutoHeightWithBottomView:bottomView bottomMargin:bottomH];
    
    _timeLabel.text = model.add_time;
}

#pragma mark - private actions

- (void)reportTapClick:(UITapGestureRecognizer *)tap {

    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickReport:)]) {
        [self.delegate didClickReport:self.model];
    }
}

- (void)moreButtonClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMoreButtonClickedNSIndexPath:)]) {
        [self.delegate didMoreButtonClickedNSIndexPath:self.indexPath];
    }
}

- (void)operationButtonClicked:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didOperationButtonClickedNSIndexPath:andButton:andModel:)]) {
        [self.delegate didOperationButtonClickedNSIndexPath:self.indexPath andButton:sender andModel:self.model];
    }
}

-(void)delectBtnClicked:(UIButton *)sender{

    if (self.delegate && [self.delegate respondsToSelector:@selector(delectClickLinkNSIndexPath:WithModel:)]) {
        [self.delegate delectClickLinkNSIndexPath:self.indexPath WithModel:self.model];
    }
}

#define icon -- 点击事件
- (void)iconTapClick:(UITapGestureRecognizer *)tap {

    if (self.delegate && [self.delegate respondsToSelector:@selector(didLinkinGoWithModel:)]) {
        
        [self.delegate didLinkinGoWithModel:self.model];
    }
}

- (void)contentClick:(UITapGestureRecognizer *)tap {
    
    if (tap.state == UIGestureRecognizerStateBegan){
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didLongAllPresscontentWithModel:)]) {
            [self.delegate didLongAllPresscontentWithModel:self.model];
        }
    }
}

//点击评论
- (void)didAllClickWithModel:(LSLinkInCellCommentItemModel *)model {

    if (self.delegate && [self.delegate respondsToSelector:@selector(didAllClickWithModel:andNSIndexPath:)]) {
        [self.delegate didAllClickWithModel:model andNSIndexPath:self.indexPath];
    }
}

//长按评论
- (void)didLongAllPressWithModel:(LSLinkInCellCommentItemModel *)model {

    //创建一个菜单控制器  单例
    if ([ShareAppManager.loginUser.user_id isEqualToString:[NSString stringWithFormat:@"%d",model.uid_from]]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didLongAllPressWithModel:andNSIndexPath:)]) {
            [self.delegate didLongAllPressWithModel:model andNSIndexPath:self.indexPath];
        }
    }
    
}

//点击用户链接
- (void)didClickLink:(NSString *)user_id WithUserName:(NSString *)user_name andModel:(LSLinkInCellCommentItemModel *)model {

    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickLink:WithUserName:andModel:)]) {
        [self.delegate didClickLink:user_id WithUserName:user_name andModel:model];
    }
}

//点击赞事件
- (void)didClickPraise:(LSLinkInCellLikeItemModel *)model {

    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickPraise:)]) {
        [self.delegate didClickPraise:model];
    }
}

//点击播放视频
- (void)didClickVideo:(LSLinkInFileModel *)lFileModel {

    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickPlayVideo:)]) {
        [self.delegate didClickPlayVideo:lFileModel];
    }
}

@end
