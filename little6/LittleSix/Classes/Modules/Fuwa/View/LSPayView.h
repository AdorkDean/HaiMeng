//
//  LSWechatAndZFBBuyView.h
//  LittleSix
//
//  Created by Jim huang on 17/3/23.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LSPayType) {
    LSPayTypeWechat,
    LSPayTypeAlipay
};

@interface LSPayView : UIView

@property (nonatomic,copy) void(^payBlock)(LSPayType type);

+ (instancetype)showInView:(UIView *)view price:(NSString *)price withPayBlock:(void(^)(LSPayType type))block;

@end
