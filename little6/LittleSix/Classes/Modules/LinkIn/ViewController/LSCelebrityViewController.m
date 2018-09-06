//
//  LSCelebrityViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSCelebrityViewController.h"
#import "LSDynamicViewController.h"
#import "LSLinkInApplyModel.h"
#import "UIView+HUD.h"
#import "ComfirmView.h"

static NSString *const reuse_id = @"LSCelebrityCell";

@interface LSCelebrityViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray * dataSource;

@end

@implementation LSCelebrityViewController

- (NSMutableArray *)dataSource {

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"名人";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTableView];
    [self initSourceData];
    [self naviBarConfig];
    [self registerNotification];
}

- (void)registerNotification {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kCelebrityLinkInInfoNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self initSourceData];
    }];
}

- (void)naviBarConfig{

    if ((self.type == 3 || self.type == 4) && [self.user_id isEqualToString:ShareAppManager.loginUser.user_id]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"navi_chat_more"] forState:UIControlStateNormal];
        [button sizeToFit];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        @weakify(self)
        [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
            @strongify(self);
            ModelComfirm *item1 = [ModelComfirm comfirmModelWith:@"编辑" titleColor:[UIColor redColor] fontSize:16];
            ModelComfirm *cancelItem = [ModelComfirm comfirmModelWith:@"取消" titleColor:HEXRGB(0x666666) fontSize:16];
            //确认提示框
            [ComfirmView showInView:LSKeyWindow cancelItemWith:cancelItem dataSource:@[ item1 ] actionBlock:^(ComfirmView *view, NSInteger index) {
                UIViewController *vc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSCelebrity"];
                [vc setValue:[NSString stringWithFormat:@"%d",self.sh_id] forKey:@"s_id"];
                [vc setValue:[NSString stringWithFormat:@"%d",self.type] forKey:@"type"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }];
    }
}

- (void)initSourceData {
    
    [LSCelebrityModel celebrityWithlistToken:ShareAppManager.loginUser.access_token school_id:self.sh_id type:self.type success:^(NSArray *list) {
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
    LSCelebrityModel * model = self.dataSource[indexPath.row];
    cell.celebrityModel = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LSCelebrityModel * model = self.dataSource[indexPath.row];
    NSString * urlString = self.type == 1 ? [NSString stringWithFormat:@"https://api.66boss.com/web/school/celebrity?id=%d",model.id]: self.type == 2 ? [NSString stringWithFormat:@"https://api.66boss.com/web/hometown/celebrity?id=%d",model.id]:self.type == 3 ? [NSString stringWithFormat:@"https://api.66boss.com/web/cofc/celebrity?id=%d",model.id] : [NSString stringWithFormat:@"https://api.66boss.com/web/clan/celebrity?id=%d",model.id];
    UIViewController *vc = [NSClassFromString(@"LSWebViewController") new];
    [vc setValue:urlString forKey:@"urlString"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((self.type == 3 || self.type == 4) && [self.user_id isEqualToString:ShareAppManager.loginUser.user_id]) {
        return UITableViewCellEditingStyleDelete;
    }else {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    UITableViewRowAction *update = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"修改" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        @strongify(self)
        LSCelebrityModel *model = self.dataSource[indexPath.row];
        
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSCelebrity"];
        [vc setValue:[NSString stringWithFormat:@"%d",model.id] forKey:@"s_id"];
        [vc setValue:[NSString stringWithFormat:@"%d",self.type] forKey:@"type"];
        [vc setValue:model forKey:@"model"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        @strongify(self)
        LSCelebrityModel *model = self.dataSource[indexPath.row];
        
        NSUInteger row = [self.dataSource indexOfObject:model];
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        //同步数据
        [self.dataSource removeObject:model];
        [self deleteModel:model];
        
        //刷新表格
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
    }];
    
    delete.backgroundColor = [UIColor redColor];
    update.backgroundColor = [UIColor lightGrayColor];
    return @[delete,update];
}

- (void)deleteModel:(LSCelebrityModel *)model {

    [LSKeyWindow showLoading];
    [LSLinkInApplyModel linkInCelebrityDeleteWithC_id:[NSString stringWithFormat:@"%d",model.id] type:self.type success:^{
        [LSKeyWindow hideHUDAnimated:YES];
    } failure:^(NSError *error) {
        [LSKeyWindow hideHUDAnimated:YES];
    }];
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

@implementation LSCelebrityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [UIImageView new];
        self.iconImage = iconView;
        iconView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(15);
            make.width.height.offset(150);
        }];
        
        UILabel *nameLabel = [UILabel new];
        nameLabel.text = @"鸠摩智";
        nameLabel.font = [UIFont boldSystemFontOfSize:16];
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.mas_right).offset(20);
            make.top.equalTo(iconView).offset(4);
        }];
        
        UILabel *ageLabel = [UILabel new];
        ageLabel.text = @"";
        ageLabel.font = SYSTEMFONT(16);
        [self addSubview:ageLabel];
        self.ageLabel = ageLabel;
        [ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.mas_right).offset(10);
            make.centerY.equalTo(nameLabel);
        }];
        
        UILabel *detailLabel = [UILabel new];
        detailLabel.text = @"周二（2月14日）美联储主席耶伦在特朗普就任总统后首次在国会发表半年度货币政策证词，明确表示未来加息的可能性，美元震荡走高，主要非美货币小幅承压。但在中国央行积极稳健干预之下，人民币中间价依旧逆势走强。周二发布的强势的中国CPI和PPI数据，也对人民币汇价起到支撑作用。";
        detailLabel.numberOfLines = 0;
        detailLabel.font = SYSTEMFONT(15);
        detailLabel.textColor = [UIColor lightGrayColor];
        self.detailLabel = detailLabel;
        [self addSubview:detailLabel];
        [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel);
            make.top.equalTo(nameLabel.mas_bottom).offset(12);
            make.bottom.equalTo(iconView.mas_bottom);
            make.right.equalTo(self).offset(-15);
        }];
        
    }
    return self;
}

-(void)setCelebrityModel:(LSCelebrityModel *)celebrityModel{

    _celebrityModel = celebrityModel;
    
    [self.iconImage setImageWithURL:[NSURL URLWithString:celebrityModel.photo] placeholder:timeLineBigPlaceholderName];
    
    self.nameLabel.text = celebrityModel.name;
    self.detailLabel.text = celebrityModel.desc;
    
}

- (void)setDynamicModel:(LSDynamicModel *)dynamicModel {

    _dynamicModel = dynamicModel;
    [self.iconImage setImageWithURL:[NSURL URLWithString:dynamicModel.pics[0]] placeholder:timeLineBigPlaceholderName];
    
    self.nameLabel.text = dynamicModel.title;
    self.detailLabel.text = dynamicModel.content;
}

@end

@implementation LSCelebrityModel

+(void)celebrityWithlistToken:(NSString *)access_token
                    school_id:(int)school_id
                         type:(int)type
                      success:(void (^)(NSArray * list))success
                      failure:(void (^)(NSError *))failure{
    
    NSString * celebrityPath = type == 1?kCelebrityPath:type == 2 ? khCelebrityPath : type == 3 ? kcofcCelebrityPath : kclanCelebrityPath;
    NSString * parameter = type == 3 ? @"cofc_id" : type == 4 ? @"clan_id" : @"id";
    NSString *path = [NSString stringWithFormat:@"%@%@?%@=%d",kBaseUrl,celebrityPath,parameter,school_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        for (NSDictionary *dic in model.result) {
            LSCelebrityModel * celModel = [LSCelebrityModel modelWithJSON:dic];
            [arr addObject:celModel];
        }
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
