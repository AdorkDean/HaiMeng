//
//  LSSendMessageView.m
//  LittleSix
//
//  Created by GMAR on 2017/3/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSendMessageView.h"
#define windowRect [UIScreen mainScreen].bounds

NSUInteger const FontSizes = 17.0;
@interface LSSendMessageView () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UIView *customInputAccessoryView;

@property (nonatomic, assign,getter=isChanged) BOOL changed;
@property (nonatomic, assign) CGFloat originTextViewWidth;
@property (nonatomic, strong) UIButton * sendButton;

@end

@implementation LSSendMessageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.textView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    
    [self finishSendMessage];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self removeFromSuperview];
}

- (void)keyboardDidShow:(NSNotification *)nitification {
    [self becomeFirstResponderForInputTextField];
}
- (void)keyboardDidHide:(NSNotification *)nitification {
    [self resignFirstResponderForInputTextFields];
}
#pragma mark - 公开方法

- (void)becomeFirstResponderForTextFieldPid:(int)pid {
    self.pid = pid;
    if (!self.textView.isFirstResponder) {
        [self.textView becomeFirstResponder];
    }
}

- (void)becomeFirstResponderForInputTextField {
    if (!self.inputTextField.isFirstResponder) {
        [self.inputTextField becomeFirstResponder];
    }
}

- (void)resignFirstResponderForInputTextFields {
    if ([self.inputTextField isFirstResponder]) {
        [self.inputTextField resignFirstResponder];
    }
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

- (void)finishSendMessage {
    self.inputTextField.text = nil;
    [self resignFirstResponderForInputTextFields];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self removeFromSuperview];
    
}

#pragma mark - Propertys

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.returnKeyType = UIReturnKeySend;
        _textView.inputAccessoryView = self.customInputAccessoryView;
    }
    return _textView;
}

- (UIView *)customInputAccessoryView {
    if (!_customInputAccessoryView) {
        _customInputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 55)];
        _customInputAccessoryView.backgroundColor = [UIColor colorWithWhite:0.910 alpha:1.000];
        [_customInputAccessoryView addSubview:self.inputTextField];
        [_customInputAccessoryView addSubview:self.sendButton];
    }
    return _customInputAccessoryView;
}
- (UITextView *)inputTextField {
    if (!_inputTextField) {
        _inputTextField = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(_customInputAccessoryView.bounds) - 80, CGRectGetHeight(_customInputAccessoryView.bounds) - 20)];
        _inputTextField.delegate = self;
        _inputTextField.font = [UIFont systemFontOfSize:17];
        _inputTextField.returnKeyType = UIReturnKeySend;
        [_inputTextField addSubview:self.placeholder];
    }
    return _inputTextField;
}

- (UILabel *)placeholder {

    if (!_placeholder) {
        _placeholder = [UILabel new];
        _placeholder.text = @"评论";
        _placeholder.textColor = [UIColor lightGrayColor];
        _placeholder.frame = CGRectMake(10, 10, CGRectGetWidth(_inputTextField.bounds)-30, CGRectGetHeight(_inputTextField.bounds) - 20);
    }
    return _placeholder;
}

-(UIButton *)sendButton{
    
    if (!_sendButton) {
        
        _sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.backgroundColor = kMainColor;
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _sendButton.frame = CGRectMake(CGRectGetMaxX(_inputTextField.frame)+10, 10, 60-10, CGRectGetHeight(_customInputAccessoryView.bounds) - 20);
    }
    return _sendButton;
}



#pragma mark - UITextField Delgate

-(void)sendButtonClick:(UIButton *)sender{

    if ([self.sendMessageDelegate respondsToSelector:@selector(didSendMessage:albumInputView:andPid:)]){
    
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        [self.sendMessageDelegate didSendMessage:self.inputTextField.text albumInputView:self andPid:self.pid];
        
        [self finishSendMessage];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (textView.text.length  > 0) {
        self.placeholder.text = @"";
    }else{
        self.placeholder.text = @"评论";
    }
    
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        // 发送文字
        if ([self.sendMessageDelegate respondsToSelector:@selector(didSendMessage:albumInputView:andPid:)]) {
            
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
            [self.sendMessageDelegate didSendMessage:textView.text albumInputView:self andPid:self.pid];
            
            [self finishSendMessage];
        }
        
        //在这里做你响应return键的代码
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate
//* 如果是懒加载的在这里获取的width不正确 */
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.originTextViewWidth==0) {
        self.originTextViewWidth = textView.bounds.size.width;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    CGSize  textSize = [textView.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:FontSizes]}];
    CGFloat textWidth = textSize.width+10;
    if (textWidth < self.textView.bounds.size.width) {
        if (self.isChanged) {
            //* 回到最初 */
            [self updateSelfOfTextViewSize];
        }
        self.changed=NO;
    } else {
        //* 换行了 */
        self.changed = YES;
        [self updateSelfOfTextViewSize];
    }
}
#pragma mark - 更新输入框、本身View大小
- (void)updateSelfOfTextViewSize {
    [UIView animateWithDuration:.3 animations:^{
        //* 当UITextView的高度大于100的时候不在增加高度,模仿微信 */
        if (self.textView.bounds.size.height>80) {
            return ;
        }
        //* TextView 大小*/
        CGRect bounds = self.textView.bounds;
        CGSize maxSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX);
        CGSize newSize = [self.textView sizeThatFits:maxSize];
        self.textView.frame = CGRectMake(10, 10, self.originTextViewWidth, newSize.height);
        
        //*本身View 大小*/
        CGRect rect = self.frame;
        //        NSLog(@"self.textView.frame = %@",NSStringFromCGRect(self.textView.frame));
        //* 10*2 为 上下Margin  */
        rect.size.height = self.textView.frame.size.height+10*2;
        //* 当前的y －（这个Accessory的height － 本身的height）。 其本质是向上(Y轴)移动增加的height*/
        rect.origin.y = rect.origin.y-(rect.size.height-self.frame.size.height);
        self.frame = rect;
    }];
}
@end
