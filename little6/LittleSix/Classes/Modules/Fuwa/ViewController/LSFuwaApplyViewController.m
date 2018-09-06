//
//  LSFuwaApplyViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/4/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaApplyViewController.h"
#import "LSFuwaModel.h"
#import "UIView+HUD.h"
#import "LSChoosePickVeiw.h"
#import "LSFuwaApplyView.h"

@interface LSFuwaApplyViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *useTextField;
@property (weak, nonatomic) IBOutlet UITextField *regionTextField;

@property (nonatomic,strong) UIButton *selectedButton;
@property (weak, nonatomic) IBOutlet UIButton *merchantsButton;

@property (nonatomic,strong) LSFuwaApplyModel *model;

@end

@implementation LSFuwaApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"申请福娃";
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
 
    self.view.backgroundColor = [UIColor whiteColor];
    ViewBorderRadius(self.applyButton, 5, 1, HEXRGB(0xff0012));
    self.selectedButton = self.merchantsButton;
    
    self.model = [LSFuwaApplyModel new];
    self.model.shop = 1;
    
    RAC(self.model,name) = self.nameTextField.rac_textSignal;
    RAC(self.model,phone) = self.phoneTextField.rac_textSignal;
    RAC(self.model,purpose) = self.useTextField.rac_textSignal;
    RAC(self.model,region) = self.regionTextField.rac_textSignal;
    RAC(self.model,number) = self.accountTextField.rac_textSignal;
    
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextFieldTextDidChangeNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self textFiledEditChanged:x];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    UIImage *image = [[UIImage imageNamed:@"fuwa_top"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (IBAction)regionAction:(id)sender {
    [self.view endEditing:YES];
    LSChoosePickVeiw * addressPickView = [LSChoosePickVeiw new];
    [addressPickView ininSoureData:1];
    @weakify(self)
    [addressPickView setConfig:^(NSString * address,NSString * province_Id,NSString * city_Id,NSString * town_Id){
        @strongify(self)
        self.regionTextField.text = address;
        self.model.region = address;
    }];
    [self.view addSubview:addressPickView];
}

- (IBAction)typeAction:(UIButton *)sender {
    
    self.selectedButton.selected = NO;
    sender.selected = YES;
    self.selectedButton = sender;
    
    self.model.shop = sender.tag;
}

- (IBAction)applyAction:(id)sender {
    
    if (![self canGo]) return;
    
    [self.view endEditing:YES];
    
    [LSFuwaApplyView showInView:LSKeyWindow doneAction:^{
        
        [LSKeyWindow showLoading:@"正在申请"];
        
        [LSFuwaModel appleFuwaWith:self.model success:^{
            [LSKeyWindow showSucceed:@"申请成功" hideAfterDelay:1.5];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [LSKeyWindow showError:@"申请失败" hideAfterDelay:1.5];
        }];

    } cancelBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}

- (BOOL)canGo {
    
    if (!self.model.name || self.model.name.length == 1) {
        [LSKeyWindow showError:@"名字小于或等于一个字" hideAfterDelay:1.5];
        return NO;
    }
    if (!self.model.name || self.model.name.length == 0) {
        
        [LSKeyWindow showError:@"请填写姓名" hideAfterDelay:1.5];
        return NO;
    }
    if (!self.model.phone || self.model.phone.length == 0) {
        [LSKeyWindow showError:@"请填写手机" hideAfterDelay:1.5];
        return NO;
    }
    if (!self.model.number || self.model.number.length == 0) {
        [LSKeyWindow showError:@"请填写个数" hideAfterDelay:1.5];
        return NO;
    }
    if (!self.model.purpose || self.model.purpose.length == 0) {
        [LSKeyWindow showError:@"请填写用途" hideAfterDelay:1.5];
        return NO;
    }
    if (!self.model.region || self.model.region.length == 0) {
        [LSKeyWindow showError:@"请选择区域" hideAfterDelay:1.5];
        return NO;
    }
    
    if (![self isMobileNumber:self.phoneTextField.text]) {
        [LSKeyWindow showError:@"手机格式错误" hideAfterDelay:1.5];
        return NO;
    }
    
    return YES;
}

- (BOOL)isMobileNumber:(NSString *)mobileNum {
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[06-8])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:mobileNum];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //删除文字
    if (string.length == 0) return YES;
    
    if ([textField isEqual:self.phoneTextField]) {
        return textField.text.length < 11;
    }
    else if ([textField isEqual:self.accountTextField]) {
        return textField.text.length < 3;
    }
    else if ([textField isEqual:self.useTextField]) {
        return textField.text.length+string.length <= 200;
    }
    
    return YES;
}

- (void)textFiledEditChanged:(NSNotification*)obj {
    
    UITextField *textField = (UITextField *)obj.object;
    
    if (![textField isEqual:self.nameTextField]) return;
    
    NSInteger kMaxLength = 5;
    
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if(!position) {
            if(toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }
        else{
            
        }
    }
    else{
        if(toBeString.length > kMaxLength) {
            textField.text= [toBeString substringToIndex:kMaxLength];
        }
    }
}

@end
