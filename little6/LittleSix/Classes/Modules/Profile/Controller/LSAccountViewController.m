//
//  LSAccountViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSAccountViewController.h"
#import "LSChangePWDViewController.h"
#import "UIView+HUD.h"
@interface LSAccountViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *QQNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *securityLabel;

@end

@implementation LSAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"账号与安全";
    self.tableView.backgroundColor = HEXRGB(0xefeff4);
    self.userIDLabel.text = ShareAppManager.loginUser.user_id;
    self.QQNumLabel.text = @"";
    self.phoneNumLabel.text =ShareAppManager.loginUser.mobile_phone;
    self.emailLabel.text = @"";
    self.securityLabel.text = @"未保护";
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15 : 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    userLoginType loginType = ShareAppManager.loginUser.loginType;
    if (indexPath.section == 2 && indexPath.row==0 ) {
        if (loginType == userLoginTypeWeChat || loginType == userLoginTypeQQ) {
            [self.view showAlertWithTitle:@"不能修改密码" message:@"微信或QQ登录的时候不能修改密码"];
            return;
        }
        
        LSChangePWDViewController * pwdVC = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"LSChangePWDViewController"];
        [self.navigationController pushViewController:pwdVC animated:YES];
    }
    
}
@end
