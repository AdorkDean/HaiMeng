//
//  LSSclectSchoolViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/30.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSclectSchoolViewController.h"
#import "LSHobbieModel.h"
#import "UIView+HUD.h"

static NSString *const reuse_id = @"LSSearchSchoolCell";
@interface LSSclectSchoolViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (retain, nonatomic) NSMutableArray * dataArray;

@end

@implementation LSSclectSchoolViewController

- (NSMutableArray *)dataArray {

    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"搜索学校";
    self.titleField.delegate = self;
    self.titleField.returnKeyType = UIReturnKeySearch; //设置按键类型
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.tableFooterView = [UIView new];
    [self.table registerClass:[LSSearchSchoolCells class] forCellReuseIdentifier:reuse_id];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    [self postSeachSchoolText:textField.text]
    ;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    [self postSeachSchoolText:string];
    
    return YES;
}

-(void)postSeachSchoolText:(NSString *)text{
    
    [LSSchoolModels searchSchoolWithlistToken:ShareAppManager.loginUser.access_token key:text level:self.level success:^(NSArray *array) {
        
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:array];
        [self.table reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LSSearchSchoolCells * cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    
    LSSchoolModels * model = self.dataArray[indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LSSchoolModels * model = self.dataArray[indexPath.row];
    if (self.sureBackSchool) {
        self.sureBackSchool(model);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@implementation LSSearchSchoolCells

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *nameLabel = [UILabel new];
        nameLabel.font = SYSTEMFONT(15);
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
            make.height.offset(20);
        }];
        
        
        UILabel *sunameLabel = [UILabel new];
        sunameLabel.font = SYSTEMFONT(13);
        self.sunameLabel = sunameLabel;
        sunameLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:sunameLabel];
        [sunameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nameLabel.mas_bottom).offset(5);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
            make.bottom.equalTo(self.mas_bottom).offset(-5);
        }];
        
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = HEXRGB(0xbcbcbc);
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel);
            make.bottom.right.equalTo(self);
            make.height.offset(0.5);
        }];
        
        
    }
    return self;
}
-(void)setModel:(LSSchoolModels *)model{
    
    _model = model;
    
    self.nameLabel.text = model.name;
    self.sunameLabel.text = model.region;
}

@end
