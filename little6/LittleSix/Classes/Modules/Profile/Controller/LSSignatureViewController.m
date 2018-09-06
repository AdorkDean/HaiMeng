//
//  LSsignatureViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSignatureViewController.h"
#import "UIView+HUD.h"

@interface LSSignatureViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation LSSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个性签名";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"保存" forState:UIControlStateNormal];
    button.titleLabel.font = SYSTEMFONT(16);
    [button sizeToFit];
    [button addTarget:self action:@selector(changeSignature) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.contentTextView.delegate =self;
    self.contentTextView.text = [LSAppManager sharedAppManager].loginUser.signature;
    self.countLabel.text = [NSString stringWithFormat:@"%lu/30",(unsigned long)self.contentTextView.text.length];
}

-(void)changeSignature{
    
    if (self.contentTextView.text.length>30)
    {
        [self.view showError:@"简介不能超过30字" hideAfterDelay:1];
        return ;
    }
    [self.view showLoading];
    [LSUserModel changeSignatureWithStr:self.contentTextView.text Success:^{
        [self.view showSucceed:@"修改个性签名成功" hideAfterDelay:1];
        [LSAppManager sharedAppManager].loginUser.signature = self.contentTextView.text;
        self.SignatureBlock(self.contentTextView.text);
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [self.view showError:@"修改个性签名失败" hideAfterDelay:1];

    }];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15 : 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}


#pragma mark - *** UITextView Delegate ***
- (void)textViewDidChange:(UITextView *)textView{
    
    self.countLabel.text = [NSString stringWithFormat:@"%lu/30",(unsigned long)textView.text.length];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * searchStr =[NSString string];
    if (!(range.location == 0&& range.length == 1)) {
        if (range.length == 0)
            searchStr = [textView.text stringByAppendingString:text];
        else
            searchStr = [textView.text substringToIndex:[textView.text length]-1];
        
        if (searchStr.length>30)
        {
            [self.view showError:@"简介不能超过30字" hideAfterDelay:1];
            return NO;
        }
        else
        {
            return YES;
        }
    }else{
        return YES;
    }

}

-(void)dealloc{
    
}

@end
