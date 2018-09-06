//
//  LSSearchPhoneNumListViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/29.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSearchPhoneNumListViewController.h"
#import "LSPhoneNumListModel.h"
#import "UIView+HUD.h"
#import "LSContactDetailViewController.h"
#define keyWindow         [UIApplication sharedApplication].keyWindow
static NSString *const reuse_id = @"LSSearchPhoneNumListCell";

@interface LSSearchPhoneNumListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSMutableArray * dataSource;

@end

@implementation LSSearchPhoneNumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"好友列表";
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataSource = [NSMutableArray array];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self.view showLoading];
    [LSPhoneNumListModel searchFriendWithPhoneList:self.listStr Success:^(NSArray *modelArr) {
        [self.view showSucceed:@"加载成功" hideAfterDelay:1];
        [self.dataSource addObjectsFromArray:modelArr];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self.view showError:@"加载信息失败" hideAfterDelay:1];

    }];
    
}

#pragma mark tableView
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView = tableView;
        [self.view addSubview:tableView];
        
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        tableView.tableFooterView = [UIView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[LSSearchPhoneNumListCell class] forCellReuseIdentifier:reuse_id];
        
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.right.bottom.left.equalTo(self.view);
        }];
        
    }
    return _tableView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LSPhoneNumListModel * model = self.dataSource[indexPath.row];
    LSSearchPhoneNumListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    cell.model = model;
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  64;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LSPhoneNumListModel * model = self.dataSource[indexPath.row];
    LSContactDetailViewController * vc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
    vc.user_id = model.user_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

@interface LSSearchPhoneNumListCell ()

@property(nonatomic,strong) UIImageView * iconView;
@property(nonatomic,strong) UILabel * nameLabel;
@property(nonatomic,strong) UILabel * phoneNumLabel;
@property(nonatomic,strong) UIButton * addBtn;

@end

@implementation LSSearchPhoneNumListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeConstraints];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

-(void)makeConstraints{
    UIImageView * iconView = [UIImageView new];
    self.iconView = iconView;
    [self.contentView addSubview:iconView];
    
    UILabel *nameLabel = [UILabel new];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = HEXRGB(0x333333);
    [self.contentView addSubview:nameLabel];
    
    UILabel *phoneNumLabel = [UILabel new];
    phoneNumLabel.font = [UIFont systemFontOfSize:13];
    phoneNumLabel.textColor = HEXRGB(0x999999);
    self.phoneNumLabel = phoneNumLabel;
    [self.contentView addSubview:phoneNumLabel];
    
    UIButton * addBtn = [UIButton new];
    self.addBtn =addBtn;
    addBtn.backgroundColor = [UIColor greenColor];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addBtn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
    ViewRadius(addBtn, 5);
    [self.contentView addSubview:addBtn];
    
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(50);
    }];
    
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconView.mas_right).offset(5);
        make.top.equalTo(iconView);
        make.height.mas_equalTo(20);
        make.right.equalTo(addBtn.mas_left).offset(-10);
    }];
    
    [phoneNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(nameLabel);
        make.top.equalTo(self.contentView.mas_centerY).offset(5);
    }];
    
}

-(void)setModel:(LSPhoneNumListModel *)model{
    _model =model;
    
    self.nameLabel.text =model.user_name;
    self.phoneNumLabel.text = model.mobile_phone;
    [self.iconView setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:timeLineSmallPlaceholderName];
    if (model.is_friends.intValue){
        self.addBtn.backgroundColor = [UIColor whiteColor];
        [self.addBtn setTitle:@"已添加" forState:UIControlStateNormal];
        [self.addBtn setTitleColor:HEXRGB(0x999999) forState:UIControlStateNormal];
        self.addBtn.enabled =  NO;
    }else{
        self.addBtn.backgroundColor = HEXRGB(0xd3000f);
        [self.addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [self.addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.addBtn.enabled = YES;
    }
    
}

-(void)addFriend{
    [keyWindow showLoading];
    [LSPhoneNumListModel addFriendWithUserID:self.model.user_id Success:^{
        [keyWindow showSucceed:@"添加成功" hideAfterDelay:1];
    } failure:^(NSError *error) {
        [keyWindow showError:@"添加失败" hideAfterDelay:1];
    }];
}


@end
