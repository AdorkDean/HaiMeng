//
//  LSNameViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSNameViewController.h"

@interface LSNameViewController ()

@property (retain,nonatomic)UITextField * textField;

@end

@implementation LSNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.title = @"姓名";
    [self initSuView];
}

-(void)initSuView{

    self.textField = [UITextField new];
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.textField];
    self.textField.placeholder = self.name;
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_topLayoutGuide).offset(10);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@(40));
    }];
    
    UIButton * saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 60, 30);
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    UIBarButtonItem * itme = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    self.navigationItem.rightBarButtonItem = itme;
}
-(void)saveBtnClick:(UIButton *)sender{

    if (self.saveClick) {
        self.saveClick(self.textField.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
