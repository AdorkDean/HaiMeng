//
//  LSLSApplyCreateTableViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/4/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLSApplyCreateTableViewController.h"
#import "LSChoosePickVeiw.h"
#import "LSLinkInPopView.h"
#import "LSLinkInApplyModel.h"
#import "UIView+HUD.h"

@interface LSLSApplyCreateTableViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;

@property (copy, nonatomic) NSString * provinceId;
@property (copy, nonatomic) NSString * cityId;
@property (copy, nonatomic) NSString * townId;

@end

@implementation LSLSApplyCreateTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"创建";
    
    self.nameTextField.delegate = self;
    self.nameTextField.returnKeyType = UIReturnKeyDone;
    if (self.type) {
        self.typeLabel.text = self.type == 3 ? @"商会" : self.type == 4 ? @"宗亲" : @"企业号";
    }
    
}


- (void)createRequest {

    if ([self.nameTextField.text isEqualToString:@""]||self.nameTextField.text.length == 0 || [self.provinceId isEqualToString:@""] || self.provinceId.length == 0 || [self.cityId isEqualToString:@""] || self.cityId.length == 0 || [self.townId isEqualToString:@""] || self.townId.length == 0) {
        
        [self.view showError:@"请完善资料" hideAfterDelay:1.5];
        return;
    }
    [self.view showLoading];
    [self.nameTextField resignFirstResponder];
    [LSLinkInApplyModel linkInApplyWithName:self.nameTextField.text province:self.provinceId city:self.cityId district:self.townId type:self.typeLabel.text success:^{
        //发送通知刷新人脉首页
        [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteLinkInInfoNoti object:nil];
        [self.navigationController popViewControllerAnimated:YES];
        [self.view hideHUDAnimated:YES];
    } failure:^(NSError *error) {
        [self.view showError:@"创建失败" hideAfterDelay:1.0];
        [self.view hideHUDAnimated:YES];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case 0:
        {
            [self.nameTextField resignFirstResponder];
            if (self.type) return;
            [[LSLinkInPopView linkInMainView] showInView:self andArray:@[@[@"宗亲",@"商会",@"部落"],@[@"取消"]] withBlock:^(NSString *title) {
                self.typeLabel.text = title;
            }];
        }
            break;
        case 2:
        {
            [self.nameTextField resignFirstResponder];
            LSChoosePickVeiw * addressChoose = [[LSChoosePickVeiw alloc] init];
            [addressChoose ininSoureData:1];
            addressChoose.config = ^(NSString * address,NSString *provinceId, NSString *cityId, NSString *townId){
                self.regionLabel.text = address;
                self.provinceId = provinceId;
                self.cityId = cityId;
                self.townId = townId;
            };
            [self.view addSubview:addressChoose];
        }
            break;
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    UIView *footerView = [UIView new];
    
    footerView.backgroundColor = [UIColor clearColor];
//    UIView *lineView = [UIView new];
//    lineView.backgroundColor = HEXRGB(0xbcbcbc);
//    [footerView addSubview:lineView];
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(footerView.mas_left).offset(16);
//        make.top.right.equalTo(footerView);
//        make.height.offset(0.5);
//    }];
//    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setTitle:@"创建" forState:UIControlStateNormal];
    nextButton.backgroundColor = kMainColor;
    nextButton.titleLabel.font = SYSTEMFONT(18);
    ViewRadius(nextButton, 5);
    nextButton.frame = CGRectMake(30, 80, kScreenWidth-60, 50);
    [footerView addSubview:nextButton];
    @weakify(self)
    [[nextButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton * button) {
        @strongify(self);

        [self createRequest];
    }];

    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 150;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    
    return YES;
}

@end

