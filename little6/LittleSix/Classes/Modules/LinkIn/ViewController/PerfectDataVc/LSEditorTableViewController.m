//
//  LSEditorTableViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/4/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEditorTableViewController.h"
#import "LSLinkInApplyModel.h"
#import "UIView+HUD.h"

@interface LSEditorTableViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *editorTextView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation LSEditorTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"编辑";
    self.countLabel.hidden = [self.editorType isEqualToString:@"introduce"]?YES:NO;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"保存" forState:UIControlStateNormal];
    button.titleLabel.font = SYSTEMFONT(16);
    [button sizeToFit];
    [button addTarget:self action:@selector(changeSignature) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.editorTextView.delegate =self;
    
    self.editorTextView.text = [self.editorType isEqualToString:@"introduce"] ? self.desc : [self.editorType isEqualToString:@"address"] ? self.address : self.phone;
    self.countLabel.text = [NSString stringWithFormat:@"%lu/50",(unsigned long)self.editorTextView.text.length];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

-(void)changeSignature{
    
    [self.view endEditing:YES];
    
    if (![self.editorType isEqualToString:@"introduce"]) {
    
        if (self.editorTextView.text.length>50)
        {
            [self.view showError:@"文字不能超过50字" hideAfterDelay:1];
            return ;
        }
    }
    [self.view showLoading];
    
    if ([self.editorType isEqualToString:@"introduce"]) {
        
        [LSLinkInApplyModel linkInApplyWithC_id:self.s_id name:@"" desc:self.editorTextView.text contact:@"" province:@"" city:@"" district:@"" address:@"" type:[self.type intValue]success:^{
            
            [self.view hideHUDAnimated:YES];
            [self.view showInfo:@"保存成功" hideAfterDelay:1.0];
            [[NSNotificationCenter defaultCenter] postNotificationName:kIntroduceLinkInInfoNoti object:nil];
            //发送通知刷新人脉首页
            [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteLinkInInfoNoti object:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError *error) {
            [self.view hideHUDAnimated:YES];
            [LSKeyWindow showError:@"保存失败" hideAfterDelay:1.0];
        }];
        
    }else if ([self.editorType isEqualToString:@"address"]){

        [LSLinkInApplyModel linkInApplyWithC_id:self.s_id name:@"" desc:@"" contact:@"" province:@"" city:@"" district:@"" address:self.editorTextView.text type:[self.type intValue]success:^{
            
            [self.view hideHUDAnimated:YES];
            [self.view showInfo:@"保存成功" hideAfterDelay:1.0];
            [[NSNotificationCenter defaultCenter] postNotificationName:kIntroduceLinkInInfoNoti object:nil];
            //发送通知刷新人脉首页
            [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteLinkInInfoNoti object:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError *error) {
            [self.view hideHUDAnimated:YES];
            [LSKeyWindow showError:@"保存失败" hideAfterDelay:1.0];
        }];
    }else {
    
        [LSLinkInApplyModel linkInApplyWithC_id:self.s_id name:@"" desc:@"" contact:self.editorTextView.text province:@"" city:@"" district:@"" address:@"" type:[self.type intValue]success:^{
            
            [self.view hideHUDAnimated:YES];
            [self.view showInfo:@"保存成功" hideAfterDelay:1.0];
            [[NSNotificationCenter defaultCenter] postNotificationName:kIntroduceLinkInInfoNoti object:nil];
            //发送通知刷新人脉首页
            [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteLinkInInfoNoti object:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError *error) {
            [self.view hideHUDAnimated:YES];
            [LSKeyWindow showError:@"保存失败" hideAfterDelay:1.0];
        }];
    }
    
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15 : 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return [self.editorType isEqualToString:@"introduce"] ? 200 : 100 ;
}


#pragma mark - *** UITextView Delegate ***
- (void)textViewDidChange:(UITextView *)textView {
    
    if ([self.editorType isEqualToString:@"introduce"]) return;
    
    NSInteger kMaxLength = 50;
    
    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        if(!position) {
            if(toBeString.length > kMaxLength) {
                textView.text = [toBeString substringToIndex:kMaxLength];
            }
        }
        else{
            
        }
    }
    else{
        if(toBeString.length > kMaxLength) {
            textView.text= [toBeString substringToIndex:kMaxLength];
        }
    }

    self.countLabel.text = [NSString stringWithFormat:@"%lu/50",(unsigned long)textView.text.length];
}

- (IBAction)deleteClick:(UIButton *)sender {
    
    self.editorTextView.text = @"";
    [self.editorTextView becomeFirstResponder];
}


@end
