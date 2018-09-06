//
//  LSChatInputView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/11.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSChatInputView.h"
#import "LSEmotionPannel.h"
#import "ZHRecordButton.h"

@interface LSChatInputView () <YYTextViewDelegate,LSEmotionPannelDelegate,LSMorePannelDelegate>

@property (nonatomic,strong) LSChatToolBar *toolBar;

@property (nonatomic,strong) LSEmotionPannel *emotionPannel;

@property (nonatomic,strong) LSMorePannel *morePannel;

@end

@implementation LSChatInputView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.clipsToBounds = YES;
        
        _toolBar = [[LSChatToolBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kToolBarItemH)];
        _toolBar.textView.delegate = self;
        _toolBar.textView.returnKeyType = UIReturnKeySend;
        [self addSubview:_toolBar];
        [_toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.offset(kToolBarItemH);
        }];
        
        LSEmotionPannel *emotionPannel = [LSEmotionPannel new];
        emotionPannel.delegate = self;
        self.emotionPannel = emotionPannel;
        emotionPannel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:emotionPannel];
        [emotionPannel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.offset(kPannelViewH);
        }];
        
        LSMorePannel *morePannel = [LSMorePannel new];
        morePannel.delegate = self;
        self.morePannel = morePannel;
        morePannel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:morePannel];
        [morePannel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.offset(kPannelViewH);
        }];
        
        self.toolBarHeight = kToolBarItemH;
        
        [self installToolBarButtonsAction];
        [self installNotiAndDelegate];
        //添加点击事件
        [self addActions];
    }
    return self;
}

- (void)addActions {
    @weakify(self)
    [[self rac_signalForSelector:@selector(emotionPannelDidClickAddButton) fromProtocol:@protocol(LSEmotionPannelDelegate)] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(chatInputViewDidClickAddButton:)]) {
            [self.delegate chatInputViewDidClickAddButton:self];
        }
    }];
    [[self rac_signalForSelector:@selector(emotionPannelDidClickEditButton) fromProtocol:@protocol(LSEmotionPannelDelegate)] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(chatInputViewDidClickEditButton:)]) {
            [self.delegate chatInputViewDidClickEditButton:self];
        }
    }];
    [[self rac_signalForSelector:@selector(emotionPannelDidClickSettingButton) fromProtocol:@protocol(LSEmotionPannelDelegate)] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(chatInputViewDidClickCustomButton:)]) {
            [self.delegate chatInputViewDidClickCustomButton:self];
        }
    }];
    
    [[self rac_signalForSelector:@selector(morePannelClickWithItem:) fromProtocol:@protocol(LSMorePannelDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(chatInputView:didClickFeatureItem:)]) {
            [self.delegate chatInputView:self didClickFeatureItem:tuple.first];
        }
    }];
    
    //监听录音事件
    [self.toolBar.recordButton setRecordComplete:^( NSString *filePath) {
        @strongify(self)
        if (!filePath) return;
        if (![self.delegate respondsToSelector:@selector(chatInputViewRecordComplete:recordPath:)]) return;
        [self.delegate chatInputViewRecordComplete:self recordPath:filePath];
    }];
    
}   

- (void)installNotiAndDelegate {
    
    @weakify(self);
    [[self rac_signalForSelector:@selector(textViewDidChange:) fromProtocol:@protocol(UITextViewDelegate)] subscribeNext:^(RACTuple *truple) {
        @strongify(self);
        
        UITextView *textView = truple.first;
        
        CGSize size = textView.contentSize;
        
        if (size.height < 80) {
            textView.height = size.height;
            [self.toolBar mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.offset(textView.height+12);
            }];
            self.toolBarHeight = textView.height+12;
            if ([self.delegate respondsToSelector:@selector(chatInputViewTextDidChange:)]) {
                [self.delegate chatInputViewTextDidChange:self];
            }
        }
        
    }];
    
}

