//
//  LSMyLinkCenterViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMyLinkCenterViewController.h"
#import "PopoverView.h"
#import "UIView+SDAutoLayout.h"
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "LSLinkCompleteInfoViewController.h"
#import "LSLinkInDateilSchoolCell.h"
#import "LSAlbumOperation.h"
#import "LSLinkInCellModel.h"
#import "LSLinkInCenterHeadeViewr.h"
#import "LSLinkMessageViewController.h"
#import "LSPostNewsModel.h"
#import "LSSendMessageView.h"
#import <YYKit/YYKit.h>
#import "UIView+HUD.h"
#import "LSPlayerVideoView.h"
#import "MJRefresh.h"
#import "LSContactModel.h"
#import "LSUMengHelper.h"
#import "LSLinkInPopView.h"
#import "ComfirmView.h"
#import "UIAlertController+LSAlertController.h"


static NSString *const reuse_id = @"LSLinkInDateilSchoolCell";

@interface LSMyLinkCenterViewController ()<UITableViewDelegate,UITableViewDataSource,LSSendMessageViewDelegate,LSLinkInDateilSchoolCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LSAlbumOperation *operationView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL isBool;
@property (nonatomic, strong) UIView * clearView;
@property (nonatomic, retain) UIView *navView;
@property (nonatomic, retain) NSMutableArray * dataSource;
@property (nonatomic, strong) LSSendMessageView *sendMessageView;
@property (nonatomic, assign) int repley;

@property (nonatomic, retain) LSLinkInCenterHeadeViewr *headerView;
@property (nonatomic, retain) LSLinkInMessageButton *messageBtn;
@property (nonatomic, assign) int page;

@property (nonatomic, assign) BOOL isMyLinkIn;
@property (nonatomic, strong) UIButton *rightAddButton;
@property (nonatomic, strong) LSFriendsProfileModel *friendmodel;

@end

@implementation LSMyLinkCenterViewController

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view showLoading];
    
    [self createTableView];
    
    [self naviBarConfig];
    [self initDataSources];
    MJRefreshNormalHeader * gifHeadView = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(initDataSources)];
    
    self.tableView.mj_header = gifHeadView;
    gifHeadView.lastUpdatedTimeLabel.hidden = YES;
    gifHeadView.stateLabel.hidden = YES;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshTableFoot)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //导航条透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self getFriends];
    [self hasMessage];
    __weak typeof(self) weakSelf = self;
    [self.headerView setCompleteClick:^{
        
        LSLinkCompleteInfoViewController * completeVc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSLinkCompleteInfo"];
        [weakSelf.navigationController pushViewController:completeVc animated:YES];
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //导航条透明
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:kMainColor] forBarMetrics:UIBarMetricsDefault];
}

- (void)initDataSources {
    
    self.page = 0;
    [LSLinkInCellModel linkInCenterWithlistToken:ShareAppManager.loginUser.access_token user_id:self.user_id page:self.page size:10 success:^(NSArray *array) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSError *error) {
        
        [self.view hideHUDAnimated:YES];
        [self.view showError:@"没有更多数据" hideAfterDelay:1.5];
        [self.tableView.mj_header endRefreshing];
        
    }];
}

- (void)hasMessage {

    [LSLinkInCellModel linkInMessageCountSuccess:^(LSLinkInCellModel *model) {
        if (![model.count isEqualToString:@"0"]) {
            self.messageBtn.hasNewMessage = YES;
        }else {
            self.messageBtn.hasNewMessage = NO;
        }
    } failure:nil];
}

- (void)getFriends {
    
    [LSFriendsProfileModel getFriendsProfileToken:ShareAppManager.loginUser.access_token user_id:self.user_id success:^(LSFriendsProfileModel *model) {
        
        self.friendmodel = model;
        [self.headerView.icomImage setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:timeLineSmallPlaceholderName];
        self.headerView.nameLabel.text = model.user_name;
        self.headerView.suTitleLabel.text = [NSString stringWithFormat:@"%@ %@",model.district_str,model.school];
        self.headerView.nextBtn.hidden = [model.user_id isEqualToString: ShareAppManager.loginUser.user_id] ? NO:YES;
        
        NSURL * url = [NSURL URLWithString:model.avatar];
        UIImageView * imageView = [UIImageView new];
        [imageView setImageWithURL:url placeholder:timeLineBigPlaceholderName];
        UIImage *image = [[YYImageCache sharedCache] getImageForKey:url.absoluteString];
        UIImage * blurImage = [image imageByBlurSoft];
        self.headerView.headerImage.image = blurImage;
        
    } failure:^(NSError *error) {
        [self.view showError:@"服务器异常" hideAfterDelay:1.5];
    }];
}

