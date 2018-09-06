//
//  LSFuwaSuccessFriendView.h
//  LittleSix
//
//  Created by Jim huang on 17/4/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  LSFuwaModel;
@interface LSFuwaSuccessFriendView : UIView

+ (instancetype)SuccessFriendView;

@property(nonatomic,strong)LSFuwaModel * model;

@property (nonatomic,copy)void (^playClick)(NSString * urlStr,NSString * picUrl);

@end
