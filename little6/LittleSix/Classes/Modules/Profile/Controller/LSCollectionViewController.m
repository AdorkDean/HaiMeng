//
//  LSCollectionViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/4/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSCollectionViewController.h"
#import "LSCollectionDetailViewController.h"
#import "YYPhotoGroupView.h"
#import "LSPlayerVideoView.h"
#import "UIView+HUD.h"
#import "NSString+Util.h"
#import "LSBaseModel.h"
#import "ConstKeys.h"
#import "MJRefresh.h"

static NSString * textReuse_id = @"LSCollectTextCell";
static NSString * imageReuse_id = @"LSCollectImageCell";
static NSString * videoReuse_id = @"LSCollectVideoCell";

@interface LSCollectionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSMutableArray * dataSource;
@property (assign,nonatomic) int page;

@end

@implementation LSCollectionViewController

- (NSMutableArray *)dataSource {

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"收藏";
    self.page = 1;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self createTableView];
    [self requestData];
    
    MJRefreshNormalHeader * gifheadView = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTableHeader)];
    
    self.tableView.mj_header = gifheadView;
    gifheadView.lastUpdatedTimeLabel.hidden = YES;
    gifheadView.stateLabel.hidden = YES;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshTableFoot)];
}

- (void)refreshTableHeader {

    self.page = 1;
    [self requestData];
}

- (void)refreshTableFoot {

    self.page ++;
    [LSKeyWindow showLoading];
    [LSCollectModel userCollectListWithPage:self.page success:^(NSArray *list) {
        
        [self.dataSource addObjectsFromArray:list];
        [self.tableView reloadData];
        [LSKeyWindow hideHUDAnimated:YES];
        [self.tableView.mj_footer endRefreshing];
       
    } failure:^(NSError *error) {
        [LSKeyWindow hideHUDAnimated:YES];
        [self.tableView.mj_footer endRefreshing];
        
    }];
}

- (void)requestData {

    [LSKeyWindow showLoading];
    [LSCollectModel userCollectListWithPage:self.page success:^(NSArray *list) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:list];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    LSCollectModel * model = self.dataSource[indexPath.row];
    if (model.type == 0) {
        return [NSString countingSize:model.text fontSize:15 width:kScreenWidth-80].height+60 > 150 ? 150 : [NSString countingSize:model.text fontSize:15 width:kScreenWidth-80].height+60;
    }else {
    
        return 180;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LSCollectModel * model = self.dataSource[indexPath.row];
    NSString * cell_reuse_id;
    if (model.type == 0) {
        cell_reuse_id = textReuse_id;
    }else if (model.type == 1){
        cell_reuse_id = imageReuse_id;
    }else{
        cell_reuse_id = videoReuse_id;
    }
    
    LSCollectBaseCell * cell = [tableView dequeueReusableCellWithIdentifier:cell_reuse_id];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LSCollectModel * model = self.dataSource[indexPath.row];
    UIViewController *vc = [NSClassFromString(@"LSCollectionDetailViewController") new];
    [vc setValue:model forKey:@"model"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
   
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        @strongify(self)
        LSCollectModel * model = self.dataSource[indexPath.row];
        [LSCollectModel userDeleteCollectListWithFid:model.id success:^{
            
            [self requestData];
            [LSKeyWindow showSucceed:@"删除成功" hideAfterDelay:1];
            
        } failure:^(NSError *error) {
            [LSKeyWindow showError:@"删除失败" hideAfterDelay:1];
        }];
    }];
    
    delete.backgroundColor = [UIColor redColor];
    return @[delete];
}

#pragma mark - Getter & Setter
- (void)createTableView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView = tableView;

    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerClass:[LSCollectTextCell class] forCellReuseIdentifier:textReuse_id];
    [tableView registerClass:[LSCollectImageCell class] forCellReuseIdentifier:imageReuse_id];
    [tableView registerClass:[LSCollectVideoCell class] forCellReuseIdentifier:videoReuse_id];
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
}

@end

@implementation LSCollectBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView * iconView = [UIImageView new];
        self.iconView = iconView;
        iconView.image = [UIImage imageNamed:@"contact_group_chats"];
        iconView.layer.cornerRadius = 15;
        iconView.clipsToBounds = YES;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.left.equalTo(self).offset(10);
            make.width.height.offset(30);
        }];
        
        UILabel * timeLabel = [UILabel new];
        timeLabel.text = @"2017/04/21";
        timeLabel.textAlignment = UITextAlignmentRight;
        timeLabel.font = [UIFont systemFontOfSize:13];
        timeLabel.textColor = [UIColor lightGrayColor];
        self.timeLabel = timeLabel;
        [self addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self.mas_right).offset(-10);
            make.top.equalTo(self.mas_top).offset(15);
            make.width.offset(80);
        }];
        
        UILabel * nameLabel = [UILabel new];
        self.nameLabel = nameLabel;
        nameLabel.textColor = [UIColor lightGrayColor];
        nameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.mas_right).offset(10);
            make.top.equalTo(self.mas_top).offset(15);
            make.right.equalTo(timeLabel.mas_left).offset(-10);
        }];
        
    }
    return self;
}