- (void)refreshTableFoot {

    self.page ++;
    [LSLinkInCellModel linkInCenterWithlistToken:ShareAppManager.loginUser.access_token user_id:self.user_id page:self.page size:10 success:^(NSArray *array) {
        
        [self.dataSource addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
        [self.tableView.mj_footer endRefreshing];
        
    } failure:^(NSError *error) {
        
        [self.view hideHUDAnimated:YES];
        [self.tableView.mj_footer endRefreshing];
        
    }];
}

#pragma mark -- 发送消息的代理事件
- (void)didSendMessage:(NSString *)message albumInputView:(LSSendMessageView *)sendMessageView andPid:(int)pid {
    
    if (self.selectedIndexPath && self.selectedIndexPath.row < self.dataSource.count) {
        
        LSLinkInCellModel * cellModel = self.dataSource[self.selectedIndexPath.row];
        
        [LSPostNewsModel commentsLinkWithlistToken:ShareAppManager.loginUser.access_token feed_id:cellModel.feed_id uid_to:self.repley content:message pid:pid success:^{
            
            [self initDataSources];
            [sendMessageView finishSendMessage];
            
        } failure:^(NSError *error) {
            
            [self.view showError:@"服务器异常" hideAfterDelay:1.5];
            [sendMessageView finishSendMessage];
            
        }];
        
        [sendMessageView finishSendMessage];
    }
}

- (void)naviBarConfig {
    
    if (self.isMyLinkIn) {
        LSLinkInMessageButton *messageButton = [LSLinkInMessageButton buttonWithType:UIButtonTypeCustom];
        [messageButton setImage:[UIImage imageNamed:@"linkin_news"] forState:UIControlStateNormal];
        [messageButton setTitle:@"消息" forState:UIControlStateNormal];
        messageButton.titleLabel.font = SYSTEMFONT(14);
        messageButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        messageButton.size = CGSizeMake(80, 30);
        self.messageBtn = messageButton;
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:messageButton];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem.width = -20;
        self.navigationItem.rightBarButtonItems = @[spaceItem,rightItem];
        @weakify(self)
        [[messageButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIButton * _Nullable button) {
            @strongify(self)

            [self messageBtnClick:button];
        }];
    }
    else {
        UIButton *naviButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightAddButton = naviButton;
        ViewRadius(naviButton, 2);
        naviButton.size = CGSizeMake(60, 25);
        naviButton.titleLabel.font = SYSTEMFONT(13);
        [naviButton setTitle:@"已添加" forState:UIControlStateSelected];
        [naviButton setTitle:@"+ 添加" forState:UIControlStateNormal];
        [naviButton setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
        [naviButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateSelected];
        
        @weakify(self)
        [[naviButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIButton * _Nullable button) {
            @strongify(self)

            [self rightBtnClick:button];
        }];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:naviButton];
    }
}

-(void)messageBtnClick:(UIButton *)sender {

    LSLinkMessageViewController * messVc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSLinkMessageViewController"];
    
    [self.navigationController pushViewController:messVc animated:YES];
}

-(void)rightBtnClick:(UIButton *)sender {
    @weakify(self)
    [UIAlertController alertTitle:@"温馨提示" mesasge:@"说一句成为好友的机率更大哦!" withOK:@"发送" preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *alertAction, UITextField *textField) {
        @strongify(self)
        [self sendButton:sender withTitle:textField.text];
    } cancleHandler:^(UIAlertAction *alert) {
        
    } viewController:self];
}

- (void)sendButton:(UIButton *)sender withTitle:(NSString *)title{

    NSString * titleStr = [title isEqualToString:@""] ? @"加一下呗":title;
    
    [LSContactModel sendFriendsWithlistToken:ShareAppManager.loginUser.access_token uid_to:[NSString stringWithFormat:@"%@",self.user_id] friend_note:titleStr success:^(LSContactModel* cmodel){
        
        if (!sender.selected) {
            sender.selected = YES;
            sender.enabled = YES;
            [self.view showSucceed:@"发送成功" hideAfterDelay:1.5];
        }
        [LSUMengHelper pushNotificationWithUsers:@[cmodel.uid_to] message:@"你有一条好友添加消息" extension:@{@"contactTpye":kAddContactPath,@"user_id":cmodel.uid_to} success:^{
            
        } failure:nil];
        
    } failure:^(NSError *error ) {
        [self.view showSucceed:@"发送失败" hideAfterDelay:1.5];
    }];
}

-(void)checkUserIsMyFriend {
    
    [LSContactModel isFriendsWithlistToken:ShareAppManager.loginUser.access_token uid_to:[NSString stringWithFormat:@"%@",self.user_id] success:^(LSContactModel *model) {
        self.rightAddButton.selected = model.is_friend;
    } failure:nil];
}

