//
//  LSMessageModel.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/12.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMessageModel.h"
#import "NSString+Util.h"
#import "ConstKeys.h"
#import "LSEmotionManager.h"

@implementation LSMessageModel
    
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

- (void)setSenderId:(NSString *)senderId {
    _senderId = senderId;
    
    //消息发送者的ID和当前的用户ID匹配则消息是自己发送的
    self.fromMe = [senderId isEqualToString:ShareAppManager.loginUser.user_id];
}

@end

@implementation LSTextParaser

+ (NSMutableAttributedString *)parseText:(NSString *)text withFont:(UIFont *)font {
    
    if (text.length == 0) return nil;
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    attributedText.lineSpacing = 1.23;
    attributedText.font = font;
    attributedText.color = [UIColor blackColor];
    
    //匹配手机
    NSArray<NSTextCheckingResult *> * phoneResults = [[self phoneRegExpression] matchesInString:text options:NSMatchingReportProgress range:attributedText.rangeOfAll];
    
    for (NSTextCheckingResult *phoneRes in phoneResults) {
        
        if (phoneRes.range.location == NSNotFound) continue;
        
        if (![attributedText attribute:YYTextHighlightAttributeName atIndex:phoneRes.range.location]) {
            
            [attributedText setColor:HEXRGB(0x1F79FD) range:phoneRes.range];
            
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setBorder:[self highlightBorder]];
            
            [attributedText setTextHighlight:highlight range:phoneRes.range];
        }
    }
    
    //匹配URL
    NSArray<NSTextCheckingResult *> * urlResults = [[self urlRegExpression] matchesInString:text options:NSMatchingReportProgress range:attributedText.rangeOfAll];

    for (NSTextCheckingResult *urlRes in urlResults) {
        
        if (urlRes.range.location == NSNotFound) continue;
        
        if (![attributedText attribute:YYTextHighlightAttributeName atIndex:urlRes.range.location]) {
            
            [attributedText setColor:HEXRGB(0x1F79FD) range:urlRes.range];
            
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setBorder:[self highlightBorder]];
            
            [attributedText setTextHighlight:highlight range:urlRes.range];
        }
    }
    
    return attributedText;
}

/// 高亮的文字背景色
+ (YYTextBorder *)highlightBorder {
    
    YYTextBorder *border = [YYTextBorder new];
    border.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
    border.fillColor = HEXRGB(0xD4D1D1);
    
    return border;
}

