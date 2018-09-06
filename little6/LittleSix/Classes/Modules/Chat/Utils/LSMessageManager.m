//
//  LSMessageManager.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/12.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMessageManager.h"
#import "NSString+Util.h"
#import <FMDB/FMDB.h>
#import "LSOBaseModel.h"

#define kLogoutCode 1999
#define kTimeoutInterval 5

@interface LSMessageManager () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;

@property (nonatomic, strong) YYCache *cache;

@property (nonatomic, strong) FMDatabase *chatDB;

@end

@implementation LSMessageManager

static LSMessageManager *_instance;

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedManager {
    if (_instance == nil) {
        _instance = [[LSMessageManager alloc] init];
        
        YYCache *cache = [[YYCache alloc] initWithName:kConversationCache];
        _instance.cache = cache;
        
        NSMutableDictionary *dict = (NSMutableDictionary *)[cache objectForKey:kConversationCache];
        if (!dict) {
            dict = [NSMutableDictionary dictionary];
        }
        _instance.conversationDict = dict;
    }
    return _instance;
}

+ (void)connect:(NSString *)userId {
    [LSMessageManager sharedManager].userId = userId;
    [[LSMessageManager sharedManager] initChatDBWithUserId:userId];
    NSMutableDictionary *dict = (NSMutableDictionary *)[ShareMessageManager.cache objectForKey:kConversationCache];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    _instance.conversationDict = dict;
}

- (void)_connect {
    
    if (!_instance.userId) return;
    
    NSString *urlString = [kWSUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *connectURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:connectURL];
    
    _instance.webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    
    _instance.webSocket.delegate = self;
    
    //打开连接
    [self.webSocket open];
}

+ (void)logout {
    if (![LSMessageManager sharedManager].webSocket) return;
    if (![LSMessageManager sharedManager].userId) return;
    NSString *message = [NSString stringWithFormat:@"logout_%@",[LSMessageManager sharedManager].userId];
    [[LSMessageManager sharedManager].webSocket send:message];
    [LSMessageManager sharedManager].userId = nil;
    [[LSMessageManager sharedManager].webSocket closeWithCode:kLogoutCode reason:@"退出登录"];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    if (![message isKindOfClass:[NSString class]]) return;

    NSArray *arr = [((NSString *)message) componentsSeparatedByString:@"_"];
    
    if (arr.count==0) return;
    
    NSString *type = arr.firstObject;
    
    if (arr.count <= 4) return;
    
    //根据会话id获取聊天会话
    LSConversationModel *conversation = [self conversationWithInfos:arr];
    
    LSMessageModel *messageModel;
    
    if ([type isEqualToString:@"text"]) {
        messageModel = [self textMessageModelWithInfo:arr];
    }else if ([type isEqualToString:@"emotion"]) {
        messageModel = [self emotionModelWithInfo:arr];
    }
    else if ([type isEqualToString:@"video"]) {
        messageModel = [self videoModelWithInfo:arr];
    }
    else if ([type isEqualToString:@"picture"]) {
        messageModel = [self pictureModelWithInfo:arr];
    }
    else if ([type isEqualToString:@"audio"]) {
        messageModel = [self audioModelWithInfo:arr];
    }
    
    //没有生成消息
    if (!messageModel) return;
    
    //判断是否需要插入时间
    [self initMessageTimeModel:conversation timeStamp:messageModel.timeStamp];
    
    //将数据保存到数据库
    [self updateMessage:messageModel];
    
    //设置未读消息数
    conversation.lastMessage = messageModel;
    conversation.unReadCount ++;

    //保存会话记录
    [[self class] syncConversations];
    
    //通知代理对象接收到新消息
    if ([self.delegate respondsToSelector:@selector(didReceiveNewMessage:)]) {
        [self.delegate didReceiveNewMessage:conversation.lastMessage];
    }
    
}

#pragma mark - 消息类型解析
//判断是否需要插入时间
- (void)initMessageTimeModel:(LSConversationModel *)conversation timeStamp:(NSTimeInterval)timeStamp {
    
    if (!conversation.lastMessage) return;
    
    LSMessageModel *lastMessage = conversation.lastMessage;
    //判断消息时间
    if ((timeStamp - lastMessage.timeStamp) > 300) {
        LSMessageModel *timeModel = [self timestampModel];
        timeModel.conversation_id = conversation.conversationId;
        //保存到数据库
        [self updateMessage:timeModel];
        
        //通知代理对象
        if ([self.delegate respondsToSelector:@selector(didReceiveNewMessage:)]) {
            [self.delegate didReceiveNewMessage:timeModel];
        }
    }
}

