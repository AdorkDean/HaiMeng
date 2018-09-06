//
//  LSPhoneDetailViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPhoneDetailViewController.h"
#import "LSChangePhoneNumViewController.h"
#import "LSSearchPhoneNumListViewController.h"
#import <ContactsUI/ContactsUI.h>

@interface LSPhoneDetailViewController ()<CNContactPickerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *uploadAddressBookBtn;
@property (weak, nonatomic) IBOutlet UIButton *changePhoneNumBtn;


@end

@implementation LSPhoneDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定手机号";
    if (ShareAppManager.loginUser.loginType == userLoginTypeQQ ||ShareAppManager.loginUser.loginType == userLoginTypeWeChat ) {
        self.phoneNumLabel.text = @"你正在用QQ或者微信登录";
        self.changePhoneNumBtn.hidden = YES;
    }else{
        self.phoneNumLabel.text = [NSString stringWithFormat:@"你的手机号:%@",ShareAppManager.loginUser.mobile_phone];
        self.changePhoneNumBtn.hidden = NO;
    }

    [self.changePhoneNumBtn addTarget:self action:@selector(pushtoChangePhoneNumVC) forControlEvents:UIControlEventTouchUpInside];
    
    [self.uploadAddressBookBtn addTarget:self action:@selector(pushToAdressBook) forControlEvents:UIControlEventTouchUpInside];
    
    self.changePhoneNumBtn.layer.cornerRadius = 6.0;
    self.uploadAddressBookBtn.layer.cornerRadius = 6.0;

}

-(void)pushToAdressBook{
    
    CNContactPickerViewController *contactPickerViewController = [[CNContactPickerViewController alloc] init];
    contactPickerViewController.delegate = self;
    
    [self presentViewController:contactPickerViewController animated:YES completion:nil];
    
}

-(void)pushtoChangePhoneNumVC{
    LSChangePhoneNumViewController * phoneNumVC = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"LSChangePhoneNumViewController"];
    @weakify(self)

    [phoneNumVC setPhoneNumBlock:^(NSString * newPhoneNum){
        @strongify(self)
        self.phoneNumLabel.text = [NSString stringWithFormat:@"你的手机号:%@",ShareAppManager.loginUser.mobile_phone];
    }];
    [self.navigationController pushViewController:phoneNumVC animated:YES];
}


- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts {
    
    if (contacts.count<1) return;
    
    NSMutableArray * selectPhoneNumArr = [NSMutableArray array];
    for (CNContact *contact in contacts) {
        
        NSArray * phoneNumbers = contact.phoneNumbers;
        for (CNLabeledValue<CNPhoneNumber*>*phone in phoneNumbers) {
            
            CNPhoneNumber *phoneNumber = (CNPhoneNumber *)phone.value;
            NSString * phoneStr = [phoneNumber stringValue];
            phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"-" withString:@""];

            if ([self valiMobile:phoneStr]) [selectPhoneNumArr addObject:phoneStr];
        }
    }
    
    NSString * listStr = [selectPhoneNumArr componentsJoinedByString:@","];

    LSSearchPhoneNumListViewController * vc = [LSSearchPhoneNumListViewController new];
    vc.listStr = listStr;
    [self.navigationController pushViewController:vc animated:YES];
}



-(BOOL)valiMobile:(NSString *)mobile
{
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11)
    {
        return NO;
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else{
            return NO;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
