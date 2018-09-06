//
//  Enums.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/12.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#ifndef Enums_h
#define Enums_h
//选择朋友View类型
typedef enum {
    SelectContactViewTypeAll,
    SelectContactViewTypeOnlyMe,
    SelectContactViewTypeCanSee,
    SelectContactViewTypeNoSee,
    SelectContactViewTypeRemind,
}SelectContactViewType;

typedef enum {
    TimeLineContentTypeSelf,
    TimeLineContentTypeOther,
}TimeLineContentType;

typedef NS_ENUM(NSUInteger, LSMessageType) {
    LSMessageTypeUnknow,
    LSMessageTypePicture,
    LSMessageTypeVideo,
    LSMessageTypeEmotion,
    LSMessageTypeTime,
    LSMessageTypeSystem,
    LSMessageTypeText,
    LSMessageTypeAudio
};

//回话类型
typedef NS_ENUM(NSUInteger, LSConversationType) {
    LSConversationTypeChat,
    LSConversationTypeGroup
};

#endif /* Enums_h */
