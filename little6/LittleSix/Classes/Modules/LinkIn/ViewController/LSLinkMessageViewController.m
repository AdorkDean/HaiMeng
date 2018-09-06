//
//  LSLinkMessageViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkMessageViewController.h"
#import "LSLinkMessageModel.h"
#import "LSLinkInMessageDetailsViewController.h"
#import "NSString+Util.h"

static NSString *const reuse_id = @"LSLinkMessageCell";

@interface LSLinkMessageViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

@property (retain,nonatomic) NSMutableArray * dataArray;

@end

@implementation LSLinkMessageViewController

- (NSMutableArray *)dataArray{

    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的消息";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self createTableView];
    [self initDataSource];
}

- (void)initDataSource{

    [LSLinkMessageModel messageLinkWithlistToken:ShareAppManager.loginUser.access_token page:0 size:20 success:^(NSArray *array) {
        
        [self.dataArray removeAllObjects];
        
        [self.dataArray addObjectsFromArray:array];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSLinkMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    
    LSLinkMessageModel * messgae = self.dataArray[indexPath.row];
    cell.messageModel = messgae;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LSLinkMessageModel * messgae = self.dataArray[indexPath.row];
    LSLinkInMessageDetailsViewController * linkMessageVc = [LSLinkInMessageDetailsViewController new];
    linkMessageVc.feed_id = [NSString stringWithFormat:@"%d",messgae.feed_id];
    [self.navigationController pushViewController:linkMessageVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    LSLinkMessageModel *model = self.dataArray[indexPath.row];
    return 60+[NSString countingSize:model.msg_content fontSize:14 width:kScreenWidth-140].height;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        
        LSLinkMessageModel *model = self.dataArray[indexPath.row];
        
        NSUInteger row = [self.dataArray indexOfObject:model];
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        //同步数据
        [self.dataArray removeObject:model];
        [self deleteDataSource:model];
        //刷新表格
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
    }];
    
    delete.backgroundColor = [UIColor redColor];
    
    return @[delete];
}

- (void)deleteDataSource:(LSLinkMessageModel *)model{

    [LSLinkMessageModel deleteOneMessageLinkWithlistToken:ShareAppManager.loginUser.access_token msg_id:model.msg_id success:^{
        
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Getter & Setter
- (void)createTableView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView = tableView;
    
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerClass:[LSLinkMessageCell class] forCellReuseIdentifier:reuse_id];
    [self.view addSubview:tableView];
    tableView.tableFooterView = [UIView new];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 60, 30);
    [rightButton setTitle:@"清空" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(cleanListClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)cleanListClick:(UIButton *)sender{

    [LSLinkMessageModel cleanListMessageLinkWithlistToken:ShareAppManager.loginUser.access_token success:^{
        
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
    
}

@end

@interface LSLinkMessageCell ()

@end

@implementation LSLinkMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [UIImageView new];
        self.iconImage = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.offset(47);
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self).offset(10);
        }];
        
        UILabel *nickLabel = [UILabel new];
        nickLabel.text = @"潘金莲";
        self.nameLabel = nickLabel;
        nickLabel.font = SYSTEMFONT(14);
        nickLabel.textColor = HEXRGB(0x60739B);
        [self addSubview:nickLabel];
        [nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.mas_right).offset(10);
            make.right.equalTo(self.mas_right).offset(-80);
            make.top.equalTo(self).offset(13);
        }];
        
        UIImageView *imageView = [UIImageView new];
        self.photoView = imageView;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.height.offset(60);
            make.right.equalTo(self).offset(-10);
        }];
        
        UILabel *tipsLabel = [UILabel new];
        tipsLabel.font = SYSTEMFONT(14);
        tipsLabel.text = @"回复了你";
        tipsLabel.numberOfLines = 0;
        self.tipsLabel = tipsLabel;
        [self addSubview:tipsLabel];
        [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nickLabel);
            make.right.equalTo(imageView.mas_left).offset(-5);
            make.top.equalTo(nickLabel.mas_bottom).offset(4);
        }];
        
        UILabel *dateTimeLabel = [UILabel new];
        dateTimeLabel.font = SYSTEMFONT(12);
        dateTimeLabel.textColor = HEXRGB(0x737373);
        dateTimeLabel.text = @"2016年12月31日";
        self.dateTimeLabel = dateTimeLabel;
        [self addSubview:dateTimeLabel];
        [dateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tipsLabel);
            make.top.equalTo(tipsLabel.mas_bottom).offset(4);
        }];
        
    }
    return self;
}

- (void)setMessageModel:(LSLinkMessageModel *)messageModel{

    _messageModel = messageModel;
    
    [self.iconImage setImageWithURL:[NSURL URLWithString:messageModel.avatar] placeholder:timeLineSmallPlaceholderName];
    self.nameLabel.text = messageModel.user_name;
    self.dateTimeLabel.text = messageModel.add_time;
    [self.photoView setImageWithURL:[NSURL URLWithString:messageModel.feed_file] placeholder:timeLineSmallPlaceholderName];
    self.tipsLabel.text = messageModel.msg_content;
}

@end
