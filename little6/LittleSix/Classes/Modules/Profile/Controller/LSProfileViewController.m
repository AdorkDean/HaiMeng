//
//  LSProfileViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSProfileViewController.h"
#import "LSPersonInfoViewController.h"

#import "LSWalletsViewController.h"

#import "MMDrawerController.h"
#import "LSMenuDetailButton.h"


@interface LSProfileViewController ()

@property (nonatomic,strong) LSUserModel *userModel;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;

@end

@implementation LSProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人中心";

    self.tableView.backgroundColor = HEXRGB(0xefeff4);
    
    ViewBorderRadius(self.iconView, 5.0, 0.5, [UIColor lightGrayColor]);
    self.iconView.clipsToBounds = YES;
    
    LSMenuDetailButton *leftButton = [LSMenuDetailButton buttonWithType:UIButtonTypeCustom];
    
    UIBarButtonItem *lefItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = lefItem;
    
    [[leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.iconView setImageWithURL:[NSURL URLWithString:ShareAppManager.loginUser.avatar] placeholder:timeLineSmallPlaceholderName];
    self.nameLabel.text = ShareAppManager.loginUser.user_name;
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15 : 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && indexPath.row == 2 && [LSAppManager isInReview]) {
        return 0.1;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        LSPersonInfoViewController * infoVC = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileVC"];
        [self.navigationController pushViewController:infoVC animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        [self pushViewController:@"LSTimeLineHomeViewController"];
    }
    else if (indexPath.section == 1 && indexPath.row == 1) {
        [self pushViewController:@"LSCollectionViewController"];
    }
    else if (indexPath.section == 1 && indexPath.row == 2) {
        UIViewController * VC =  [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"XWalletsVC"];

        VC.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:VC animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 0) {
        [self pushViewController:@"LSEmotionsShopViewController"];
    }
}

- (UIViewController *)pushViewController:(NSString *)string {
    UIViewController *vc = [NSClassFromString(string) new];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    return vc;
}

@end
