
//
//  LSFuwaHiddenViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaHiddenViewController.h"
#import "LSFuwaNewAdressModel.h"
#import "LSFuwaCreateLocationViewController.h"
#import "LSFuwaSelectedViewController.h"
#import "UIView+HUD.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "LSFuwaBackpackViewController.h"
#import "LSFuwaActivityInputView.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "LSCaptureViewController.h"
#import "LSFuwaModel.h"



static NSString *reuseId = @"LSFuwaLocationCell";

@interface LSFuwaHiddenViewController () <AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource,
                                          AMapLocationManagerDelegate>

@property (nonatomic, strong) AMapLocationManager *locationManager;

@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, assign) BOOL capturing;

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *changeButton;
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) NSArray<AMapPOI *> *pois;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic,strong) LSFuwaActivityInputView * actView;
@property (nonatomic,copy) NSString * fuwaCount;

@property (nonatomic,strong) NSMutableArray *locaArr;


@end

@implementation LSFuwaHiddenViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"藏福娃";
    

    [self configSubviews];

    [self configFocusBlock];

    //获取当前的位置
    [self initialLocation];

    [self setNotifications];
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingPathComponent:@"listArr.data"];
//    NSFileManager* fileManager=[NSFileManager defaultManager];
//    BOOL blDele= [fileManager removeItemAtPath:filePath error:nil];
    NSMutableArray *listArr = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    self.locaArr = listArr;
    [self.tableView reloadData];
    
    
    [super viewWillAppear:animated];
}

- (void)initialLocation {

    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 100;
    self.locationManager.locatingWithReGeocode = YES;
    [self.locationManager startUpdatingLocation];

    @weakify(self)
    [[[self rac_signalForSelector:@selector(amapLocationManager:didUpdateLocation:reGeocode:) fromProtocol:@protocol(AMapLocationManagerDelegate)] throttle:0.2] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)

        CLLocation *location = tuple.second;
        AMapLocationReGeocode *reGeocode = tuple.last;

        if (!reGeocode) return;
        [self.locationManager stopUpdatingLocation];

        NSString *title = reGeocode.POIName ? reGeocode.POIName
                                            : [NSString stringWithFormat:@"%@%@", reGeocode.street, reGeocode.number];
        self.currentLocation = location;
        if (self.locaArr.count>0) {
            LSFuwaNewAdressModel * model = self.locaArr[0];
                    [self.locationButton setTitle:model.name forState:UIControlStateNormal];

        }else{
                    [self.locationButton setTitle:@"请创建新位置" forState:UIControlStateNormal];
        }
        
        NSMutableArray *keywords = [NSMutableArray array];
        if (reGeocode.POIName) {
            [keywords addObject:reGeocode.POIName];
        }
        if (reGeocode.AOIName) {
            [keywords addObject:reGeocode.AOIName];
        }
        if (reGeocode.street) {
            [keywords addObject:reGeocode.street];
        }
        //周边搜索
        [self poiSearchWithLocation:location keywords:keywords];
    }];

    [[self rac_signalForSelector:@selector(amapLocationManager:didChangeAuthorizationStatus:) fromProtocol:@protocol(AMapLocationManagerDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        CLAuthorizationStatus status = (CLAuthorizationStatus)[[tuple last] integerValue];

        if (status == kCLAuthorizationStatusDenied) {

            if (![CLLocationManager locationServicesEnabled]) return;

            [self.view showAlertWithTitle:@"系统提示" message:@"应用需要开启位置访问权限" cancelAction:nil doneAction:^{
               //跳转到应用的设置界面
               NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
               if (![[UIApplication sharedApplication] canOpenURL:url]) return;
               [[UIApplication sharedApplication] openURL:url];
           }];
        }
    }];
}

