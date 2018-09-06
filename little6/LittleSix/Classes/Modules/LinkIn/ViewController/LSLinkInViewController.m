//
//  LSLinkInViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkInViewController.h"
#import "LSMyLinkCenterViewController.h"
#import "LSContactDetailViewController.h"
#import "PopoverView.h"
#import "LSLSLinkInModel.h"
#import "LSIndexLinkInModel.h"
#import "UIView+HUD.h"
#import "LSSearchMatchModel.h"
#import "LSAddLinkInTableCell.h"
#import "LSLinkInApplyModel.h"
#import "LSContactModel.h"
#import "LSUMengHelper.h"
#import "UIAlertController+LSAlertController.h"
#import "LSLinkInApplyModel.h"
#import "MMDrawerController.h"
#import "LSMenuDetailButton.h"


static NSString *const reuse_id = @"LSLinkInCell";
static NSString *const link_id = @"AddLinkTableCell";

@interface LSLinkInViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSArray * schoolArray;
@property (nonatomic,strong) NSArray * regionArray;
@property (nonatomic,strong) NSArray * dataSource;

@property (nonatomic,strong) NSArray * clanArr;
@property (nonatomic,strong) NSArray * cofcArr;

@property (nonatomic,strong) NSArray * stribeArr;

@end

@implementation LSLinkInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"人脉";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self naviBarConfig];
    [self createTableView];
    [self initDataSource];
    [self registerNotification];
}

- (void)registerNotification {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kCompleteLinkInInfoNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self initDataSource];
    }];
}

-(void)initDataSource {
    
    [self.view showLoading];
    [LSIndexLinkInModel indexLinkWithlistToken:ShareAppManager.loginUser.access_token success:^(NSArray *schoolArray,NSArray *regionArray,NSArray *clanArr,NSArray *cofcArr,NSArray *stribeArr) {
        
        self.schoolArray = schoolArray;
        self.regionArray = regionArray;
        self.clanArr = clanArr;
        self.cofcArr = cofcArr;
        self.stribeArr = stribeArr;
        
        if (regionArray.count == 0 && schoolArray.count == 0&&clanArr.count == 0&&cofcArr.count == 0 && stribeArr.count == 0) {
            [self showAlertTips];
            [self recommendedDataSource];
        }
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
        
    } failure:^(NSError *errer) {
        [self.view hideHUDAnimated:YES];
        [self.view showErrorWithError:errer];
    }];
}

- (void)recommendedDataSource {
    
    [self.view showLoading];
    [LSSearchMatchModel classmatesWithlistToken:ShareAppManager.loginUser.access_token home:2 page:0 size:20 success:^(NSArray *array) {
        
        self.dataSource = array;
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
        
    } failure:^(NSError *error) {
        [self.view showError:@"服务器异常" hideAfterDelay:1.5];
        [self.view hideHUDAnimated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)naviBarConfig {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"navi_chat_more"] forState:UIControlStateNormal];
    [button sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        @strongify(self)
        PopoverView *popoverView = [PopoverView popoverView];
        popoverView.showShade = YES; // 显示阴影背景
        popoverView.style = PopoverViewStyleMain;
        [popoverView showToView:button withActions:[self menuActions]];
    }];
    
    LSMenuDetailButton *leftButton = [LSMenuDetailButton buttonWithType:UIButtonTypeCustom];
    
    UIBarButtonItem *lefItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = lefItem;
    
    [[leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }];
}

- (NSArray<PopoverAction *> *)menuActions {
    @weakify(self)
    PopoverAction *action1 = [PopoverAction actionWithImage:nil title:@"添加人脉" handler:^(PopoverAction *action) {
        @strongify(self)
        [self performSegueWithIdentifier:@"AddLink" sender:nil];
    }];
    
    PopoverAction *action2;
    
    if (self.schoolArray.count > 0 || self.regionArray.count > 0) {
        action2 = [PopoverAction actionWithImage:nil title:@"人脉中心" handler:^(PopoverAction *action) {
            @strongify(self)
            LSMyLinkCenterViewController * myLinkVc = [LSMyLinkCenterViewController new];
            myLinkVc.user_id = ShareAppManager.loginUser.user_id;
            myLinkVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:myLinkVc animated:YES];
        }];
    }
    else {
        action2 = [PopoverAction actionWithImage:nil title:@"完善资料" handler:^(PopoverAction *action) {
            @strongify(self)
            [self performSegueWithIdentifier:@"CompleteInfo" sender:nil];
        }];
    }
    
    PopoverAction *action3 = [PopoverAction actionWithImage:nil title:@"申请创建" handler:^(PopoverAction *action) {
        @strongify(self)
        UIViewController * applyCreateVc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSLSApplyCreate"];
        applyCreateVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:applyCreateVc animated:YES];
    }];
    
    return @[action1, action2, action3];
}