+ (NSRegularExpression *)phoneRegExpression {
    
    NSString *regex = @"([\\d]{7,25}(?!\\d))|((\\d{3,4})-(\\d{7,8}))|((\\d{3,4})-(\\d{7,8})-(\\d{1,4}))";
    
    return [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
}

+ (NSRegularExpression *)urlRegExpression {
    
    NSString *regex = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|^[a-zA-Z0-9]+(\\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\\$\\.\\+!\\*\\(\\)/,:;@&=\\?~#%]*)*";
    
    return [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
}

@end

@implementation LSTextMessageModel

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

- (instancetype)init {
    if ([super init]) {
        self.messageType = LSMessageTypeText;
    }
    return self;
}

@end

@implementation LSPictureMessageModel

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

- (instancetype)init {
    if ([super init]) {
        self.messageType = LSMessageTypePicture;
    }
    return self;
}

- (void)setPicUrl:(NSString *)picUrl {
    _picUrl = picUrl;
    
    NSRange range = [picUrl rangeOfString:@"-"];
    if (range.location != NSNotFound) {
        NSString *subString = [picUrl substringFromIndex:range.location+1];
        range = [subString rangeOfString:@"."];
        subString = [subString substringToIndex:range.location];
        NSArray *arr = [subString componentsSeparatedByString:@"x"];
        self.originWidth = [arr.firstObject floatValue];
        self.originHeight = [arr.lastObject floatValue];
    }
}

- (void)setScaleWidth:(CGFloat)scaleWidth {
    _scaleWidth = isnan(scaleWidth) ? 60 : scaleWidth;
}

- (void)setScaleHeight:(CGFloat)scaleHeight {
    _scaleHeight = isnan(scaleHeight) ? 60 : scaleHeight;
}

@end

@implementation LSAudioMessageModel

- (instancetype)init {
    if ([super init]) {
        self.messageType = LSMessageTypeAudio;
    }
    return self;
}

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

- (NSString *)localFilePath {
    return [kRecordFolder stringByAppendingPathComponent:self.fileName];
}

- (void)setRemoteUrl:(NSString *)remoteUrl {
    _remoteUrl = remoteUrl;
    
    NSString *newString = [remoteUrl stringByReplacingOccurrencesOfString:@".mp3" withString:@""];
    NSArray *arr = [newString componentsSeparatedByString:@"-"];
    
    //获取音频时长
    self.duration = [arr.lastObject floatValue];
}

@end

@implementation LSVideoMessageModel

- (instancetype)init {
    if ([super init]) {
        self.messageType = LSMessageTypeVideo;
    }
    return self;
}

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

- (void)setRemoteVideoURL:(NSString *)remoteVideoURL {
    _remoteVideoURL = remoteVideoURL;
    
    NSArray *arr = [remoteVideoURL componentsSeparatedByString:@"."];
    NSString *extension = arr.lastObject;
    
    self.remoteThumURL = [remoteVideoURL stringByReplacingOccurrencesOfString:extension withString:@"jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(remoteVideoURL.length-5, 5)];
    
//    http://livecdn.66boss.com/emovideo/1db8d1e70eb77ed011099438fb56a30f-160x284.mov
    //获取视频的宽高
    NSRange range = [remoteVideoURL rangeOfString:@"-"];
    if (range.location != NSNotFound) {
        NSString *subString = [remoteVideoURL substringFromIndex:range.location+1];
        range = [subString rangeOfString:@"."];
        subString = [subString substringToIndex:range.location];
        NSArray *arr = [subString componentsSeparatedByString:@"x"];
        self.originWidth = [arr.firstObject floatValue];
        self.originHeight = [arr.lastObject floatValue];
    }
}

- (NSString *)localVideoFilePath {
    return [kCaptureFolder stringByAppendingPathComponent:self.localFileName];
}

- (UIImage *)thumImage {
    UIImage *image = [UIImage imageWithContentsOfFile:[kCaptureFolder stringByAppendingPathComponent:self.localThumName]];
    return image;
}

@end


@implementation LSEmotionMessageModel

- (instancetype)init {
    if ([super init]) {
        self.messageType = LSMessageTypeEmotion;
    }
    return self;
}

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

- (void)setCode:(NSString *)code {
    _code = code;
    
    NSString *newString = [code stringByReplacingOccurrencesOfString:@"~" withString:@"+"];
    newString = [newString stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    NSString *decodeString = [newString base64DecodedString];
    
    NSArray *array = [decodeString componentsSeparatedByString:@"/"];
    
    if (array.count==3) {
        NSString *catoryId = array.firstObject;
        NSString *packetId = array[1];
        
        NSArray *arr = [[decodeString lastPathComponent] componentsSeparatedByString:@"-"];
        
        self.originWidth = [arr[1] floatValue];
        self.originHeight = [arr.lastObject floatValue];
        
        NSString *fileName = arr.firstObject;
        NSArray *list = [fileName componentsSeparatedByString:@"."];
        
        NSString *fileExtensiong = list.lastObject;
        
        self.emo_url = [NSString stringWithFormat:@"%@/%@/%@/%@.%@",kEmoBaseURL,catoryId,packetId,code,fileExtensiong];
    }
    
    //判断本地是否存在
    LSEmotionModel *model = [LSEmotionManager findEmoitonModelByCode:code];
    if (!model) return;
    
    self.localFilePath = [model filePath];
}

- (void)setScaleWidth:(CGFloat)scaleWidth {
    _scaleWidth = isnan(scaleWidth) ? 60 : scaleWidth;
}

- (void)setScaleHeight:(CGFloat)scaleHeight {
    _scaleHeight = isnan(scaleHeight) ? 60 : scaleHeight;
}

@end