#pragma mark - Getter & Setter
- (void)setModel:(LSCollectModel *)model {
    _model = model;
    
    [self.iconView setImageWithURL:[NSURL URLWithString:model.from_avatar] placeholder:timeLineSmallPlaceholderName];
    self.nameLabel.text = [model.group_name isEqualToString:@""]?model.from_name:model.group_name;
    self.timeLabel.text = model.add_time;
}

@end

@implementation LSCollectTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel * contentLabel = [UILabel new];
        contentLabel.numberOfLines = 0;
        self.contentLabel = contentLabel;
        contentLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(10);
            make.top.equalTo(self.iconView.mas_bottom).offset(5);
            make.right.equalTo(self.mas_right).offset(-10);
        }];
        
    }
    return self;
}

- (void)setModel:(LSCollectModel *)model {
    [super setModel:model];
    
    self.contentLabel.text = model.text;
}

- (void)setDmodel:(LSCollectModel *)dmodel{
    [super setModel:dmodel];
    
    self.contentLabel.text = dmodel.text;
}
@end

@implementation LSCollectImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView * bodyImage = [UIImageView new];
        self.bodyImage = bodyImage;
        [self addSubview:bodyImage];
        [bodyImage mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self.iconView.mas_bottom).offset(10);
            make.bottom.equalTo(self.self.mas_bottom).offset(-10);
        }];
    }
    return self;
}

- (void)setModel:(LSCollectModel *)model {
    [super setModel:model];
    
    [self.bodyImage setImageWithURL:[NSURL URLWithString:model.thum] placeholder:timeLineBigPlaceholderName];
}

- (void)setDmodel:(LSCollectModel *)dmodel{
    
    [super setModel:dmodel];
    
    UIImageView * imageView = [UIImageView new];
    NSURL * url = [NSURL URLWithString:dmodel.thum];
    [imageView setImageWithURL:url placeholder:timeLineBigPlaceholderName];
    
    UIImage *image = [[YYImageCache sharedCache] getImageForKey:url.absoluteString];
    self.bodyImage.mj_w = image.size.width;
    [self.bodyImage setImageWithURL:[NSURL URLWithString:dmodel.thum] placeholder:timeLineBigPlaceholderName];
    
}

@end

@implementation LSCollectVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView * bodyImage = [UIImageView new];
        self.bodyImage = bodyImage;
        [self addSubview:bodyImage];
        [bodyImage mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self.iconView.mas_bottom).offset(10);
            make.bottom.equalTo(self.self.mas_bottom).offset(-10);
        }];
        
        UIImageView * iconImage = [UIImageView new];
        iconImage.image = [UIImage imageNamed:@"play"];
        [bodyImage addSubview:iconImage];
        [iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.height.offset(50);
            make.center.equalTo(bodyImage);
        }];
    }
    return self;
}

- (void)setModel:(LSCollectModel *)model {
    [super setModel:model];
    
    [self.bodyImage setImageWithURL:[NSURL URLWithString:model.thum] placeholder:timeLineBigPlaceholderName];
}

- (void)setDmodel:(LSCollectModel *)dmodel{

    [super setModel:dmodel];
    
    UIImageView * imageView = [UIImageView new];
    NSURL * url = [NSURL URLWithString:dmodel.thum];
    [imageView setImageWithURL:url placeholder:timeLineBigPlaceholderName];
    
    UIImage *image = [[YYImageCache sharedCache] getImageForKey:url.absoluteString];
    self.bodyImage.mj_w = image.size.width;
    [self.bodyImage setImageWithURL:[NSURL URLWithString:dmodel.thum] placeholder:timeLineBigPlaceholderName];
    
}

@end

@implementation LSCollectModel

+(void)userCollectListWithPage:(int)page
                       success:(void (^)(NSArray * list))success
                       failure:(void (^)(NSError *))failure {
    
    NSString * size = @"10";
    NSString *path = [NSString stringWithFormat:@"%@%@?page=%d&size=%@",kBaseUrl,kFavoritesPath,page,size];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSArray * arr = [NSArray modelArrayWithClass:[LSCollectModel class] json:model.result];
        
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)userAddCollectListWithFromid:(int)fromid
                              gname:(NSString *)gname
                               thum:(NSString *)thum
                                url:(NSString *)url
                               type:(NSString *)type
                               text:(NSString *)text
                            success:(void (^)(LSCollectModel * model))success
                            failure:(void (^)(NSError *))failure {

    NSString *gnames = [gname stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *textStr = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *path = [NSString stringWithFormat:@"%@%@?fromid=%d&gname=%@&thum=%@&url=%@&type=%@&text=%@",kBaseUrl,kAddFavoritesPath,fromid,gnames,thum,url,type,textStr];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
    
        LSCollectModel * cmodel = [LSCollectModel modelWithJSON:model.result];
        !success?:success(cmodel);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];

}

+(void)userDeleteCollectListWithFid:(NSString *)fid
                            success:(void (^)())success
                            failure:(void (^)(NSError *))failure {

    NSString *path = [NSString stringWithFormat:@"%@%@?fid=%@",kBaseUrl,kDeleteFavoritesPath,fid];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

@end
