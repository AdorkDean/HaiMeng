//
//  LSDiscoverViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSDiscoverViewController.h"
#import "LSQRCodeViewController.h"
#import "MMDrawerController.h"
#import "LSMenuDetailButton.h"

@interface LSDiscoverViewController ()

@end

@implementation LSDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"发现";
    
    [self installNotis];
    
    LSMenuDetailButton *leftButton = [LSMenuDetailButton buttonWithType:UIButtonTypeCustom];
    
    UIBarButtonItem *lefItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = lefItem;
    
    [[leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }];
}

- (void)installNotis {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kInReviewNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15 : 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([LSAppManager isInReview] && indexPath.section == 3 && indexPath.row == 1) {
        return 0;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //朋友圈
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self pushViewController:@"LSTimeLineViewController"];
    }//扫一扫
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        LSQRCodeViewController * vc = [LSQRCodeViewController new];
        vc.codeType = LSQRcodeTypeFriend;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }//摇一摇
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        [self pushViewController:@"LSShakeViewController"];
    }//附近的人
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        [self pushViewController:@"LSPeopleNearbyViewController"];
    }//购物
    else if (indexPath.section == 3 && indexPath.row == 0)
    {//
//        [self pushViewController:@"LSWebViewController"];
        
        UIViewController *vc = [NSClassFromString(@"LSWebViewController") new];
        vc.hidesBottomBarWhenPushed = YES;
        [vc setValue:@"http://m.66boss.com/" forKey:@"urlString"];
        [self.navigationController pushViewController:vc animated:YES];

    }//游戏
    else if (indexPath.section == 3 && indexPath.row == 1)
    {
        [self pushViewController:@"LSFuwaHomeViewController"];
    }
    
}

- (void)pushViewController:(NSString *)string {
    UIViewController *vc = [NSClassFromString(string) new];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
