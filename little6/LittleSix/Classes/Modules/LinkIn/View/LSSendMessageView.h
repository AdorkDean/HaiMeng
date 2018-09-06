//
//  LSSendMessageView.h
//  LittleSix
//
//  Created by GMAR on 2017/3/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSSendMessageView;

@protocol LSSendMessageViewDelegate <NSObject>

@optional
- (void)didSendMessage:(NSString *)message albumInputView:(LSSendMessageView *)sendMessageView andPid:(int)pid;

@end

@interface LSSendMessageView : UIView

@property (nonatomic, weak) id <LSSendMessageViewDelegate> sendMessageDelegate;

- (void)becomeFirstResponderForTextFieldPid:(int)pid;
- (void)resignFirstResponderForInputTextFields;

- (void)finishSendMessage;
@property (nonatomic, strong) UITextView *inputTextField;
@property (nonatomic, assign) int pid;
@property (nonatomic, strong) UILabel * placeholder;

@end
