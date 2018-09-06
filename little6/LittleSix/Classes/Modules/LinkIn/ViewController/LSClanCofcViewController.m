//
//  LSClanCofcViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/4/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSClanCofcViewController.h"
#import "PopoverView.h"
#import "UIView+SDAutoLayout.h"
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "LSCaptureViewController.h"
#import "LSLinkInDateilSchoolCell.h"
#import "LSAlbumOperation.h"
#import "LSLinkInCellModel.h"
#import "LSLinkMessageViewController.h"
#import "LSMyLinkCenterViewController.h"
#import "UIViewController+Util.h"
#import "LSSendMessageView.h"
#import "ImagePickerManager.h"
#import "LSPostNewsModel.h"
#import "UIView+HUD.h"
#import "LSPlayerVideoView.h"
#import "MJRefresh.h"
#import "LSTablePostViewController.h"
#import "LSLinkInPopView.h"
#import "TZImageManager.h"
#import "TZImagePickerController.h"
#import "LSLinkInApplyModel.h"
#import "ComfirmView.h"

static NSString *const reuse_id = @"SchoolCell";

@interface LSClanCofcViewController () <UITableViewDelegate,UITableViewDataSource,LSSendMessageViewDelegate,LSLinkInDateilSchoolCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray * dataArray;
@property (nonatomic, strong) LSAlbumOperation *operationView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL isBool;
@property (nonatomic, strong) UIView * clearView;
@property (nonatomic, retain) NSMutableArray * dataSource;
@property (nonatomic, strong) LSSendMessageView *sendMessageView;
@property (nonatomic, strong) LSClanCofcHeaderView *headerView ;
@property (nonatomic, strong) LSLinkInInformationModel *infoModel;
@property (nonatomic, assign) int repley;
@property (nonatomic,strong) UIImage *videoCoverImage;
@property (nonatomic, assign) int page;

@end

@implementation LSClanCofcViewController

-(NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)setNaviBarTintColor:(UIColor *)color {
    //
    NSDictionary *attribute = @{NSForegroundColorAttributeName : color};
    [self.navigationController.navigationBar setTitleTextAttributes:attribute];
    [self.navigationController.navigationBar setBarTintColor:color];
    [self.navigationController.navigationBar setTintColor:color];
    //设置UIBarbuttonItem的大小样式
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    NSMutableDictionary *itemAttr = [NSMutableDictionary dictionary];
    itemAttr[NSForegroundColorAttributeName] = color;
    itemAttr[NSFontAttributeName] = SYSTEMFONT(16);
    [item setTitleTextAttributes:itemAttr forState:UIControlStateNormal];
    [item setTitleTextAttributes:itemAttr forState:UIControlStateHighlighted];
    [item setTitleTextAttributes:itemAttr forState:UIControlStateSelected];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isFuwa) {
        [self.navigationController.navigationBar setTranslucent:YES];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:kMainColor] forBarMetrics:UIBarMetricsDefault];
        UIColor * color = [UIColor whiteColor];
        [self setNaviBarTintColor:color];
    }
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
    [self headerViews];
    [self naviBarConfig];
    [self initDataSources];
    [self isFouceUserInfo];
    
    MJRefreshNormalHeader * GifheadView = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTableHeader)];
    
    self.tableView.mj_header = GifheadView;
    GifheadView.lastUpdatedTimeLabel.hidden = YES;
    GifheadView.stateLabel.hidden = YES;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshTableFoot)];
    [self infoUserData];
    [self registerNotification];
}

- (void)isFouceUserInfo {

    [LSLinkInApplyModel linkInIsFocusWithC_id:[NSString stringWithFormat:@"%d",self.sh_id] type:self.type success:^(NSString *isfocus) {
        if ([isfocus isEqualToString:@"1"]) {
            self.headerView.fouceBtn.selected = YES;
        }else {
            self.headerView.fouceBtn.selected = NO;
        }
    } failure:nil];
}

