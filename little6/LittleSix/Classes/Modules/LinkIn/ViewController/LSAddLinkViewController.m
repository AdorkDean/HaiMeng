//
//  LSAddLinkViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSAddLinkViewController.h"
#import "LSAddLinkInTableCell.h"
#import "LSSearchMatchModel.h"
#import "LSLinkCustomTagViewController.h"
#import "LSContactDetailViewController.h"
#import "UIView+HUD.h"
#import "LSContactModel.h"
#import <YYKit/YYKit.h>
#import "LSUMengHelper.h"
#import "UIAlertController+LSAlertController.h"

#define kAnimationDuration 0.25
static NSString *const reuse_id = @"AddLinkTableCell";
@interface LSAddLinkViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollBarCenterXConst;
@property (weak, nonatomic) IBOutlet UIView *menusView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (retain,nonatomic) LSCountryMenViewController * countryVc;
@property (retain,nonatomic) LSClassMatesViewController * classVc;
@property (retain,nonatomic) LSLinkCustomTagViewController * customTagVc;
@property (assign,nonatomic) int country;

@end

@implementation LSAddLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加人脉";
    self.country = 0;
    self.classVc = self.childViewControllers[0];
    self.countryVc = self.childViewControllers[1];
    self.customTagVc = self.childViewControllers[2];
}

#pragma mark - Action
- (IBAction)menusButtonAction:(UIButton *)sender {
    
    [self updateScrollBarWithIndex:sender.tag];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        CGFloat offsetX = CGRectGetWidth(self.scrollView.frame) * sender.tag;
        self.scrollView.contentOffset = CGPointMake(offsetX, 0);
    }];
}

- (void)updateScrollBarWithIndex:(NSInteger)index {
    if (index == 1) {
        self.country ++;
        if (self.country == 1) {
            [self.countryVc _initDataSource];
        }
    }
    self.scrollBarCenterXConst.constant = index * (kScreenWidth*0.3333);
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [self.menusView layoutIfNeeded];
    }];
}

#pragma mark - ScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger page = scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame);
    [self updateScrollBarWithIndex:page];
}

@end

// 同乡
@interface LSCountryMenViewController()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (retain,nonatomic)UITableView * tableView;
@property (retain,nonatomic)UIView * headerView;
@property (retain,nonatomic)UITextField * textField;

@property (retain,nonatomic)NSMutableArray * dataSource;

@end

@implementation LSCountryMenViewController

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

- (void)_initDataSource {
    
    [self.view showLoading];
    [LSSearchMatchModel classmatesWithlistToken:ShareAppManager.loginUser.access_token home:0 page:0 size:20 success:^(NSArray *array) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
        
    } failure:^(NSError *error) {
        [self.view showError:@"服务器异常" hideAfterDelay:1.5];
        [self.view hideHUDAnimated:YES];
    }];
}

-(void)createTabelView{

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView = tableView;
    
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerNib:[UINib nibWithNibName:@"LSAddLinkInTableCell" bundle:nil] forCellReuseIdentifier:reuse_id];
    
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
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.backgroundColor = [UIColor whiteColor];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.headerView.mas_top).offset(10);
        make.left.equalTo(self.headerView.mas_left).offset(10);
        make.right.equalTo(self.headerView.mas_right).offset(-10);
        make.bottom.equalTo(self.headerView.mas_bottom).offset(-10);
    }];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.headerView.height = 0;
    }];
    self.textField.placeholder = @"";
    [[LSLinkInSearchView searchMainV] showInView:self andPage:0 WithBlock:^(NSArray *list) {
        [UIView animateWithDuration:0.2 animations:^{
            self.headerView.height = 50;
        }];
        
        self.textField.placeholder = @"搜索人脉";
        if (list != nil) {
            if (list.count != 0) {
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:list];
            }else{
                
                [self _initDataSource];
            }
        }
        [self.tableView reloadData];
    }];
    [self.tableView reloadData];
    return NO;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    LSAddLinkInTableCell * cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LSSearchMatchModel * model = self.dataSource[indexPath.row];
    cell.searchModel = model;
    
    @weakify(self)
    [cell setAddFriendsClick:^(LSSearchMatchModel *searchModel) {
        @strongify(self)
        [self sendFriend:searchModel];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LSSearchMatchModel * model = self.dataSource[indexPath.row];
    LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
    lsvc.user_id = model.user_id;
    lsvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lsvc animated:YES];
}

