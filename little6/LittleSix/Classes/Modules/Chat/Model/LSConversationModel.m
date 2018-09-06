//
//  LSConversationModel.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSConversationModel.h"
#import "LSMessageManager.h"

@implementation LSConversationModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self modelEncodeWithCoder:aCoder];
}
    
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self modelCopy];
}

- (void)setLastMessage:(LSMessageModel *)lastMessage {
    _lastMessage = lastMessage;
    self.lastUpdateTimeStamp = lastMessage.timeStamp;
}

- (void)setUnReadCount:(NSInteger)unReadCount {
    _unReadCount = unReadCount;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageUnReadCountDidChange object:nil];
}

@end
