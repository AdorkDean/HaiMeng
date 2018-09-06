//
//  LSTimeLineViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTimeLineViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+Util.h"
#import "LSTimeLineTableHeaderView.h"
#import "LSOptionsView.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "LSPostTimeLineViewController.h"
#import "LSTimeLineMessageViewController.h"
#import "LSTimeLineHomeViewController.h"
#import "LSPostCommentView.h"
#import "LSAlbumsViewController.h"
#import "LSTimeLineTableListModel.h"
#import "LSAppManager.h"
#import "MJRefresh.h"
#import "LSCaptureViewController.h"
#import "LSGoodAndCommentView.h"
#import "UIView+HUD.h"
#import "LSContactDetailViewController.h"
#import "LSContactModel.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "NSString+Util.h"
#import "ComfirmView.h"

static NSString *const reuse_id = @"LSTimeLineTableViewCell";

@interface LSTimeLineViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate,LSGoodAndCommentViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) LSPostCommentView *postCommentView;
@property (nonatomic,strong)  LSTimeLineTableHeaderView *headerView;
@property (nonatomic,assign) int page;

@property (nonatomic,strong) UIImagePickerController * imagePickerVc;
@property (nonatomic,strong) UIImage *videoCoverImage;

@end

@implementation LSTimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"朋友圈";
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.dataSource = [NSMutableArray array];
    [self setConstraints];
    [self setNotification];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    @weakify(self)
    [LSTimeLineTableListModel getFirstMsgSuccess:^(LSGetNewMsgModel *NewMsgModel) {
        if (NewMsgModel.count>0) {
            @strongify(self)
            self.headerView.MyDevelopmentsView.hidden = NO;
            self.headerView.MyDevelopmentsView.model = NewMsgModel;
        }else{
            [self hiddenKeyboardAndPostCommentView];
        }
    } failure:^(NSError *error) {
        
    }];
}

-(void)setNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToNewMsgVC) name:TimeLineMessageNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToMyTimeLineVC) name:TimeLineMyIconNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBGImage:) name:TimeLineBGImageNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCellWithNoti:) name:TimeLineReloadCellNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openAddCommentViewWithNoti:) name:addCommentViewNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTimelineData) name:kreloadTimeLineNoti object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenAddPostView) name:TimeLineGoodAndCommentBtnNoti object:nil];
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:TimeLinePlayVideoNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSDictionary *dic = x.userInfo;
        UIImage * image = x.object;
        
        UIViewController * vc = [NSClassFromString(@"LSVideoPlayerViewController") new];
        [vc setValue:[NSURL URLWithString:dic[@"UrlStr"]] forKey:@"playURL"];
        [vc setValue:image forKey:@"coverImage"];
        [self presentViewController:vc animated:YES completion:nil];
        
    }];
}

-(void)setConstraints{
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"photo"] style:UIBarButtonItemStyleDone target:self action:@selector(pushToWriteTimeLineVC)];
    
    self.postCommentView = [LSPostCommentView new];
    self.postCommentView.hidden = YES;
    [self.view addSubview:self.postCommentView];
    [self.view bringSubviewToFront:self.postCommentView];
    
    
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.postCommentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.height.equalTo(self.view);
    }];
    
    MJRefreshNormalHeader * GifheadView = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTableHead)];
    
    self.tableView.mj_header = GifheadView;
    GifheadView.lastUpdatedTimeLabel.hidden = YES;
    GifheadView.stateLabel.hidden = YES;

    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshTableFoot)];
    
    [self.tableView.mj_header beginRefreshing];

}


#pragma mark reloadTableView
-(void)reloadTimelineData{
    
    [self.tableView.mj_header beginRefreshing];
}


-(void)refreshTableHead{
    @weakify(self)
    self.page = 0;
    [LSTimeLineTableListModel getTimeLineListWithPage:self.page pageSize:20 success:^(NSArray * modelArr) {
        @strongify(self)
        [self.tableView.mj_header endRefreshing];
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:modelArr];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        @strongify(self)
        NSDictionary * Info = error.userInfo;
        NSString * infostr = Info[@"NSLocalizedFailureReason"];
        if ([infostr isEqualToString:@"没有更多数据了"]) {
            [self.dataSource removeAllObjects];
            [self.tableView reloadData];
            
        }
        [self.tableView.mj_header endRefreshing];

    }];
}

