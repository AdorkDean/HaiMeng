//
//  LSMessageModel.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/12.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSTextLinePositionModifier;
@interface LSMessageModel : NSObject <NSCoding,NSCopying>

//回话ID
@property (nonatomic,copy) NSString *conversation_id;
@property (nonatomic,assign) LSConversationType conversation_type;

//消息ID
@property (nonatomic,copy) NSString *message_id;

@property (nonatomic,assign) LSMessageType messageType;

@property (nonatomic,copy) NSString *senderId;
@property (nonatomic,copy) NSString *sender;
@property (nonatomic,copy) NSString *senderAvartar;

@property (nonatomic,assign) BOOL fromMe;

@property (nonatomic,assign) NSTimeInterval timeStamp;

@property (nonatomic,strong) NSMutableDictionary *extension;

#pragma mark - emotion
@property (nonatomic,copy) NSString *emotionCode;

#pragma mark - system
@property (nonatomic,copy) NSString *systemMessage;

//cell的高度
@property (nonatomic,assign) CGFloat cellHeight;

@property (nonatomic,assign,getter=isForward) BOOL forward;

@end

//文本解析对象
@interface LSTextParaser : NSObject

+ (NSMutableAttributedString *)parseText:(NSString *)text withFont:(UIFont *   )font;

@end

@interface LSTextMessageModel : LSMessageModel <NSCoding,NSCopying>

@property (nonatomic,copy) NSString *text;

//布局用
@property (nonatomic,strong) NSMutableAttributedString *richTextAttributedString;
@property (nonatomic,assign) CGFloat textWidth;
@property (nonatomic,assign) CGFloat textHeight;

@end

@interface LSPictureMessageModel : LSMessageModel <NSCoding,NSCopying>

//图片URL 上传/下载
@property (nonatomic,copy) NSString *picUrl;
//发送时的图片
@property (nonatomic,strong) UIImage *image;

//计算后图片布局的宽高
@property (nonatomic,assign) CGFloat scaleWidth;
@property (nonatomic,assign) CGFloat scaleHeight;

//接受到图片的宽高
@property (nonatomic,assign) CGFloat originWidth;
@property (nonatomic,assign) CGFloat originHeight;

//是否上传完成
@property (nonatomic,assign) BOOL uploadComplete;
//是否下载完成
@property (nonatomic,assign) BOOL downloadComplete;

@end

@interface LSAudioMessageModel : LSMessageModel <NSCoding,NSCopying>

@property (nonatomic,copy) NSString *fileName;

//服务器的文件地址
@property (nonatomic,copy) NSString *remoteUrl;

@property (nonatomic,assign) CGFloat duration;

//是否上传完成
@property (nonatomic,assign) BOOL uploadComplete;
//是否下载完成
@property (nonatomic,assign) BOOL downloadComplete;

//获取本地录音文件的地址
- (NSString *)localFilePath;

@end

@interface LSVideoMessageModel : LSMessageModel <NSCoding,NSCopying>

@property (nonatomic,copy) NSString *remoteVideoURL;
@property (nonatomic,copy) NSString *remoteThumURL;

//保存到本地的文件名
@property (nonatomic,copy) NSString *localFileName;
//fromMe时用
@property (nonatomic,copy) NSString *localThumName;

@property (nonatomic,assign) CGFloat originWidth;
@property (nonatomic,assign) CGFloat originHeight;

@property (nonatomic,assign) CGFloat scaleWidth;
@property (nonatomic,assign) CGFloat scaleHeight;

//是否上传完成
@property (nonatomic,assign) BOOL uploadComplete;
//是否下载完成
@property (nonatomic,assign) BOOL downloadComplete;

- (NSString *)localVideoFilePath;
- (UIImage *)thumImage;

@end

@interface LSEmotionMessageModel : LSMessageModel <NSCoding,NSCopying>

@property (nonatomic,assign) CGFloat originWidth;
@property (nonatomic,assign) CGFloat originHeight;

@property (nonatomic,assign) CGFloat scaleWidth;
@property (nonatomic,assign) CGFloat scaleHeight;

//表情编码
@property (nonatomic,copy) NSString *code;
//表情包的远程下载地址
@property (nonatomic,copy) NSString *emo_url;
//本地有图片则localFilePath不为nil
@property (nonatomic,copy) NSString *localFilePath;

@end
