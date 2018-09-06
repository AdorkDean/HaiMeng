//
//  LSMyTimeLineViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTimeLineHomeViewController.h"
#import "LSPostTimeLineViewController.h"
#import "LSTimeLineHomePicViewController.h"
#import "LSTimeLineHomeDetailViewController.h"
#import "LSTimeLineMessageViewController.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "LSTimeLineTableHeaderView.h"
#import "LSOptionsView.h"
#import "LSAppManager.h"
#import "MJRefresh.h"
#import "LSTimeLineTableListModel.h"
#import "LSAlbumsViewController.h"
#import "LSCaptureViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSDate+Util.h"
#import "UIView+HUD.h"
static NSString *const reuse_id = @"LSMyTimeLineTableViewCell";
static NSString *const topReuse_id = @"LSNewMyTimeLineTableViewCell";
#define ArrIndex  self.type==TimeLineContentTypeSelf?indexPath.row-1:indexPath.row

@interface LSTimeLineHomeViewController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *dataSource;
@property(nonatomic,strong) LSTimeLineTableHeaderView * headView;
@property(nonatomic,assign) int page;
@property(nonatomic,strong) NSMutableArray *lastDateArray;
@property(nonatomic,strong) NSMutableArray *lastDateModelArray;
@property (nonatomic,strong) UIImagePickerController * imagePickerVc;
@property (nonatomic,strong) UIImage *videoCoverImage;
@property (nonatomic,assign)TimeLineContentType type;

@end

@implementation LSTimeLineHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"相册";
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataSource = [NSMutableArray array];
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor whiteColor];

    [self setNotification];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
    
    MJRefreshNormalHeader * GifheadView = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTableHead)];
    
    self.tableView.mj_header = GifheadView;
    GifheadView.lastUpdatedTimeLabel.hidden = YES;
    GifheadView.stateLabel.hidden = YES;
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshTableFoot)];
    
    [self.tableView.mj_header beginRefreshing];
}


-(void)setNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLSOptionsView) name:showOptionsViewNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTimelineData) name:kreloadTimeLineNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBGImage:) name:TimeLineBGImageNoti object:nil];
}

#pragma mark -reloadTable

- (void)reloadTimelineData {
    [self.tableView.mj_header beginRefreshing];
}