- (void)configSubviews {

    UILabel *tipsLabel = [UILabel new];
    self.tipsLabel = tipsLabel;
    tipsLabel.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0.5];
    tipsLabel.text = @"对准目标停留一会儿";
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.font = SYSTEMFONT(14);
    [self.view addSubview:tipsLabel];
    ViewRadius(tipsLabel, 15);
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view.mas_bottom).offset(-(kScreenHeight - CGRectGetMaxY(self.rectView.frame)) * 0.5);
        make.height.offset(30);
        make.width.offset(175);
    }];

    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.locationButton = locationButton;
    locationButton.titleLabel.font = SYSTEMFONT(14);
    [locationButton setImage:[UIImage imageNamed:@"fuwa_position_bz"] forState:UIControlStateNormal];
    [locationButton setTitle:@"正在定位" forState:UIControlStateNormal];
    [locationButton setTitleColor:HEXRGB(0xffffff) forState:UIControlStateNormal];
    [self.view addSubview:locationButton];
    ViewBorderRadius(locationButton, 19, 1, HEXRGB(0xff0012));
    locationButton.backgroundColor = [UIColor colorWithRGB:0xd3000f alpha:0.65];
    [locationButton addTarget:self action:@selector(locationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        CGFloat offset = (self.rectView.top - 64) * 0.5;
        make.centerY.equalTo(self.mas_topLayoutGuide).offset(offset);
        make.height.offset(38);
        make.width.offset(182);
    }];

    [locationButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [locationButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [locationButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 30)];

    UIImageView *iconView = [UIImageView new];
    self.iconView = iconView;
    iconView.image = [UIImage imageNamed:@"fuwa_nospread"];
    [locationButton addSubview:iconView];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(locationButton);
        make.centerX.equalTo(locationButton.mas_right).offset(-20);
    }];

    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.changeButton = changeButton;
    changeButton.titleLabel.font = SYSTEMFONT(15);
    [changeButton setTitle:@"换个地方" forState:UIControlStateNormal];
    [changeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:changeButton];
    [changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-50);
    }];
    @weakify(self)
    [[changeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *_Nullable x) {
        @strongify(self)
        [self updateView:NO];
    }];

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveButton = saveButton;
    saveButton.titleLabel.font = BOLDSYSTEMFONT(18);
    saveButton.backgroundColor = HEXRGB(0xd3000f);
    ViewBorderRadius(saveButton, 5, 1, HEXRGB(0xff0012));
    [saveButton setTitle:@"藏在这里" forState:UIControlStateNormal];
    [saveButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateNormal];
    [self.view addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(changeButton.mas_top).offset(-21);
        make.height.offset(45);
        make.width.equalTo(locationButton);
    }];

    [[saveButton rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(__kindof UIControl *_Nullable x) {
            @strongify(self)

        if (!self.currentLocation) {
            [self.view showAlertWithTitle:@"系统提示" message:@"无法定位当前位置,请检查是否开启位置权限" cancelAction:nil doneAction:^{
               //跳转到应用的设置界面
               NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
               if (![[UIApplication sharedApplication] canOpenURL:url]) return;
               [[UIApplication sharedApplication] openURL:url];
           }];
        }else if([self.locationButton.currentTitle isEqualToString:@"请创建新位置"]||[self.locationButton.currentTitle isEqualToString:@""]){
            [LSKeyWindow showError:@"请创建新位置" hideAfterDelay:0.5];
            return;
        }else {
            
            LSFuwaHiddenCountView * countView = [LSFuwaHiddenCountView fuwaHiddenCountView];
            countView.frame = self.view.bounds;
            [self.view addSubview:countView];
            
            [countView setHiddenFuwaCount:^(NSString * countStr,fuwaHiddenCountType hiddenType) {
                
                self.fuwaCount = countStr;
                self.actView =   [LSFuwaActivityInputView showInView:self.view hiddenType:hiddenType doneAction:^(NSString *detailString, LSCaptureModel *model, NSString *day, NSString *fuwaType) {
                    @strongify(self)
                    detailString = !detailString ? @"" : detailString;
                    [self sendSaveRequestActivityDetail:detailString videoModel:model day:day hiddenType:hiddenType fuwaType:fuwaType];
                } skipAction:^(NSString * day){
                } selectVideo:^{
                    TZImagePickerController *TZimagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
                    TZimagePickerVc.isSelectOriginalPhoto = YES;
                    TZimagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
                    TZimagePickerVc.allowPickingVideo = YES;
                    TZimagePickerVc.allowPickingImage = NO;
                    TZimagePickerVc.allowPickingOriginalPhoto = NO;
                    TZimagePickerVc.allowPickingGif = NO;
                    @weakify(self)
                    [TZimagePickerVc setDidFinishPickingVideoHandle:^(UIImage * coverImage, id asset) {
            
            
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
                            self.actView.model = model;
                        }];
                        
                    }];
                    
                    [self presentViewController:TZimagePickerVc animated:YES completion:nil];
                    
                } recordVideo:^{
                    LSCaptureViewController * videoVC = [LSCaptureViewController new];
                    UINavigationController *NavVc = [[UINavigationController alloc]initWithRootViewController:videoVC];
                    [self presentViewController:NavVc animated:YES completion:nil];
                    videoVC.capCompleteBlock =^(LSCaptureModel *model){
                        self.actView.model = model;
                    };
                    
                }];
                
            }];
            
        }

    }];

    UIImageView *coverView = [UIImageView new];
    coverView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverView = coverView;
    [self.view insertSubview:coverView belowSubview:self.cycleView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self updateView:NO];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [tableView registerClass:[LSFuwaLocationCell class] forCellReuseIdentifier:reuseId];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor colorWithRGB:0xd3000f alpha:0.65];
    tableView.rowHeight = 50;
    self.tableView = tableView;
    ViewBorderRadius(tableView, 3, 1, HEXRGB(0xff0012));
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(locationButton);
        make.top.equalTo(locationButton.mas_bottom).offset(10);
        make.width.offset(256);
        make.height.offset(350);
    }];

    LSFuwaSearchView *headerView = [[LSFuwaSearchView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 50)];
    tableView.tableHeaderView = headerView;
    headerView.backgroundColor = [UIColor clearColor];
    [headerView setSearchBlock:^{
        @strongify(self)
        
        if (!self.currentLocation) {
            [self.view showAlertWithTitle:@"系统提示" message:@"无法定位当前位置,请检查是否开启位置权限" cancelAction:nil doneAction:^{
                //跳转到应用的设置界面
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if (![[UIApplication sharedApplication] canOpenURL:url]) return;
                [[UIApplication sharedApplication] openURL:url];return;
            }];
        }
//        LSFuwaSearchLocationViewController *searchVC = [LSFuwaSearchLocationViewController new];
//        searchVC.pois = self.pois;
//        UINavigationController *naviVC =
//            [[UINavigationController alloc] initWithRootViewController:searchVC];
//        [self presentViewController:naviVC animated:YES completion:nil];
        LSFuwaCreateLocationViewController * createVC =[[UIStoryboard storyboardWithName:@"Fuwa" bundle:nil]instantiateViewControllerWithIdentifier:@"LSFuwaCreateLocationViewController"];
        
        if (self.pois.count>0) {
            AMapPOI * poi = self.pois[0];
            createVC.city = poi.city;
            createVC.district = poi.district;
        }
            UINavigationController *naviVC =
                [[UINavigationController alloc] initWithRootViewController:createVC];
            [self presentViewController:naviVC animated:YES completion:nil];
    }];
    tableView.hidden = YES;
}