-(void)refreshTableFoot{
    self.page ++;
    @weakify(self)

    [LSTimeLineTableListModel getTimeLineListWithPage:self.page pageSize:20 success:^(NSArray * modelArr) {
        @strongify(self)
        [self.tableView.mj_footer endRefreshing];
        [self.dataSource addObjectsFromArray:modelArr];
        [self.tableView reloadData];

    } failure:^(NSError *error) {
        
        [self.tableView.mj_footer endRefreshing];

    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:TimeLineGoodAndCommentBtnNoti object:nil];
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
        
        [tableView registerClass:[LSTimeLineTableViewCell class] forCellReuseIdentifier:reuse_id];

        LSTimeLineTableHeaderView *headerView = [[LSTimeLineTableHeaderView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 320)];
        headerView.type = @"TimeLine";
        self.headerView = headerView;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];
    
        tableView.tableHeaderView = headerView;
        headerView.backgroundColor =[UIColor whiteColor];
        headerView.model = ShareAppManager.loginUser;
        [LSUserModel searchUserWithUserID:ShareAppManager.loginUser.user_id.intValue Success:^(LSUserModel *userModel) {
            headerView.model = userModel;
            ShareAppManager.loginUser.cover_pic = userModel.cover_pic;
        } failure:^(NSError *error) {
            [self.view showError:@"获取个人信息失败" hideAfterDelay:1];
        }];
        self.tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @weakify(self)
    LSTimeLineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    LSTimeLineTableListModel * model = self.dataSource[indexPath.row];
    cell.model = model;
    cell.goodAndCommentView.delegate = self;
    cell.index = (int)indexPath.row;
    [cell setToUserViewBlock:^(int userID){
        NSLog(@"%d",userID);
        @strongify(self)
        LSContactDetailViewController * vc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];

        vc.user_id = [NSString stringWithFormat:@"%d",userID];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [cell setDeleteBlock:^(){
        @strongify(self)
        [self.view showAlertWithTitle:@"删除朋友圈" message:@"确定要删除这条朋友圈吗?" cancelAction:^{
            
        } doneAction:^{
            [LSTimeLineTableListModel deleteTimeLineWithFeed_id:model.feed_id success:^{
                [self.dataSource removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRow:indexPath.row inSection:indexPath.section withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView reloadData];
            } failure:^(NSError *error) {
                [self.view showError:@"删除失败" hideAfterDelay:1];
            }];
            
            
        }];
    }];
    
    [cell setContentClick:^(LSTimeLineTableListModel *model) {
        
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
    }];
    
    [cell configCellWithModel:model];

    return cell;
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataSource.count>0) {
        LSTimeLineTableListModel * model = self.dataSource[indexPath.row];
        
        CGFloat height = [LSTimeLineTableViewCell hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
            LSTimeLineTableViewCell *cell = (LSTimeLineTableViewCell *)sourceCell;
            [cell configCellWithModel:model];
        }];
        return  height;
    }
    return 0;
}

-(void)hiddenKeyboardAndPostCommentView{
    self.postCommentView.hidden = YES;
    [self.view endEditing:YES];
}


#pragma mark Delegate&notification Action

-(void)CommentViewLongPressWithCommentModel:(LSTimeLineCommentModel *)model cellIndex:(int)cellIndex{

        self.postCommentView.hidden = NO;
        self.postCommentView.index = cellIndex;
        self.postCommentView.type = postCommentTypeAnswer;
        self.postCommentView.commentModel = model;
        [self.postCommentView.commentTextField becomeFirstResponder];


}

