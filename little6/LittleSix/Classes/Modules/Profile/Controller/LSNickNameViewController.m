//
//  LSNickNameViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSNickNameViewController.h"
#import "UIView+HUD.h"
@interface LSNickNameViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation LSNickNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"名字";
 
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"保存" forState:UIControlStateNormal];
    
    button.titleLabel.font = SYSTEMFONT(16);
    [button sizeToFit];
    [button addTarget:self action:@selector(changeName) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.nameTextField.text = [LSAppManager sharedAppManager].loginUser.user_name;
}

-(void)changeName{
    
    [self.nameTextField endEditing:YES];
    
    if ([self.nameTextField.text isEqualToString:[LSAppManager sharedAppManager].loginUser.user_name]) {
        [self.view showError:@"请修改名字后再提交" hideAfterDelay:1];
    }else{
        [self.view showLoading];
        [LSUserModel changeUserNameWithStr:self.nameTextField.text Success:^{
            [self.view showSucceed:@"修改成功" hideAfterDelay:1];
            self.changeNameBlock(self.nameTextField.text);
            ShareAppManager.loginUser.user_name = self.nameTextField.text;
            //异步将用户信息保存到本地
            kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
                [LSAppManager storeUser:ShareAppManager.loginUser];
            })
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [self.view showError:@"修改失败" hideAfterDelay:1];

        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

@end
