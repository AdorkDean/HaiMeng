//
//  LSMessageManager.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/12.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSConversationModel.h"
#import <SocketRocket/SocketRocket.h>


#define ShareMessageManager [LSMessageManager sharedManager]

@protocol LSMessageManagerDelegate <NSObject>

@optional
- (void)didReceiveNewMessage:(LSMessageModel *)message;

@end


//单例类
@interface LSMessageManager : NSObject

//代理对象
@property (nonatomic,weak) id<LSMessageManagerDelegate> delegate;

@property (nonatomic,copy) NSString *userId;

@property (nonatomic,strong) NSMutableDictionary *conversationDict;

//获取WebSocket连接状态
+ (SRReadyState)connectState;

+ (instancetype)sharedManager;

+ (void)connect:(NSString *)userId;

+ (void)logout;

+ (void)deleteConversation:(LSConversationModel *)model;

//获取回话，没有则创建
+ (LSConversationModel *)conversation:(LSConversationModel *)model;

//获取所有未读消息数量
+ (NSInteger)totalUnReadCount;

//同步回话到本地存储
+ (void)syncConversations;

//初始化数据库
- (void)initChatDBWithUserId:(NSString *)user_id;
//将聊天消息模型保存到数据库
//- (NSString *)saveMessageModel:(LSMessageModel *)model withConversationId:(NSString *)conversation_id;
//删除会话下的所有消息
- (BOOL)deleteMessagesInConversation:(NSString *)conversation_id;
- (BOOL)deleteMessageByMessageId:(NSString *)message_id andConversationId:(NSString *)conversation_id;
//更新消息模型,数据库没有就插入数据库，有则更新数据库
- (void)updateMessage:(LSMessageModel *)message;

//获取回话消息
- (NSMutableArray<LSMessageModel *> *)messagesInConversation:(NSString *)conversation_id earlierMessageId:(NSString *)message_id;

//转发消息
+ (void)forwardMessage:(LSMessageModel *)message conversation:(LSConversationModel *)converId;

//发送消息
+ (void)sendTextMessage:(LSTextMessageModel *)message conversation:(LSConversationModel *)conversation;

//发送图片
+ (void)sendPictureMessage:(LSPictureMessageModel *)message conversation:(LSConversationModel *)conversation uploadProgress:(void(^)(NSProgress *progress))uploadProgress success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

//发送音频
+ (void)sendAudioMessage:(LSAudioMessageModel *)message conversation:(LSConversationModel *)conversation uploadProgress:(void(^)(NSProgress *progress))uploadProgress success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

//发送视频
+ (void)sendVideoMessage:(LSVideoMessageModel *)message conversation:(LSConversationModel *)conversation uploadProgress:(void(^)(NSProgress *progress))uploadProgress success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

//发送表情图片
+ (void)sendEmotionMessage:(LSEmotionMessageModel *)message conversation:(LSConversationModel *)conversation;

//音频下载
+ (void)downloadAudio:(LSAudioMessageModel *)message success:(void (^)(void))success failure:(void (^)(void))failure;

//创建时间模型
- (void)initMessageTimeModel:(LSConversationModel *)conversation timeStamp:(NSTimeInterval)timeStamp;


@end