- (void)sendSaveRequestActivityDetail:(NSString *)detail videoModel:(LSCaptureModel *)videoModel day:(NSString *)day hiddenType:(fuwaHiddenCountType)type fuwaType:(NSString *)fuwaType{
    
    LFUITips *tips = [LFUITips showLoading:@"正在上传...." inView:LSKeyWindow];
    [LSKeyWindow addSubview:tips];
    
    NSString * typeStr;
    NSString * Class;
    if (type == fuwaHiddenCountTypeMerChant) {
        typeStr = @"1";
        Class = fuwaType;
    }else{
        typeStr = @"0";
        Class = @"i";
    }
    
    if (videoModel!=nil) {
  
        
        [LSFuwaModel saveFuwaVideoWith:self.locationButton.currentTitle location:self.currentLocation Fuwacount:self.fuwaCount cluesImage:self.coverView.image detail:detail videoModel:videoModel validtime:day type:typeStr class:Class uploadProgress:^(NSProgress *progress) {
            
            kDISPATCH_MAIN_THREAD((^{
                tips.detailsLabel.text =[NSString stringWithFormat:@"%.2f%%",(CGFloat)progress.completedUnitCount/progress.totalUnitCount*100.00];
                
            }));
        } success:^{
            UIViewController *vc = [NSClassFromString(@"LSFuwaHiddenSuccessViewController") new];
            [vc setValue:self.coverView.image forKey:@"cluesImage"];
            [vc setValue:self.self.locationButton.currentTitle forKey:@"position"];
            [self.navigationController pushViewController:vc animated:YES];
            
            [tips showSucceed:@"发布成功" hideAfterDelay:1];
            

        } failure:^(NSError *error) {
            [tips showError:@"发布失败" hideAfterDelay:1];
            
        }];
        
    }else{
        
        
        
        [LSFuwaModel saveFuwaWith:self.locationButton.currentTitle location:self.currentLocation Fuwacount:self.fuwaCount cluesImage:self.coverView.image detail:detail validtime:day type:typeStr class:Class uploadProgress:^(NSProgress *progress) {
            kDISPATCH_MAIN_THREAD((^{
                tips.detailsLabel.text =[NSString stringWithFormat:@"%.2f%%",(CGFloat)progress.completedUnitCount/progress.totalUnitCount*100.00];
                
            }));
        } success:^{
            UIViewController *vc = [NSClassFromString(@"LSFuwaHiddenSuccessViewController") new];
            [vc setValue:self.coverView.image forKey:@"cluesImage"];
            [vc setValue:self.self.locationButton.currentTitle forKey:@"position"];
            [self.navigationController pushViewController:vc animated:YES];
            
            [tips showSucceed:@"发布成功" hideAfterDelay:1];
        } failure:^(NSError *error) {
            [tips showError:@"发布失败" hideAfterDelay:1];

        }];
        
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


- (void)updateView:(BOOL)complete {

    self.coverView.hidden = !complete;
    self.changeButton.hidden = !complete;
    self.saveButton.hidden = !complete;

    self.tipsLabel.hidden = complete;

    if (!complete) {
        self.capturing = NO;
    }
}

- (void)configFocusBlock {

    @weakify(self)
    [self setFocusCompleteBlock:^{
        @strongify(self)
        if (self.capturing) return;

        [self captureComplete:^(UIImage *image, NSError *error) {
            if (error || !image) {
                self.capturing = NO;
            } else {
                self.coverView.image = image;
                [self updateView:YES];
            }
        }];

        self.capturing = YES;
    }];
}

#pragma mark - Action
- (void)locationButtonAction:(UIButton *)button {
    button.selected = !button.selected;

    if (button.selected) {
        self.iconView.image = [UIImage imageNamed:@"fuwa_spread"];
        self.tableView.hidden = NO;
    } else {
        self.iconView.image = [UIImage imageNamed:@"fuwa_nospread"];
        self.tableView.hidden = YES;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self locationButtonAction:self.locationButton];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locaArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LSFuwaLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];

    cell.model = self.locaArr[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSFuwaNewAdressModel * model = self.locaArr[indexPath.row];

    [self.locationButton setTitle:model.name forState:UIControlStateNormal];
    [self locationButtonAction:self.locationButton];
}

- (void)poiSearchWithLocation:(CLLocation *)location keywords:(NSArray *)keywords {

    AMapSearchAPI *search = [[AMapSearchAPI alloc] init];
    self.search = search;
    search.delegate = self;

    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.keywords = [keywords componentsJoinedByString:@"|"];

    request.location =
        [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    /* 按照距离排序. */
    request.sortrule = 0;
    request.requireExtension = YES;

    //发起检索
    [search AMapPOIAroundSearch:request];

    @weakify(self)
    [[self rac_signalForSelector:@selector(onPOISearchDone:response:) fromProtocol:@protocol(AMapSearchDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        AMapPOISearchResponse *response = tuple.last;

        self.pois = response.pois;
        [self.tableView reloadData];

        self.search = nil;
    }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

    if (status == kCLAuthorizationStatusDenied) {

        if (![CLLocationManager locationServicesEnabled]) return;

        [self.view showAlertWithTitle:@"系统提示" message:@"应用需要开启地图访问权限" cancelAction:nil doneAction:^{
               //跳转到应用的设置界面
               NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
               if (![[UIApplication sharedApplication] canOpenURL:url]) return;
               [[UIApplication sharedApplication] openURL:url];
        }];
    }
}

- (void)setNotifications {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kFuwaNewAdressNoti object:nil] subscribeNext:^(NSNotification * _Nullable noti) {
        @strongify(self)
        NSDictionary *info = noti.userInfo;
        LSFuwaNewAdressModel *model = info[@"LSFuwaNewAdressModel"];
        [self.locationButton setTitle:model.name forState:UIControlStateNormal];
    }];
}

@end

@implementation LSFuwaLocationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];

        UIImageView *iconView = [UIImageView new];
        iconView.image = [UIImage imageNamed:@"fuwa_position_bz"];
        [self addSubview:iconView];

        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.centerX.equalTo(self.mas_left).offset(20);
        }];

        UILabel *titleLabel = [UILabel new];
        self.titleLabel = titleLabel;
        titleLabel.font = SYSTEMFONT(14);
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(-10);
            make.left.equalTo(iconView.mas_right).offset(10);
            make.right.equalTo(self).offset(-15);
        }];

        UILabel *subLabel = [UILabel new];
        self.subLabel = subLabel;
        subLabel.font = SYSTEMFONT(12);
        subLabel.textColor = HEXRGB(0xcccccc);
        [self addSubview:subLabel];
        [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(9);
            make.left.equalTo(titleLabel);
            make.right.equalTo(titleLabel);
        }];
    }
    return self;
}

