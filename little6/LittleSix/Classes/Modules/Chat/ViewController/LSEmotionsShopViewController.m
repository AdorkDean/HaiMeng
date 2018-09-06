//
//  LSEmotionsShopViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEmotionsShopViewController.h"
#import "LSEmotionModel.h"
#import "UIView+HUD.h"
#import "ZHCycleView.h"
#import "MJRefresh.h"
#import "HttpManager.h"
#import "LSEmotionManager.h"

static NSString *const reuseId = @"LSEmotionShopCell";

@interface LSEmotionsShopViewController () <UISearchResultsUpdating,UISearchControllerDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UISearchController *searchControl;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSArray *adArray;
@property (nonatomic,strong) NSMutableArray *groupArray;

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) ZHCycleView *headerView;

@end

@implementation LSEmotionsShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"精选表情";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self installSubviews];
    
    [self loadNewData];
}

- (void)installSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kEmotionPackageUpdateNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
}

- (void)loadNewData {
    
    self.page = 1;
    
    [LSEmotionShopModel emotionStoreInfo:self.page size:20 success:^(LSEmotionShopModel *emoShop) {
        
        self.adArray = emoShop.hot;
        self.groupArray = [NSMutableArray arrayWithArray:emoShop.groups];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self.view showError:@"请求失败" hideAfterDelay:1.5];
    }];
}

- (void)loadMoreData {
    
    if (!self.groupArray) {
        [self loadNewData];
        return;
    }
    
    self.page++;
    
    [LSEmotionShopModel emotionStoreInfo:self.page size:20 success:^(LSEmotionShopModel *emoShop) {

        [self.groupArray addObjectsFromArray:emoShop.groups];
        [self.tableView reloadData];
        
        if (emoShop.groups.count==0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else {
            [self.tableView.mj_footer endRefreshing];
        }
        
    } failure:^(NSError *error) {
        [self.view showError:@"请求失败" hideAfterDelay:1.5];
        self.page--;
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section != 1 ? 0 : self.groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionShopCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@%ld",reuseId,indexPath.row]];
    
    if (!cell) {
        cell = [[LSEmotionShopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@%ld",reuseId,indexPath.row]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.package = self.groupArray[indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) return nil;
    
    NSMutableArray *list = [NSMutableArray array];
    for (LSHotEmotionModel *model in self.adArray) {
        [list addObject:model.group_cover];
    }
    
    if (self.headerView) {
        [self.headerView destoryTimer];
    }

    @weakify(self)
    ZHCycleView *headerView = [ZHCycleView cycleViewWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*0.56) imageUrlGroups:list placeHolderImage:nil selectAction:^(NSInteger index) {
        @strongify(self)
        
        LSHotEmotionModel *package = self.adArray[index];
        UIViewController *vc = [NSClassFromString(@"LSEmotionPackageInfoViewController") new];
        [vc setValue:package.group_id forKey:@"packid"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    self.headerView = headerView;
    
    headerView.currentPageTintColor = kMainColor;
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor clearColor];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section != 0 ? 0 : kScreenWidth * 0.56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionPackage *package = self.groupArray[indexPath.row];
    UIViewController *vc = [NSClassFromString(@"LSEmotionPackageInfoViewController") new];
    [vc setValue:package.group_id forKey:@"packid"];
    [self.navigationController pushViewController:vc animated:YES];
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
    
    LSEmotionShopSearchResultViewContorller *searchVC = (LSEmotionShopSearchResultViewContorller *)self.searchControl.searchResultsController;
    searchVC.keyword = searchBar.text;
}

#pragma mark - Getter & Setter
- (UISearchController *)searchControl {
    if (!_searchControl) {
        LSEmotionShopSearchResultViewContorller *vc = [NSClassFromString(@"LSEmotionShopSearchResultViewContorller") new];
        @weakify(self)
        [vc setItemClickBlock:^(LSEmotionShopSearchResultViewContorller *searchVC ,NSString *group_Id) {
            @strongify(self)
            [searchVC dismissViewControllerAnimated:YES completion:^{
                UIViewController *vc = [NSClassFromString(@"LSEmotionPackageInfoViewController") new];
                [vc setValue:group_Id forKey:@"packid"];
                [self.navigationController pushViewController:vc animated:YES];
                [self.searchControl.searchBar setBackgroundImage:[UIImage imageWithColor:HEXRGB(0xefeff4)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
                self.searchControl.searchBar.text = nil;
            }];
        }];
        UISearchController *searchControl = [[UISearchController alloc] initWithSearchResultsController:vc];
        _searchControl = searchControl;
        searchControl.searchResultsUpdater = self;
        searchControl.searchBar.placeholder = @"搜索表情";
        searchControl.delegate = self;
        searchControl.searchBar.delegate = self;
        [searchControl.searchBar setBackgroundImage:[UIImage imageWithColor:HEXRGB(0xefeff4)]];
    }
    return _searchControl;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView = tableView;
        tableView.rowHeight = 80;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableHeaderView = self.searchControl.searchBar;
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        tableView.tableFooterView = [UIView new];
//        [tableView registerClass:[LSEmotionShopCell class] forCellReuseIdentifier:reuseId];
        
        tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    }
    return _tableView;
}

- (void)dealloc {
    [self.headerView destoryTimer];
    self.headerView = nil;
}

@end

@interface LSEmotionShopCell ()

@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subTitleLabel;
@property (nonatomic,strong) UIButton *downloadButton;

@end

@implementation LSEmotionShopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [UIImageView new];
        self.iconView = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.offset(10);
            make.width.height.offset(58);
        }];
        
        UILabel *titleLabel = [UILabel new];
        self.titleLabel = titleLabel;
        titleLabel.font = SYSTEMFONT(16);
        titleLabel.textColor = [UIColor blackColor];
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.mas_right).offset(20);
            make.centerY.equalTo(self).offset(-10);
        }];
        
        UILabel *subTitleLabel = [UILabel new];
        self.subTitleLabel = subTitleLabel;
        subTitleLabel.font = SYSTEMFONT(12);
        subTitleLabel.textColor = HEXRGB(0x888888);
        [self addSubview:subTitleLabel];
        [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(12);
            make.left.equalTo(titleLabel);
        }];
        
        UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.downloadButton = downloadButton;
        downloadButton.titleLabel.font = SYSTEMFONT(13);
        [downloadButton setTitle:@"下载" forState:UIControlStateNormal];
        [downloadButton setTitleColor:kMainColor forState:UIControlStateNormal];
        [downloadButton setTitle:@"已下载" forState:UIControlStateDisabled];
        [downloadButton setTitleColor:HEXRGB(0xc5c5c5) forState:UIControlStateDisabled];
        [downloadButton setBackgroundImage:[UIImage imageNamed:@"emotion_redborder"] forState:UIControlStateNormal];
        [downloadButton setBackgroundImage:[UIImage imageNamed:@"emotion_greyborder"] forState:UIControlStateDisabled];
        [downloadButton addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:downloadButton];
        [downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.height.offset(26);
            make.right.offset(-15);
            make.width.offset(60);
        }];
        
    }
    return self;
}