- (void)headerViews {

    @weakify(self)
    [self.headerView setSetCoverClick:^{
        @strongify(self);
        
        if (![self.infoModel.user_id isEqualToString:ShareAppManager.loginUser.user_id]) return;
        
        [[LSLinkInPopView linkInMainView] showInView:self andArray:@[@[@"更换图片背景",],@[@"取消"]] withBlock:^(NSString *title) {
            if ([title isEqualToString:@"更换图片背景"]) {
                
                [[ImagePickerManager new] pickPhotoWithPresentedVC:self allocEditing:YES finishPicker:^(NSDictionary *info) {
                    
                    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
                    [LSLinkInApplyModel linkInApplyWithC_id:[NSString stringWithFormat:@"%d",self.sh_id] logo:nil banner:image type:self.type success:^(NSDictionary *dic){
                        [self.headerView.bgView setImageWithURL:[NSURL URLWithString:dic[@"banner"]] placeholder:timeLineBigPlaceholderName];
                    } failure:nil];
                }];
            }
        }];
    }];
    
    //关注按钮
    self.headerView.setFocusClick = ^(UIButton * sender){
        @strongify(self);
        [self fouceRequest:sender];
    };
}

- (void)fouceRequest:(UIButton *)sender {

    if (!sender.selected) {
        [LSLinkInApplyModel linkInFocusWithC_id:[NSString stringWithFormat:@"%d",self.sh_id] type:self.type success:^{
            sender.selected = YES;
            self.headerView.focusLabel.text = [NSString stringWithFormat:@"%d人",[self.infoModel.count intValue]+1];
            //发送通知刷新人脉首页
            [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteLinkInInfoNoti object:nil];
            [self.view showSucceed:@"成功关注" hideAfterDelay:1];
        } failure:nil];
    }else {
        [LSLinkInApplyModel linkInCancelFocusWithC_id:[NSString stringWithFormat:@"%d",self.sh_id] type:self.type success:^{
            sender.selected = NO;
            self.headerView.focusLabel.text = [NSString stringWithFormat:@"%d人",[self.infoModel.count intValue]];
            //发送通知刷新人脉首页
            [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteLinkInInfoNoti object:nil];
            [self.view showSucceed:@"取消关注" hideAfterDelay:1];
        } failure:nil];
    }
    
}

- (void)registerNotification {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kLinkSchoolInfoNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self initDataSources];
    }];
}