-(void)setModel:(LSFuwaNewAdressModel *)model{
    _model = model;
    self.titleLabel.text = model.name;
    self.subLabel.text = model.totalAdress;
    
}
@end

@implementation LSFuwaSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *searchBtn = [UIButton new];
        @weakify(self)
        [[searchBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            self.searchBlock();
        }];
        [self addSubview:searchBtn];

        [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        searchBtn.alpha = 0.3;
        searchBtn.backgroundColor = HEXRGB(0x000000);

        UIImageView *searchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchfuwa"]];

        [searchBtn addSubview:searchImageView];

        UILabel *searchLabel = [UILabel new];
        searchLabel.text = @"创建你现在的位置";
        searchLabel.font = [UIFont systemFontOfSize:12];
        searchLabel.textColor = [UIColor whiteColor];
        [searchBtn addSubview:searchLabel];

        [searchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(searchBtn);
        }];

        [searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(searchLabel);
            make.width.height.mas_equalTo(15);
            make.right.equalTo(searchLabel.mas_left);
        }];
    }
    return self;
}

@end

@interface LSFuwaHiddenCountView ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (weak, nonatomic) IBOutlet UITextField *hiddenCountTextField;
@property (nonatomic,strong) LSFuwaActivityInputView * actView;

@property (weak, nonatomic) IBOutlet UIButton *merchantBtn;
@property (weak, nonatomic) IBOutlet UIButton *personBtn;