- (LSMessageModel *)timestampModel {
    LSMessageModel *timeModel = [LSMessageModel new];
    timeModel.messageType = LSMessageTypeTime;
    timeModel.timeStamp = [[NSDate date] timeIntervalSince1970];
    return timeModel;
}

- (LSMessageModel *)emotionModelWithInfo:(NSArray *)info {
    
    LSEmotionMessageModel *emotionModel = [LSEmotionMessageModel new];
    [self baseInfoMessage:emotionModel withInfo:info];
    emotionModel.code = info[2];
    
    return emotionModel;
}

- (LSPictureMessageModel *)pictureModelWithInfo:(NSArray *)info {
    
    LSPictureMessageModel *picModel = [LSPictureMessageModel new];
    [self baseInfoMessage:picModel withInfo:info];
    picModel.picUrl = info[2];
        
    return picModel;
}

- (LSAudioMessageModel *)audioModelWithInfo:(NSArray *)info {
    
    LSAudioMessageModel *audioModel = [LSAudioMessageModel new];
    [self baseInfoMessage:audioModel withInfo:info];
    audioModel.remoteUrl = info[2];
        
    return audioModel;
}

- (LSVideoMessageModel *)videoModelWithInfo:(NSArray *)info {
    
    LSVideoMessageModel *videoModel = [LSVideoMessageModel new];
    [self baseInfoMessage:videoModel withInfo:info];
    videoModel.remoteVideoURL = info[2];
    
    return videoModel;
}

//公共消息类型
- (void)baseInfoMessage:(LSMessageModel *)message withInfo:(NSArray *)info {
    
    message.conversation_id = info[4];
    message.senderId = info[1];
    message.timeStamp = ((NSString *)info[5]).doubleValue;
    message.conversation_type = [((NSString *)info[3]) isEqualToString:@"unicast"] ? LSConversationTypeChat : LSConversationTypeGroup;
    
    NSDictionary *extension = [[((NSString *)info.lastObject) base64DecodedString] toDictionary];
    
    if (extension) {
        message.extension = [NSMutableDictionary dictionaryWithDictionary:extension];
        message.sender = extension[@"sender"];
        message.senderAvartar = extension[@"senderAvartar"];
    }
}

- (LSTextMessageModel *)textMessageModelWithInfo:(NSArray *)info {
    
    LSTextMessageModel *textModel = [LSTextMessageModel new];
    textModel.text = info[2];
    [self baseInfoMessage:textModel withInfo:info];
    
    return textModel;
}

- (LSConversationModel *)conversationWithInfos:(NSArray *)infos {
    
    NSString *converId = infos[4];
    
    NSDictionary *extension = [[((NSString *)infos.lastObject) base64DecodedString] toDictionary];
    
    LSConversationModel *conversation = _instance.conversationDict[converId];
    
    if (conversation) {
        conversation.title = extension[@"conversation"];
        conversation.avartar = extension[@"conversationAvartar"];
        return conversation;
    }
    
    conversation = [LSConversationModel new];
    
    conversation.title = extension[@"conversation"];
    conversation.avartar = extension[@"conversationAvartar"];
    
    conversation.type = [((NSString *)infos[3]) isEqualToString:@"unicast"] ? LSConversationTypeChat : LSConversationTypeGroup;
    conversation.conversationId = converId;
    
    _instance.conversationDict[converId] = conversation;
    
    //同步消息
    [[self class] syncConversations];
    
    return conversation;
}

+ (void)deleteConversation:(LSConversationModel *)model {
    [ShareMessageManager deleteMessagesInConversation:model.conversationId];
    _instance.conversationDict[model.conversationId] = nil;
    [[self class] syncConversations];
}

+ (LSConversationModel *)conversation:(LSConversationModel *)model {
    
    LSConversationModel *conversation = [LSMessageManager sharedManager].conversationDict[model.conversationId];
    
    if (!conversation) {
        conversation = model;
        [LSMessageManager sharedManager].conversationDict[model.conversationId] = model;
        [LSMessageManager syncConversations];
    }
    
    return conversation;
}

+ (void)syncConversations {
    [ShareMessageManager.cache setObject:_instance.conversationDict forKey:kConversationCache];
}

