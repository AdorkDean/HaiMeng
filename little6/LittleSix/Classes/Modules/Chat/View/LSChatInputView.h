//
//  LSChatInputView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/11.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMorePannel.h"

#define kToolBarItemW 44
#define kToolBarItemH 49
#define kTextViewH 36
#define kPannelViewH 250
#define kAnimationDuration 0.3

typedef NS_ENUM (NSUInteger, LSChatInputStatus) {
    LSChatInputStatusNone,
    LSChatInputStatusEdit,
    LSChatInputStatusEmotion,
    LSChatInputStatusMore,
    LSChatInputStatusRecord
};

@class LSChatInputView,YYTextView,ZHRecordButton;
@protocol LSChatInputViewDelegate <NSObject>

@optional
//输入框的变化事件
- (void)chatInputViewWillShowPannel:(LSChatInputView *)inputView;
- (void)chatInputViewWillDismissPannel:(LSChatInputView *)inputView;
- (void)chatInputViewWillHideKeyboardView:(LSChatInputView *)inputVie;
- (void)chatInputViewTextDidChange:(LSChatInputView *)inputView;
- (void)chatInputViewWillRecord:(LSChatInputView *)inputView;

- (void)chatInputViewRecordComplete:(LSChatInputView *)inputView recordPath:(NSString *)filePath;

//按钮的事件
- (void)chatInputViewDidClickCustomButton:(LSChatInputView *)inputView;
- (void)chatInputViewDidClickAddButton:(LSChatInputView *)inputView;
- (void)chatInputViewDidClickEditButton:(LSChatInputView *)inputView;

- (void)chatInputView:(LSChatInputView *)inputView didSendText:(NSString *)text;

- (void)chatInputView:(LSChatInputView *)inputView didClickFeatureItem:(LSFeatureModel *)model;

@end

@interface LSChatInputView : UIView

@property (nonatomic,weak) id<LSChatInputViewDelegate> delegate;

@property (nonatomic,assign) LSChatInputStatus inputStatus;

@property (nonatomic,assign) CGFloat toolBarHeight;
@property (nonatomic,assign) CGFloat keyboardHeight;


+ (instancetype)inputView;

- (void)endIntput;

@end

@interface LSChatToolBar : UIView

@property (nonatomic,strong) UIButton *voiceButton;
@property (nonatomic,strong) UIButton *emotionButton;
@property (nonatomic,strong) UIButton *moreButton;
@property (nonatomic,strong) YYTextView *textView;
@property (nonatomic,strong) ZHRecordButton *recordButton;

@end

