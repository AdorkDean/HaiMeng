//
//  LSPeopleNearViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPeopleNearViewController.h"
#import "LSPeopleNearModel.h"
#import "LSContactDetailViewController.h"
#import "LSOptionsView.h"
static NSString *const reuse_id = @"LSTimeLineMsgTableViewCell";

@interface LSPeopleNearViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView * tableView;

@property(nonatomic,strong) NSMutableArray * dataSource;

@end

@implementation LSPeopleNearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"附近的人";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"shake_setup"] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(rightItemAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}


-(void)rightItemAction{
    LSOptionsView * optionsView = [[LSOptionsView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.frame WithData:@[@"女性",@"男性",@"全部"]];
    [optionsView setSelectCellBlock:^(NSString * title){
        
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:optionsView];

}


-(void)loadDataWithSex:(NSString *)sex{
    
}
#pragma mark tableView
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView = tableView;
        [self.view addSubview:tableView];
        
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [tableView registerClass:[LSPeopleNearCell class] forCellReuseIdentifier:reuse_id];

        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];
    
        self.tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  50;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LSPeopleNearCell * cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    LSPeopleNearModel * model = self.dataSource[indexPath.row];
    cell.model = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LSPeopleNearModel * model = self.dataSource[indexPath.row];
    LSContactDetailViewController *vc = [LSContactDetailViewController new];
    vc.user_id =model.user_id;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@interface LSPeopleNearCell ()

@property (nonatomic,strong) UIImageView * iconView;
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UILabel * distanceLabel;
@property (nonatomic,strong) UILabel * introduceLabel;

@end


@implementation LSPeopleNearCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setConstraints];
    }
    return self;
}

-(void)setConstraints{
    UIImageView *iconView = [UIImageView new];
    self.iconView = iconView;
    [self.contentView addSubview:iconView];
    
    UILabel *nameLabel = [UILabel new];;
    self.nameLabel = nameLabel;
    [self.contentView addSubview:nameLabel];
    
    UILabel *distanceLabel = [UILabel new];
    self.distanceLabel = distanceLabel;
    [self.contentView addSubview:distanceLabel];
    
    UILabel *introduceLabel = [UILabel new];
    self.introduceLabel = distanceLabel;
    [self.contentView addSubview:introduceLabel];
    
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.left.equalTo(self.contentView).offset(5);
        make.width.height.mas_equalTo(40);
    }];
    
    [introduceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-5);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconView);
        make.left.equalTo(iconView.mas_right).offset(5);
        make.right.equalTo(introduceLabel.mas_left).offset(-5);
        make.height.mas_equalTo(20);
    }];
    
    [distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(15);
        make.left.right.height.equalTo(nameLabel);
    }];
    
}


-(void)setModel:(LSPeopleNearModel *)model{
    _model = model;
    
    [self.iconView setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:timeLineBigPlaceholderName];
    self.nameLabel.text = model.name;
    self.introduceLabel.text = model.introduce;
    self.distanceLabel.text = model.distance;
}



@end