+ (NSInteger)totalUnReadCount {
    
    __block NSInteger unReadCount = 0;
    
    [ShareMessageManager.conversationDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, LSConversationModel *_Nonnull obj, BOOL * _Nonnull stop) {
        unReadCount += obj.unReadCount;
    }];
    
    return unReadCount;
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"连接成功");
    NSString *login_token = [NSString stringWithFormat:@"login_%@",_instance.userId];
    [webSocket send:login_token];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"failure:%@",error);
    //自动重连
    kDISPATCH_AFTER_BLOCK(kTimeoutInterval, ^{
        [self _connect];
    })
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"%@",@"断开连接");
    if (code==kLogoutCode) return;
    //自动重连
    kDISPATCH_AFTER_BLOCK(kTimeoutInterval, ^{
        [self _connect];
    })
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    
}

+ (SRReadyState)connectState {
    return ShareMessageManager.webSocket.readyState;
}

#pragma mark - MessageDB
- (void)initChatDBWithUserId:(NSString *)user_id {
    
    if (!user_id) return;
    if (self.chatDB) [self.chatDB close];

    NSString *db_name = [NSString stringWithFormat:@"chat_%@.sqlite",user_id];
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:db_name];
    
    _chatDB = [FMDatabase databaseWithPath:filePath];
    
    if (![self.chatDB open]) return;

    [self.chatDB executeUpdate:@"CREATE TABLE IF NOT EXISTS `messages` (`msg_id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,`conversaton_id` varchar(100) NOT NULL ,message_model blob not null,message_type int(4));"];
}

- (NSString *)saveMessageModel:(LSMessageModel *)model withConversationId:(NSString *)conversation_id {
    
    NSData *data = [model modelToJSONData];
    
    [self.chatDB executeUpdate:@"insert into messages (conversaton_id,message_model,message_type) values(?,?,?)",conversation_id,data,@(model.messageType)];
    
    FMResultSet *set = [self.chatDB executeQuery:@"select * from messages where conversaton_id = ? order by msg_id desc limit 1",conversation_id];
    
    NSString *messageId;
    
    while ([set next]) {
        messageId = [set stringForColumn:@"msg_id"];
    }
    
    model.message_id = messageId;
    
    return messageId;
}

- (BOOL)deleteMessagesInConversation:(NSString *)conversation_id {
    BOOL success = [self.chatDB executeUpdate:@"delete from messages where conversaton_id = ?", conversation_id];
    return success;
}

- (BOOL)deleteMessageByMessageId:(NSString *)message_id andConversationId:(NSString *)conversation_id {
    BOOL success = [self.chatDB executeUpdate:@"delete from messages where conversaton_id = ? and msg_id = ?", conversation_id , message_id];
    return success;
}

- (void)updateMessage:(LSMessageModel *)message {
    
    if (message.message_id) {
        NSData *data = [message modelToJSONData];
        [self.chatDB executeUpdate:@"update messages set message_model = ? where conversaton_id = ? and msg_id = ?",data, message.conversation_id , message.message_id];
    }
    else {
        [self saveMessageModel:message withConversationId:message.conversation_id];
    }
}

- (NSMutableArray<LSMessageModel *> *)messagesInConversation:(NSString *)conversation_id earlierMessageId:(NSString *)message_id {
    
    NSString *sql = message_id ? @"select * from messages where conversaton_id = ? and msg_id < ? order by msg_id asc limit 30" : @"select * from (select * from messages where conversaton_id = ? order by msg_id desc limit 30) order by msg_id asc";
    
    FMResultSet *set = [self.chatDB executeQuery:sql,conversation_id,message_id];
    
    NSMutableArray *list = [NSMutableArray array];

    while ([set next]) {
        
        NSInteger type = [set intForColumn:@"message_type"];
        NSData *data = [set dataForColumn:@"message_model"];
        
        LSMessageModel *model;
        
        switch (type) {
            case LSMessageTypeText:
                model = [LSTextMessageModel modelWithJSON:data];
                break;
            case LSMessageTypePicture:
                model = [LSPictureMessageModel modelWithJSON:data];
                break;
            case LSMessageTypeAudio:
                model = [LSAudioMessageModel modelWithJSON:data];
                break;
            case LSMessageTypeVideo:
                model = [LSVideoMessageModel modelWithJSON:data];
                break;
            case LSMessageTypeEmotion:
                model = [LSEmotionMessageModel modelWithJSON:data];
                break;
            default:
                model = [LSMessageModel modelWithJSON:data];
                break;
        }
        
        NSString *messageId = [set stringForColumn:@"msg_id"];
        model.message_id = messageId;
        [list addObject:model];
    }
    
    [set close];
    
    return list;
}