- (IBAction)downloadAction:(UIButton *)sender {
    
    if (self.task) return;
    
    self.task = [HttpManager download:self.package.download downloadProgress:^(NSProgress *progress) {
        kDISPATCH_MAIN_THREAD((^{
            CGFloat ratio = (float)progress.completedUnitCount/progress.totalUnitCount;
            NSString *title = [NSString stringWithFormat:@"%d%%",(int)(ratio*100)];
            [self.downloadButton setTitle:title forState:UIControlStateNormal];
        }));
    } completeHandler:^(NSURLResponse *response, NSURL *fileUrl, NSError *error) {
        if (error) {
            self.task = nil;
            self.downloadButton.enabled = YES;
            [self.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
            [LSKeyWindow showError:@"下载失败" hideAfterDelay:1.5];
        }
        else {
            self.downloadButton.enabled = NO;
            NSString *filePath = [fileUrl.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            NSDictionary *dict = [LSEmotionManager unPackEmotionPackage:filePath removeSourceFile:YES];
            if (dict) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kEmotionPackageUpdateNoti object:nil];
            }
            
        }
    }];
}


- (void)setPackage:(LSEmotionPackage *)package {
    _package = package;
    
    [self.iconView setImageWithURL:[NSURL URLWithString:package.group_icon] placeholder:nil];
    self.titleLabel.text = package.group_name;
    self.subTitleLabel.text = package.group_desc;
    self.downloadButton.hidden = NO;
    BOOL exist = [LSEmotionManager exitEmotionPackageById:package.group_id];
    if (exist) {
        self.downloadButton.enabled = NO;
    }
    else {
        [self.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
    }
}

- (void)setSearchModel:(LSPackageSearchModel *)searchModel {
    _searchModel = searchModel;
    
    [self.iconView setImageWithURL:[NSURL URLWithString:searchModel.icon] placeholder:nil];
    self.downloadButton.hidden = YES;
    
    NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc] initWithString:searchModel.sname];
    
    NSRange nameRange = [searchModel.sname rangeOfString:self.keyword];
    if (nameRange.location != NSNotFound) {
        [titleAttr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(nameRange.location, self.keyword.length)];
    }
  
    NSMutableAttributedString *descAttr = [[NSMutableAttributedString alloc] initWithString:searchModel.sdesc];
    
    NSRange descRange = [searchModel.sdesc rangeOfString:self.keyword];
    if (descRange.location != NSNotFound) {
        [descAttr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(descRange.location, self.keyword.length)];
    }

    self.titleLabel.attributedText = titleAttr;
    self.subTitleLabel.attributedText = descAttr;
}

@end

@implementation LSEmotionShopSearchResultViewContorller 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self installSubviews];
}

- (void)installSubviews {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView = tableView;
    tableView.rowHeight = 80;
    tableView.tableFooterView = [UIView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[LSEmotionShopCell class] forCellReuseIdentifier:reuseId];
    
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
}

- (void)loadData {
    
    [LSPackageSearchModel searchWithKeyword:self.keyword success:^(NSArray *list) {
        self.dataSource = list;
        [self.tableView reloadData];
    } failure:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSEmotionShopCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    cell.keyword = self.keyword;
    cell.searchModel = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSPackageSearchModel *model = self.dataSource[indexPath.row];
    !self.itemClickBlock ? : self.itemClickBlock(self,model.group_id);
}

- (void)setKeyword:(NSString *)keyword {
    _keyword = keyword;
    [self loadData];
}

@end
