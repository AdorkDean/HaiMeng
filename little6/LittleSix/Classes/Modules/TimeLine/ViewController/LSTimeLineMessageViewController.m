//
//  LSTimeLineMessageViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTimeLineMessageViewController.h"
#import "LSTimeLineHomeDetailViewController.h"
#import "MJRefresh.h"
#import "LSTimeLineMsgModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "UIView+HUD.h"

static NSString *const reuse_id = @"LSTimeLineMsgTableViewCell";

@interface LSTimeLineMessageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) int page;
@end

@implementation LSTimeLineMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"消息";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [UIView new];
    self.dataSource = [NSMutableArray array];
    self.tableView.backgroundColor = [UIColor whiteColor];

    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"清空" forState:UIControlStateNormal];
    sendButton.titleLabel.font = SYSTEMFONT(16);
    [sendButton sizeToFit];
    @weakify(self)

    [[sendButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)

        [self deleteAllBtnClick];
    }];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
    
    MJRefreshGifHeader * GifheadView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTableHead)];
    
    self.tableView.mj_header = GifheadView;
    GifheadView.lastUpdatedTimeLabel.hidden = YES;
    GifheadView.stateLabel.hidden = YES;
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshTableFoot)];
    
    [self.tableView.mj_header beginRefreshing];
}





-(void)deleteAllBtnClick{
    
    [self.view showLoading];
    [LSTimeLineMsgModel deleteAllMsgSuccess:^{
        [self.view showSucceed:@"清空成功" hideAfterDelay:1];
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.view showError:@"清空失败" hideAfterDelay:1];
    }];
}

-(void)refreshTableHead{
    self.page = 0;
    [LSTimeLineMsgModel getMsgListWithPage:self.page Success:^(NSArray *modelArr) {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:modelArr];
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        

        [self.tableView.mj_header endRefreshing];
        


    }];
    
}


-(void)refreshTableFoot{
    self.page++;
    [LSTimeLineMsgModel getMsgListWithPage:self.page Success:^(NSArray *modelArr) {
        [self.dataSource addObjectsFromArray:modelArr];
        [self.tableView.mj_footer endRefreshing];

    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];

    }];
}

#pragma mark tableView
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView = tableView;
        [self.view addSubview:tableView];
        
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[LSTimeLineMsgTableViewCell class] forCellReuseIdentifier:reuse_id];
        
    }
    return _tableView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LSTimeLineMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    LSTimeLineMsgModel * model = self.dataSource[indexPath.row];
    cell.model =model;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSTimeLineMsgModel * model = self.dataSource[indexPath.row];
    LSTimeLineHomeDetailViewController *Vc = [LSTimeLineHomeDetailViewController new];
    Vc.feed_Id =model.feed_id;
    Vc.user_id = [NSString stringWithFormat:@"%i",model.user_id];
    [self.navigationController pushViewController:Vc animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return  78;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LSTimeLineMsgModel * model = self.dataSource[indexPath.row];

        [self.view showLoading];
        [LSTimeLineMsgModel deleteMsgWithMessageId:model.msg_id Success:^{
            
            [self.view showSucceed:@"删除成功" hideAfterDelay:1];
            [self.dataSource removeObjectAtIndex:indexPath.row];     
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } failure:^(NSError *error) {
            [self.view showError:@"删除失败" hideAfterDelay:1];
        }];


    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {

    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@interface LSTimeLineMsgTableViewCell ()
@property(nonatomic,strong) UIButton *iconBtn;
@property(nonatomic,strong) UILabel *nameLabel;
@property(nonatomic,strong) UILabel *contentLabel;
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UIImageView *contentImageView;

@end

@implementation LSTimeLineMsgTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeConstrains];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // Configure the view for the selected state
}

-(void)makeConstrains{
    self.iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.iconBtn];
    self.iconBtn.backgroundColor = [UIColor redColor];
    
    self.nameLabel = [UILabel new];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:self.nameLabel];
    self.nameLabel.textColor = HEXRGB(0x60739b);
    
    self.contentLabel = [UILabel new];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.contentLabel];
    self.contentLabel.textColor = [UIColor blackColor];
    
    self.timeLabel = [UILabel new];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.timeLabel];
    self.timeLabel.textColor =HEXRGB(0x737373);
    
    self.contentImageView = [UIImageView new];
    [self.contentView addSubview:self.contentImageView];
    self.contentImageView.backgroundColor = [UIColor orangeColor];
    
    [self.iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(7);
        make.left.equalTo(self.contentView).with.offset(10);
        make.width.height.mas_equalTo(47);
    }];
    
    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(10);
        make.right.equalTo(self.contentView).with.offset(-10);
        make.width.height.mas_equalTo(60);
        
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconBtn.mas_top).with.offset(5);
        make.left.equalTo(self.iconBtn.mas_right).with.offset(10);
        make.right.equalTo(self.contentImageView.mas_left).with.offset(-10);
        make.height.mas_equalTo(17);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(5);
        make.left.right.height.equalTo(self.nameLabel);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(5);
        make.left.right.height.equalTo(self.contentLabel);
    }];
}


-(void)setModel:(LSTimeLineMsgModel *)model{
    _model = model;
    [self.iconBtn setImageWithURL:[NSURL URLWithString:model.avatar] forState:UIControlStateNormal placeholder:timeLineSmallPlaceholderName];
    self.nameLabel.text = model.user_name;
    self.contentLabel.text = model.msg_content;
    self.timeLabel.text = model.add_time;
    [self.contentImageView setImageWithURL:[NSURL URLWithString:model.feed_file] placeholder:timeLineBigPlaceholderName];
}
@end
