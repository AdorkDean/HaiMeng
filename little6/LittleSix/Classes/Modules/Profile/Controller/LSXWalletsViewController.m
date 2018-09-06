//
//  LSXWalletsViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/7/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSXWalletsViewController.h"
#import "UIView+HUD.h"

@interface LSXWalletsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *chargeButton;
@property (weak, nonatomic) IBOutlet UIButton *withdrawalButton;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@end

@implementation LSXWalletsViewController

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    [self loadAmountData];
}

-(void)loadAmountData{
    
    [LSUserModel queryBalancesSuccess:^(NSString * balanceStr) {
        CGFloat balance = balanceStr.floatValue;
        self.balanceLabel.text = [NSString stringWithFormat:@"%.2f",balance];
        
    } failure:^(NSError *error) {
        [self.view showError:@"查询余额失败" hideAfterDelay:1];
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"钱包";
}

- (IBAction)withdrawalClick:(UIButton *)sender {
    
    UIViewController * vc =  [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"WalletsVC"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)chargeClick:(UIButton *)sender {
    
    UIViewController * vc =  [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"ChargeVC"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
