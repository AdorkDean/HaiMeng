//
//  LSEditorSchoolTableController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/30.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEditorSchoolTableController.h"
#import "LSSclectSchoolViewController.h"
#import "LSLSLinkInModel.h"
#import "LSHobbieModel.h"
#import "UIView+HUD.h"
#import "LSChoosePickVeiw.h"

@interface LSEditorSchoolTableController ()

@property (retain,nonatomic) LSSchoolModels * smodel;
@property (weak, nonatomic) IBOutlet UITextField *schoolField;
@property (weak, nonatomic) IBOutlet UILabel *schoolLabel;
@property (weak, nonatomic) IBOutlet UITextField *collegeField;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (assign,nonatomic) NSInteger admissionTime;
@property (assign,nonatomic) NSInteger school_id;

@end

@implementation LSEditorSchoolTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    self.tableView.tableFooterView = [UIView new];
    
    [self initSuView];
}

-(void)initSuView{
    
    UIButton * saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 60, 30);
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [saveBtn setTitle:@"完成" forState:UIControlStateNormal];
    UIBarButtonItem * itme = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    self.navigationItem.rightBarButtonItem = itme;
    self.school_id = 0;
    if (self.linkModel) {
        self.level = [self.linkModel.level intValue];
        self.admissionTime = [self.linkModel.edu_year intValue];
        self.school_id = [self.linkModel.school_id integerValue];
        self.schoolField.text = self.linkModel.school_name;
        self.timeField.text = self.linkModel.edu_year;
        self.collegeField.text = self.linkModel.note;
    }
}

-(void)saveBtnClick:(UIButton *)sender{
    
    if (self.school_id == 0) {
        [self.view showAlertWithTitle:@"温馨提示" message:@"请选择学校"];
        return;
    }
    if (self.linkModel) {
        
        [LSAddSchoolModel updateSchoolWithlistUser_id:self.linkModel.us_id edu_year:self.admissionTime school_id:self.school_id note:self.collegeField.text success:^{
            //发送通知刷新人脉首页
            [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteLinkInInfoNoti object:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError *errer) {
            [self.view showError:@"修改失败" hideAfterDelay:1.5];
        }];
        
    }else {
    
        [LSAddSchoolModel addSchoolWithlistToken:ShareAppManager.loginUser.access_token andLevel:self.level edu_year:self.admissionTime school_id:self.school_id note:self.collegeField.text success:^{
            //发送通知刷新人脉首页
            [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteLinkInInfoNoti object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *errer) {
            [self.view showError:@"添加失败(请勿重复添加哦)" hideAfterDelay:1.5];
        }];
    }
    
}


- (void)setLevel:(int)level {

    _level = level;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 3;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.level != 5) {
        if (indexPath.row == 1) {
            return 0.0;
        }
    }
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.view endEditing:YES];
    if (indexPath.row == 0) {
    
        if (!self.linkModel) {
            LSSclectSchoolViewController * sclVc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSSclectSchool"];
            [sclVc setSureBackSchool:^(LSSchoolModels * model) {
                
                self.school_id = [model.id integerValue];
                self.smodel = model;
                self.schoolField.text = model.name;
            }];
            sclVc.level = self.level;
            [self.navigationController pushViewController:sclVc animated:YES];
        }
        
    }else if (indexPath.row == 2){
    
        LSDatePickerView *datePickerView = [[LSDatePickerView alloc] initDatePackerRow:0 WithResponse:^(NSString * str) {
            self.admissionTime = [str integerValue];
            self.timeField.text = str;
        }];
        [datePickerView show];
    }
    
}


@end