-(void)refreshTableHead{
    
    self.page = 0;
    
    [LSTimeLineTableListModel searchGalleryWithuserID:self.userID page:self.page success:^(NSArray *modelArr) {
        
        self.lastDateModelArray = [NSMutableArray array];
        self.lastDateArray = [NSMutableArray array];
        [self.tableView.mj_header endRefreshing];
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:modelArr];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
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
    [LSTimeLineTableListModel searchGalleryWithuserID:self.userID page:self.page success:^(NSArray *modelArr) {
        @strongify(self)
        [self.tableView.mj_footer endRefreshing];
        [self.dataSource addObjectsFromArray:modelArr];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView = tableView;
        _tableView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:tableView];
        
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [tableView registerClass:[LSHomeTimeLineTableViewCell class] forCellReuseIdentifier:reuse_id];
        [tableView registerClass:[LSNewHomeTimeLineTableViewCell class] forCellReuseIdentifier:topReuse_id];

        LSTimeLineTableHeaderView *headerView = [[LSTimeLineTableHeaderView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 320)];
        headerView.type = @"home";
        headerView.MyDevelopmentsView.hidden =YES;
        
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];

        tableView.tableHeaderView = headerView;
        headerView.backgroundColor =[UIColor whiteColor];
        
        
        [LSUserModel searchUserWithUserID:self.userID Success:^(LSUserModel *userModel) {
            headerView.model = userModel;
            if (self.userID == ShareAppManager.loginUser.user_id.intValue) {
                ShareAppManager.loginUser.cover_pic = userModel.cover_pic;

            }

        } failure:^(NSError *error) {
            [self.view showError:@"获取个人信息失败" hideAfterDelay:1];
        }];
        
        
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int num = self.type == TimeLineContentTypeSelf?self.dataSource.count+1:self.dataSource.count;
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    if (indexPath.row == 0 && self.type == TimeLineContentTypeSelf) {
        LSNewHomeTimeLineTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:topReuse_id];
        return cell;
    }else{
    LSHomeTimeLineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    LSTimeLineTableListModel * model = self.dataSource[ArrIndex];
    cell.model = model;
    NSString * date = [NSDate dateWithTimeInterval:model.add_time.doubleValue format:@"MM月dd日"];
        NSString * todayDate = [NSDate dateWithTimeInterval:[NSDate date].timeIntervalSince1970 format:@"MM月dd日"];
//        NSLog(@"%@--------%@",date,todayDate);
        
    if ((![self.lastDateArray containsObject:date]&&![self.lastDateModelArray containsObject:model])&&[date isEqualToString:todayDate]&& self.type == TimeLineContentTypeOther) {
        [self.lastDateArray addObject:date];
        [self.lastDateModelArray addObject:model];
        [cell setToday];
        
    }else if (([self.lastDateArray containsObject:date]&&![self.lastDateModelArray containsObject:model])||[date isEqualToString:todayDate]) {
        [cell setCellDateWithDateStr:@""];

    }else{
        [self.lastDateArray addObject:date];
        [self.lastDateModelArray addObject:model];
        [cell setCellDateWithDateStr:date];

    }
        
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LSHomeTimeLineTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ((indexPath.row !=0 || self.type ==TimeLineContentTypeOther) && cell.type==MyTimeLineCellTypepic) {
        LSTimeLineHomePicViewController * vc = [[LSTimeLineHomePicViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        vc.model = self.dataSource[ArrIndex];

    }else if ((indexPath.row !=0 || self.type ==TimeLineContentTypeOther) &&(cell.type == MyTimeLineCellTypeText || cell.type == MyTimeLineCellTypeVideo))
    {
        LSTimeLineHomeDetailViewController *Vc = [LSTimeLineHomeDetailViewController new];
        LSTimeLineTableListModel * model = self.dataSource[ArrIndex];
        Vc.feed_Id = model.feed_id;
        [self.navigationController pushViewController:Vc animated:YES];
        Vc.user_id = model.user_id;
    
    }

}


#pragma mark delegate&action
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int cellHeight = 85;

    if (indexPath.row != 0 || self.type == TimeLineContentTypeOther) {
        
        if (self.dataSource.count>0) {
            
            
            LSTimeLineTableListModel * model = self.dataSource[ArrIndex];
            
            if (model.files.count>0) {
                LSTimeLineImageModel * fmodel = model.files[0];
                if (model.feed_type == 1 && fmodel.file_url.length==0) cellHeight = 40;
            }else{
                cellHeight = 40;
            }
        }
    }

    return  cellHeight;
}


-(void)pushToTimeLineMessageVC{
    LSTimeLineMessageViewController *vc = [[LSTimeLineMessageViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}


-(void)showLSOptionsView{
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


-(void)setUserID:(int)userID{
    _userID = userID;
    if (userID == [LSAppManager sharedAppManager].loginUser.user_id.intValue || self.userID == 0) {
        self.type = TimeLineContentTypeSelf;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navi_chat_more"] style:UIBarButtonItemStyleDone target:self action:@selector(pushToTimeLineMessageVC)];
    }else{
        self.type = TimeLineContentTypeOther;
        self.navigationItem.rightBarButtonItem = nil;
    }
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


-(void)changeBGImage:(NSNotification *)noti{
    
    if (self.userID == ShareAppManager.loginUser.user_id.intValue || self.userID == 0) {
        
        NSDictionary * infoDic = noti.userInfo;
        NSString * type = infoDic[@"type"];
        if ([type isEqualToString:@"TimeLine"]) return;
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
                                [self.view showLoading];
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
    }else
    {
        return;
    }
}



-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end



#define textwidth [UIApplication sharedApplication].keyWindow.frame.size.width-160

@interface LSHomeTimeLineTableViewCell ()
@property (nonatomic,strong) UILabel *dateLabel;
@property (nonatomic,strong) UIImageView *contentImageView;
@property (nonatomic,strong) UILabel * contentLabel;
@property (nonatomic,strong) UIView *bgView;

@end

@implementation LSHomeTimeLineTableViewCell

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
    self.dateLabel = [UILabel new];
    self.dateLabel.font = [UIFont systemFontOfSize:12];
    self.dateLabel.textColor = [UIColor blackColor];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.dateLabel];
    
    self.bgView = [UIView new];
    [self.contentView addSubview:self.bgView];
    
    
    self.contentImageView = [UIImageView new];
    [self.bgView addSubview:self.contentImageView];
    
    self.contentLabel = [UILabel new];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.textColor = [UIColor blackColor];
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    self.contentLabel.preferredMaxLayoutWidth = textwidth;
    [self.bgView addSubview:self.contentLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.right.equalTo(self.contentView).offset(-5);
        make.left.equalTo(self.contentView).with.offset(81);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];

    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.bgView);
        make.width.height.mas_equalTo(75);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(5);
        make.left.equalTo(self.contentView).with.offset(10);
        make.right.equalTo(self.contentImageView.mas_left).with.offset(-10);
        make.height.mas_equalTo(30);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.left.equalTo(self.contentImageView.mas_right).with.offset(5);
        make.right.equalTo(self.bgView).with.offset(-30);
        make.height.equalTo(self.contentImageView);
        
    }];
}
-(void)setType:(MyTimeLineCellType)type{
    _type = type;
}

-(void)setModel:(LSTimeLineTableListModel *)model{
    _model =model;
    if (model.files.count>0) {
 
        LSTimeLineImageModel * imageModel = self.model.files[0];
        if ( imageModel.file_url.length>0 && model.feed_type == 1){
            
            [self.contentImageView setImageWithURL:[NSURL URLWithString:imageModel.file_thumb] placeholder:[UIImage imageWithColor:HEXRGB(0xf3f3f3)]];
            self.type = MyTimeLineCellTypepic;
            self.contentLabel.numberOfLines = 0;

            
        }else if(model.feed_type == 2){
            self.type = MyTimeLineCellTypeVideo;
            [self.contentImageView setImageWithURL:[NSURL URLWithString:imageModel.file_thumb] placeholder:[UIImage imageWithColor:HEXRGB(0xf3f3f3)]];
            self.contentLabel.numberOfLines = 0;

        }else{
            self.type = MyTimeLineCellTypeText;
            self.contentLabel.numberOfLines = 1;
        }
    }
    
    [self changeConTraints];
    
    self.contentLabel.text = self.model.content;
    

}


-(void)setToday{
    NSMutableAttributedString *newATDate = [[NSMutableAttributedString alloc]initWithString:@"今天"];
    [newATDate setFont:[UIFont boldSystemFontOfSize:27]];
    self.dateLabel.attributedText =newATDate;
}

-(void)setCellDateWithDateStr:(NSString *)DateStr{
    if (DateStr.length>0) {
        self.dateLabel.attributedText =[self setDateFormatWithDateStr:DateStr];

    }else{
        self.dateLabel.attributedText = [[NSAttributedString alloc]initWithString:DateStr];
    }
}

-(NSAttributedString *)setDateFormatWithDateStr:(NSString *)dateStr{
    NSMutableAttributedString *ATTtext =[[NSMutableAttributedString alloc]initWithString:dateStr];
    
    NSRange range = [dateStr rangeOfString:@"月" options:NSCaseInsensitiveSearch];
        range.length = range.location+1;
        range.location = 0;
    NSUInteger length = dateStr.length-range.length;
    
    NSRange otherRange = NSMakeRange(range.length, length);
    [ATTtext setFont:[UIFont boldSystemFontOfSize:16] range:range];
    [ATTtext setFont:[UIFont boldSystemFontOfSize:10] range:otherRange];

    return ATTtext;
}


-(void)changeConTraints{

    switch (self.type) {
        case MyTimeLineCellTypepic:case MyTimeLineCellTypeVideo:
            [self.contentImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(75);
            }];
            self.bgView.backgroundColor = [UIColor whiteColor];
            break;
            
        case MyTimeLineCellTypeText:
            [self.contentImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(0);
            }];
            self.bgView.backgroundColor = HEXRGB(0xf3f3f3);
            
            break;
            
        case MyTimeLineCellTypeUrl:
            
            break;
            
        default:
            break;
    }
}


