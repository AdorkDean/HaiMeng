//
//  LSLinkCustomTagViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkCustomTagViewController.h"
#import "LSAddLinkInTableCell.h"
#import "LSAddLinkViewController.h"
#import "LSContactDetailViewController.h"
#import "LSLinkInViewController.h"
#import "LSSearchMatchModel.h"
#import "LSContactModel.h"
#import "UIView+HUD.h"
#import "LSUMengHelper.h"
#import "UIAlertController+LSAlertController.h"

static NSString *const link_id = @"AddLinkTableCell";
static NSString *const reuse_id = @"LSLinkInCell";
@interface LSLinkCustomTagViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (retain, nonatomic) UITableView * tableView;
@property (retain, nonatomic) UIView * headerView;
@property (retain, nonatomic) UITextField * textField;
@property (retain, nonatomic) NSMutableArray * dataSource;

@property (copy,nonatomic) NSArray * clanArray;
@property (copy,nonatomic) NSArray * homeArray;
@property (copy,nonatomic) NSArray * userArray;
@property (copy,nonatomic) NSArray * schArray;

@end

@implementation LSLinkCustomTagViewController

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createTabelView];
}

- (void)createTabelView{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView = tableView;
    
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerNib:[UINib nibWithNibName:@"LSAddLinkInTableCell" bundle:nil] forCellReuseIdentifier:link_id];
    [tableView registerClass:[LSLinkInCell class] forCellReuseIdentifier:reuse_id];
    
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
    
    tableView.tableFooterView = [UIView new];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    self.headerView.userInteractionEnabled = YES;
    self.tableView.tableHeaderView = self.headerView;
    
    self.textField = [UITextField new];
    [self.headerView addSubview:self.textField];
    self.textField.placeholder = @"搜索人脉";
    self.textField.delegate = self;
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_top).offset(10);
        make.left.equalTo(self.headerView.mas_left).offset(10);
        make.right.equalTo(self.headerView.mas_right).offset(-10);
        make.bottom.equalTo(self.headerView.mas_bottom).offset(-10);
    }];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.headerView.height = 0;
    }];
    self.textField.placeholder = @"";
    [[LSLinkInCustomSearchView searchMainV] showInView:self andPage:2 WithBlock:^(NSArray *clanArray,NSArray *homeArray,NSArray *userArray,NSArray *schArray) {
        [UIView animateWithDuration:0.2 animations:^{
            self.headerView.height = 50;
        }];
        
        self.textField.placeholder = @"搜索人脉";
        
        self.clanArray = clanArray;
        self.homeArray = homeArray;
        self.userArray = userArray;
        self.schArray = schArray;
        
        [self.tableView reloadData];
    }];
    
    [self.tableView reloadData];
    return NO;
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.clanArray.count : section == 1 ? self.homeArray.count : section == 2? self.userArray.count : self.schArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0 && self.clanArray.count == 0) {
        return 0;
    }
    else if (section == 1 && self.homeArray.count == 0) {
        return 0;
    }
    else if (section == 2 && self.userArray.count == 0) {
        return 0;
    }
    else if (section == 3 && self.schArray.count == 0) {
        return 0;
    }
    else {
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = SYSTEMFONT(14);
    titleLabel.textColor = HEXRGB(0x888888);
    
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.top.bottom.equalTo(headerView);
    }];
    
    UIButton * moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setTitle:@"查看更多" forState:UIControlStateNormal];
    [moreButton setTitleColor:kMainColor forState:UIControlStateNormal];
    moreButton.titleLabel.font = SYSTEMFONT(14);
    moreButton.hidden = YES;
    [headerView addSubview:moreButton];
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(10);
        make.top.bottom.equalTo(headerView);
    }];
    
    if (section == 0) {
        titleLabel.text = @"宗亲人脉";
    }else if(section == 1){
        titleLabel.text = @"家乡人脉";
    }else if(section == 2){
        titleLabel.text = @"好友人脉";
    }else if(section == 3){
        titleLabel.text = @"学校人脉";
    }
    
    @weakify(self)
    [[moreButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton * button) {
        @strongify(self)
        UIViewController * vc = [NSClassFromString(@"LSClanCofcListViewController") new];
        
        [vc setValue:@"4" forKey:@"type"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 2) {
        
        LSAddLinkInTableCell * cell = [tableView dequeueReusableCellWithIdentifier:link_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        LSSearchMatchModel * model = indexPath.section == 0 ? self.clanArray[indexPath.row] : indexPath.section == 1 ?  self.homeArray[indexPath.row] : indexPath.section == 2 ? self.userArray[indexPath.row] : self.schArray[indexPath.row] ;
        cell.searchModel = model;
        @weakify(self)
        [cell setAddFriendsClick:^(LSSearchMatchModel *searchModel ) {
            @strongify(self)
            [self sendFriend:searchModel];
        }];
        
        return cell;
    }
    LSLinkInCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LSSearchMatchModel * model = indexPath.section == 0 ? self.clanArray[indexPath.row] : indexPath.section == 1 ?  self.homeArray[indexPath.row] : indexPath.section == 2 ? self.userArray[indexPath.row] : self.schArray[indexPath.row] ;
    cell.searchModel = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSSearchMatchModel * model = indexPath.section == 0 ? self.clanArray[indexPath.row] : indexPath.section == 1 ?  self.homeArray[indexPath.row] : indexPath.section == 2 ? self.userArray[indexPath.row] : self.schArray[indexPath.row];
    
    if (indexPath.section == 2) {
        LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
        lsvc.user_id = model.user_id;
        lsvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:lsvc animated:YES];
    }else if(indexPath.section == 0){
        
        UIViewController *vc = [NSClassFromString(@"LSClanCofcViewController") new];
        [vc setValue:model.id forKey:@"sh_id"];
        [vc setValue:@(4) forKey:@"type"];
        [vc setValue:model.name forKey:@"titleStr"];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else {
        
        UIViewController *vc = [NSClassFromString(@"LSLinkSchoolViewController") new];
        if (indexPath.section == 1) {
            
            [vc setValue:model.id forKey:@"sh_id"];
            [vc setValue:@(2) forKey:@"type"];
            [vc setValue:model.name forKey:@"titleStr"];
            
        }else if (indexPath.section == 3){
            
            [vc setValue:model.id forKey:@"sh_id"];
            [vc setValue:@(1) forKey:@"type"];
            [vc setValue:model.name forKey:@"titleStr"];
            
        }
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)sendRequest:(LSSearchMatchModel *)model withTitle:(NSString *)title{
    
    NSString * titleStr = [title isEqualToString:@""] ? @"加一下呗":title;
    
    [LSContactModel sendFriendsWithlistToken:ShareAppManager.loginUser.access_token uid_to:[NSString stringWithFormat:@"%@",model.user_id] friend_note:titleStr success:^(LSContactModel* cmodel){
        
        [LSUMengHelper pushNotificationWithUsers:@[cmodel.uid_to] message:@"你有一条好友添加消息" extension:@{@"contactTpye":kAddContactPath,@"user_id":cmodel.uid_to} success:^{
            
        } failure:nil];
        [self.view showWithText:@"发送成功" hideAfterDelay:1.5];
        
    } failure:^(NSError *error ) {
        [self.view showWithText:@"添加失败" hideAfterDelay:1.5];
    }];
}

- (void)sendFriend:(LSSearchMatchModel *)model {
    @weakify(self)
    [UIAlertController alertTitle:@"温馨提示" mesasge:@"说一句成为好友的机率更大哦!" withOK:@"发送" preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *alertAction, UITextField *textField) {
        @strongify(self)
        [self sendRequest:model withTitle:textField.text];
    } cancleHandler:^(UIAlertAction *alert) {
        
    } viewController:self];
    
}

@end

//搜索页面
@interface LSLinkInCustomSearchView()<UITextFieldDelegate>

@property (retain,nonatomic)UIImageView * navgView;
@property (retain,nonatomic)UIView * bgView;

@property (retain,nonatomic)UIButton * cancelBtn;

@property (retain,nonatomic)UITextField * textField;
@property (assign,nonatomic)int page;


@property (copy,nonatomic) NSArray * clanArray;
@property (copy,nonatomic) NSArray * homeArray;
@property (copy,nonatomic) NSArray * userArray;
@property (copy,nonatomic) NSArray * schArray;

@end
@implementation LSLinkInCustomSearchView

+ (instancetype)searchMainV {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"LSLinkInCustomSearchView" owner:nil options:nil] lastObject];
}

