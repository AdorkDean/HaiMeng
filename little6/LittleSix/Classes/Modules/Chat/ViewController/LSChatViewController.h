//
//  LSChatViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSConversationModel;
@interface LSChatViewController : UIViewController

@property (nonatomic,strong) LSConversationModel *conversation;

- (instancetype)initWithConversation:(LSConversationModel *)model;

@end
