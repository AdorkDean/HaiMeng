//
//  LSAddPhoneContactViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSAddPhoneContactViewController.h"
#import "LSContactDetailViewController.h"
#import "LSContactModel.h"
#import <ContactsUI/ContactsUI.h>
#import "LSMatchingModel.h"
#import "LSChineseSort.h"
#import "UIView+HUD.h"
#import "LSUMengHelper.h"
#import "UIAlertController+LSAlertController.h"


static NSString *reuseId = @"LSMatchingCell";
@interface LSAddPhoneContactViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, retain) UITableView * tableView;
@property (nonatomic, retain) NSMutableArray * dataSource;

//排序后的出现过的拼音首字母数组
@property(nonatomic, strong) NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic, strong) NSMutableArray *letterResultArr;
@property(nonatomic, strong) NSString * phoneStr;

@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation LSAddPhoneContactViewController

- (NSMutableArray *)dataArray {
    
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


- (NSMutableArray *)dataSource {

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"匹配通讯录";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self _naviRightItem];
    [self _configTableView];
    [self getPhone];
    
}

-(void)_initDataSource {

    [self.view showLoading];
    [LSMatchingModel matchingFriendsWithlistToken:ShareAppManager.loginUser.access_token phones:self.phoneStr success:^(NSArray *array) {
        
        //根据LSContactModel对象的 user_name 属性 按中文 对 LSContactModel数组 排序
        [self.dataArray removeAllObjects];
        for (LSMatchingModel * model in array) {
            for (LSAddressBook *addbook in self.dataSource) {
                if ([model.mobile_phone isEqualToString:addbook.phone]) {
                    model.real_name = addbook.name;
                    [self.dataArray addObject:model];
                }
            }
        }
        
        self.indexArray = [LSChineseSort IndexWithArray:self.dataArray Key:@"real_name"];
        self.letterResultArr = [LSChineseSort sortObjectArray:self.dataArray Key:@"real_name"];
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
        
    } failure:^(NSError *error) {
        [self.view hideHUDAnimated:YES];
        
    }];
}

-(void)getPhone {
    
    // 3.1.创建联系人仓库
    CNContactStore *store = [[CNContactStore alloc] init];
    
    // keys决定这次要获取哪些信息,比如姓名/电话
    NSArray *fetchKeys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
    
    // 3.3.请求联系人
    NSError *error = nil;
    
    [store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        // stop是决定是否要停止
        // 1.获取姓名
        NSString *firstname = contact.givenName;
        NSString *lastname = contact.familyName;
        
        // 2.获取电话号码
        NSArray *phones = contact.phoneNumbers;
        
        LSAddressBook *addbook = [LSAddressBook new];
        
        addbook.name = [NSString stringWithFormat:@"%@%@",lastname,firstname];
        
        // 3.遍历电话号码
        NSString *newP;
        for (CNLabeledValue *labelValue in phones) {
            
            CNPhoneNumber *phoneNumber = labelValue.value;
            
            newP = [phoneNumber.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""];
            newP = [newP stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            // 去除+86
            if ([newP containsString:@"+86"]) {
                newP = [newP stringByReplacingOccurrencesOfString:@"+86" withString:@""];
            }
            // 去除+
            if ([newP containsString:@"+"]) {
                newP = [newP stringByReplacingOccurrencesOfString:@"+" withString:@""];
            }
            addbook.phone = newP;
            
            self.phoneStr = [NSString stringWithFormat:@"%@,%@",self.phoneStr,newP];
        }
        [self.dataSource addObject:addbook];
        NSLog(@"%ld",self.dataSource.count);
    }];
    
    [self _initDataSource];

}

- (void)_configTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.rowHeight = 55;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    self.tableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
    self.tableView.sectionIndexColor = HEXRGB(0x555555);
    self.tableView.backgroundColor = HEXRGB(0xefeff4);
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
    [self.tableView registerClass:[LSMatchingCell class] forCellReuseIdentifier:reuseId];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.indexArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.letterResultArr objectAtIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LSMatchingCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    LSMatchingModel * model = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];;
    
    cell.matchingModel = model;
    
    @weakify(self)
    [cell setDealWithClick:^(LSMatchingModel *model) {
        @strongify(self)
        [self sendFriend:model];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

     LSMatchingModel * model = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];;
    
    LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
    lsvc.user_id = [NSString stringWithFormat:@"%d",model.user_id];
    [self.navigationController pushViewController:lsvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    return 0.0;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexArray;;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView new];
    headerView.backgroundColor = HEXRGB(0xefeff4);
    
    UILabel *indexLabel = [UILabel new];
    indexLabel.font = SYSTEMFONT(14);
    indexLabel.textColor = HEXRGB(0x8e8e93);
    indexLabel.text = self.indexArray[section];
    
    [headerView addSubview:indexLabel];
    [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView);
        make.left.equalTo(headerView).offset(10);
    }];
    
    return headerView;
}