#pragma mark - Getter & Setter
- (void)createTableView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView = tableView;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[LSLinkInDateilSchoolCell class] forCellReuseIdentifier:reuse_id];
    
    tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.view);//
    }];
    
    self.headerView = [NSClassFromString(@"LSLinkInCenterHeadeViewr") new];
    self.headerView.frame = CGRectMake(0, 0, kScreenWidth, 250);
    tableView.tableHeaderView = self.headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSLinkInDateilSchoolCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.sd_tableView = tableView;
    cell.sd_indexPath = indexPath;
    
    LSLinkInCellModel * cellModel = self.dataSource[indexPath.row];
    cell.model = cellModel;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id model = self.dataSource[indexPath.row];
    return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[LSLinkInDateilSchoolCell class] contentViewWidth:[self cellContentViewWith]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.operationView dismiss];
}

- (CGFloat)cellContentViewWith {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait && [[UIDevice currentDevice].systemVersion floatValue] < 8) {
        width = [UIScreen mainScreen].bounds.size.height;
    }
    return width;
}

#pragma mark -- 点赞评论按钮
- (LSAlbumOperation *)operationView {
    if (!_operationView) {
        _operationView = [LSAlbumOperation initailzerAlbumOperationView];
        @weakify(self)
        _operationView.didSelectedOperationCompletion = ^(AlbumOperationType operationType,UIButton * sender) {
            @strongify(self)
            switch (operationType) {
                case XHAlbumOperationTypeLike:
                    if (sender.selected) {
                        [self addLike:1];
                    }else{
                        [self addLike:0];
                    }
                    break;
                case XHAlbumOperationTypeReply:
                {
                    self.sendMessageView = [[LSSendMessageView alloc] initWithFrame:CGRectZero];
                    self.sendMessageView.sendMessageDelegate = self;
                    [self.view addSubview:self.sendMessageView];
                    [self.sendMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.bottom.right.equalTo(self.view);
                        make.top.equalTo(self.mas_topLayoutGuide);
                    }];
                    [self.sendMessageView becomeFirstResponderForTextFieldPid:0];
                }
                    break;
                default:
                    break;
            }
        };
    }
    return _operationView;
}

-(void)addLike:(int)type {
    
    if (self.selectedIndexPath && self.selectedIndexPath.row < self.dataSource.count) {
        
        LSLinkInCellModel * cellModel = self.dataSource[self.selectedIndexPath.row];
        
        [LSPostNewsModel praiseLinkWithlistToken:ShareAppManager.loginUser.access_token feed_id:cellModel.feed_id type:type success:^{
            
            [self initDataSources];
            
        } failure:^(NSError *error) {
            [self.view showError:@"服务器异常" hideAfterDelay:1.5];
        }];
    }
}

-(void)deleteNew:(LSLinkInCellModel *)model {
    
    [LSPostNewsModel delectLinkWithlistToken:ShareAppManager.loginUser.access_token feed_id:model.feed_id success:^{
        
        [self initDataSources];
        
    } failure:^(NSError *error) {
        
        [self.view showError:@"服务器异常" hideAfterDelay:1.5];
    }];
}

#define mark cell 的代理事件
//点击评论
- (void)didAllClickWithModel:(LSLinkInCellCommentItemModel *)model andNSIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedIndexPath = indexPath;
    self.repley = model.uid_from;
    
    self.sendMessageView = [[LSSendMessageView alloc] initWithFrame:CGRectZero];
    self.sendMessageView.sendMessageDelegate = self;
    [self.view addSubview:self.sendMessageView];
    [self.sendMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    self.sendMessageView.placeholder.text = [NSString stringWithFormat:@"回复:%@",model.uid_from_name];
    [self.sendMessageView becomeFirstResponderForTextFieldPid:model.pid];
}

//长按评论
- (void)didLongAllPressWithModel:(LSLinkInCellCommentItemModel *)model andNSIndexPath:(NSIndexPath *)indexPath {
    
    [[LSLinkInPopView linkInMainView] showInView:self andArray:@[@[@"删除"],@[@"取消"]] withBlock:^(NSString *title) {
        
        if ([title isEqualToString:@"删除"]) {
            
            [LSPostNewsModel delectCommentsWithlistToken:ShareAppManager.loginUser.access_token comm_id:model.comm_id success:^{
                
                [self initDataSources];
                
            } failure:^(NSError *error) {
                
                [self.view showError:@"服务器异常" hideAfterDelay:1.5];
            }];
        }
    }];
}



//点击用户链接
- (void)didClickLink:(NSString *)user_id WithUserName:(NSString *)user_name andModel:(LSLinkInCellCommentItemModel *)model {
    
    if([self.friendmodel.user_id isEqualToString:user_id]) return;

    LSMyLinkCenterViewController * myLinkVc = [LSMyLinkCenterViewController new];
    
    myLinkVc.user_id = user_id;
    myLinkVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myLinkVc animated:YES];
}

