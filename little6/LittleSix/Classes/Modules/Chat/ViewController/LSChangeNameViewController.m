//
//  LSChangeNameViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSChangeNameViewController.h"
#import "UIView+HUD.h"
#import "LSGroupModel.h"

@interface LSChangeNameViewController ()

@property (retain,nonatomic)UITextField * textField;

@property (retain,nonatomic)UITextView * textView;

@end

@implementation LSChangeNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    
    [self createUI];
    [self navigationBar];
    
}

- (void)navigationBar {

    UIButton * completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    completeBtn.titleLabel.font = SYSTEMFONT(16);
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(completeClick:) forControlEvents:UIControlEventTouchUpInside];
    [completeBtn sizeToFit];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:completeBtn];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)completeClick:(UIButton *)sender {

    [LSGroupModel modifyGroupWithGroupid:self.groupid notice:self.textView.text name:self.textField.text success:^(NSString *message) {
        
        NSString * textStr = self.type == 1 ? self.textField.text : self.textView.text;
        if (self.sureClick) {
            self.sureClick(textStr,self.type);
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        [LSKeyWindow showError:@"修改失败" hideAfterDelay:1.5];
    }];
}

- (void)createUI {

    if (self.type == 1) {
        self.title = @"群聊名称";
        UILabel * nameLabel = [UILabel new];
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textColor = [UIColor lightGrayColor];
        nameLabel.text = @"群聊名称";
        [self.view addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.view.mas_left).offset(15);
            make.right.equalTo(self.view.mas_right).offset(-15);
            make.top.equalTo(self.mas_topLayoutGuide);
            make.height.equalTo(@(20));
        }];
        
        self.textField = [UITextField new];
        self.textField.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.textField];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.equalTo(self.view);
            make.top.equalTo(nameLabel.mas_bottom).offset(5);
            make.height.equalTo(@(40));
        }];
    }else{
        self.title = @"群公告";
        UILabel * nameLabel = [UILabel new];
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textColor = [UIColor lightGrayColor];
        nameLabel.text = @"群公告";
        [self.view addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.view.mas_left).offset(15);
            make.right.equalTo(self.view.mas_right).offset(-15);
            make.top.equalTo(self.mas_topLayoutGuide);
            make.height.equalTo(@(20));
        }];
        
        self.textView = [UITextView new];
        self.textView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.textView];
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.equalTo(self.view);
            make.top.equalTo(nameLabel.mas_bottom).offset(5);
            make.height.equalTo(@(100));
        }];
    }
    
    
}


@end