- (void)showAlertTips {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"中国传统有“九同”，完善资料即可开启寻找之旅。" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"先去看看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"完善资料" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"CompleteInfo" sender:nil];
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.schoolArray.count == 0 && self.regionArray.count == 0 && self.clanArr.count == 0 && self.cofcArr.count == 0 && self.stribeArr.count == 0 ? 6 : 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.schoolArray.count : section == 1 ? self.regionArray.count : section == 2? self.clanArr.count : section == 3 ? self.cofcArr.count : section == 4 ? self.stribeArr.count : self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 5) {
        LSAddLinkInTableCell * cell = [tableView dequeueReusableCellWithIdentifier:link_id];
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
    
    LSLinkInCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LSIndexLinkInModel * model = indexPath.section == 0 ? self.schoolArray[indexPath.row] : indexPath.section == 1 ?  self.regionArray[indexPath.row] : indexPath.section == 2 ? self.clanArr[indexPath.row] : indexPath.section == 3 ? self.cofcArr[indexPath.row] : self.stribeArr[indexPath.row] ;
    cell.indexModel = model;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0 && self.schoolArray.count == 0) {
        return 0;
    }
    else if (section == 1 && self.regionArray.count == 0) {
        return 0;
    }
    else if (section == 2 && self.clanArr.count == 0) {
        return 0;
    }
    else if (section == 3 && self.cofcArr.count == 0) {
        return 0;
    }
    else if (section == 4 && self.stribeArr.count == 0) {
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
        titleLabel.text = @"我的学校";
    }else if(section == 1){
        titleLabel.text = @"我的家乡";
    }else if(section == 2){
        titleLabel.text = @"我的宗亲";
        moreButton.hidden = NO;
        moreButton.tag = 1000;
    }else if(section == 3){
        titleLabel.text = @"我的商会";
        moreButton.hidden = NO;
        moreButton.tag = 1001;
    }else if(section == 4){
        titleLabel.text = @"我的部落";
//        moreButton.hidden = NO;
//        moreButton.tag = 1002;
    }else {
        titleLabel.text = @"推荐";
    }
    @weakify(self)
    [[moreButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton * button) {
        @strongify(self)
        UIViewController * vc = [NSClassFromString(@"LSClanCofcListViewController") new];
        if (button.tag == 1000) {
            [vc setValue:@"4" forKey:@"type"];
        }else if (button.tag == 1001){
            [vc setValue:@"3" forKey:@"type"];
        }else if (button.tag == 1002){
            [vc setValue:@"5" forKey:@"type"];
        }
        
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    return headerView;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section < 2) {
        
        LSIndexLinkInModel * model;
        UIViewController *vc = [NSClassFromString(@"LSLinkSchoolViewController") new];
        if (indexPath.section == 0) {
            model = self.schoolArray[indexPath.row];
            [vc setValue:@(model.school_id) forKey:@"sh_id"];
            [vc setValue:@(1) forKey:@"type"];
            [vc setValue:model.name forKey:@"titleStr"];
        }else if (indexPath.section == 1){
            model = self.regionArray[indexPath.row];
            [vc setValue:@(model.hometown_id) forKey:@"sh_id"];
            [vc setValue:@(2) forKey:@"type"];
            [vc setValue:model.name forKey:@"titleStr"];
        }
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section >=2 && indexPath.section < 5) {
        
        LSIndexLinkInModel * model;
        UIViewController *vc = [NSClassFromString(@"LSClanCofcViewController") new];
        if (indexPath.section == 2) {
            model = self.clanArr[indexPath.row];
            [vc setValue:@(model.clan_id) forKey:@"sh_id"];
            [vc setValue:@(4) forKey:@"type"];
            [vc setValue:model.name forKey:@"titleStr"];
        }else if (indexPath.section == 3){
            model = self.cofcArr[indexPath.row];
            [vc setValue:@(model.cofc_id) forKey:@"sh_id"];
            [vc setValue:@(3) forKey:@"type"];
            [vc setValue:model.name forKey:@"titleStr"];
        }else if (indexPath.section == 4){
            model = self.stribeArr[indexPath.row];
            [vc setValue:@(model.stribe_id) forKey:@"sh_id"];
            [vc setValue:@(5) forKey:@"type"];
            [vc setValue:model.name forKey:@"titleStr"];
        }
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        
        LSSearchMatchModel * model = self.dataSource[indexPath.row];
        LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
        lsvc.user_id = model.user_id;
        lsvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:lsvc animated:YES];
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSIndexLinkInModel * model = indexPath.section == 0 ? self.schoolArray[indexPath.row] : indexPath.section == 1 ?  self.regionArray[indexPath.row] : indexPath.section == 2 ? self.clanArr[indexPath.row] : self.cofcArr[indexPath.row] ;
    if ((indexPath.section == 2||indexPath.section == 3||indexPath.section == 4) && [model.user_id isEqualToString:ShareAppManager.loginUser.user_id]) return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    UITableViewRowAction *update = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"修改" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        @strongify(self)
        LSIndexLinkInModel * model = indexPath.section == 0 ? self.schoolArray[indexPath.row] : indexPath.section == 1 ?  self.regionArray[indexPath.row] : indexPath.section == 2 ? self.clanArr[indexPath.row] : self.cofcArr[indexPath.row] ;
        NSString * c_id = indexPath.section == 2 ? [NSString stringWithFormat:@"%ld",model.clan_id] : [NSString stringWithFormat:@"%ld",model.cofc_id];
        NSString * type = indexPath.section == 2 ? @"4" : @"3";
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSEditProfile"];
        [vc setValue:c_id forKey:@"s_id"];
        [vc setValue:type forKey:@"type"];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        @strongify(self)
        LSIndexLinkInModel * model = indexPath.section == 0 ? self.schoolArray[indexPath.row] : indexPath.section == 1 ?  self.regionArray[indexPath.row] : indexPath.section == 2 ? self.clanArr[indexPath.row] : indexPath.section == 3 ? self.cofcArr[indexPath.row] : self.stribeArr[indexPath.row] ;
        
        if (indexPath.section == 2) {
            [self sendRequsetDelete:model withRow:4];
        }else if (indexPath.section == 3){
            [self sendRequsetDelete:model withRow:3];
        }else if (indexPath.section == 4){
            [self sendRequsetDelete:model withRow:5];
        }
        
    }];
    
    delete.backgroundColor = [UIColor redColor];
    update.backgroundColor = [UIColor lightGrayColor];
    return @[delete];
}

