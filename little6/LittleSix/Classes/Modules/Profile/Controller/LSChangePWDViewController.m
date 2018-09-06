//
//  LSChangePWDViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSChangePWDViewController.h"
#import "UIView+HUD.h"

@interface LSChangePWDViewController ()
@property (weak, nonatomic) IBOutlet UITextField *pwdOldTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdNewTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdNewAgainTextField;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@end

@implementation LSChangePWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    
    [self.sureBtn addTarget:self action:@selector(setSureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    

    self.sureBtn.layer.cornerRadius = 6.0;

}

-(void)setSureBtnAction{
    
    NSString *oldPWD = [self.pwdOldTextField.text stringByTrim];
    NSString *newPWD = [self.pwdNewTextField.text stringByTrim];
    NSString *newAgainPWD = [self.pwdNewAgainTextField.text stringByTrim];

    if (oldPWD.length<6 || newPWD.length<6||newAgainPWD.length<6) {
        [self.view showAlertWithTitle:@"提示" message:@"密码长度不能少于6位"];
        return;
    }else if (![newPWD isEqualToString:newAgainPWD]){
        [self.view showAlertWithTitle:@"提示" message:@"两次输入的新密码不一致"];
        return;
    }else if([oldPWD isEqualToString:newPWD]){
        [self.view showAlertWithTitle:@"提示" message:@"新密码和旧密码不能相同"];
        return;
    }
    
    [LSKeyWindow showLoading];
    [LSUserModel changePWDWithNewPWD:newPWD OldPWD:oldPWD Success:^{
        [LSKeyWindow showSucceed:@"修改成功" hideAfterDelay:1];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [LSKeyWindow showSucceed:@"修改失败" hideAfterDelay:1];

    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