-(void)pushToWriteTimeLineVC{

    LSOptionsView * optionsView = [[LSOptionsView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.frame WithData:@[@"照相",@"图文朋友圈",@"选视频发朋友圈",@"录视频发朋友圈"]];
    @weakify(self)

    [optionsView setSelectCellBlock:^(NSString *title){
        @strongify(self)
        if ([title  isEqualToString: @"图文朋友圈"]) {
            UIStoryboard *board = [UIStoryboard storyboardWithName: @"TimeLine" bundle: nil];
            LSPostTimeLineViewController *postVC = [board instantiateViewControllerWithIdentifier: @"postTimeLineView"];
            [self.navigationController pushViewController:postVC animated:YES];

        }else if ([title isEqualToString:@"录视频发朋友圈"]){
            LSCaptureViewController * videoVC = [LSCaptureViewController new];
            UINavigationController *NavVc = [[UINavigationController alloc]initWithRootViewController:videoVC];
            [self presentViewController:NavVc animated:YES completion:nil];
            videoVC.capCompleteBlock =^(LSCaptureModel *model){
                
                UIStoryboard *board = [UIStoryboard storyboardWithName: @"TimeLine" bundle: nil];
                LSPostTimeLineViewController *postVC = [board instantiateViewControllerWithIdentifier: @"postTimeLineView"];
                [postVC setPostType:LSPostTimeLineTypeVideo WithModel:model];
                [self.navigationController pushViewController:postVC animated:YES];
            };
            
        }else if([title isEqualToString:@"照相"]){
            
            self.imagePickerVc = [[UIImagePickerController alloc]init];
            self.imagePickerVc.delegate = self;
            self.imagePickerVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            self.imagePickerVc.allowsEditing = YES;
            self.imagePickerVc.title = @"拍照发朋友圈";
            [self selectImageFromCamera];
            

        }else if([title isEqualToString:@"选视频发朋友圈"]){
            
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
                        UIStoryboard *board = [UIStoryboard storyboardWithName: @"TimeLine" bundle: nil];
                        LSPostTimeLineViewController *postVC = [board instantiateViewControllerWithIdentifier: @"postTimeLineView"];
                        [postVC setPostType:LSPostTimeLineTypeVideo WithModel:model];
                        @strongify(self)
                        [self.navigationController pushViewController:postVC animated:YES];
                    })
                }];
                
            }];
            [self presentViewController:TZimagePickerVc animated:YES completion:nil];

        }
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:optionsView];
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



- (void)selectImageFromCamera
{
    self.imagePickerVc.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    self.imagePickerVc.mediaTypes = @[(NSString *)kUTTypeImage];
    
    [self presentViewController:self.imagePickerVc animated:YES completion:nil];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage * pickerImage = info[@"UIImagePickerControllerOriginalImage"];
    if ([picker.title isEqualToString:@"拍照发朋友圈"]) {
        [picker dismissViewControllerAnimated:YES completion:^{
            UIStoryboard *board = [UIStoryboard storyboardWithName: @"TimeLine" bundle: nil];
            LSPostTimeLineViewController *postVC = [board instantiateViewControllerWithIdentifier: @"postTimeLineView"];
            [self.navigationController pushViewController:postVC animated:YES];
            [postVC setPostType:LSPostTimeLineTypePhoto WithModel:pickerImage];
            
            NSLog(@"选择完毕-----info:%@",info);
        }];
    }else{
        [self.view showLoading];
        [LSTimeLineTableListModel changeHeadBGImageWithImage:pickerImage success:^(NSString *BGimageUrl) {
            [LSAppManager sharedAppManager].loginUser.cover_pic = BGimageUrl;
            [[NSNotificationCenter defaultCenter]postNotificationName:TimeLineDoneBGImageNoti object:nil];
            
            [picker dismissViewControllerAnimated:YES completion:^{
                [self.view showSucceed:@"更换成功" hideAfterDelay:1];

            }];
        } failure:^(NSError *error) {
            [picker dismissViewControllerAnimated:YES completion:^{
                [self.view showError:@"更换失败" hideAfterDelay:1];
                
            }];
        }];
        
    }


}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(void)changeBGImage:(NSNotification *)noti{
    NSDictionary * infoDic = noti.userInfo;
    NSString * type = infoDic[@"type"];
    if ([type isEqualToString:@"home"]) return;
    LSOptionsView * optionsView = [[LSOptionsView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.frame WithData:@[@"从手机相册中选择",@"拍照"]];
    @weakify(self)
    [optionsView setSelectCellBlock:^(NSString *title){
        @strongify(self)
        if([title isEqualToString:@"从手机相册中选择"]){

            
            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
            imagePickerVc.isSelectOriginalPhoto = YES;
            imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
            imagePickerVc.allowPickingVideo = NO;
            imagePickerVc.allowPickingImage = YES;
            imagePickerVc.allowPickingOriginalPhoto = YES;
            imagePickerVc.allowPickingGif = NO;
            @weakify(self)
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                @strongify(self)
                
                for (PHAsset *asset in assets) {
                    //获取原图
                    [[TZImageManager manager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                            if(photo){
                                [LSTimeLineTableListModel changeHeadBGImageWithImage:photo success:^(NSString *BGimageUrl) {
                                    [LSAppManager sharedAppManager].loginUser.cover_pic = BGimageUrl;
                                    [LSAppManager storeUser:[LSAppManager sharedAppManager].loginUser];
                                    

                                    [[NSNotificationCenter defaultCenter]postNotificationName:TimeLineDoneBGImageNoti object:nil];
                                    [self.view showSucceed:@"更换成功" hideAfterDelay:1];
                                } failure:^(NSError *error) {
                                    [self.view showError:@"更换失败" hideAfterDelay:1];
                                }];
                            }
                    }];
                }
                
            }];
            [self presentViewController:imagePickerVc animated:YES completion:nil];
        }else{
            self.imagePickerVc = [[UIImagePickerController alloc]init];
            self.imagePickerVc.delegate = self;
            self.imagePickerVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            self.imagePickerVc.allowsEditing = YES;
            self.imagePickerVc.title = @"修改背景图片";
            
            [self selectImageFromCamera];
            
            
        }
        
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:optionsView];
}




