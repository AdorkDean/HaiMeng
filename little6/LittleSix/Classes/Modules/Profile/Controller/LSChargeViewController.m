//
//  LSChargeViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/7/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSChargeViewController.h"
#import <AlipaySDK/AlipaySDK.h>

@interface LSChargeViewController ()

@property (nonatomic,assign) NSInteger payType;
@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;

@end

@implementation LSChargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"充值";
    
    self.payType = 0;
}

- (IBAction)chargeTypeClick:(UISegmentedControl *)sender {
    
    NSInteger index = sender.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.payType = 0;
            break;
            
        default:
            self.payType = 1;
            break;
    }
}

- (IBAction)chargeClick:(UIButton *)sender {
    
}

- (void)doAlipay:(NSString *)orderString {
    
    if (!orderString) return;
    
    NSString *appScheme = @"HimengApp";
    
    // NOTE: 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"支付回调 = %@",resultDic);
    }];
}

@end