- (void)showInView:(UIViewController *)view andPage:(int)page WithBlock:(void(^)(NSArray *clanArray,NSArray *homeArray,NSArray *userArray,NSArray *schArray))sureBlock {
    
    self.frame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height);
    
    [view.navigationController.view addSubview:self];
    
    self.page = page;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.bgView = [UIView new];
    self.bgView.backgroundColor = [UIColor blackColor];
    self.bgView.alpha = 0.6;
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [self.bgView addGestureRecognizer:tap];
    self.navgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, 65)];
    self.navgView.userInteractionEnabled = YES;
    [self addSubview:self.navgView];
    [self.navgView setImage:[UIImage imageWithColor:kMainColor]];;
    
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.navgView.origin = CGPointMake(0, 0);
    }];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navgView addSubview:self.cancelBtn];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.navgView.mas_top).offset(25);
        make.right.equalTo(self.navgView.mas_right).offset(-10);
        make.bottom.equalTo(self.navgView.mas_bottom).offset(-10);
        make.width.equalTo(@(50));
    }];
    
    self.textField = [UITextField new];
    self.textField.backgroundColor = [UIColor whiteColor];
    NSString *holderText = @"搜索人脉";
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc]initWithString:holderText];
    [placeholder addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:15]
                        range:NSMakeRange(0, holderText.length)];
    self.textField.attributedPlaceholder = placeholder;
    self.textField.delegate = self;
    [self.textField becomeFirstResponder];
    self.textField.returnKeyType = UIReturnKeySearch; //设置按键类型
    self.textField.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    self.textField.borderStyle= UITextBorderStyleRoundedRect;
    [self.navgView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.navgView.mas_top).offset(25);
        make.left.equalTo(self.navgView.mas_left).offset(10);
        make.right.equalTo(self.cancelBtn.mas_left).offset(-10);
        make.bottom.equalTo(self.navgView.mas_bottom).offset(-10);
    }];
    
    UIImage *image = [UIImage imageNamed:@"addcontact_group_search"];
    UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    leftImage.image = image;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    leftImage.center = leftView.center;
    [leftView addSubview:leftImage];
    
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.leftView = leftView;
    
    [self.textField sizeToFit];
    
    self.sureBlock = sureBlock;
    
}

