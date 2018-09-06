//
//  LSLinkSchoolViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkSchoolViewController.h"
#import "PopoverView.h"
#import "UIView+SDAutoLayout.h"
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "LSCaptureViewController.h"
#import "LSLinkInDateilSchoolCell.h"
#import "TZImageManager.h"
#import "LSAlbumOperation.h"
#import "LSLinkInCellModel.h"
#import "LSLinkInHeaderView.h"
#import "LSLinkMessageViewController.h"
#import "LSMyLinkCenterViewController.h"
#import "TZImagePickerController.h"
#import "UIViewController+Util.h"
#import "LSSendMessageView.h"
#import "LSPostNewsModel.h"
#import "UIView+HUD.h"
#import "LSPlayerVideoView.h"
#import "MJRefresh.h"
#import "LSTablePostViewController.h"
#import "LSLinkInPopView.h"
#import "ComfirmView.h"
#import "LSVideoPlayerViewController.h"


static NSString *const reuse_id = @"SchoolCell";

@interface LSLinkSchoolViewController () <UITableViewDelegate,UITableViewDataSource,LSSendMessageViewDelegate,LSLinkInDateilSchoolCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray * dataArray;
@property (nonatomic, strong) LSAlbumOperation *operationView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL isBool;
@property (nonatomic, strong) UIView * clearView;
@property (nonatomic, retain) NSMutableArray * dataSource;
@property (nonatomic, strong) LSSendMessageView *sendMessageView;
@property (nonatomic, strong) LSLinkInHeaderView *headerView ;
@property (nonatomic,strong) UIImage *videoCoverImage;
@property (nonatomic, assign) int repley;

@property (nonatomic, assign) int page;

@end

@implementation LSLinkSchoolViewController

-(NSMutableArray *)dataSource {

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.titleStr;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = bgColor;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    [self.view showLoading];
    [self naviBarConfig];
    [self initDataSources];
    
    MJRefreshNormalHeader * GifheadView = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTableHeader)];
    
    self.tableView.mj_header = GifheadView;
    GifheadView.lastUpdatedTimeLabel.hidden = YES;
    GifheadView.stateLabel.hidden = YES;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshTableFoot)];
    [self infoUserData];
    [self registerNotification];
}

- (void)registerNotification {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kLinkSchoolInfoNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self initDataSources];
    }];
}