#pragma mark - 发送消息
+ (void)forwardMessage:(LSMessageModel *)message conversation:(LSConversationModel *)conversation {
    
    message.forward = YES;
    
    switch (message.messageType) {
        case LSMessageTypeText:
        {
            LSTextMessageModel *textMessage = (LSTextMessageModel *)message;
            [self sendTextMessage:textMessage conversation:conversation];
        }
            break;
        case LSMessageTypeVideo:
        {
            LSVideoMessageModel *videoMessage = (LSVideoMessageModel *)message;
            [self forwardVideoMessage:videoMessage inConversation:conversation];
        }
            break;
            
        case LSMessageTypeEmotion:
        {
            LSEmotionMessageModel *emotionMessage = (LSEmotionMessageModel *)message;
            [self sendEmotionMessage:emotionMessage conversation:conversation];
        }
            break;
            
        case LSMessageTypePicture:
        {
            LSPictureMessageModel *picMessage = (LSPictureMessageModel *)message;
            [self forwardPictureMessage:picMessage conversation:conversation];
        }
            break;
            
        default:
            break;
    }
    
}

+ (void)sendTextMessage:(LSTextMessageModel *)message conversation:(LSConversationModel *)conversation {
    
    //发送文本消息
    if (message.messageType != LSMessageTypeText) return;
    
    NSString *type = message.conversation_type == LSConversationTypeChat? @"unicast" : @"group";
    
    NSString *ext = [message.extension modelToJSONString];
    NSString *base64Ext = [ext base64EncodedString];
    
    NSString *msg = [NSString stringWithFormat:@"text_%@_%@_%@_%@",message.conversation_id,message.text,type,base64Ext];
    
    [ShareMessageManager.webSocket send:msg];
    
    //将消息保存到数据库
    [ShareMessageManager updateMessage:message];
    
    conversation.lastMessage = message;
    [self syncConversations];
}

