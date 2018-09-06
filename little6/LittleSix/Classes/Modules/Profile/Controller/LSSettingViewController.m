//
//  LSSettingViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSettingViewController.h"
#import "LSAboutUsViewController.h"
#import "ComfirmView.h"
#import "LSShareView.h"

@interface LSSettingViewController ()

@end

@implementation LSSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.backgroundColor = HEXRGB(0xefeff4);

    self.title = @"设置";
}

#pragma mark - Action

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15 : 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 1 && indexPath.row == 0) {
        
        LSAboutUsViewController * aboutVc = [LSAboutUsViewController new];
        
        [self.navigationController pushViewController:aboutVc animated:YES];
    }
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        
        [self shareAction];
    }
    
    if (indexPath.section == 1 && indexPath.row == 2) {
        
        UIViewController *webVC = [NSClassFromString(@"LSWebViewController") new];
        [webVC setValue:@"gameRule" forKey:@"type"];
        [webVC setValue:kFuwaRuleURL forKey:@"urlString"];
        [self.navigationController pushViewController:webVC animated:YES];
    }
    
    //退出登录
    if (indexPath.section == 2) {
        ModelComfirm *item1 = [ModelComfirm comfirmModelWith:@"确认退出" titleColor:HEXRGB(0x666666) fontSize:16];
        ModelComfirm *cancelItem = [ModelComfirm comfirmModelWith:@"取消" titleColor:[UIColor redColor] fontSize:16];
        //确认提示框
        [ComfirmView showInView:LSKeyWindow cancelItemWith:cancelItem dataSource:@[ item1 ] actionBlock:^(ComfirmView *view, NSInteger index) {
            //退出登录
            [LSAppManager logout];
        }];
    }
}

- (void)shareAction {
    
    NSURL *shareURL = [NSURL URLWithString:@"http://www.boss89.com"];
    
    if (!shareURL) return;
    
    NSString *shareTitle = @"嗨萌一起来玩嗨萌吧~~";
    
    NSMutableDictionary *shareParam = [NSMutableDictionary dictionary];
    
    NSString * logoImage = @"http://wsimcdn.hmg66.com/hm_logo.png";
    [shareParam SSDKSetupShareParamsByText:@"这里有你喜爱的AR寻宝和海量嗨萌视频，你想不到的事情正在发生，赶快来玩吧~~" images:@[logoImage] url:shareURL title:shareTitle type:SSDKContentTypeWebPage];
    
    [LSShareView showInView:LSKeyWindow withItems:[LSShareView shareItems] actionBlock:^(SSDKPlatformType type) {
        //分享出去
        [LSShareView shareTo:type withParams:shareParam onStateChanged:nil];
    }];
}

@end
