//
//  LSGroupChatDetailsViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/3/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSGroupModel,LSConversationModel;
@interface LSGroupChatDetailsViewController : UITableViewController

@property (nonatomic, strong) LSConversationModel *conversation;
@property (nonatomic, strong)LSGroupModel * gmodel;
@property (nonatomic, copy) NSString * groupid;

@end

@protocol LSGroupChatTableViewCellDelegate <NSObject>

@optional

- (void)didClickRow:(NSIndexPath *)indexPath withArr:(NSArray *)list;

@end;

@interface GroupChatTableViewCell : UITableViewCell

@property (nonatomic, strong)NSArray * list;

@property (nonatomic, copy)NSString * userId;

@property (nonatomic, weak) id<LSGroupChatTableViewCellDelegate> delegate;

@property (nonatomic, copy) void(^removeClick)(NSString * members);

@property (nonatomic, copy) void(^nextClick)(NSArray * members);

@end