- (void)infoUserData {

    [LSPostNewsModel schoolWithHomeAndId:[NSString stringWithFormat:@"%d",self.sh_id] type:self.type success:^(LSPostNewsModel *model) {
        
        [self.headerView.bgView setImageWithURL:[NSURL URLWithString:model.banner] placeholder:timeLineSmallPlaceholderName];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)refreshTableFoot {

    self.page ++;
    
    [LSLinkInCellModel linkInWithlistToken:ShareAppManager.loginUser.access_token id_value:self.type id_value_ext:self.sh_id page:self.page size:10 success:^(NSArray *array) {
        
        [self.dataSource addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
        [self.tableView.mj_footer endRefreshing];
        
    } failure:^(NSError *error) {
        [self.view hideHUDAnimated:YES];
        [self.tableView.mj_footer endRefreshing];
        
    }];

}

- (void)refreshTableHeader {

    self.page = 0;
    [LSLinkInCellModel linkInWithlistToken:ShareAppManager.loginUser.access_token id_value:self.type id_value_ext:self.sh_id page:self.page size:10 success:^(NSArray *array) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.view hideHUDAnimated:YES];
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark -- 发送消息的代理事件
- (void)didSendMessage:(NSString *)message albumInputView:(LSSendMessageView *)sendMessageView andPid:(int)pid {
    
    [self.sendMessageView removeFromSuperview];
    if (self.selectedIndexPath && self.selectedIndexPath.row < self.dataSource.count) {
        
        LSLinkInCellModel * cellModel = self.dataSource[self.selectedIndexPath.row];
        
        [LSPostNewsModel commentsLinkWithlistToken:ShareAppManager.loginUser.access_token feed_id:cellModel.feed_id uid_to:self.repley content:message pid:pid success:^{
            
            [self initDataSources];
            [sendMessageView finishSendMessage];
        } failure:^(NSError *error) {
            [sendMessageView finishSendMessage];
        }];
        
        [sendMessageView finishSendMessage];
    }
}

- (void)initDataSources {
    
    self.page = 0;
    [LSLinkInCellModel linkInWithlistToken:ShareAppManager.loginUser.access_token id_value:self.type id_value_ext:self.sh_id page:self.page size:10 success:^(NSArray *array) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.view hideHUDAnimated:YES];
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)naviBarConfig {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"navi_chat_more"] forState:UIControlStateNormal];
    [button sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        @strongify(self)
        PopoverView *popoverView = [PopoverView popoverView];
        popoverView.showShade = YES; // 显示阴影背景
        popoverView.style = PopoverViewStyleMain;
        [popoverView showToView:button withActions:[self menuActions]];
    }];
}

- (NSArray<PopoverAction *> *)menuActions {
    
    PopoverAction *action1 = [PopoverAction actionWithImage:nil title:@"发布消息" handler:^(PopoverAction *action) {

        [self pushToWriteLinkInVC];
    }];
    
    PopoverAction *action2 = [PopoverAction actionWithImage:nil title:@"我的消息" handler:^(PopoverAction *action) {

        LSLinkMessageViewController * messVc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSLinkMessageViewController"];
        [self.navigationController pushViewController:messVc animated:YES];
    }];
    
    return @[action1, action2];
}

- (void)pushToWriteLinkInVC {
    
    [[LSLinkInPopView linkInMainView] showInView:self andArray:@[@[@"照相",@"图文",@"视频",@"本地小视频"],@[@"取消"]] withBlock:^(NSString *title) {
        
        if ([title  isEqualToString: @"图文"]) {
            
            UIStoryboard *board = [UIStoryboard storyboardWithName: @"PostNews" bundle: nil];
            LSTablePostViewController *postVC = [board instantiateViewControllerWithIdentifier: @"LSTablePostViewController"];
            UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:postVC];
            [postVC setValue:@(self.sh_id) forKey:@"sh_id"];
            [postVC setValue:@(self.type) forKey:@"types"];
            [self presentViewController:naviVC animated:YES completion:nil];
            
        }else if ([title isEqualToString:@"视频"]){
            
            LSCaptureViewController * videoVC = [LSCaptureViewController new];
            [self presentViewController:videoVC animated:YES completion:nil];
            videoVC.capCompleteBlock =^(LSCaptureModel *model){
                
                UIStoryboard *board = [UIStoryboard storyboardWithName: @"PostNews" bundle: nil];
                LSTablePostViewController *postVC = [board instantiateViewControllerWithIdentifier: @"LSTablePostViewController"];
                UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:postVC];
                [postVC setPostType:LSPostTimeLineTypeVideo WithModel:model];
                [postVC setValue:@(self.sh_id) forKey:@"sh_id"];
                [postVC setValue:@(self.type) forKey:@"types"];
                [self presentViewController:naviVC animated:YES completion:nil];
            };
            
        }else if([title isEqualToString:@"照相"]){
            
            UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
            [imagePickerVC setSourceType:UIImagePickerControllerSourceTypeCamera];
            imagePickerVC.delegate = self;
            [self presentViewController:imagePickerVC animated:YES completion:nil];
        }else if ([title isEqualToString:@"本地小视频"]){
        
            TZImagePickerController *TZimagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
            TZimagePickerVc.isSelectOriginalPhoto = YES;
            TZimagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
            TZimagePickerVc.allowPickingVideo = YES;
            TZimagePickerVc.allowPickingImage = NO;
            TZimagePickerVc.allowPickingOriginalPhoto = NO;
            TZimagePickerVc.allowPickingGif = NO;
            @weakify(self)
            [TZimagePickerVc setDidFinishPickingVideoHandle:^(UIImage * coverImage, id asset) {
                self.videoCoverImage = coverImage;
                
                [[TZImageManager manager] getVideoWithAsset:asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
                    
                    AVAsset *currentPlayerAsset = playerItem.asset;
                    
                    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]){
                        kDISPATCH_MAIN_THREAD(^{
                            LFUITips *tips = [LFUITips showError:@"不支持视频格式" inView:LSKeyWindow hideAfterDelay:1];
                            [LSKeyWindow addSubview:tips];
                        });
                        return ;
                    }
                    NSURL *url = [(AVURLAsset *)currentPlayerAsset URL];
                    
                    NSFileManager* manager = [NSFileManager defaultManager];
                    
                    NSString *filePath = [self copyAssetToCaptureFolder:url withImage:coverImage];
                    
                    if ([manager fileExistsAtPath:filePath]){
                        
                        if ([[manager attributesOfItemAtPath:filePath error:nil] fileSize]>20*1024*1024) {
                            kDISPATCH_MAIN_THREAD(^{
                                LFUITips *tips = [LFUITips showError:@"视频大小超过20M" inView:LSKeyWindow hideAfterDelay:1];
                                [LSKeyWindow addSubview:tips];
                            });
                            return;
                        }
                    }
                    
                    LSCaptureModel *model = [LSCaptureModel captureModelWithName:[filePath lastPathComponent]];
                    
                    kDISPATCH_MAIN_THREAD(^{
                        UIStoryboard *board = [UIStoryboard storyboardWithName: @"PostNews" bundle: nil];
                        LSTablePostViewController *postVC = [board instantiateViewControllerWithIdentifier: @"LSTablePostViewController"];
                        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:postVC];
                        [postVC setPostType:LSPostTimeLineTypeVideo WithModel:model];
                        @strongify(self)
                        [postVC setValue:@(self.sh_id) forKey:@"sh_id"];
                        [postVC setValue:@(self.type) forKey:@"types"];
                        [self presentViewController:naviVC animated:YES completion:nil];
                    })
                }];
                
            }];
            [self presentViewController:TZimagePickerVc animated:YES completion:nil];
        }
    }];
    
}