- (void)sendRequest:(LSMatchingModel *)model withTitle:(NSString *)title{
    
    NSString * titleStr = [title isEqualToString:@""] ? @"加一下呗":title;
    
    [LSContactModel sendFriendsWithlistToken:ShareAppManager.loginUser.access_token uid_to:[NSString stringWithFormat:@"%d",model.user_id] friend_note:titleStr success:^(LSContactModel* cmodel){
        
        [LSUMengHelper pushNotificationWithUsers:@[cmodel.uid_to] message:@"你有一条好友添加消息" extension:@{@"contactTpye":kAddContactPath,@"user_id":cmodel.uid_to} success:^{
            
            [self.view showSucceed:@"发送成功" hideAfterDelay:1.5];
            
        } failure:^(NSError *error) {
            
        }];
        
    } failure:^(NSError *error ) {
        [self.view showError:@"添加失败" hideAfterDelay:1.5];
    }];
}

- (void)sendFriend:(LSMatchingModel *)model {
    @weakify(self)
    [UIAlertController alertTitle:@"温馨提示" mesasge:@"说一句成为好友的机率更大哦!" withOK:@"发送" preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *alertAction, UITextField *textField) {
        @strongify(self)
        [self sendRequest:model withTitle:textField.text];
    } cancleHandler:^(UIAlertAction *alert) {
        
    } viewController:self];
    
}

//////////////////////////////////////////
- (void)_installSubviews {
    
    self.view.backgroundColor = [UIColor whiteColor];

    UIScrollView *scrollView = [UIScrollView new];
    scrollView.backgroundColor = HEXRGB(0xefeff4);
    [self.view addSubview:scrollView];
    scrollView.bounces = YES;
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    UIView *containerView = [UIView new];
    containerView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
        make.bottom.equalTo(self.view);
    }];
    
    UIImageView *iconView = [UIImageView new];
    iconView.image = [UIImage imageNamed:@"contact_m_bigphone"];
    
    [scrollView addSubview:iconView];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(scrollView);
        make.top.equalTo(scrollView).offset(32);
    }];
    
    UILabel *phoneLabel = [UILabel new];
    phoneLabel.font = SYSTEMFONT(18);
    phoneLabel.text = @"你的手机号:18826444971";
    
    [scrollView addSubview:phoneLabel];
    [phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(scrollView);
        make.top.equalTo(iconView.mas_bottom).offset(36);
    }];

    UILabel *tipsLabel = [UILabel new];
    tipsLabel.text = @"上传你的手机通讯录";
    tipsLabel.textColor = HEXRGB(0x888888);
    tipsLabel.font = SYSTEMFONT(13);
    
    [scrollView addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phoneLabel.mas_bottom).offset(18);
        make.left.equalTo(scrollView).offset(22);
    }];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ViewRadius(sendButton, 5);
    sendButton.backgroundColor = kMainColor;
    [sendButton setTitle:@"上传通讯录找朋友" forState:UIControlStateNormal];
    
    [scrollView addSubview:sendButton];
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scrollView).offset(20);
        make.right.equalTo(scrollView).offset(-20);
        make.top.equalTo(tipsLabel.mas_bottom).offset(47);
        make.height.offset(47);
    }];
    
}

- (void)_naviRightItem {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];//navi_chat_more
    [button sizeToFit];
    
    //    @weakify(self)
    //    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
    //        @strongify(self);
    //
    //    }];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}


@end

@implementation LSMatchingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [UIImageView new];
        self.iconView = iconView;
        [self addSubview:iconView];
        
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.width.height.offset(36);
        }];
        
        UIButton *statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.statusButton = statusButton;
        ViewRadius(statusButton, 4);
        statusButton.titleLabel.font = SYSTEMFONT(14);
        
        [statusButton setBackgroundImage:[UIImage imageWithColor:HEXRGB(0xd42136)] forState:UIControlStateNormal];
        [statusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [statusButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateSelected];
        [statusButton setTitleColor:HEXRGB(0xb3b3b3) forState:UIControlStateSelected];
        [statusButton addTarget:self action:@selector(statuClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:statusButton];
        [statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-15);
            make.width.offset(50);
            make.height.offset(28);
        }];
        
        UILabel *nameLabel = [UILabel new];
        self.nameLabel = nameLabel;
        nameLabel.font = SYSTEMFONT(15);
        nameLabel.textColor = [UIColor blackColor];
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(iconView);
            make.left.equalTo(iconView.mas_right).offset(10);
        }];
        
        UILabel *descLabel = [UILabel new];
        descLabel.font = SYSTEMFONT(14);
        self.descLabel = descLabel;
        descLabel.textColor = HEXRGB(0x888888);
        [self addSubview:descLabel];
        [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel);
            make.bottom.equalTo(iconView.mas_bottom).offset(4);
        }];
        
        iconView.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

-(void)setMatchingModel:(LSMatchingModel *)matchingModel {
    
    _matchingModel = matchingModel;
    
    [self.iconView setImageWithURL:[NSURL URLWithString:matchingModel.avatar] placeholder:[UIImage imageNamed:@""]];
    self.nameLabel.text = matchingModel.real_name;
    self.descLabel.text = [NSString stringWithFormat:@"嗨萌:%@",matchingModel.user_name];
    
    self.statusButton.selected = matchingModel.is_friends == 1?YES:NO;
    NSString * name = matchingModel.is_friends == 0 ? @"添加":@"已添加";
    [self.statusButton setTitle:name forState:UIControlStateNormal];
}

-(void)statuClick:(UIButton *)sender{
    
    if (self.dealWithClick) {
        self.dealWithClick(self.matchingModel);
    }
}

@end
