//
//  LSAddContactViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSAddContactViewController.h"
#import "LSPersonCodeView.h"
#import "LSContactModel.h"
#import "LSAddConactResultsViewController.h"
#import "LSContactDetailViewController.h"
#import "LSQRCodeViewController.h"

@interface LSAddContactViewController () <UISearchResultsUpdating,UISearchControllerDelegate,UISearchBarDelegate>

@property (nonatomic,strong) UISearchController *searchControl;

@end

@implementation LSAddContactViewController

- (void)viewDidLoad {
    self.title = @"添加朋友";
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.definesPresentationContext = YES;
    [self.navigationController.navigationBar setTranslucent:YES];
    self.searchControl.searchBar.frame = CGRectMake(0, 0, kScreenWidth, 15);
    self.tableView.tableHeaderView = self.searchControl.searchBar;
    
}

#pragma mark - Action
- (IBAction)searchButtonAction:(id)sender {
    [self.searchControl.searchBar becomeFirstResponder];
}

- (void)codeButtonAction {
    
    [[LSPersonCodeView personCodeView] showInView:self.navigationController.view andType:@"uid" andUser_id:ShareAppManager.loginUser.user_id withAvatar:ShareAppManager.loginUser.avatar withUser_name:ShareAppManager.loginUser.user_name withSex:ShareAppManager.loginUser.sex withDistrict_str:ShareAppManager.loginUser.district_str enter:1];
    
}

#pragma mark - TableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //扫一扫
    if (indexPath.section == 1 && indexPath.row == 0) {
        LSQRCodeViewController * vc = [LSQRCodeViewController new];
        vc.codeType = LSQRcodeTypeFriend;

        [self.navigationController pushViewController:vc animated:YES];
        
    }//手机联系人
    else if (indexPath.section == 1 && indexPath.row == 1) {
        UIViewController *vc = [NSClassFromString(@"LSAddPhoneContactViewController") new];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section != 0) return nil;
    
    UIView *footerView = [UIView new];
    
    UILabel *accountLabel = [UILabel new];
    accountLabel.font = SYSTEMFONT(14);
    NSString *title = @"我的二维码:";
    accountLabel.text = title;
    
    NSDictionary *attributes = @{NSFontAttributeName: accountLabel.font};
    CGRect rect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    CGFloat margin = 10;
    CGFloat imageW = 18;
    CGFloat titleX = (kScreenWidth-rect.size.width-margin-imageW)*0.5;
    
    UIButton *codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [codeButton setImage:[UIImage imageNamed:@"addcontact_my_qr_code"] forState:UIControlStateNormal];
    [codeButton addTarget:self action:@selector(codeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:codeButton];
    [codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footerView).offset(8);
        make.width.height.offset(imageW);
        make.left.equalTo(footerView).offset(titleX+rect.size.width+margin);
    }];
    
    [footerView addSubview:accountLabel];
    [accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(codeButton);
        make.right.equalTo(codeButton.mas_left).offset(-margin);
    }];

    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 60;
        case 1:
            return 0.0;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 46;
        case 1:
            return 60;
        default:
            return 0;
    }
}



#pragma mark - SearchControl
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    self.searchControl.searchBar.alpha = 1;
    [searchController.searchBar setBackgroundImage:[UIImage imageWithColor:kMainColor] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIButton *button = [searchController.searchBar valueForKey:@"cancelButton"];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
}
- (void)didPresentSearchController:(UISearchController *)searchController {
    
}
- (void)willDismissSearchController:(UISearchController *)searchController {
    [searchController.searchBar setBackgroundImage:[UIImage imageWithColor:HEXRGB(0xefeff4)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.searchControl.searchBar.alpha = 0;
    self.searchControl = nil;
    self.searchControl.searchBar.frame = CGRectMake(0, 0, kScreenWidth, 15);
    self.searchControl.searchBar.alpha = 0;
    [self.tableView beginUpdates];
    self.searchControl.searchBar.alpha = 0;
    [self.tableView setTableHeaderView:self.searchControl.searchBar];
    self.searchControl.searchBar.alpha = 0;
    [self.tableView endUpdates];
    [self.searchControl.searchBar sizeToFit];
    self.searchControl.searchBar.alpha = 0;
    
}
- (void)didDismissSearchController:(UISearchController *)searchController {
    self.searchControl.searchBar.alpha = 0;
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

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = YES;
    
    UIButton *button = [searchBar valueForKey:@"cancelButton"];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTintColor:[UIColor orangeColor]];
    
    return YES;
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
        searchControl.searchBar.alpha = 0;
        [searchControl.searchBar setBackgroundImage:[UIImage imageWithColor:HEXRGB(0xefeff4)]];
    }
    return _searchControl;
}

@end