@property (nonatomic,assign) int personCount;

@property (nonatomic,assign) int MerChantCount;

@property (nonatomic,assign)fuwaHiddenCountType  type;

@end

@implementation LSFuwaHiddenCountView

+ (instancetype)fuwaHiddenCountView{
    return [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaHiddenCountView" owner:nil options:nil]lastObject];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    NSString *holderText = @"填写要藏福娃的个数";
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
    [placeholder addAttribute:NSForegroundColorAttributeName
                        value:HEXRGB(0x999999)
                        range:NSMakeRange(0, holderText.length)];
    self.hiddenCountTextField.attributedPlaceholder = placeholder;
    self.type = fuwaHiddenCountTypeMerChant;
    self.merchantBtn.selected = YES;
    
    [LSFuwaBackPackModel searchApplyFuwaCountSuccess:^(int personCount,int MerChantCount) {
        self.personCount = personCount;
        self.MerChantCount = MerChantCount;
        
        if (self.type == fuwaHiddenCountTypeMerChant) {
            self.totalCountLabel.text = [NSString stringWithFormat:@"可藏商家福娃(个数):%i",MerChantCount];
            self.totalCountLabel.textColor =[UIColor whiteColor];
        }else{
            self.totalCountLabel.text = [NSString stringWithFormat:@"可藏个人福娃(个数):%i",personCount];
        }

        self.totalCountLabel.textColor = [UIColor whiteColor];
    } failure:^(NSError *error) {
        [LSKeyWindow showError:@"获取福娃信息失败" hideAfterDelay:0.5];
    }];
    
    self.hiddenCountTextField.delegate = self;
    
}



-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSString * new_text_str = [textField.text stringByReplacingCharactersInRange:range withString:string];//变化后的字符串
    
    
    if (![self isPureInt:new_text_str]) {
        self.totalCountLabel.text = @"福娃个数只能是整数";
        self.totalCountLabel.textColor = HEXRGB(0xe7d09a);
        
    }else if ((new_text_str.intValue > self.MerChantCount && self.type == fuwaHiddenCountTypeMerChant) ||(new_text_str.intValue > self.personCount && self.type == fuwaHiddenCountTypePerson)){
        self.totalCountLabel.text = @"输入个数超过您申请福娃的个数";
        self.totalCountLabel.textColor = HEXRGB(0xe7d09a);
        
    }else{
        if (self.type == fuwaHiddenCountTypeMerChant) {
            self.totalCountLabel.text = [NSString stringWithFormat:@"可藏商家福娃(个数):%i",self.MerChantCount];
            self.totalCountLabel.textColor =[UIColor whiteColor];
        }else{
            self.totalCountLabel.text = [NSString stringWithFormat:@"可藏个人福娃(个数):%i",self.personCount];
        }
        
        self.totalCountLabel.textColor = [UIColor whiteColor];
        
    }
    return YES;
}