- (void)sendRequsetDelete:(LSIndexLinkInModel *)model withRow:(int)row {
    
    NSString * c_id = row == 4 ? [NSString stringWithFormat:@"%ld",model.clan_id] : row == 3 ? [NSString stringWithFormat:@"%ld",model.cofc_id] : [NSString stringWithFormat:@"%ld",model.stribe_id];
    
    [LSLinkInApplyModel linkInApplyDelectWithC_id:c_id type:row success:^{
        
        [self initDataSource];
        
    } failure:nil];
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

#pragma mark - Getter & Setter
- (void)createTableView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView = tableView;
    
    tableView.rowHeight = 60;
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerClass:[LSLinkInCell class] forCellReuseIdentifier:reuse_id];
    [tableView registerNib:[UINib nibWithNibName:@"LSAddLinkInTableCell" bundle:nil] forCellReuseIdentifier:link_id];
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation LSLinkInCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [UIImageView new];
        self.iconImage = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.offset(10);
            make.width.height.offset(40);
        }];
        
//        UILabel *imgLabel = [UILabel new];
//        imgLabel.font = [UIFont boldSystemFontOfSize:20];
//        imgLabel.textAlignment = NSTextAlignmentCenter;
//        self.imgLabel = imgLabel;
//        imgLabel.hidden = YES;
//        [self addSubview:imgLabel];
//        [imgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(iconView);
//        }];
        
        UILabel *nameLabel = [UILabel new];
        nameLabel.font = [UIFont boldSystemFontOfSize:15];
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.mas_right).offset(10);
            make.centerY.equalTo(self).offset(-10);
        }];
        
        UILabel *subtitleLabel = [UILabel new];
        subtitleLabel.font = SYSTEMFONT(14);
        subtitleLabel.textColor = HEXRGB(0x888888);
        self.subtitleLabel = subtitleLabel;
        [self addSubview:subtitleLabel];
        [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel);
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(self).offset(10);
        }];
        
    }
    return self;
}

-(void)setIndexModel:(LSIndexLinkInModel *)indexModel{
    
    _indexModel = indexModel;
    self.nameLabel.text = indexModel.name;
    self.subtitleLabel.text = indexModel.brief_desc;
    NSString * imsgeStr = indexModel.school_id != 0? @"school":@"honetown";
    [self.iconImage setImageWithURL:[NSURL URLWithString:indexModel.logo] placeholder:[UIImage imageNamed:imsgeStr]];
    if (indexModel.school_id != 0) {
        self.iconImage.layer.cornerRadius = 20;
        self.iconImage.clipsToBounds = YES;
    }
}

- (void)setApplyModel:(LSLinkInApplyModel *)applyModel {

    _applyModel = applyModel;
    self.nameLabel.text = applyModel.name;
    self.subtitleLabel.text = applyModel.desc;
    [self.iconImage setImageWithURL:[NSURL URLWithString:applyModel.logo] placeholder:timeLineSmallPlaceholderName];
    
}

- (void)setSearchModel:(LSSearchMatchModel *)searchModel {
    _searchModel = searchModel;
    self.nameLabel.text = searchModel.name;
    self.subtitleLabel.text = searchModel.desc;
    [self.iconImage setImageWithURL:[NSURL URLWithString:searchModel.logo] placeholder:timeLineSmallPlaceholderName];
}

@end