//工具条按钮事件
- (void)installToolBarButtonsAction {
    @weakify(self)
    [[self.toolBar.emotionButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        @strongify(self)
        
        button.selected = !button.selected;
        
        if (!button.selected) {
            [self.toolBar.textView becomeFirstResponder];
        }
        else {
            if (self.inputStatus == LSChatInputStatusNone) {
                if ([self.delegate respondsToSelector:@selector(chatInputViewWillShowPannel:)]) {
                    [self.delegate chatInputViewWillShowPannel:self];
                }
            }
            else if (self.inputStatus == LSChatInputStatusMore) {
                self.morePannel.alpha = 0;
                self.toolBar.moreButton.selected = NO;
            }
            else if (self.inputStatus == LSChatInputStatusEdit) {
                [self.toolBar.textView endEditing:YES];
                if ([self.delegate respondsToSelector:@selector(chatInputViewWillShowPannel:)]) {
                    [self.delegate chatInputViewWillShowPannel:self];
                }
            }
            else if (self.inputStatus == LSChatInputStatusRecord) {
                [self hideRecordButton];
                if ([self.delegate respondsToSelector:@selector(chatInputViewWillShowPannel:)]) {
                    [self.delegate chatInputViewWillShowPannel:self];
                }
            }
            
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.emotionPannel.transform = CGAffineTransformMakeTranslation(0, -kPannelViewH);
            } completion:^(BOOL finished) {
                self.morePannel.alpha = 1;
                self.morePannel.transform = CGAffineTransformIdentity;
            }];
            
            self.inputStatus = LSChatInputStatusEmotion;
        }
        
    }];
    
    [[self.toolBar.moreButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        @strongify(self)
        
        button.selected = !button.selected;
        
        if (!button.selected) {
            [self.toolBar.textView becomeFirstResponder];
        }
        else {
            if (self.inputStatus == LSChatInputStatusNone) {
                if ([self.delegate respondsToSelector:@selector(chatInputViewWillShowPannel:)]) {
                    [self.delegate chatInputViewWillShowPannel:self];
                }
            }
            else if (self.inputStatus == LSChatInputStatusEmotion) {
                self.emotionPannel.alpha = 0;
                self.toolBar.emotionButton.selected = NO;
            }
            else if (self.inputStatus == LSChatInputStatusEdit) {
                [self.toolBar.textView endEditing:YES];
                if ([self.delegate respondsToSelector:@selector(chatInputViewWillShowPannel:)]) {
                    [self.delegate chatInputViewWillShowPannel:self];
                }
            }
            else if (self.inputStatus == LSChatInputStatusRecord) {
                [self hideRecordButton];
                if ([self.delegate respondsToSelector:@selector(chatInputViewWillShowPannel:)]) {
                    [self.delegate chatInputViewWillShowPannel:self];
                }
            }
            
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.morePannel.transform = CGAffineTransformMakeTranslation(0, -kPannelViewH);
            } completion:^(BOOL finished) {
                self.emotionPannel.alpha = 1;
                self.emotionPannel.transform = CGAffineTransformIdentity;
            }];
            
            self.inputStatus = LSChatInputStatusMore;
        }
        
    }];
    
    [[self.toolBar.voiceButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        @strongify(self);
        
        button.selected = !button.selected;
        
        if (!button.selected) {
            
            [self.toolBar.textView becomeFirstResponder];
            
            [self.toolBar mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.offset(self.toolBarHeight);
            }];
            
            [self layoutIfNeeded];
        }
        else {
            if (self.inputStatus != LSChatInputStatusNone) {
                
                [self.toolBar mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.offset(kToolBarItemH);
                }];
                
                [self layoutIfNeeded];
                
                if ([self.delegate respondsToSelector:@selector(chatInputViewWillRecord:)]) {
                    [self.delegate chatInputViewWillRecord:self];
                }
            }
            
            [self.toolBar.textView endEditing:YES];
            self.toolBar.recordButton.alpha = 1;
            self.inputStatus = LSChatInputStatusRecord;
        }
        
    }];
    
}

- (void)endIntput {
    
    [self.toolBar.textView endEditing:YES];
    
    if ([self.delegate respondsToSelector:@selector(chatInputViewWillDismissPannel:)]) {
        [self.delegate chatInputViewWillDismissPannel:self];
    }
    
    [self dismissPannelView];
    
    self.inputStatus = LSChatInputStatusNone;
    [self resetToolButtonsStatus];
}

- (void)dismissPannelView {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.emotionPannel.transform = CGAffineTransformIdentity;
        self.morePannel.transform = CGAffineTransformIdentity;
    }];
}