-(void)selfRemove{
    [self endEditing:YES];
    [self removeFromSuperview];
}

- (IBAction)bgBtnAction:(id)sender {
    [self selfRemove];
    
}
- (IBAction)cancelBtnAction:(id)sender {
    [self selfRemove];
}

- (IBAction)sureAction:(id)sender {
    [self endEditing:YES];
    if (self.hiddenCountTextField.text.length == 0) {
        [LSKeyWindow showError:@"个数不能为空" hideAfterDelay:0.5];
        return;
    } else if (![self isPureInt:self.hiddenCountTextField.text]) {
        self.totalCountLabel.text = @"福娃个数只能是整数";
        self.totalCountLabel.textColor = HEXRGB(0xe7d09a);
        return;
    }else if ((self.hiddenCountTextField.text.intValue> self.MerChantCount && self.type == fuwaHiddenCountTypeMerChant) ||(self.hiddenCountTextField.text.intValue > self.personCount && self.type == fuwaHiddenCountTypePerson)){
        self.totalCountLabel.text = @"输入个数超过您申请福娃的个数";
        self.totalCountLabel.textColor = HEXRGB(0xe7d09a);
        return;
        
    }else if (self.hiddenCountTextField.text.intValue <1)
    {
        [LSKeyWindow showError: @"个数不能小于1" hideAfterDelay:0.5];
        return;
    }
    
    self.hiddenFuwaCount(self.hiddenCountTextField.text,self.type);
    [self removeFromSuperview];
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}


-(void)setType:(fuwaHiddenCountType)type{
    _type = type;
    if (self.type == fuwaHiddenCountTypeMerChant) {
        self.totalCountLabel.text = [NSString stringWithFormat:@"可藏商家福娃(个数):%i",self.MerChantCount];
        self.totalCountLabel.textColor =[UIColor whiteColor];
    }else{
        self.totalCountLabel.text = [NSString stringWithFormat:@"可藏个人福娃(个数):%i",self.personCount];
    }
    self.totalCountLabel.textColor =[UIColor whiteColor];
}


- (IBAction)MerchantBtnAction:(UIButton *)sender {
    self.type = fuwaHiddenCountTypeMerChant;
    sender.selected = YES;
    self.personBtn.selected = NO;
    
}

- (IBAction)personBtnAction:(UIButton *)sender {
    self.type = fuwaHiddenCountTypePerson;
    sender.selected = YES;
    self.merchantBtn.selected = NO;
    
}


@end
