//
//  LSConversationModel.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMessageModel.h"

@interface LSConversationModel : NSObject <NSCoding,NSCopying>

@property (nonatomic,assign) LSConversationType type;

@property (nonatomic,copy)   NSString *conversationId;

@property (nonatomic,assign) NSInteger unReadCount;

@property (nonatomic,copy)   NSString *title;
@property (nonatomic,copy)   NSString *avartar;

@property (nonatomic,strong) LSMessageModel *lastMessage;

@property (nonatomic,assign) NSTimeInterval lastUpdateTimeStamp;

@end
