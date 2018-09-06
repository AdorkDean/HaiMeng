//
//  LSLinkInDateilSchoolCell.h
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSLinkInCellModel,LSLinkInCellCommentItemModel,LSLinkInCellLikeItemModel,LSLinkInFileModel;

@protocol LSLinkInDateilSchoolCellDelegate <NSObject>

//点击评论
-(void)didAllClickWithModel:(LSLinkInCellCommentItemModel *)model andNSIndexPath:(NSIndexPath *)indexPath;

@optional

//长按内容
-(void)didLongAllPresscontentWithModel:(LSLinkInCellModel *)model;

//长按评论
-(void)didLongAllPressWithModel:(LSLinkInCellCommentItemModel *)model andNSIndexPath:(NSIndexPath *)indexPath;

//跳转人脉中心代理事件
-(void)didLinkinGoWithModel:(LSLinkInCellModel *)linkModel;

//点击用户链接
-(void)didClickLink:(NSString *)user_id WithUserName:(NSString *)user_name andModel:(LSLinkInCellCommentItemModel *)model;

//点击收起和全文
-(void)didMoreButtonClickedNSIndexPath:(NSIndexPath *)indexPath;

//点赞，评论
-(void)didOperationButtonClickedNSIndexPath:(NSIndexPath *)indexPath andButton:(UIButton *)sender andModel:(LSLinkInCellModel *)model;

//删除帖子
-(void)delectClickLinkNSIndexPath:(NSIndexPath *)indexPath WithModel:(LSLinkInCellModel *)model;

//点击赞事件
-(void)didClickPraise:(LSLinkInCellLikeItemModel *)model;

//点击播放视频
-(void)didClickPlayVideo:(LSLinkInFileModel *)lFileModel;

//report
-(void)didClickReport:(LSLinkInCellModel *)reportModel;

@end

@interface LSLinkInDateilSchoolCell : UITableViewCell

@property (nonatomic, strong) LSLinkInCellModel *model;
//
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id<LSLinkInDateilSchoolCellDelegate> delegate; //这个优先级没有block高

@end
