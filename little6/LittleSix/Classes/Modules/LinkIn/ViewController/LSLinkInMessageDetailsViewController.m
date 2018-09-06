//
//  LSLinkInMessageDetailsViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/22.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkInMessageDetailsViewController.h"
#import "LSLinkInDateilSchoolCell.h"
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "LSMyLinkCenterViewController.h"
#import "UIView+SDAutoLayout.h"
#import "LSLinkInCellModel.h"
#import "LSAlbumOperation.h"
#import "LSSendMessageView.h"
#import "LSPostNewsModel.h"
#import "UIView+HUD.h"
#import "LSPlayerVideoView.h"

static NSString *const reuse_id = @"SchoolCell";

@interface LSLinkInMessageDetailsViewController ()<UITableViewDelegate,UITableViewDataSource,LSLinkInDateilSchoolCellDelegate,LSSendMessageViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray * dataSource;
@property (nonatomic, strong) LSAlbumOperation *operationView;
@property (nonatomic, strong) LSSendMessageView *sendMessageView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) int repley;

@end

@implementation LSLinkInMessageDetailsViewController

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = bgColor;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    [self _initDataSource];
}

- (void)_initDataSource {

    [LSLinkInCellModel linkInMessageDetails:self.feed_id success:^(LSLinkInCellModel *model) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObject:model];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self.view showAlertWithTitle:@"温馨提示" message:@"帖子不存在" cancelAction:^{
            
        } doneAction:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

#pragma mark -- 发送消息的代理事件
- (void)didSendMessage:(NSString *)message albumInputView:(LSSendMessageView *)sendMessageView andPid:(int)pid {
    
    [self.sendMessageView removeFromSuperview];
    if (self.selectedIndexPath && self.selectedIndexPath.row < self.dataSource.count) {
        
        LSLinkInCellModel * cellModel = self.dataSource[self.selectedIndexPath.row];
        
        [LSPostNewsModel commentsLinkWithlistToken:ShareAppManager.loginUser.access_token feed_id:cellModel.feed_id uid_to:self.repley content:message pid:pid success:^{
            
            [self _initDataSource];
            [sendMessageView finishSendMessage];
        } failure:^(NSError *error) {
            [sendMessageView finishSendMessage];
        }];
        
        [sendMessageView finishSendMessage];
    }
}

#pragma mark - Getter & Setter
- (UITableView *)tableView {
    
    if (!_tableView) {
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView = tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[LSLinkInDateilSchoolCell class] forCellReuseIdentifier:reuse_id];
        tableView.tableFooterView = [UIView new];
        
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id model = self.dataSource[indexPath.row];
    return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[LSLinkInDateilSchoolCell class] contentViewWidth:[self cellContentViewWith]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10;
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

- (void)addLike:(int)type {
    
    if (self.selectedIndexPath && self.selectedIndexPath.row < self.dataSource.count) {
        LSLinkInCellModel * cellModel = self.dataSource[self.selectedIndexPath.row];
        [LSPostNewsModel praiseLinkWithlistToken:ShareAppManager.loginUser.access_token feed_id:cellModel.feed_id type:type success:^{
            
            [self _initDataSource];
            
        } failure:^(NSError *error) {
            [self.view showError:@"服务器异常" hideAfterDelay:1.5];
        }];
    }
}

- (void)deleteNew:(LSLinkInCellModel *)model {
    
    [LSPostNewsModel delectLinkWithlistToken:ShareAppManager.loginUser.access_token feed_id:model.feed_id success:^{
        
        [self _initDataSource];
        
    } failure:^(NSError *error) {
        [self.view showError:@"服务器异常" hideAfterDelay:1.5];
    }];
}

#define cell 的代理事件
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
    
    [LSPostNewsModel delectCommentsWithlistToken:ShareAppManager.loginUser.access_token comm_id:model.comm_id success:^{
        
        [self _initDataSource];
        
    } failure:^(NSError *error) {
        [self.view showError:@"服务器异常" hideAfterDelay:1.5];
    }];
}

//跳转人脉中心代理事件
-(void)didLinkinGoWithModel:(LSLinkInCellModel *)linkModel {
    
    LSMyLinkCenterViewController * myLinkVc = [LSMyLinkCenterViewController new];
    myLinkVc.user_id = linkModel.user_id;
    myLinkVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myLinkVc animated:YES];
}

//点击用户链接
- (void)didClickLink:(NSString *)user_id WithUserName:(NSString *)user_name andModel:(LSLinkInCellCommentItemModel *)model {
    
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
    CGRect targetRect = CGRectMake(CGRectGetMinX(sender.frame), origin_Y, CGRectGetWidth(sender.bounds)+60, CGRectGetHeight(sender.bounds)+20);
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
    
    [self deleteNew:model];
    
}

//点击赞事件
- (void)didClickPraise:(LSLinkInCellLikeItemModel *)model {
    
    LSMyLinkCenterViewController * myLinkVc = [LSMyLinkCenterViewController new];
    myLinkVc.user_id = model.user_id;
    myLinkVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myLinkVc animated:YES];
}

//点击播放视频
- (void)didClickPlayVideo:(LSLinkInFileModel *)lFileModel {
    
    NSURL * url = [NSURL URLWithString:lFileModel.file_thumb];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage * image = [UIImage imageWithData:data];
    
    UIViewController * vc = [NSClassFromString(@"LSVideoPlayerViewController") new];
    [vc setValue:[NSURL URLWithString:lFileModel.file_url] forKey:@"playURL"];
    [vc setValue:image forKey:@"coverImage"];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