-(void)pushToNewMsgVC{
    self.headerView.MyDevelopmentsView.hidden = YES;
    LSTimeLineMessageViewController *vc = [[LSTimeLineMessageViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)pushToMyTimeLineVC{
    LSUserModel * userModel =[LSAppManager sharedAppManager].loginUser;
    LSContactModel * cModel = [LSContactModel new];
    cModel.user_name = userModel.user_name;
    cModel.friend_id = userModel.user_id.integerValue;
    cModel.avatar = userModel.avatar;
    LSContactDetailViewController * vc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
    vc.user_id = [NSString stringWithFormat:@"0"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)hiddenAddPostView{
    self.postCommentView.hidden = YES;
    [self.view endEditing:YES];
}

-(void)reloadCellWithNoti:(NSNotification *)noti{
    [self hiddenKeyboardAndPostCommentView];
    NSDictionary *dic = noti.userInfo;
    LSTimeLineTableListModel * model =dic[@"newModel"];
    NSNumber *indexNum = dic[@"index"];
    [self.view endEditing:YES];
    [self.dataSource replaceObjectAtIndex:indexNum.intValue withObject:model];
    
    [self.tableView reloadRow:indexNum.intValue inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView scrollToRow:indexNum.intValue inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)openAddCommentViewWithNoti:(NSNotification *)noti{
    NSDictionary *dic = noti.userInfo;
    
    LSTimeLineTableListModel *model = dic[@"commentModel"];
    NSNumber *index = dic[@"index"];
    self.postCommentView.hidden = NO;
    self.postCommentView.type = postCommentTypeNew;
    self.postCommentView.model = model;
    self.postCommentView.index = index.intValue;
    [self.postCommentView.commentTextField becomeFirstResponder];

}



-(void)dealloc{

    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end

#import "LSTimeLinePicOrLinkView.h"
#import "LSGoodAndCommentView.h"
#import "LSTimeLineCellOperationMenu.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "LSTimeLineTableListModel.h"

#define  margin 10
#define rightMargin -30

@interface LSTimeLineTableViewCell ()

@property(nonatomic,strong) UIButton *userIconView;
@property(nonatomic,strong) UILabel *userNameLabel;
@property(nonatomic,strong) UILabel *userTextLabel;
@property(nonatomic,strong) LSTimeLinePicOrLinkView *userPicOrLinkView;
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UIButton *goodAndCommentBtn;
@property(nonatomic,strong) LSTimeLineCellOperationMenu *OperationMenu;
@property(nonatomic,strong) UIButton * deleteBtn;
@property(nonatomic,strong) UIButton * closeTextBtn;

@end

@implementation LSTimeLineTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeConstrains];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setNotification];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

-(void)makeConstrains{
    self.userIconView = [UIButton new];
    [self.userIconView addTarget:self action:@selector(iconViewClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.userIconView];
    
    
    self.userNameLabel = [UILabel new];
    [self.contentView addSubview:self.userNameLabel];
    self.userNameLabel.textColor = HEXRGB(0x576b95);
    self.userNameLabel.font = [UIFont systemFontOfSize:15];
    self.userNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView bringSubviewToFront:self.userNameLabel];
    [self.userNameLabel sizeToFit];
    
    self.userTextLabel = [UILabel new];
    [self.contentView addSubview:self.userTextLabel];
    self.userTextLabel.font = [UIFont systemFontOfSize:14];
    self.userTextLabel.textColor = [UIColor blackColor];
    self.userTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.userTextLabel.numberOfLines = 0;
    self.userTextLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width-94;
    [self.userTextLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.userTextLabel sizeToFit];
    
    
    UILongPressGestureRecognizer * contentLabelTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(contentClick:)];
    self.userTextLabel.userInteractionEnabled = YES;
    [self.userTextLabel addGestureRecognizer:contentLabelTap];
    
    self.closeTextBtn = [UIButton new];
    self.closeTextBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.closeTextBtn setTitle:@"打开" forState:UIControlStateNormal];
    [self.closeTextBtn setTitle:@"收起" forState:UIControlStateSelected];
    [self.closeTextBtn setTitleColor:HEXRGB(0x6F99FF) forState:UIControlStateNormal];
    [self.closeTextBtn addTarget:self action:@selector(controlUserTextLabel) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.closeTextBtn];

    
    self.userPicOrLinkView = [LSTimeLinePicOrLinkView new];
    [self.contentView addSubview:self.userPicOrLinkView];
    
    
    self.timeLabel = [UILabel new];
    [self.contentView addSubview:self.timeLabel];
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor = HEXRGB(0x737373);
    
    self.goodAndCommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.goodAndCommentBtn addTarget:self action:@selector(clickedGoodAndCommentBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.goodAndCommentBtn];
    [self.goodAndCommentBtn setImage:[UIImage imageNamed:@"information"] forState:UIControlStateNormal];
    
    
    self.OperationMenu = [LSTimeLineCellOperationMenu new];
    [self.contentView addSubview:self.OperationMenu];
    self.OperationMenu.alpha = 0;
    self.OperationMenu.show = NO;
    
    self.goodAndCommentView = [LSGoodAndCommentView new];
    [self.contentView addSubview:self.goodAndCommentView];
    self.goodAndCommentView.backgroundColor = HEXRGB(0xefeff4);
    self.hyb_lastViewInCell = self.goodAndCommentView;
    self.hyb_bottomOffsetToCell = 10;
    
    self.deleteBtn = [UIButton new];
    [self.deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:HEXRGB(0x6F99FF) forState:UIControlStateNormal];
    self.deleteBtn.titleLabel.font =[UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.deleteBtn];
    [self.contentView sendSubviewToBack:self.deleteBtn];
    
    [self.userIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.contentView).with.offset(12);
        make.width.height.mas_equalTo(42);
        
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(18);
        make.left.equalTo(self.userIconView.mas_right).with.offset(margin);
        make.right.equalTo(self.contentView.mas_right).with.offset(rightMargin);
        make.height.mas_offset(25);
    }];
    
    [self.userTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameLabel.mas_bottom).with.offset(margin);
        make.left.equalTo(self.userNameLabel);
        make.right.equalTo(self.userNameLabel);
        
    }];
    
    [self.closeTextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userTextLabel.mas_bottom).offset(3);
        make.left.equalTo(self.userIconView.mas_right).with.offset(margin);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(15);
    }];
    
    [self.userPicOrLinkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.self.closeTextBtn.mas_bottom).with.offset(margin);
        make.left.equalTo(self.userTextLabel);
        make.right.equalTo(self.userTextLabel);
    }];
    
    [self.goodAndCommentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userPicOrLinkView.mas_bottom).with.offset(margin);
        make.right.equalTo(self.contentView.mas_right).with.offset(-margin);
        make.width.height.mas_equalTo(20);
        
    }];
    
    [self.OperationMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.goodAndCommentBtn);
        make.right.equalTo(self.goodAndCommentBtn.mas_left).with.offset(-4);
        make.width.mas_offset(180);
        make.height.mas_offset(39);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.goodAndCommentBtn);
        make.left.equalTo(self.userNameLabel);
        make.height.mas_equalTo(25);
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.timeLabel);
        make.left.equalTo(self.timeLabel.mas_right).offset(margin);
        make.width.mas_equalTo(30);
    }];
    
    [self.goodAndCommentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.goodAndCommentBtn.mas_bottom).with.offset(margin);
        make.left.equalTo(self.timeLabel);
        make.right.equalTo(self.userTextLabel);
    }];
}


