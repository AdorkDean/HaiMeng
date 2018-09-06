//
//  LSContactGroupsViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSContactGroupsViewController.h"
#import "LSContactViewController.h"
//#import "UIImage+Color.h"
#import "LSGroupModel.h"
#import "UIView+HUD.h"
#import "LSChatViewController.h"
#import "LSGroupChatDetailsViewController.h"
#import "LSAddConactResultsViewController.h"
#import "LSSearchGResultsViewController.h"
#import "LSConversationModel.h"

static NSString *reuseId = @"LSContactGroupsCell";

@interface LSContactGroupsViewController () <UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,UISearchControllerDelegate,UISearchBarDelegate>

@property (nonatomic,strong) UITableView *tabelView;
@property (nonatomic,strong) UISearchController *searchControl;
@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation LSContactGroupsViewController

-(NSMutableArray *)dataSource {

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"群聊";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;
    [self.navigationController.navigationBar setTranslucent:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createTabelView];
    
    [self _initDataSources];
}

-(void)_initDataSources {

    [self.view showLoading];
    [LSGroupModel groupWithlistsUser_Id:ShareAppManager.loginUser.user_id success:^(NSArray *array) {
        
        [self.dataSource removeAllObjects];
        
        [self.dataSource addObjectsFromArray:array];
        
        self.titleLabel.text = [NSString stringWithFormat:@"%ld个群聊",self.dataSource.count];
        [self.tabelView reloadData];
        [self.view hideHUDAnimated:YES];
    } failure:^(NSError *error) {
        [self.view hideHUDAnimated:YES];
        
    }];
}

#pragma mark - TabelView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSContactGroupsCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    LSGroupModel * model = self.dataSource[indexPath.row];
    
    cell.groupModel = model;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.tabBarController.selectedIndex = 0;
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    LSGroupModel *gmodel = self.dataSource[indexPath.row];

    [[NSNotificationCenter defaultCenter] postNotificationName:kSendGroupMessageNoti object:gmodel userInfo:nil];

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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    NSString * key = [searchBar.text stringByTrim];
    
    [self searchResults:key];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString * key = [searchBar.text stringByTrim];

    [self searchResults:key];
}

- (void)searchResults:(NSString *)key {

    NSMutableArray * arr = [NSMutableArray array];
    
    for (LSGroupModel * model in self.dataSource) {
        
        if ([model.name rangeOfString:key].location != NSNotFound) {
            
            [arr addObject:model];
        }
    }
    
    LSSearchGResultsViewController *vc = (LSSearchGResultsViewController *)self.searchControl.searchResultsController;
    vc.searchResults = arr;
    [vc.tableView reloadData];
    
    @weakify(self)
    [vc setIndexClick:^(LSGroupModel *gmodel) {
       @strongify(self)
        LSConversationModel *model = [LSConversationModel new];
        model.type = LSConversationTypeGroup;
        model.conversationId = gmodel.groupid;
        model.title = gmodel.name;
        model.avartar = gmodel.snap;
        
        //是好友到聊天界面
        LSChatViewController *chatVC = [[LSChatViewController alloc] initWithConversation:model];
        [self.navigationController pushViewController:chatVC animated:YES];
    }];
}

#pragma mark - Getter & Setter
- (UISearchController *)searchControl {
    if (!_searchControl) {
        LSSearchGResultsViewController *vc = [LSSearchGResultsViewController new];
        
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

#pragma mark - Getter & Setter
- (void)createTabelView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tabelView = tableView;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[LSContactGroupsCell class] forCellReuseIdentifier:reuseId];
    tableView.rowHeight = 55;
    
    tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    tableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
    
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    UIView *footerView = [UIView new];
    footerView.backgroundColor = [UIColor clearColor];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.text = @"";
    self.titleLabel.font = SYSTEMFONT(16);
    self.titleLabel.textColor = HEXRGB(0x929297);
    
    [footerView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(footerView);
        make.top.equalTo(footerView).offset(16);
    }];
    footerView.frame = CGRectMake(0, 0, kScreenWidth, 80);
    
    tableView.tableFooterView = footerView;
    tableView.tableHeaderView = self.searchControl.searchBar;
}


@end

@implementation LSContactGroupsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [UIImageView new];
        self.iconView = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.centerY.equalTo(self);
            make.width.height.offset(35);
        }];
        
        UILabel *nameLabel = [UILabel new];
        self.nameLabel = nameLabel;
        nameLabel.text = @"今晚打老虎";
        nameLabel.font = SYSTEMFONT(16);
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(iconView.mas_right).offset(10);
            make.right.equalTo(self.mas_right).offset(-10);
        }];
        
        iconView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}
-(void)setGroupModel:(LSGroupModel *)groupModel{

    _groupModel = groupModel;
    
    [self.iconView setImageWithURL:[NSURL URLWithString:groupModel.snap] placeholder:[UIImage imageNamed:@""]];
    self.nameLabel.text = groupModel.name;
}

@end
