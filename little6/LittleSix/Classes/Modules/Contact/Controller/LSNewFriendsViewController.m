//
//  LSNewFriendsViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSNewFriendsViewController.h"
#import "UIViewController+Util.h"
#import "LSContactModel.h"
#import "LSContactDetailViewController.h"
#import "LSAddConactResultsViewController.h"
#import "NSString+Util.h"
#import "UIView+HUD.h"
#import "LSUMengHelper.h"

static NSString *reuseId = @"LSNewFriendCell";

@interface LSNewFriendsViewController () <UISearchResultsUpdating,UISearchControllerDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchControl;
@property (nonatomic, retain) NSMutableArray * dataArray;
@end

@implementation LSNewFriendsViewController

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

-(NSMutableArray *)dataArray{
    
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.definesPresentationContext = YES;
    [self.navigationController.navigationBar setTranslucent:YES];
    self.title = @"新的朋友";
    
    [self _tableViewConfig];
    [self naviItemAction];
    [self initDataSource];
}

-(void)initDataSource{
    
    [self.view showLoading];
    [LSNewFriendstModel newFriendsWithlistToken:ShareAppManager.loginUser.access_token success:^(NSArray *array) {
        
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
    } failure:^(NSError *error) {
        [self.view hideHUDAnimated:YES];
        [self.view showErrorWithError:error];
    }];
}

-(void)dealWithSource:(LSNewFriendstModel *)fmodel{

    [LSContactModel dealWithWithlistToken:ShareAppManager.loginUser.access_token uid:fmodel.id feedback_mark:@"2" success:^(LSContactModel *model) {
        
        [self initDataSource];
        //发送通知刷新
        [[NSNotificationCenter defaultCenter] postNotificationName:kContactInfoNoti object:nil];
        [LSUMengHelper pushNotificationWithUsers:@[fmodel.user_id] message:[NSString stringWithFormat:@"%@和你已经成为好友",ShareAppManager.loginUser.user_name] extension:@{@"contactTpye":kAcceptPath,@"user_id":ShareAppManager.loginUser.user_id} success:^{
            
        } failure:nil];
        [self.view showWithText:@"添加成功" hideAfterDelay:1.5];
        
    } failure:^(NSError *error) {
        [self.view showWithText:@"添加失败" hideAfterDelay:1.5];
    }];
}

- (void)_tableViewConfig {
    [self.tableView registerClass:[LSNewFriendCell class] forCellReuseIdentifier:reuseId];
    self.tableView.backgroundColor = HEXRGB(0xefeff4);
    self.tableView.tableHeaderView = self.searchControl.searchBar;
}

- (void)naviItemAction {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"添加朋友" forState:UIControlStateNormal];
    button.titleLabel.font = SYSTEMFONT(16);
    [button sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        UIViewController *vc = [UIViewController controllerFromStroyboard:@"Chat" identify:@"LSAddContactViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - Action
- (IBAction)addPhoneContactAction:(id)sender {
    
    UIViewController *vc = [NSClassFromString(@"LSAddPhoneContactViewController") new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) return [super tableView:tableView numberOfRowsInSection:section];

    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    LSNewFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    LSNewFriendstModel * model = self.dataArray[indexPath.row];
    cell.newfriendsModel = model;
    @weakify(self)
    [cell setDealWithClick:^(LSNewFriendstModel *newModel) {
        @strongify(self)
        [self dealWithSource:model];
    }];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        LSNewFriendstModel * model = self.dataArray[indexPath.row];
        LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
        lsvc.user_id = model.user_id;
        [self.navigationController pushViewController:lsvc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) return 60;
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section==0 ? 20 : 0.1;
}

#pragma mark - SearchControl
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    [searchController.searchBar setBackgroundImage:[UIImage imageWithColor:kMainColor] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIButton *button = [searchController.searchBar valueForKey:@"cancelButton"];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    
}
- (void)didPresentSearchController:(UISearchController *)searchController {
}
- (void)willDismissSearchController:(UISearchController *)searchController {
    [searchController.searchBar setBackgroundImage:[UIImage imageWithColor:HEXRGB(0xefeff4)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}
- (void)didDismissSearchController:(UISearchController *)searchController {
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = YES;
    
    UIButton *button = [searchBar valueForKey:@"cancelButton"];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTintColor:[UIColor orangeColor]];
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString * key = [searchBar.text stringByTrim];
    [LSContactModel findFriendsWithlistToken:ShareAppManager.loginUser.access_token key:key success:^(NSArray *array) {
        
        LSAddConactResultsViewController *vc = (LSAddConactResultsViewController *)self.searchControl.searchResultsController;
        vc.searchResults = array;
        [vc.tableView reloadData];
        
        @weakify(self)
        [vc setIndexClick:^(LSContactModel *model) {
            @strongify(self)
            searchBar.showsCancelButton = YES;
            [self.searchControl.searchBar resignFirstResponder];
            
            LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
            lsvc.user_id = [NSString stringWithFormat:@"%ld",model.user_id];
            [self.navigationController pushViewController:lsvc animated:YES];
        }];
        
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark - Getter & Setter
- (UISearchController *)searchControl {
    if (!_searchControl) {
        LSAddConactResultsViewController *vc = [LSAddConactResultsViewController new];

        UISearchController *searchControl = [[UISearchController alloc] initWithSearchResultsController:vc];
        _searchControl = searchControl;
        searchControl.searchResultsUpdater = self;
        searchControl.searchBar.placeholder = @"搜索";
        searchControl.delegate = self;
        searchControl.searchBar.delegate = self;
        [searchControl.searchBar setBackgroundImage:[UIImage imageWithColor:HEXRGB(0xefeff4)]];
    }
    return _searchControl;
}


@end

@implementation LSNewFriendCell

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
            make.right.equalTo(statusButton.mas_left).offset(-10);
            make.left.equalTo(iconView.mas_right).offset(10);
        }];
        
        UILabel *descLabel = [UILabel new];
        descLabel.font = SYSTEMFONT(14);
        self.descLabel = descLabel;
        descLabel.textColor = HEXRGB(0x888888);
        [self addSubview:descLabel];
        [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel);
            make.right.equalTo(statusButton.mas_left).offset(-10);
            make.bottom.equalTo(iconView.mas_bottom).offset(4);
        }];
        
        iconView.backgroundColor = [UIColor lightGrayColor];
        nameLabel.text = @"怪蜀黍";
        descLabel.text = @"今晚，约吗？";
    }
    return self;
}
-(void)setNewfriendsModel:(LSNewFriendstModel *)newfriendsModel{
    
    _newfriendsModel = newfriendsModel;
    
    [self.iconView setImageWithURL:[NSURL URLWithString:newfriendsModel.avatar] placeholder:[UIImage imageNamed:@""]];
    self.nameLabel.text = newfriendsModel.user_name;
    self.descLabel.text = newfriendsModel.friend_note;
    
    self.statusButton.selected = [newfriendsModel.feedback_mark intValue] == 0||[newfriendsModel.feedback_mark intValue]== 2?YES:NO;
    NSString * title = [newfriendsModel.feedback_mark intValue]== 2?@"已添加":@"添加";
    [self.statusButton setTitle:title forState:UIControlStateNormal];
    [self.statusButton setTitle:@"已添加" forState:UIControlStateSelected];
}

-(void)statuClick:(UIButton *)sender{

    if (self.dealWithClick) {
        sender.selected = !sender.selected;
        self.dealWithClick(self.newfriendsModel);
    }
}

@end