//点击收起和全文
- (void)didMoreButtonClickedNSIndexPath:(NSIndexPath *)indexPath {
    
    LSLinkInCellModel *model = self.dataSource[indexPath.row];
    model.isOpening = !model.isOpening;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

//点赞，评论
- (void)didOperationButtonClickedNSIndexPath:(NSIndexPath *)indexPath andButton:(UIButton *)sender andModel:(LSLinkInCellModel *)model {
    
    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:indexPath];
    CGFloat origin_Y = rectInTableView.origin.y + sender.frame.origin.y;
    CGRect targetRect = CGRectMake(CGRectGetMinX(sender.frame), origin_Y, CGRectGetWidth(sender.bounds), CGRectGetHeight(sender.bounds));
    if (self.operationView.shouldShowed) {
        [self.operationView dismiss];
        return;
    }
    self.repley = 0;
    self.selectedIndexPath = indexPath;
    [self.operationView showAtView:self.tableView rect:targetRect andIs_praise:model.is_praise];
}

//删除帖子
- (void)delectClickLinkNSIndexPath:(NSIndexPath *)indexPath WithModel:(LSLinkInCellModel *)model {
    
    [self.view showAlertWithTitle:@"温馨提示" message:@"你确定要把这条帖子删除吗？" cancelAction:^{
        
    } doneAction:^{
        
        [self deleteNew:model];
    }];
    
}

//点击赞事件
- (void)didClickPraise:(LSLinkInCellLikeItemModel *)model {
    
    if([self.friendmodel.user_id isEqualToString:model.user_id]) return;
    LSMyLinkCenterViewController * myLinkVc = [LSMyLinkCenterViewController new];
    myLinkVc.user_id = model.user_id;
    myLinkVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myLinkVc animated:YES];
}

//点击播放视频
- (void)didClickPlayVideo:(LSLinkInFileModel *)lFileModel {
    
    NSURL * url = [NSURL URLWithString:lFileModel.file_thumb];
    UIImageView * imageView = [UIImageView new];
    [imageView setImageWithURL:url placeholder:timeLineBigPlaceholderName];
    UIImage *image = [[YYImageCache sharedCache] getImageForKey:url.absoluteString];
    
    UIViewController * vc = [NSClassFromString(@"LSVideoPlayerViewController") new];
    [vc setValue:[NSURL URLWithString:lFileModel.file_url] forKey:@"playURL"];
    [vc setValue:image forKey:@"coverImage"];
    [self presentViewController:vc animated:YES completion:nil];
}

//举报
-(void)didClickReport:(LSLinkInCellModel *)reportModel {
    
    ModelComfirm *item = [ModelComfirm comfirmModelWith:@"举报" titleColor:HEXRGB(0x666666) fontSize:16];
    ModelComfirm *cancelItem = [ModelComfirm comfirmModelWith:@"取消" titleColor:HEXRGB(0x666666) fontSize:16];
    //确认提示框
    [ComfirmView showInView:LSKeyWindow cancelItemWith:cancelItem dataSource:@[item] actionBlock:^(ComfirmView *view, NSInteger index) {
        
        UIViewController *reportVC = [NSClassFromString(@"WeiboReportViewController") new];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:reportVC];
        
        [self presentViewController:naviVC animated:YES completion:nil];
    }];
}

- (void)setUser_id:(NSString *)user_id {
    _user_id = user_id;
    self.headerView.userId = user_id;
    self.isMyLinkIn = [self.user_id isEqualToString:ShareAppManager.loginUser.user_id];
}

- (void)setIsMyLinkIn:(BOOL)isMyLinkIn {
    _isMyLinkIn = isMyLinkIn;
    
    if (isMyLinkIn) return;
    [self checkUserIsMyFriend];
}

@end

@implementation LSLinkInMessageButton

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIView *redView = [UIView new];
        self.redView = redView;
        redView.backgroundColor = [UIColor redColor];
        
        [self addSubview:redView];
        CGFloat viewH = 8;
        ViewRadius(redView, viewH*0.5);
        
        redView.hidden = YES;
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft|     UIRectCornerTopLeft cornerRadii:CGSizeMake(self.width, self.height)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = self.bounds;
    maskLayer.path = path.CGPath;
    self.layer.mask = maskLayer;
    
    self.redView.centerX = CGRectGetMaxX(self.imageView.frame);
    self.redView.centerY = self.imageView.top;
    self.redView.size = CGSizeMake(8, 8);
}

- (void)setHasNewMessage:(BOOL)hasNewMessage {
    _hasNewMessage = hasNewMessage;
    
    if (hasNewMessage) {
        self.redView.hidden = NO;
    }
    else {
        self.redView.hidden = YES;
    }
}

@end
