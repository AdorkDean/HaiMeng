//
//  LSWalletsViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/4/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSWalletsViewController.h"
#import "LSUserModel.h"
#import "UIView+HUD.h"
@interface LSWalletsViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (nonatomic,assign) BOOL dot;


@end

@implementation LSWalletsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"提现";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.nameTextField.delegate = self;
    self.accountTextField.delegate = self;
    self.amountTextField.delegate = self;
    self.amountTextField.keyboardType = UIKeyboardTypeDecimalPad;
    [self loadAmountData];
}


- (IBAction)sureAction:(id)sender {
    if (self.nameTextField.text.length == 0) {
        [self.view showError:@"真实姓名不能为空" hideAfterDelay:1 ];
        return;
    }else if(self.accountTextField.text.length == 0 ){
        [self.view showError:@"帐号不能为空" hideAfterDelay:1 ];
        return;
    }else if (self.amountTextField.text.length == 0){
        [self.view showError:@"金额不能为空" hideAfterDelay:1 ];
        return;
    }else if (self.amountTextField.text.floatValue<10){
        [self.view showError:@"最低提取金额为10元" hideAfterDelay:1 ];
        return;
    }
    
    [self.view endEditing:YES];
    LSUserwWithDrawModel * model = [LSUserwWithDrawModel new];
    model.userName = self.nameTextField.text;
    model.account = self.accountTextField.text;
    model.amount = self.amountTextField.text;
    @weakify(self)
    LSWalletsAlterView * alterView = [LSWalletsAlterView walletsAlterView];
    alterView.model = model;
    [alterView setSuccessBlock:^{
        @strongify(self)
        [self loadAmountData];
        self.nameTextField.text = @"";
        self.accountTextField.text = @"";
        self.amountTextField.text = @"";
    }];
    alterView.frame = self.navigationController.view.bounds;
    [self.navigationController.view addSubview:alterView];
    [alterView show];
}

-(void)loadAmountData{
    
    [LSUserModel queryBalancesSuccess:^(NSString * balanceStr) {
        CGFloat balance = balanceStr.floatValue;
        self.balanceLabel.text = [NSString stringWithFormat:@"%.2f",balance];
        
    } failure:^(NSError *error) {
        [self.view showError:@"查询余额失败" hideAfterDelay:1];
    }];
}



-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 判断是否输入内容，或者用户点击的是键盘的删除按钮
    
    if (![string isEqualToString:@""]) {
        
        if (textField == self.amountTextField) {
            
            // 小数点在字符串中的位置 第一个数字从0位置开始
            
            NSInteger dotLocation = [textField.text rangeOfString:@"."].location;
            
            // 判断字符串中是否有小数点，并且小数点不在第一位
            
            // NSNotFound 表示请求操作的某个内容或者item没有发现，或者不存在
            
            // range.location 表示的是当前输入的内容在整个字符串中的位置，位置编号从0开始
            
            if (dotLocation == NSNotFound && range.location != 0) {
                
                // 取只包含“myDotNumbers”中包含的内容，其余内容都被去掉
                
                if (range.location >= 7) {
                    [self.view showError:@"单笔金额不能超过百万" hideAfterDelay:1];
                    
                    
                    
                    if ([string isEqualToString:@"."] && range.location == 9)
                        
                    {
                        
                        return YES;
                        
                    }
                    
                    return NO;
                    
                }else{
                    
                    if (_dot ==YES)
                        
                    {
                        
                        if ([string isEqualToString:@"."])
                            
                        {
                            
                            return YES;
                            
                        }
                        
                        return NO;
                        
                    }else{
                        
                        NSString *first = [textField.text substringFromIndex:0];
                        
                        if ([first isEqualToString:@"0"])
                            
                        {
                            
                            if ([string isEqualToString:@"."])
                                
                            {
                                
                                return YES;
                                
                            }
                            
                            return NO;
                            
                        }else{
                            
                            return YES;
                            
                        }
                        
                    }
                    
                }
                
            }else {
                
                if ([string isEqualToString:@"."]){
                    
                    NSString *first = [textField.text substringFromIndex:0];
                    
                    if ([first isEqualToString:@"0"]) {
                        
                        self.amountTextField.text = @"0";
                        
                    }else if ([first isEqualToString:@""]){
                        
                        self.amountTextField.text = @"0";
                        
                    }else{
                        
                        if ([string isEqualToString:@"."]){
                            
                            return NO;
                            
                        }
                        
                        return YES;
                        
                    }
                    
                }
                
                if ([string isEqualToString:@"0"]){
                    
                    _dot =YES;
                    
                }else{
                    
                    _dot =NO;
                    
                }
                
            }
            
            if (dotLocation != NSNotFound && range.location > dotLocation + 2) {
                
                return NO;
                
            }
            
            if (textField.text.length > 11) {
                
                return NO;
                
            }
            
            
        }
        
    }
    
    return YES;
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.nameTextField) {
        [self.accountTextField becomeFirstResponder];
        
    }else if(textField == self.accountTextField){
        
        [self.amountTextField becomeFirstResponder];
        
    }
    
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
@interface LSWalletsAlterView()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end

@implementation LSWalletsAlterView


+ (instancetype)walletsAlterView {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"LSWalletsAlterView" owner:nil options:nil]firstObject];
}



- (IBAction)sureAction:(id)sender {
    


    [LSUserModel getMoneyWithAmount:self.amountLabel.text alipay:self.accountLabel.text name:self.nameLabel.text Success:^(NSString * messageStr) {
        
        
        LSWalletsSuccessAlterView * successView = [LSWalletsSuccessAlterView walletsSuccessAlterView];
        @weakify(self)
        
        [successView setSuccessBlock:^{
            @strongify(self)
            self.successBlock();
            [self hidden];
        }];
        successView.frame = self.superview.bounds;
        [self.superview addSubview:successView];
        [successView show];
    } failure:^(NSError *error) {
        
        NSString * infoStr =  error.userInfo[@"NSLocalizedFailureReason"];
        if ([infoStr isEqualToString:@"amount's not enough"]) {
            [self showError:@"余额不足" hideAfterDelay:1] ;
        }else{
            [self showError:@"申请失败" hideAfterDelay:1];

        }
    }];
}


- (IBAction)cancelAction:(id)sender {
    [self hidden];
}


-(void)setModel:(LSUserwWithDrawModel *)model{
    self.nameLabel.text = model.userName;
    self.accountLabel.text = model.account;
    self.amountLabel.text = model.amount;
    
}


-(void)show{
    self.alpha = 0;
    @weakify(self)
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self)
        self.alpha = 1;
    }];
}

-(void)hidden{
    self.alpha = 1;
    @weakify(self)
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self)
        self.alpha = 0;
    } completion:^(BOOL finished) {
        @strongify(self)
        [self removeFromSuperview];
    }];
}


@end



@interface LSWalletsSuccessAlterView()

@end

@implementation  LSWalletsSuccessAlterView

+ (instancetype)walletsSuccessAlterView {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"LSWalletsAlterView" owner:nil options:nil]lastObject];
}


-(void)show{
    self.alpha = 0;
    @weakify(self)
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self)
        self.alpha = 1;
    }];
}

-(void)hidden{
    self.alpha = 1;
    @weakify(self)
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self)
        self.alpha = 0;
    } completion:^(BOOL finished) {
        @strongify(self)
        [self removeFromSuperview];
    }];
}

- (IBAction)sureAction:(id)sender {
    self.successBlock();
    [self hidden];
}


@end