@end


@interface LSNewHomeTimeLineTableViewCell ()
@property (nonatomic,strong) UILabel *dateLabel;
@property (nonatomic,strong) UIButton *contentImageView;
@end

@implementation LSNewHomeTimeLineTableViewCell

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
    self.dateLabel = [UILabel new];
    self.dateLabel.font = [UIFont systemFontOfSize:12];
    self.dateLabel.textColor = [UIColor blackColor];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.dateLabel];
    
    self.contentImageView = [UIButton new];
    [self.contentView addSubview:self.contentImageView];
    
    
    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(81);
        make.top.equalTo(self.contentView).with.offset(5);
        make.width.height.mas_equalTo(75);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(5);
        make.left.equalTo(self.contentView).with.offset(10);
        make.right.equalTo(self.contentImageView.mas_left).with.offset(-10);
        make.height.mas_equalTo(30);
    }];
    NSMutableAttributedString *newATDate = [[NSMutableAttributedString alloc]initWithString:@"今天"];
    [newATDate setFont:[UIFont boldSystemFontOfSize:27]];
    self.dateLabel.attributedText =newATDate;
    
    [self.contentImageView setImage:[UIImage imageNamed:@"timeline_add_photos"]forState:UIControlStateNormal];
    [self.contentImageView addTarget:self action:@selector(showOptionsViewNoti) forControlEvents:UIControlEventTouchUpInside];
}

-(void)showOptionsViewNoti{
    [[NSNotificationCenter defaultCenter]postNotificationName:showOptionsViewNoti object:nil];
    
}

@end