- (void)infoUserData {
    
    [LSLinkInInformationModel linkInInfoWithC_id:[NSString stringWithFormat:@"%d",self.sh_id] type:self.type success:^(LSLinkInInformationModel *model) {
        self.infoModel = model;
        [self.headerView.bgView setImageWithURL:[NSURL URLWithString:model.banner] placeholder:timeLineBigPlaceholderName];
        self.headerView.focusLabel.text = [NSString stringWithFormat:@"%@人",model.count];
        
    } failure:nil];
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
        
        if ([title isEqualToString: @"图文"]) {
            
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
        if (self.infoModel) {
            NSString * urlString = self.type == 3 ? [NSString stringWithFormat:@"https://api.66boss.com/web/cofc?id=%d",self.sh_id]:self.type == 4 ? [NSString stringWithFormat:@"https://api.66boss.com/web/clan?id=%d",self.sh_id] : [NSString stringWithFormat:@"https://api.66boss.com/web/storetribe?id=%d",self.sh_id];
            UIViewController *vc = [NSClassFromString(@"LSWebViewController") new];
            [vc setValue:urlString forKey:@"urlString"];
            [vc setValue:[NSString stringWithFormat:@"%d",self.type] forKey:@"type"];
            [vc setValue:[NSString stringWithFormat:@"%d",self.sh_id] forKey:@"s_id"];
            [vc setValue:self.infoModel.desc forKey:@"desc"];
            [vc setValue:self.infoModel.address forKey:@"address"];
            [vc setValue:self.infoModel.contact forKey:@"phone"];
            [vc setValue:self.infoModel.user_id forKey:@"user_id"];
            [self.navigationController pushViewController:vc animated:YES];
        }else {
        
            [LSKeyWindow showError:@"等一会,网络故障~~" hideAfterDelay:1.5];
        }
    }
    else if ([title isEqualToString:@"名人"]) {
        if (self.infoModel) {
            UIViewController *vc = [NSClassFromString(@"LSCelebrityViewController") new];
            [vc setValue:@(self.sh_id) forKey:@"sh_id"];
            [vc setValue:@(self.type) forKey:@"type"];
            [vc setValue:self.infoModel.user_id forKey:@"user_id"];
            [self.navigationController pushViewController:vc animated:YES];
        }else {
            
            [LSKeyWindow showError:@"等一会,网络故障~~" hideAfterDelay:1.5];
        }
        
    }
    else if ([title isEqualToString:@"创建宗亲"]||[title isEqualToString:@"创建商会"]) {
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSLSApplyCreate"];
        [vc setValue:@(self.type) forKey:@"type"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([title isEqualToString:@"动态"]) {
        
//        UIViewController *vc = [NSClassFromString(@"LSDynamicViewController") new];
//        [vc setValue:@(self.sh_id) forKey:@"sh_id"];
//        [vc setValue:@(self.type) forKey:@"type"];
//        [self.navigationController pushViewController:vc animated:YES];
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
        LSClanCofcHeaderView *headerView = [NSClassFromString(@"LSClanCofcHeaderView") new];
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

@implementation LSClanCofcHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIImageView *bgView = [UIImageView new];
        bgView.image = [UIImage imageNamed:@"pic5.jpg"];
        self.bgView = bgView;
        bgView.userInteractionEnabled = YES;
        bgView.contentMode = UIViewContentModeScaleToFill;
        bgView.clipsToBounds = YES;
        [self addSubview:bgView];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.offset(220);
        }];
        
        UITapGestureRecognizer * bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapClick)];
        [bgView addGestureRecognizer:bgTap];
        
        UIButton * focusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fouceBtn = focusBtn;
        focusBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [focusBtn setTitle:@"已关注" forState:UIControlStateSelected];
        [focusBtn setTitle:@"关注" forState:UIControlStateNormal];
        [focusBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
        [focusBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateSelected];
        ViewRadius(focusBtn, 5);
        [self addSubview:focusBtn];
        [focusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(20);
            make.right.equalTo(self.mas_right).offset(-30);
            make.width.offset(60);
            make.height.offset(30);
        }];
        
        @weakify(self)
        [[focusBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIButton * _Nullable button) {
            @strongify(self)
            
            if (self.setFocusClick) {
                self.setFocusClick(button);
            }
        }];
        
        UILabel * focusLabel = [UILabel new];
        focusLabel.font = [UIFont systemFontOfSize:14];
        focusLabel.textAlignment = NSTextAlignmentCenter;
        focusLabel.text = @"12345人";
        self.focusLabel = focusLabel;
        focusLabel.textColor = [UIColor whiteColor];
        [self addSubview:focusLabel];
        [focusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(focusBtn.mas_bottom).offset(5);
            make.right.equalTo(self.mas_right).offset(-30);
            make.width.offset(60);
            make.height.offset(20);
        }];
        
        UIView * transparent = [UIView new];
        transparent.alpha = 0.3;
        transparent.backgroundColor = [UIColor blackColor];
        [self addSubview:transparent];
        [transparent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.offset(44);
        }];
        
        UIStackView *stackView = [UIStackView new];
        self.stackView = stackView;
        [self addSubview:stackView];
        stackView.distribution = UIStackViewDistributionFillEqually;
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.offset(44);
        }];
        
    }
    
    return self;
}



- (void)bgTapClick {

    if (self.setCoverClick) {
        self.setCoverClick();
    }
}

-(void)menusButtonAction:(UIButton *)sender{
    
    if (self.bottomClick) {
        self.bottomClick(sender);
    }
}

-(void)setType:(int)type{
    
    _type = type;
    
    NSString * title = _type == 3?@"创建商会":@"创建宗亲";
    NSArray *menus = _type == 5 ? @[@"简介",@"动态"] : @[@"简介",@"名人",title];
    
    for (int i = 0; i<menus.count; i++) {
        
        NSString *title = menus[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = SYSTEMFONT(16);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.tag = 1000+i;
        [self.stackView addArrangedSubview:button];
        [button addTarget:self action:@selector(menusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}


@end
