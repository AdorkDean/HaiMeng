//
//  LSClanCofcListViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/4/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSClanCofcListViewController.h"
#import "LSLinkInViewController.h"
#import "LSLinkInApplyModel.h"
#import "UIView+HUD.h"
#import "MJRefresh.h"

static NSString *const reuse_id = @"LSLinkInCell";
@interface LSClanCofcListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic)UITableView * tableView;
@property (assign,nonatomic) int page;
@property (strong,nonatomic)NSMutableArray * dataSource;

@end

@implementation LSClanCofcListViewController

- (NSMutableArray *)dataSource {

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self createTableView];
    [self judgeType];
    [self _initDataSource];
    self.page = 1;
    MJRefreshNormalHeader * gifheadView = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTableHeader)];
    
    self.tableView.mj_header = gifheadView;
    gifheadView.lastUpdatedTimeLabel.hidden = YES;
    gifheadView.stateLabel.hidden = YES;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshTableFoot)];
}

- (void)refreshTableHeader {
    
    self.page = 1;
    [self _initDataSource];
}

- (void)refreshTableFoot {
    
    self.page ++;
    [LSKeyWindow showLoading];
    [LSLinkInApplyModel linkInApplyListWithPage:self.page type:self.type success:^(NSArray *list) {
        
        [self.dataSource addObjectsFromArray:list];;
        [self.tableView reloadData];
        [LSKeyWindow hideHUDAnimated:YES];
        [self.tableView.mj_footer endRefreshing];
        
    } failure:^(NSError *error) {
        [LSKeyWindow hideHUDAnimated:YES];
        [self.tableView.mj_footer endRefreshing];
        
    }];
}

- (void)_initDataSource {

    [LSKeyWindow showLoading];
    [LSLinkInApplyModel linkInApplyListWithPage:self.page type:self.type success:^(NSArray *list) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:list];;
        [self.tableView reloadData];
        [LSKeyWindow hideHUDAnimated:YES];
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSError *error) {
        [LSKeyWindow hideHUDAnimated:YES];
        [self.tableView.mj_header endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LSLinkInCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LSLinkInApplyModel * model = self.dataSource [indexPath.row];
    cell.applyModel = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LSLinkInApplyModel * model = self.dataSource [indexPath.row];
    UIViewController *vc = [NSClassFromString(@"LSClanCofcViewController") new];
    [vc setValue:@([model.id intValue]) forKey:@"sh_id"];
    [vc setValue:@([self.type intValue]) forKey:@"type"];
    [vc setValue:model.name forKey:@"titleStr"];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
}

- (void)judgeType {

    self.title = [self.type isEqualToString:@"4"] ? @"宗亲":[self.type isEqualToString:@"5"] ? @"企业号":@"商会";
}

@end