- (void)sendRequest:(LSSearchMatchModel *)model withTitle:(NSString *)title{
    
    NSString * titleStr = [title isEqualToString:@""] ? @"加一下呗":title;
    
    [LSContactModel sendFriendsWithlistToken:ShareAppManager.loginUser.access_token uid_to:[NSString stringWithFormat:@"%@",model.user_id] friend_note:titleStr success:^(LSContactModel* cmodel){
        
        [LSUMengHelper pushNotificationWithUsers:@[cmodel.uid_to] message:@"你有一条好友添加消息" extension:@{@"contactTpye":kAddContactPath,@"user_id":cmodel.uid_to} success:^{
            
        } failure:nil];
        [self.view showSucceed:@"发送成功" hideAfterDelay:1.5];
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

// 同学

@interface LSClassMatesViewController()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (retain,nonatomic)UITableView * tableView;
@property (retain,nonatomic)UIView * headerView;
@property (retain,nonatomic)UITextField * textField;

@property (retain,nonatomic)NSMutableArray * dataSource;

@end

@implementation LSClassMatesViewController

- (NSMutableArray *)dataSource {

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTabelView];
    [self _initDataSource];
}

- (void)_initDataSource {

    [self.view showLoading];
    [LSSearchMatchModel classmatesWithlistToken:ShareAppManager.loginUser.access_token home:1 page:0 size:20 success:^(NSArray *array) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
        
    } failure:^(NSError *error) {
        [self.view hideHUDAnimated:YES];
    }];
}

- (void)createTabelView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView = tableView;
    
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerNib:[UINib nibWithNibName:@"LSAddLinkInTableCell" bundle:nil] forCellReuseIdentifier:reuse_id];
    
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
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.backgroundColor = [UIColor whiteColor];
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
    [[LSLinkInSearchView searchMainV] showInView:self andPage:1 WithBlock:^(NSArray *list) {
        [UIView animateWithDuration:0.2 animations:^{
            self.headerView.height = 50;
        }];
        
        self.textField.placeholder = @"搜索人脉";
        if (list != nil) {
            if (list.count != 0) {
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:list];
            }else{
                [self _initDataSource];
            }
        }
        [self.tableView reloadData];
    }];
    [self.tableView reloadData];
    
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSAddLinkInTableCell * cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LSSearchMatchModel * model = self.dataSource[indexPath.row];
    cell.searchModel = model;
    
    @weakify(self)
    [cell setAddFriendsClick:^(LSSearchMatchModel *searchMode) {
        @strongify(self)
        [self sendFriend:searchMode];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSSearchMatchModel * model = self.dataSource[indexPath.row];
    LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
    lsvc.user_id = model.user_id;
    lsvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lsvc animated:YES];
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
@interface LSLinkInSearchView()<UITextFieldDelegate>

@property (retain,nonatomic)UIImageView * navgView;
@property (retain,nonatomic)UIView * bgView;

@property (retain,nonatomic)UIButton * cancelBtn;

@property (retain,nonatomic)UITextField * textField;
@property (assign,nonatomic)int page;

@end
@implementation LSLinkInSearchView

+ (instancetype)searchMainV {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"LSLinkInSearchView" owner:nil options:nil] lastObject];
}

- (void)showInView:(UIViewController *)view andPage:(int)page WithBlock:(void(^)(NSArray *list))sureBlock {
    
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
        self.sureBlock(nil);
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

    [LSSearchMatchModel searchWithlistToken:ShareAppManager.loginUser.access_token home:0 page:0 size:20 key:string success:^(NSArray *array) {
        
        if (array.count == 0) {
            [self showError:@"没有数据" hideAfterDelay:1.5];
        }
        if (self.sureBlock) {
            self.sureBlock(array);
        }
        [UIView animateWithDuration:0.1 animations:^{
            [self removeFromSuperview];
        }];
        
    } failure:nil];
}

@end