- (void)cancelClick:(UIButton *)sender  {
    
    [self removeAllSubvie];
}

- (void)removeAllSubvie{
    
    if (self.sureBlock) {
        self.sureBlock(self.clanArray,self.homeArray,self.userArray,self.schArray);
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        [self removeFromSuperview];
    }];
}
- (void)tapClick:(UITapGestureRecognizer *)tap {
    
    [self removeAllSubvie];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self requestDataWithString:textField.text];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSLog(@"%@",textField.text);
    
    return YES;
}

- (void)requestDataWithString:(NSString *)string {
    
    [LSSearchMatchModel searchsWithlistToken:ShareAppManager.loginUser.access_token home:0 key:string success:^(NSArray *clanArray,NSArray *homeArray,NSArray *userArray,NSArray *schArray) {
        
        if (clanArray.count == 0&&homeArray.count == 0&&userArray.count == 0&&schArray.count == 0) {
            [self showError:@"没有数据" hideAfterDelay:1.5];
        }
        
        self.clanArray = clanArray;
        self.homeArray = homeArray;
        self.userArray = userArray;
        self.schArray = schArray;
        
        if (self.sureBlock) {
            self.sureBlock(clanArray,homeArray,userArray,schArray);
        }
        
        [UIView animateWithDuration:0.1 animations:^{
            [self removeFromSuperview];
        }];
        
    } failure:nil];
}

@end