- (NSString *)copyAssetToCaptureFolder:(NSURL *)sourceUrl withImage:(UIImage *)image{
    
    //沙盒中没有目录则新创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:kCaptureFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:kCaptureFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString * fileStr =[sourceUrl.absoluteString lastPathComponent];
    NSString * newFileStr;
    NSString * formatStr ;
    if ([fileStr containsString:@".mov" ]||[fileStr containsString:@".MOV"]) {
        newFileStr =[fileStr stringByReplacingOccurrencesOfString:@".MOV" withString:@".mov"];;
        formatStr = @".mov";
    }
    else if ([fileStr containsString:@".mp4"]||[fileStr containsString:@".MP4"]) {
        newFileStr = [fileStr stringByReplacingOccurrencesOfString:@".MP4" withString:@".mp4"];
        formatStr = @".mp4";
    }
    
    NSString *destinationPath = [kCaptureFolder stringByAppendingPathComponent:newFileStr];
    
    NSError	*error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:destinationPath];
    if (!result) {
        [fileManager copyItemAtURL:sourceUrl toURL:[NSURL fileURLWithPath:destinationPath] error:&error];
    }
    
    
    NSData * imageData = UIImageJPEGRepresentation(image, 1);
    NSString * imagePath = [destinationPath stringByReplacingOccurrencesOfString:formatStr withString:@".jpg"];
    if ([imageData writeToFile:imagePath atomically:YES]) {
        NSLog(@"写入成功");
    };
    
    return destinationPath;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIStoryboard *board = [UIStoryboard storyboardWithName: @"PostNews" bundle: nil];
    LSTablePostViewController *postVC = [board instantiateViewControllerWithIdentifier: @"LSTablePostViewController"];
    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:postVC];
    [postVC setValue:@(self.sh_id) forKey:@"sh_id"];
    [postVC setValue:@(self.type) forKey:@"types"];
    [postVC setPostType:LSPostTimeLineTypePhoto WithModel:image];
    [self presentViewController:naviVC animated:YES completion:nil];
}