- (void)hideRecordButton {
    self.toolBar.voiceButton.selected = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.toolBar.recordButton.alpha = 0;
    }];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(YYTextView *)textView {
    self.inputStatus = LSChatInputStatusEdit;
    [self dismissPannelView];
    [self resetToolButtonsStatus];
    [self hideRecordButton];
    return YES;
}

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //点击发送按钮
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(chatInputView:didSendText:)]) {
            [self.delegate chatInputView:self didSendText:textView.text];
        }
        self.toolBar.textView.text = nil;
        return NO;
    }
    return YES;
}

- (void)resetToolButtonsStatus {
    self.toolBar.recordButton.selected = NO;
    self.toolBar.emotionButton.selected = NO;
    self.toolBar.moreButton.selected = NO;
    self.toolBar.voiceButton.selected = NO;
}

#pragma mark - Initial
+ (instancetype)inputView {
    CGRect frame = CGRectMake(0, kScreenHeight-kToolBarItemH, kScreenWidth, kToolBarItemH+kPannelViewH);
    return [[self alloc] initWithFrame:frame];
}

@end

@implementation LSChatToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = HEXRGB(0xf5f5f5);
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = HEXRGB(0xd7d7d9);
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.offset(0.5);
        }];
        
        UIImage *image = [[UIImage imageNamed:@"input-bar-flat"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f) resizingMode:UIImageResizingModeStretch];
        
        UIImageView *bgView = [[UIImageView alloc] initWithImage:image];
        
        [self addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceButton = voiceButton;
        [voiceButton setImage:[UIImage imageNamed:@"emotion_chat_picture"] forState:UIControlStateNormal];
        [voiceButton setImage:[UIImage imageNamed:@"emotion_chat_keyboard"] forState:UIControlStateSelected];
        [self addSubview:voiceButton];
        [voiceButton sizeToFit];
        [voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(self);
            make.width.height.offset(kToolBarItemW);
        }];
        
        
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton = moreButton;
        [moreButton setImage:[UIImage imageNamed:@"emotion_chat_add"] forState:UIControlStateNormal];
        [self addSubview:moreButton];
        [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(self);
            make.width.height.equalTo(voiceButton);
        }];
        
        UIButton *emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _emotionButton = emotionButton;
        [emotionButton setImage:[UIImage imageNamed:@"emotion_chat_expression"] forState:UIControlStateNormal];
        [emotionButton setImage:[UIImage imageNamed:@"emotion_chat_keyboard"] forState:UIControlStateSelected];
        [self addSubview:emotionButton];
        [emotionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(moreButton.mas_left);
            make.bottom.equalTo(self);
            make.width.height.offset(kToolBarItemW);
        }];
        
        YYTextView *textView = [YYTextView new];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 3;// 字体的行间距
        NSDictionary *attributes = @{
                                     NSFontAttributeName:SYSTEMFONT(16),
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        textView.typingAttributes = attributes;
        
        textView.textContainerInset = UIEdgeInsetsMake(9, 4, 9, 4);
        textView.backgroundColor = [UIColor whiteColor];
        _textView = textView;
        textView.font = SYSTEMFONT(16);
        textView.textColor = [UIColor blackColor];
        textView.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:0.5].CGColor;
        textView.layer.cornerRadius = 5.0f;
        textView.layer.borderWidth = 0.65f;
        textView.contentMode = UIViewContentModeRedraw;
        textView.dataDetectorTypes = UIDataDetectorTypeNone;
        textView.returnKeyType = UIReturnKeySend;
        textView.enablesReturnKeyAutomatically = YES;
        [self addSubview:textView];
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(6);
            make.bottom.equalTo(self).offset(-6);
            make.left.equalTo(voiceButton.mas_right).offset(4);
            make.right.equalTo(emotionButton.mas_left).offset(-4);
        }];
        
        ZHRecordButton *recordButton = [ZHRecordButton buttonWithType:UIButtonTypeCustom];
        [recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [recordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        recordButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:recordButton];
        _recordButton = recordButton;
        
        recordButton.backgroundColor = [UIColor whiteColor];
        recordButton.layer.cornerRadius = 5.0f;
        recordButton.layer.borderWidth = 0.5;
        recordButton.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:0.5].CGColor;
        recordButton.alpha = 0;
        
        [recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(textView);
            make.height.offset(kTextViewH+1);
        }];
        
    }
    return self;
}

@end
