//
//  LSFuwaMessageViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaMessageViewController.h"
#import "LSFuwaMessageModel.h"
#import "UIView+HUD.h"

static NSString *const reuse_id = @"LSTimeLineTableViewCell";

@interface LSFuwaMessageViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;

@end

@implementation LSFuwaMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"消息";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadData];
}

- (void)loadData {
    
    [self.view showLoading:@"正在请求"];
    
    [LSFuwaMessageModel getFuwaMessageListSuccess:^(NSMutableArray *listArr) {
        
        [self.view hideHUDAnimated:YES];
        self.dataSource = listArr;
        [self.tableView reloadData];

    } failure:^(NSError *error) {
        [self.view showError:@"请求失败" hideAfterDelay:1.5];
    }];
}

- (void)rightItemAction {
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"清空" forState:UIControlStateNormal];
    sendButton.titleLabel.font = SYSTEMFONT(16);
    [sendButton sizeToFit];
    @weakify(self)
    [[sendButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        
        if (self.dataSource.count == 0) return;
        
        [self.view showAlertWithTitle:@"提示" message:@"你确定要清空所有消息吗？" cancelAction:nil doneAction:^{
            YYCache *messageCache = [[YYCache alloc] initWithName:kCacheFolder];
            self.dataSource = [NSMutableArray array];
            [messageCache setObject:self.dataSource forKey:kMessageKey];
            [self.tableView reloadData];
        }];
        
    }];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        _tableView = tableView;

        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        tableView.tableFooterView = [UIView new];
        
        [tableView registerClass:[LSFuwaMessageCell class] forCellReuseIdentifier:reuse_id];
        
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LSFuwaMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    LSFuwaMessageModel * model = self.dataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.model = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LSFuwaMessageModel * model = self.dataSource[indexPath.row];
    if (model.type.intValue != 1) return;
    

    UIViewController *vc = [NSClassFromString(@"LSWebViewController") new];
    [vc setValue:model.url forKey:@"urlString"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        YYCache *messageCache = [[YYCache alloc] initWithName:kCacheFolder];
        [messageCache setObject:self.dataSource forKey:kMessageKey];
        
    }
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    _dataSource = dataSource;
    
    if (dataSource.count == 0) return;
    [self rightItemAction];
}

@end

@interface LSFuwaMessageCell ()

@property (nonatomic,strong) UIImageView * iconView;
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UILabel * contentLabel;
@property (nonatomic,strong) UILabel * timeLabel;

@end


@implementation LSFuwaMessageCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setConstraints];
    }
    return self;
}

-(void)setConstraints{
    
    UIImageView * iconView = [UIImageView new];
    self.iconView = iconView;
    [self.contentView addSubview:iconView];
    
    UILabel * nameLabel = [UILabel new];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = HEXRGB(0x333333);
    [self.contentView addSubview:nameLabel];
    
    UILabel * contentLabel = [UILabel new];
    self.contentLabel = contentLabel;
    contentLabel.numberOfLines = 2;
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textColor = HEXRGB(0x999999);
    [self.contentView addSubview:contentLabel];
    
    UILabel * timeLabel = [UILabel new];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = HEXRGB(0x999999);
    [self.contentView addSubview:timeLabel];
    
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(48);
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(15);
    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconView);
        make.right.equalTo(self.contentView).offset(-15);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];

    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconView);
        make.left.equalTo(iconView.mas_right).offset(13);
        make.height.mas_equalTo(20);
        make.right.equalTo(timeLabel.mas_left).offset(10);
    }];
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameLabel);
        make.top.equalTo(nameLabel.mas_bottom).offset(5);
        make.right.equalTo(self.contentView).offset(-15);
//        make.height.mas_equalTo(20);
    }];
}



-(void)setModel:(LSFuwaMessageModel *)model{
    _model = model;
    [self.iconView setImageWithURL:[NSURL URLWithString:model.snap] placeholder:timeLineBigPlaceholderName];
    self.nameLabel.text = model.nick;
    self.contentLabel.text = model.content;
}

@end