#pragma mark action

- (void)contentClick:(UITapGestureRecognizer *)tap {
    
    if (tap.state == UIGestureRecognizerStateBegan){
        
        !self.contentClick?:self.contentClick(self.model);
    }
}

-(void)clickedGoodAndCommentBtn{
    [self postOperationButtonClickedNotification];
    self.OperationMenu.show = !self.OperationMenu.isShowing;

}

-(void)setModel:(LSTimeLineTableListModel *)model{
    _model = model;

}

-(void)configCellWithModel:(LSTimeLineTableListModel *)model{
    
    __weak typeof(LSTimeLineTableViewCell) *weakself = self;

    [self.userIconView setImageWithURL:[NSURL URLWithString:model.feed_avatar] forState:UIControlStateNormal placeholder:timeLineSmallPlaceholderName];
    self.goodAndCommentView.index = self.index;
    self.goodAndCommentView.model = model;
    [self.goodAndCommentView setPushUserIDBlock:^(int userID){
        [weakself iconViewOrCommentUserClickWithUserId:userID];
    }];
    self.userNameLabel.text = model.feed_username;
    self.userTextLabel.text = model.content;
    self.closeTextBtn.selected = model.isSelected;
    CGSize textSize =  [NSString countingSize:model.content fontSize:14 width: [UIScreen mainScreen].bounds.size.width-94];
    if (textSize.height>200 && model.isSelected == NO) {
        
        self.closeTextBtn.hidden = NO;

        [self.userTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userNameLabel.mas_bottom).with.offset(margin);
            make.left.equalTo(self.userNameLabel);
            make.right.equalTo(self.userNameLabel);
            
            make.height.mas_equalTo(200);
        }];
        [self.contentView setNeedsUpdateConstraints];
        
    }else if(textSize.height>200 && model.isSelected == YES){
        self.closeTextBtn.hidden = NO;

        [self.userTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userNameLabel.mas_bottom).with.offset(margin);
            make.left.equalTo(self.userNameLabel);
            make.right.equalTo(self.userNameLabel);
        }];
        [self.contentView setNeedsUpdateConstraints];

    }else{
        self.closeTextBtn.hidden = YES;
        [self.userTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userNameLabel.mas_bottom).with.offset(margin);
            make.left.equalTo(self.userNameLabel);
            make.right.equalTo(self.userNameLabel);
        }];
        [self.contentView setNeedsUpdateConstraints];
    }
    
    self.timeLabel.text = model.add_time;
    self.userPicOrLinkView.model = model;
    self.OperationMenu.index = self.index;
    self.OperationMenu.model = model;
    self.deleteBtn.hidden = model.feed_uid == ShareAppManager.loginUser.user_id.intValue ?NO:YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self postOperationButtonClickedNotification];
    if (self.OperationMenu.isShowing) {
        self.OperationMenu.show = NO;
    }
}

