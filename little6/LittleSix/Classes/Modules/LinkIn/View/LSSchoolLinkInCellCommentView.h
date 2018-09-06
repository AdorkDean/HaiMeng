//
//  LSSchoolLinkInCellCommentView.h
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalDefines.h"

@class LSLinkInCellCommentItemModel,LSLinkInCellLikeItemModel;

@protocol LSSchoolLinkInCellCommentDelegate <NSObject>

//点击评论
-(void)didAllClickWithModel:(LSLinkInCellCommentItemModel *)model;

@optional

//长按评论
-(void)didLongAllPressWithModel:(LSLinkInCellCommentItemModel *)model;

//点击用户链接
-(void)didClickLink:(NSString *)user_id WithUserName:(NSString *)user_name andModel:(LSLinkInCellCommentItemModel *)model;

//点击赞事件
-(void)didClickPraise:(LSLinkInCellLikeItemModel *)model;

@end

@interface LSSchoolLinkInCellCommentView : UIView


- (void)setupWithLikeItemsArray:(NSArray *)likeItemsArray commentItemsArray:(NSArray *)commentItemsArray;

@property (nonatomic, weak) id<LSSchoolLinkInCellCommentDelegate> delegate; //这个优先级没有block高

@end