#pragma mark - Action
- (void)menusButtonAction:(UIButton *)button {
    
    NSString *title = button.currentTitle;
    
    if ([title isEqualToString:@"简介"]) {
        NSString * urlString = self.type == 1 ? [NSString stringWithFormat:@"https://api.66boss.com/web/school?id=%d",self.sh_id]:[NSString stringWithFormat:@"https://api.66boss.com/web/hometown?id=%d",self.sh_id];
        UIViewController *vc = [NSClassFromString(@"LSWebViewController") new];
        [vc setValue:urlString forKey:@"urlString"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([title isEqualToString:@"名人"]) {
        UIViewController *vc = [NSClassFromString(@"LSCelebrityViewController") new];
        [vc setValue:@(self.sh_id) forKey:@"sh_id"];
        [vc setValue:@(self.type) forKey:@"type"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([title isEqualToString:@"社团"]||[title isEqualToString:@"商会"]) {
        UIViewController *vc = [NSClassFromString(@"LSLinkCommunityViewController") new];
        [vc setValue:@(self.sh_id) forKey:@"sh_id"];
        [vc setValue:@(self.type) forKey:@"type"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([title isEqualToString:@"动态"]) {

        UIViewController *vc = [NSClassFromString(@"LSDynamicViewController") new];
        [vc setValue:@(self.sh_id) forKey:@"sh_id"];
        [vc setValue:@(self.type) forKey:@"type"];
        [self.navigationController pushViewController:vc animated:YES];
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
        LSLinkInHeaderView *headerView = [NSClassFromString(@"LSLinkInHeaderView") new];
        headerView.frame = CGRectMake(0, 0, kScreenWidth, 220);
        tableView.tableHeaderView = headerView;
        self.headerView = headerView;
        headerView.type = self.type;
        @weakify(self)
        [headerView setBottomClick:^(UIButton *sender) {
            @strongify(self)
            [self menusButtonAction:sender];
        }];
    }
    return _tableView;
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

- (void)addLike:(int)type {

    if (self.selectedIndexPath && self.selectedIndexPath.row < self.dataSource.count) {
        LSLinkInCellModel * cellModel = self.dataSource[self.selectedIndexPath.row];
        [LSPostNewsModel praiseLinkWithlistToken:ShareAppManager.loginUser.access_token feed_id:cellModel.feed_id type:type success:^{
            
            [self initDataSources];
            
        } failure:^(NSError *error) {
            [self.view showError:@"服务器异常" hideAfterDelay:1.5];
        }];
    }
}

- (void)deleteNew:(LSLinkInCellModel *)model {

    [LSPostNewsModel delectLinkWithlistToken:ShareAppManager.loginUser.access_token feed_id:model.feed_id success:^{
        
        [self initDataSources];
        
    } failure:^(NSError *error) {
        [self.view showError:@"服务器异常" hideAfterDelay:1.5];
    }];
}

#pragma mark cell 的代理事件
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

    [self.view showAlertWithTitle:@"温馨提示" message:@"你确定要把这条帖子删除吗？" cancelAction:^{
        
    } doneAction:^{
        
        [self deleteNew:model];
    }];

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
    UIImageView * imageView = [UIImageView new];
    [imageView setImageWithURL:url placeholder:timeLineBigPlaceholderName];
    UIImage *image = [[YYImageCache sharedCache] getImageForKey:url.absoluteString];
    
    UIViewController * vc = [NSClassFromString(@"LSVideoPlayerViewController") new];
    [vc setValue:[NSURL URLWithString:lFileModel.file_url] forKey:@"playURL"];
    [vc setValue:image forKey:@"coverImage"];
    [self presentViewController:vc animated:YES completion:nil];
}

//长按内容
-(void)didLongAllPresscontentWithModel:(LSLinkInCellModel *)model {
    
    ModelComfirm *item1 = [ModelComfirm comfirmModelWith:@"复制" titleColor:HEXRGB(0x666666) fontSize:16];
    
    ModelComfirm *cancelItem = [ModelComfirm comfirmModelWith:@"取消" titleColor:[UIColor redColor] fontSize:16];
    
    //在窗口显示
    [ComfirmView
     showInView:[UIApplication sharedApplication].keyWindow
     cancelItemWith:cancelItem
     dataSource:@[item1]
     actionBlock:^(ComfirmView *view, NSInteger index) {
         UIPasteboard *pboard = [UIPasteboard generalPasteboard];
         pboard.string = model.content;
         [LSKeyWindow showSucceed:@"复制成功" hideAfterDelay:1.5];
     }];
    
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