+ (void)sendPictureMessage:(LSPictureMessageModel *)message conversation:(LSConversationModel *)conversation uploadProgress:(void (^)(NSProgress *))uploadProgress success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    
    if (message.messageType != LSMessageTypePicture) return;
        
    [LSOBaseModel uploadImage:message.image uploadProgress:^(NSProgress *progress) {
        
        !uploadProgress?:uploadProgress(progress);
        
    } success:^(LSOBaseModel *model) {
        
        !success?:success();
        
        //生成消息发送数据
        NSString *type = message.conversation_type == LSConversationTypeChat? @"unicast" : @"group";
        NSString *ext = [message.extension modelToJSONString];
        NSString *base64Ext = [ext base64EncodedString];
        NSString *msg = [NSString stringWithFormat:@"picture_%@_%@_%@_%@",message.conversation_id,model.data,type,base64Ext];
        [ShareMessageManager.webSocket send:msg];
        
        message.uploadComplete = YES;
        message.picUrl = model.data;
        
        //将图片保存到本地
        [[YYImageCache sharedCache] setImage:message.image forKey:model.data];
        
        //将消息保存到数据库
        [ShareMessageManager updateMessage:message];

    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
    
    //将消息保存到数据库
    [ShareMessageManager updateMessage:message];
    conversation.lastMessage = message;
    [self syncConversations];
}

+ (void)sendAudioMessage:(LSAudioMessageModel *)message conversation:(LSConversationModel *)conversation uploadProgress:(void (^)(NSProgress *))uploadProgress success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    
    if (message.messageType != LSMessageTypeAudio) return;
    
    [LSOBaseModel uploadAudio:message.localFilePath uploadProgress:^(NSProgress *progress) {
        
    } success:^(LSOBaseModel *model) {
        
        NSString *type = message.conversation_type == LSConversationTypeChat? @"unicast" : @"group";
        NSString *ext = [message.extension modelToJSONString];
        NSString *base64Ext = [ext base64EncodedString];
        NSString *msg = [NSString stringWithFormat:@"audio_%@_%@_%@_%@",message.conversation_id,model.data,type,base64Ext];
        [ShareMessageManager.webSocket send:msg];
        
        message.uploadComplete = YES;
        message.remoteUrl = model.data;
        
        //获取录音时间
        NSString *content = model.data;
        content = [content stringByReplacingOccurrencesOfString:@".mp3" withString:@""];
        NSArray *arr = [content componentsSeparatedByString:@"-"];
        
        message.duration = [arr.lastObject floatValue];
        
        //将消息保存到数据库
        [ShareMessageManager updateMessage:message];
        
        !success?:success();
        
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
    
    //将消息保存到数据库
    [ShareMessageManager updateMessage:message];
    conversation.lastMessage = message;
    [self syncConversations];
}

+ (void)sendVideoMessage:(LSVideoMessageModel *)message conversation:(LSConversationModel *)conversation uploadProgress:(void (^)(NSProgress *))uploadProgress success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    
    if (message.messageType != LSMessageTypeVideo) return;
    
    [LSOBaseModel uploadVideo:[message localVideoFilePath] uploadProgress:^(NSProgress *progress) {
        
        !uploadProgress?:uploadProgress(progress);
        
    } success:^(LSOBaseModel *model) {
        
        NSString *type = message.conversation_type == LSConversationTypeChat? @"unicast" : @"group";
        NSString *ext = [message.extension modelToJSONString];
        NSString *base64Ext = [ext base64EncodedString];
        NSString *msg = [NSString stringWithFormat:@"video_%@_%@_%@_%@",message.conversation_id,model.data,type,base64Ext];
        [ShareMessageManager.webSocket send:msg];
        
        message.uploadComplete = YES;
        message.remoteVideoURL = model.data;

        //将消息保存到数据库
        [ShareMessageManager updateMessage:message];
        
        !success?:success();
        
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
    
    //将消息保存到数据库
    [ShareMessageManager updateMessage:message];
    conversation.lastMessage = message;
    [self syncConversations];
}


+ (void)sendEmotionMessage:(LSEmotionMessageModel *)message conversation:(LSConversationModel *)conversation {
    
    if (message.messageType != LSMessageTypeEmotion) return;
    
    NSString *type = message.conversation_type == LSConversationTypeChat? @"unicast" : @"group";
    NSString *ext = [message.extension modelToJSONString];
    NSString *base64Ext = [ext base64EncodedString];
    
    NSString *msg = [NSString stringWithFormat:@"emotion_%@_%@_%@_%@",message.conversation_id,message.code,type,base64Ext];
    
    //发送消息
    [ShareMessageManager.webSocket send:msg];
    
    //将消息保存到数据库
    [ShareMessageManager updateMessage:message];
    
    conversation.lastMessage = message;
    [self syncConversations];
}

+ (void)forwardVideoMessage:(LSVideoMessageModel *)message inConversation:(LSConversationModel *)conversation {
    
    NSString *type = message.conversation_type == LSConversationTypeChat? @"unicast" : @"group";
    NSString *ext = [message.extension modelToJSONString];
    NSString *base64Ext = [ext base64EncodedString];
    NSString *msg = [NSString stringWithFormat:@"video_%@_%@_%@_%@",message.conversation_id,message.remoteVideoURL,type,base64Ext];
    [ShareMessageManager.webSocket send:msg];
    
    message.uploadComplete = YES;
    
    //将消息保存到数据库
    [ShareMessageManager updateMessage:message];
    conversation.lastMessage = message;
    [self syncConversations];
}

+ (void)forwardPictureMessage:(LSPictureMessageModel *)message conversation:(LSConversationModel *)conversation {
    
    if (message.messageType != LSMessageTypePicture) return;
    
    //生成消息发送数据
    NSString *type = message.conversation_type == LSConversationTypeChat? @"unicast" : @"group";
    NSString *ext = [message.extension modelToJSONString];
    NSString *base64Ext = [ext base64EncodedString];
    NSString *msg = [NSString stringWithFormat:@"picture_%@_%@_%@_%@",message.conversation_id,message.picUrl,type,base64Ext];
    [ShareMessageManager.webSocket send:msg];
    
    message.uploadComplete = YES;
    
    //将消息保存到数据库
    [ShareMessageManager updateMessage:message];
    conversation.lastMessage = message;
    [self syncConversations];
}

+ (void)downloadAudio:(LSAudioMessageModel *)message success:(void (^)(void))success failure:(void (^)(void))failure {
    
    if (!message.remoteUrl) {
        !failure?:failure();
    }
    
    NSData *audioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:message.remoteUrl]];
    
    //判断录音文件夹是否存在，没有则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:kRecordFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:kRecordFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileName = [message.remoteUrl lastPathComponent];
    NSString *filePath = [kRecordFolder stringByAppendingPathComponent:fileName];
    
    BOOL complete = [audioData writeToFile:filePath atomically:YES];
    
    if (complete) {
        message.fileName = fileName;
        message.downloadComplete = YES;
        
        [ShareMessageManager updateMessage:message];
        
        !success?:success();
    }
    else {
        !failure?:failure();
    }
}

#pragma mark - Getter&Setter
- (void)setUserId:(NSString *)userId {
    _userId = userId;
    [self _connect];
}

@end
