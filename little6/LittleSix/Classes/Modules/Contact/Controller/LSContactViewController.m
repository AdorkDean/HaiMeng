//
//  LSContactViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSContactViewController.h"
#import "UIViewController+Util.h"
#import "LSContactModel.h"
#import "LSChineseSort.h"
#import "LSContactDetailViewController.h"
#import "LSAddConactResultsViewController.h"
#import "NSString+Util.h"
#import "MMDrawerController.h"
#import "LSMenuDetailButton.h"


static NSString *const reuseId = @"LSContactCell";

@interface LSContactViewController () <UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,UISearchControllerDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UISearchController *searchControl;

@property (nonatomic, copy) NSString * friendsCount;
@property (nonatomic, strong) UILabel * numbersLabel;
@property (nonatomic, strong) UILabel * footerTitle;
//排序后的出现过的拼音首字母数组
@property(nonatomic, strong) NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic, strong) NSMutableArray *letterResultArr;

@end

@implementation LSContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"通讯录";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;
    [self.navigationController.navigationBar setTranslucent:YES];
    [self _configTableView];
    [self _initDataSource];
    [self naviBarRightItem];
    [self registerNotification];
    [self registerAddContactNotification];
    [self friendslogCount];
}

- (void)registerNotification {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kContactInfoNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self _initDataSource];
        [self friendslogCount];
    }];
}

- (void)registerAddContactNotification {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kAddContactInfoNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self friendslogCount];
    }];
}

- (void)friendslogCount {
    [LSContactModel friendslogCountSuccess:^(NSString *messageCount) {
        self.friendsCount = messageCount;
        [self.tableView reloadData];
    } failure:nil];
}

-(void)_initDataSource {

    [LSContactModel friendsWithlistToken:ShareAppManager.loginUser.access_token success:^(NSArray *array) {
        //根据LSContactModel对象的 user_name 属性 按中文 对 LSContactModel数组 排序
        self.footerTitle.text = [NSString stringWithFormat:@"%ld位联系人",array.count];
        self.indexArray = [LSChineseSort IndexWithArray:array Key:@"first_letter"];
        self.letterResultArr = [LSChineseSort sortObjectArray:array Key:@"first_letter"];
        [self.tableView reloadData];
        
    } failure:nil];
}

- (void)naviBarRightItem {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"contact_add_peo"] forState:UIControlStateNormal];
    [button sizeToFit];
    
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        UIViewController *vc = [UIViewController controllerFromStroyboard:@"Chat" identify:@"LSAddContactViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    LSMenuDetailButton *leftButton = [LSMenuDetailButton buttonWithType:UIButtonTypeCustom];
    
    UIBarButtonItem *lefItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = lefItem;
    
    [[leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }];
}

