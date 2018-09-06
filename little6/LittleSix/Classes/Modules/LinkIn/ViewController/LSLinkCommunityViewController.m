
//
//  LSLinkCommunityViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkCommunityViewController.h"

static NSString *const reuse_id = @"LSLinkCommunityCell";

@interface LSLinkCommunityViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray * dataSource;

@end

@implementation LSLinkCommunityViewController

- (NSMutableArray *)dataSource {

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _type == 1?@"社团":@"商会";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createtTableView];
    [self initSourceData];
}

-(void)initSourceData{

    [LSLinkCommunityModel linkCommunityWithlistToken:ShareAppManager.loginUser.access_token school_id:self.sh_id type:self.type success:^(NSArray *list) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:list];
        [self.tableView reloadData];
    } failure:nil];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSLinkCommunityCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    
    LSLinkCommunityModel * model = self.dataSource[indexPath.row];
    
    cell.communityModel = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LSLinkCommunityModel * model = self.dataSource[indexPath.row];
    NSString * urlString = self.type == 1 ? [NSString stringWithFormat:@"https://api.66boss.com/web/school/league?id=%d",model.id]:[NSString stringWithFormat:@"https://api.66boss.com/hometown/cofc?id=%d",model.id];
    UIViewController *vc = [NSClassFromString(@"LSWebViewController") new];
    [vc setValue:urlString forKey:@"urlString"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Getter & Setter
- (void )createtTableView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView = tableView;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [tableView registerClass:[LSLinkCommunityCell class] forCellReuseIdentifier:reuse_id];
    
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
}



@end

@implementation LSLinkCommunityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [UIImageView new];
        //iconView.backgroundColor = [UIColor redColor];
        self.iconImage = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.height.offset(38);
            make.left.offset(20);
        }];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = @"社会混混古惑仔社团";
        self.nameLabel = titleLabel;
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.mas_right).offset(10);
            make.top.equalTo(iconView).offset(2);
        }];
        
        UILabel *subLabel = [UILabel new];
        subLabel.text = @"简介";
        self.detailLabel = subLabel;
        subLabel.font = SYSTEMFONT(14);
        subLabel.textColor = HEXRGB(0x888888);
        [self addSubview:subLabel];
        [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLabel);
            make.top.equalTo(titleLabel.mas_bottom).offset(5);
        }];
        
        
    }
    
    return self;
}

-(void)setCommunityModel:(LSLinkCommunityModel *)communityModel{

    _communityModel = communityModel;
    
    [self.iconImage setImageWithURL:[NSURL URLWithString:communityModel.logo] placeholder:[UIImage imageNamed:@""]];
    
    self.nameLabel.text = communityModel.name;
    self.detailLabel.text = communityModel.short_desc;
}

@end

@implementation LSLinkCommunityModel

+(void)linkCommunityWithlistToken:(NSString *)access_token
                        school_id:(int)school_id
                             type:(int)type
                          success:(void (^)(NSArray * list))success
                          failure:(void (^)(NSError *))failure{

    NSString * celebrityPath = type == 1?ksCommunityPath:khCommunityPath;
    NSString *path = [NSString stringWithFormat:@"%@%@?id=%d",kBaseUrl,celebrityPath,school_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        
        for (NSDictionary *dic in model.result) {
            
            LSLinkCommunityModel * lcommModel = [LSLinkCommunityModel modelWithJSON:dic];
            [arr addObject:lcommModel];
        }
        
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
