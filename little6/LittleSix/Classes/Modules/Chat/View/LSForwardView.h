//
//  LSForwardView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/4/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMessageModel.h"
#import "LSContactModel.h"

@interface LSForwardView : UIView

@property (nonatomic,strong) LSMessageModel *message;
@property (nonatomic,copy) void(^comfirmBlock)(NSString *leaveMessage);
@property (nonatomic,strong) NSArray *senders;

+ (instancetype)forwardView;

+ (void)showInView:(UIView *)view senders:(NSArray<LSContactModel *> *)senders withMessage:(LSMessageModel *)message comfirmActon:(void(^)(NSString *leaveMessage))action;

@end