-(void)controlUserTextLabel{
    
    
    
    CGSize textSize =  [NSString countingSize:self.model.content fontSize:14 width:self.userTextLabel.width];
        if (textSize.height>200 && self.model.isSelected == YES) {
    
            [self.userTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.userNameLabel.mas_bottom).with.offset(margin);
                make.left.equalTo(self.userNameLabel);
                make.right.equalTo(self.userNameLabel);

                make.height.mas_equalTo(200);
            }];
            [self.contentView setNeedsLayout];
            self.model.isSelected = NO;
            self.closeTextBtn.selected = self.model.isSelected;
        }else{
            
            [self.userTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.userNameLabel.mas_bottom).with.offset(margin);
                make.left.equalTo(self.userNameLabel);
                make.right.equalTo(self.userNameLabel);
            }];
            self.model.isSelected = YES;
            self.closeTextBtn.selected = self.model.isSelected;
        }
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:self.model forKey:@"newModel"];
    [dic setObject:[NSNumber numberWithInt:self.index] forKey:@"index"];
    [[NSNotificationCenter defaultCenter]postNotificationName:TimeLineReloadCellNoti object:nil userInfo:dic];
}

-(void)setNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveOperationButtonClickedNotification:) name:TimeLineGoodAndCommentBtnNoti object:nil];
    
    
}


- (void)postOperationButtonClickedNotification
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.goodAndCommentBtn forKey:@"selectBtn"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TimeLineGoodAndCommentBtnNoti object:nil userInfo:dic];
}

-(void)deleteBtnClick{
    self.deleteBlock();
}

-(void)iconViewClick{
    [self iconViewOrCommentUserClickWithUserId:self.model.feed_uid];
}

-(void)iconViewOrCommentUserClickWithUserId:(int)userId{
    self.ToUserViewBlock(userId);
}

- (void)receiveOperationButtonClickedNotification:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    UIButton * selectBtn =dic[@"selectBtn"];

    if (selectBtn != self.goodAndCommentBtn && self.OperationMenu.isShowing) {
        self.OperationMenu.show = NO;
    }
}



@end
