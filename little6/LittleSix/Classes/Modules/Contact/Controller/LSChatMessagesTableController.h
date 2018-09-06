//
//  LSChatMessagesTableController.h
//  LittleSix
//
//  Created by GMAR on 2017/3/23.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSConversationModel;
@interface LSChatMessagesTableController : UITableViewController

@property (retain,nonatomic) NSString *user_id;//联系人详情传一个用户ID过来
@property (nonatomic,strong) LSConversationModel *conversation;

@end

@protocol LSPersonsChatTableViewCellDelegate <NSObject>

@optional

- (void)didClickRow:(NSIndexPath *)indexPath withArr:(NSArray *)list;

@end;

@interface LSPersonsChatTableViewCell : UITableViewCell

@property (retain, nonatomic) NSArray * list;

@property (nonatomic, weak) id<LSPersonsChatTableViewCellDelegate> delegate;

@property (copy,nonatomic) void (^removeClick)(NSString * members);

@end
