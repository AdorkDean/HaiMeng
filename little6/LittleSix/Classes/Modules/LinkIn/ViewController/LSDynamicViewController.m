//
//  LSDynamicViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/4/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSDynamicViewController.h"
#import "LSCelebrityViewController.h"

static NSString *const reuse_id = @"LSCelebrityCell";

@interface LSDynamicViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray * dataSource;

@end

@implementation LSDynamicViewController

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"动态";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createTableView];
    [self initSourceData];
}

- (void)initSourceData {
    [LSDynamicModel dynamicWithlistToken:ShareAppManager.loginUser.access_token school_id:self.sh_id type:self.type success:^(NSArray *list) {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:list];
        [self.tableView reloadData];
    } failure:nil];
    
}

#pragma mark - TableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 180;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSCelebrityCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LSDynamicModel * model = self.dataSource[indexPath.row];
    cell.dynamicModel = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSDynamicModel * model = self.dataSource[indexPath.row];
    NSString * urlString = self.type == 1 ? [NSString stringWithFormat:@"https://api.66boss.com/web/school/message?id=%d",model.id]:[NSString stringWithFormat:@"https://api.66boss.com/web/hometown/message?id=%d",model.id];
    UIViewController *vc = [NSClassFromString(@"LSWebViewController") new];
    [vc setValue:urlString forKey:@"urlString"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Getter & Setter
- (void)createTableView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView = tableView;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    [tableView registerClass:[LSCelebrityCell class] forCellReuseIdentifier:reuse_id];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
}

@end

@implementation LSDynamicModel

+(void)dynamicWithlistToken:(NSString *)access_token
                  school_id:(int)sh_id
                       type:(int)type
                    success:(void (^)(NSArray * list))success
                    failure:(void (^)(NSError *))failure {

    NSString * celebrityPath = type == 1?ksMessagePath:khMessagePath;
    NSString *path = [NSString stringWithFormat:@"%@%@?id=%d",kBaseUrl,celebrityPath,sh_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        for (NSDictionary *dic in model.result) {
            LSDynamicModel * celModel = [LSDynamicModel modelWithJSON:dic];
            [arr addObject:celModel];
        }
        !success?:success(arr);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
