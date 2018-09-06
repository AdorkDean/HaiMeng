//
//  LSSchoolLinkInCellCommentView.m
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSchoolLinkInCellCommentView.h"

#import "UIView+SDAutoLayout.h"
#import "LSLinkInCellModel.h"
#import "MLLinkLabel.h"
#import "UILabel+LSUtil.h"
#import "LSLinkInCellModel.h"

const CGFloat contentFontSize = 15;
@interface LSSchoolLinkInCellCommentView ()<MLLinkLabelDelegate,YBAttributeTapActionDelegate>

@property (nonatomic, strong) NSArray *likeItemsArray;
@property (nonatomic, strong) NSArray *commentItemsArray;

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *likeLabel;
@property (nonatomic, strong) UIView *likeLableBottomLine;

@property (nonatomic, strong) NSMutableArray *commentLabelsArray;
@property (nonatomic, strong) UIImageView * praiseImage;

@end

@implementation LSSchoolLinkInCellCommentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _bgImageView = [UIImageView new];
    UIImage *bgImage = [[UIImage imageNamed:@"LikeCmtBg"] stretchableImageWithLeftCapWidth:40 topCapHeight:30];
    _bgImageView.image = bgImage;
    [self addSubview:_bgImageView];
    
    self.praiseImage = [UIImageView new];
    [self addSubview:self.praiseImage];
    [self.praiseImage mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top).offset(10);
        make.left.equalTo(self.mas_left).offset(5);
        make.width.height.equalTo(@(18));
    }];
    
    _likeLabel = [UILabel new];
    _likeLabel.textColor = [UIColor colorWithRed:126/255.0 green:167/255.0 blue:208/255.0 alpha:1.0];
    _likeLabel.numberOfLines = 0;
    _likeLabel.font = [UIFont systemFontOfSize:contentFontSize];
    [self addSubview:_likeLabel];
    [self bringSubviewToFront:_likeLabel];
    
    _likeLableBottomLine = [UIView new];
    _likeLableBottomLine.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_likeLableBottomLine];
    
    [self.likeLableBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_likeLabel.mas_bottom).offset(5);
        make.left.equalTo(self.mas_left).offset(5);
        make.width.height.offset(0.5);
        make.right.equalTo(self.mas_right).offset(-5);
    }];
    
    _bgImageView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    
}

- (void)setCommentItemsArray:(NSArray *)commentItemsArray
{
    _commentItemsArray = commentItemsArray;
    
    long originalLabelsCount = self.commentLabelsArray.count;
    long needsToAddCount = commentItemsArray.count > originalLabelsCount ? (commentItemsArray.count - originalLabelsCount) : 0;
    
    for (int i = 0; i < needsToAddCount; i++) {
        MLLinkLabel *label = [MLLinkLabel new];
        UIColor *highLightColor = TimeLineCellHighlightedColor;
        label.linkTextAttributes = @{NSForegroundColorAttributeName : highLightColor};
        label.font = [UIFont systemFontOfSize:contentFontSize];
        label.tag = 100+i;
        label.delegate = self;
        [self addSubview:label];
        [self.commentLabelsArray addObject:label];
        
    }
    
    for (int i = 0; i < commentItemsArray.count; i++) {
        LSLinkInCellCommentItemModel *model = commentItemsArray[i];
        MLLinkLabel *label = self.commentLabelsArray[i];
        
        label.attributedText = [self generateAttributedStringWithCommentItemModel:model];
        
    }
    

}

- (NSMutableArray *)commentLabelsArray {
    
    if (!_commentLabelsArray) {
        _commentLabelsArray = [NSMutableArray new];
    }
    return _commentLabelsArray;
}


