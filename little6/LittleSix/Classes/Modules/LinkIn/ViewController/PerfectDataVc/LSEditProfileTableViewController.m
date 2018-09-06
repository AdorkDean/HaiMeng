//
//  LSEditProfileTableViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/4/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEditProfileTableViewController.h"

@interface LSEditProfileTableViewController ()
@property (weak, nonatomic) IBOutlet UIView *backgroundView1;
@property (weak, nonatomic) IBOutlet UIView *backgroundView2;
@property (weak, nonatomic) IBOutlet UIView *backgroundView3;
@property (weak, nonatomic) IBOutlet UIView *backgroundView4;

@end

@implementation LSEditProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑简介";
    ViewBorderRadius(self.backgroundView1,0,1,[UIColor lightGrayColor]);
    ViewBorderRadius(self.backgroundView2,0,1,[UIColor lightGrayColor]);
    ViewBorderRadius(self.backgroundView3,0,1,[UIColor lightGrayColor]);
    ViewBorderRadius(self.backgroundView4,0,1,[UIColor lightGrayColor]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [self.type intValue] == 3 ? 4 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case 0:
        {
        
            UIViewController * selectLogoVc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSSelectLogo"];
            [selectLogoVc setValue:self.s_id forKey:@"s_id"];
            [selectLogoVc setValue:self.type forKey:@"type"];
            [self.navigationController pushViewController:selectLogoVc animated:YES];
        }
            break;
        case 1:
        {
            UIViewController * selectLogoVc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSEditor"];
            [selectLogoVc setValue:self.s_id forKey:@"s_id"];
            [selectLogoVc setValue:self.type forKey:@"type"];
            [selectLogoVc setValue:self.desc forKey:@"desc"];
            [selectLogoVc setValue:@"introduce" forKey:@"editorType"];
            [self.navigationController pushViewController:selectLogoVc animated:YES];
        }
            break;
        case 2:
        {
            UIViewController * selectLogoVc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSEditor"];
            [selectLogoVc setValue:self.s_id forKey:@"s_id"];
            [selectLogoVc setValue:self.type forKey:@"type"];
            [selectLogoVc setValue:self.address forKey:@"address"];
            [selectLogoVc setValue:@"address" forKey:@"editorType"];
            [self.navigationController pushViewController:selectLogoVc animated:YES];
        }
            break;
        case 3:
        {
            UIViewController * selectLogoVc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSEditor"];
            [selectLogoVc setValue:self.s_id forKey:@"s_id"];
            [selectLogoVc setValue:self.type forKey:@"type"];
            [selectLogoVc setValue:self.phone forKey:@"phone"];
            [selectLogoVc setValue:@"phone" forKey:@"editorType"];
            [self.navigationController pushViewController:selectLogoVc animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