- (void)_configTableView {
    
    self.tableView.tableHeaderView = self.searchControl.searchBar;

    self.tableView.rowHeight = 55;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    self.tableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
    self.tableView.sectionIndexColor = HEXRGB(0x555555);
    self.tableView.backgroundColor = HEXRGB(0xefeff4);
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    [self.tableView registerClass:[LSContactCell class] forCellReuseIdentifier:reuseId];
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    UILabel * footerTitle = [UILabel new];
    footerTitle.font = [UIFont systemFontOfSize:17];
    footerTitle.textColor = [UIColor lightGrayColor];
    self.footerTitle = footerTitle;
    footerTitle.textAlignment = UITextAlignmentCenter;
    [footerView addSubview:footerTitle];
    [footerTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(footerView);
    }];
    self.tableView.tableFooterView = footerView;
    self.friendsCount = @"0";
     
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.indexArray count]+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section==0?2: [[self.letterResultArr objectAtIndex:section-1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSContactCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (indexPath.section == 0) {
        cell.indexPath = indexPath;
        if ([self.friendsCount isEqualToString:@"0"]) {
            cell.numberLabel.hidden = YES;
        }else {
            cell.numberLabel.hidden = indexPath.row == 0 ? NO : YES ;
            cell.numberLabel.text = self.friendsCount;
        }
    }
    else {
        LSContactModel * model = [[self.letterResultArr objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        cell.contactModel = model;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"NewFriends" sender:nil];
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        UIViewController *groupVC = [NSClassFromString(@"LSContactGroupsViewController") new];
        groupVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:groupVC animated:YES];
    }
    else {
        LSContactModel * model = [[self.letterResultArr objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
        lsvc.user_id = [NSString stringWithFormat:@"%ld",model.friend_id];
        lsvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:lsvc animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView new];
    headerView.backgroundColor = HEXRGB(0xefeff4);
    
    UILabel *indexLabel = [UILabel new];
    indexLabel.font = SYSTEMFONT(14);
    indexLabel.textColor = HEXRGB(0x8e8e93);
    indexLabel.text = self.indexArray[section-1];
    
    [headerView addSubview:indexLabel];
    [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView);
        make.left.equalTo(headerView).offset(10);
    }];
    
    return headerView;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexArray;;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0.0;
            
        default:
            return 22;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *temp = _letterResultArr[indexPath.section-1];
    LSContactModel *contact = (LSContactModel *)temp[indexPath.row];
    // 删除
    [self removeContact:contact];
    // 刷新 当然数据比较大的时候可能就需要只刷新删除的对应的section了
    [tableView reloadData];
}

// 删除联系人
- (void)removeContact:(LSContactModel *)contact {
    
    [LSContactModel deleteFriendsWithlistToken:ShareAppManager.loginUser.access_token fid:contact.fid success:^{
        
        [self _initDataSource];
        
    } failure:nil];
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
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
    NSMutableArray * arr = [NSMutableArray array];
    for (NSArray * array in self.letterResultArr) {
        for (LSContactModel * model  in array) {
            if ([model.user_name rangeOfString:key].location != NSNotFound) {
                [arr addObject:model];
            }
        }
    }
    
    LSAddConactResultsViewController *vc = (LSAddConactResultsViewController *)self.searchControl.searchResultsController;
    vc.searchResults = arr;
    [vc.tableView reloadData];
    @weakify(self)
    [vc setIndexClick:^(LSContactModel *model) {
        @strongify(self)
        searchBar.showsCancelButton = YES;
        [self.searchControl.searchBar resignFirstResponder];
        LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
        lsvc.user_id = [NSString stringWithFormat:@"%ld",model.friend_id];
        lsvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:lsvc animated:YES];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
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

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@implementation LSContactCell

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
        
        UILabel *numberLabel = [UILabel new];
        numberLabel.font = SYSTEMFONT(13);
        numberLabel.textAlignment = UITextAlignmentCenter;
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.backgroundColor = [UIColor redColor];
        self.numberLabel = numberLabel;
        numberLabel.hidden = YES;
        numberLabel.layer.cornerRadius = 10;
        numberLabel.clipsToBounds = YES;
        [self addSubview:numberLabel];
        
        [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.mas_left).offset(80);
            make.centerY.equalTo(self);
            make.width.offset(30);
            make.height.offset(20);
        }];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

-(void)setContactModel:(LSContactModel *)contactModel{

    _contactModel = contactModel;
    
    [self.iconView setImageWithURL:[NSURL URLWithString:contactModel.avatar] placeholder:timeLineSmallPlaceholderName];
    self.nameLabel.text = contactModel.user_name;
    self.numberLabel.hidden = YES;
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    self.numberLabel.hidden = YES;
    switch (indexPath.row) {
        case 0:
        {
            self.iconView.image = [UIImage imageNamed:@"contact_add_friends"];
            self.nameLabel.text = @"新的朋友";
            self.numberLabel.hidden = NO;
            return;
        }
        case 1:
        {
            self.iconView.image = [UIImage imageNamed:@"contact_group_chats"];
            self.nameLabel.text = @"群聊";
            self.numberLabel.hidden = NO;
            return;
        }
        default:
            break;
    }
}

@end