- (void)setupWithLikeItemsArray:(NSArray *)likeItemsArray commentItemsArray:(NSArray *)commentItemsArray {
    
    self.likeItemsArray = [NSMutableArray arrayWithArray:likeItemsArray];
    self.commentItemsArray = [NSMutableArray arrayWithArray:commentItemsArray];
    
    [_likeLabel sd_clearAutoLayoutSettings];
    _likeLabel.frame = CGRectZero;
    
    
    if (self.commentLabelsArray.count) {
        [self.commentLabelsArray enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            [label sd_clearAutoLayoutSettings];
            label.frame = CGRectZero;
        }];
    }
    
    CGFloat margin = 10;
    
    if (likeItemsArray.count != 0) {
        
        _likeLabel.sd_layout
        .leftSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .topSpaceToView(self, margin)
        .autoHeightRatio(0);
        self.praiseImage.image = [UIImage imageNamed:@"linkin_like"];
        _likeLabel.isAttributedContent = YES;
        _likeLableBottomLine.hidden = NO;
    }else{
        self.praiseImage.image = [UIImage imageNamed:@""];
        _likeLableBottomLine.hidden = YES;
    }
    NSString * tempLike = @"    ";
    NSMutableArray * linkNameArr = [NSMutableArray array];

    for (int i = 0; i < self.likeItemsArray.count; i ++) {
        
        LSLinkInCellLikeItemModel *model = self.likeItemsArray[i];
        if (i == 0) {
            tempLike = [NSString stringWithFormat:@"%@  %@",tempLike,model.user_name];
        }else{
            tempLike = [NSString stringWithFormat:@"%@,%@",tempLike,model.user_name];
        }
        [linkNameArr addObject:model.user_name];
        
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:tempLike];
    
    _likeLabel.attributedText = attributedString;
    
    [_likeLabel yb_addAttributeTapActionWithStrings:linkNameArr delegate:self];
    
    
    UIView *lastTopView = _likeLabel;
    
    for (int i = 0; i < self.commentItemsArray.count; i++) {
        
        UILabel *label = (UILabel *)self.commentLabelsArray[i];
        CGFloat topMargin = i == 0 ? 10 : 5;
        label.sd_layout
        .leftSpaceToView(self, 8)
        .rightSpaceToView(self, 5)
        .topSpaceToView(lastTopView, topMargin)
        .autoHeightRatio(0);
        
        label.tag = 10+i;
        label.isAttributedContent = YES;
        lastTopView = label;
        
    }
    
    [self setupAutoHeightWithBottomView:lastTopView bottomMargin:6];
    
}

- (void)yb_attributeTapReturnString:(NSString *)string range:(NSRange)range index:(NSInteger)index {
    
    NSLog(@"yb_attributeTapReturnString====%@", string);
    LSLinkInCellLikeItemModel *model = self.likeItemsArray[index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickPraise:)]) {
        [self.delegate didClickPraise:model];
    }
}

#pragma mark - private actions

- (NSMutableAttributedString *)generateAttributedStringWithCommentItemModel:(LSLinkInCellCommentItemModel *)model {
    
    NSString *text = model.uid_from_name;
    if (![model.uid_to_name isEqualToString:model.uid_from_name]) {
        
        if (model.uid_to_name.length) {
            text = [text stringByAppendingString:[NSString stringWithFormat:@"回复%@", model.uid_to_name]];
        }
    }
    
    text = [text stringByAppendingString:[NSString stringWithFormat:@":%@", model.content]];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
    UIColor *highLightColor = [UIColor blueColor];
    NSString * uid_from = [NSString stringWithFormat:@"%d",model.uid_from];
    [attString setAttributes:@{NSForegroundColorAttributeName : highLightColor, NSLinkAttributeName :uid_from} range:[text rangeOfString:model.uid_from_name]];
    if (model.uid_to_name) {
        NSString * uid_to = [NSString stringWithFormat:@"%d",model.uid_to];
        [attString setAttributes:@{NSForegroundColorAttributeName : highLightColor, NSLinkAttributeName : uid_to} range:[text rangeOfString:model.uid_to_name]];
    }
    return attString;
}


#pragma mark - MLLinkLabelDelegate

- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel {
    
    NSLog(@"didClickLink====%@", link.linkValue);
    LSLinkInCellCommentItemModel *model = self.commentItemsArray[linkLabel.tag-10];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickLink:WithUserName:andModel:)]) {
        [self.delegate didClickLink:link.linkValue WithUserName:linkText andModel:model];
    }
}

- (void)didLongPressLink:(MLLink*)link linkText:(NSString*)linkText linkLabel:(MLLinkLabel*)linkLabel {
    
    NSLog(@"didLongPressLink====%@", link.linkValue);

}
-(void)didAllClickLinkLabel:(MLLinkLabel *)linkLabel {
    
    LSLinkInCellCommentItemModel *model = self.commentItemsArray[linkLabel.tag-10];
    if ([ShareAppManager.loginUser.user_id intValue] != model.uid_from) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didAllClickWithModel:)]) {
            [self.delegate didAllClickWithModel:model];
        }
    }
    
}
-(void)didLongAllPressLinkLabel:(MLLinkLabel *)linkLabel {

    LSLinkInCellCommentItemModel *model = self.commentItemsArray[linkLabel.tag-10];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLongAllPressWithModel:)]) {
        [self.delegate didLongAllPressWithModel:model];
    }
}

@end
