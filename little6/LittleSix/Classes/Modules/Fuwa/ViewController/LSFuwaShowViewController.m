//
//  LSFuwaShowViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaShowViewController.h"
#import "LSFuwaCatchViewController.h"
#import "LSFuwaLocationInfoView.h"
#import "LSFuwaCatchListView.h"
#import "LSFuwaModel.h"
#import "LSUserAnnotationView.h"
#import "UIView+HUD.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

static NSString *const reuse_id = @"reuse_id";
static NSString *const user_reuse_id = @"user_reuse_id";
static CGFloat const maxLevelZoomMeter = 0.357115;


@interface LSFuwaShowViewController () <MAMapViewDelegate, CLLocationManagerDelegate, AMapNaviWalkManagerDelegate,LSFuwaActivityViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, assign) BOOL isRequest;

@property (nonatomic, strong) NSMutableArray<LSFuwaModel *> *models;
@property (nonatomic, strong) NSMutableArray<LSAnnotation *> *annotations;
@property (nonatomic, strong) NSMutableArray<LSFuwaModel *> *nearFuwaList;

@property (nonatomic, strong) LSFuwaLocationInfoView *infoView;
@property (nonatomic, strong) LSFuwaCatchListView *listView;
@property (nonatomic, weak) LSFuwaActivityView *activityView;

@property (nonatomic, assign) BOOL isShowInfoView;
@property (nonatomic, assign) BOOL isShowListView;

@property (nonatomic, strong) AMapNaviWalkManager *naviManager;

@property (nonatomic,copy) NSString * lastListFuwaNum;
@property (nonatomic,assign) BOOL isCanCatch;
@property (nonatomic,strong) MAUserLocation  *lastUserLoaction;
@property (nonatomic,assign) CLLocationCoordinate2D lastCenterLoaction;
@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,assign) CGFloat lastZoomLevel;

@property (nonatomic,assign) BOOL isMerchantFirstShow;

@end

@implementation LSFuwaShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isMerchantFirstShow = YES;
    

    [self navigationBarConfig];

    [self requestAuthorStatus];
    
    [self manageWalkRoutes];

    [self inistallSubviews];
    self.models = [NSMutableArray array];
    
    self.lastListFuwaNum = @"nil";

}

- (void)requestAuthorStatus {
    //权限判断
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    
    [[self rac_signalForSelector:@selector(locationManager:didChangeAuthorizationStatus:) fromProtocol:@protocol(CLLocationManagerDelegate)] subscribeNext:^(RACTuple   * _Nullable tuple) {
        
        CLAuthorizationStatus status = (CLAuthorizationStatus)[tuple.last integerValue];
        
        if (status != kCLAuthorizationStatusDenied) return;
        
        if (![CLLocationManager locationServicesEnabled]) return;
        
        [LSKeyWindow showAlertWithTitle:@"系统提示" message:@"应用需要开启地图访问权限" cancelAction:nil doneAction:^{
               //跳转到应用的设置界面
               NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
               if (![[UIApplication sharedApplication] canOpenURL:url]) return;
               [[UIApplication sharedApplication] openURL:url];
        }];
    }];
}

- (void)manageWalkRoutes {
    
    self.naviManager = [[AMapNaviWalkManager alloc] init];
    [self.naviManager setDelegate:self];

    @weakify(self)
    [[self rac_signalForSelector:@selector(walkManagerOnCalculateRouteSuccess:) fromProtocol:@protocol(AMapNaviWalkManagerDelegate)] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        
        if (self.naviManager.naviRoute == nil) return;
        
        //移除线路
        [self.mapView removeOverlays:self.mapView.overlays];
        AMapNaviRoute *aRoute = self.naviManager.naviRoute;
        int count = (int)[[aRoute routeCoordinates] count];

        //添加路径Polyline
        CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < count; i++)
        {
            AMapNaviPoint *coordinate = [[aRoute routeCoordinates] objectAtIndex:i];
            coords[i].latitude = [coordinate latitude];
            coords[i].longitude = [coordinate longitude];
        }
        
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:count];
        
        [self.mapView addOverlay:polyline];
        free(coords);
        
        self.infoView.routeTime = (long)aRoute.routeTime;
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar setTranslucent:NO];

    UIImage *image = [[UIImage imageNamed:@"fuwa_top"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];

    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)navigationBarConfig {

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    [self.navigationController.navigationBar setTranslucent:NO];

    UIImage *image = [[UIImage imageNamed:@"fuwa_top"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)resizingMode:UIImageResizingModeStretch];

    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    //返回提示
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kFuwaCatchInfoNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSString * message = x.object;
        [self.view showError:message hideAfterDelay:2.0];
    }];
}

- (void)inistallSubviews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加地图
    MAMapView *mapView = [[MAMapView alloc] initWithFrame:CGRectZero];
    self.mapView = mapView;
    mapView.showsScale = YES;
    mapView.showsCompass = YES;
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MKUserTrackingModeFollow;
    

    [self.view addSubview:mapView];

    [mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];

    UIButton *hidenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hidenButton.titleLabel.font = SYSTEMFONT(16);
    [hidenButton setTitle:@"藏福娃" forState:UIControlStateNormal];
    [hidenButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateNormal];
    hidenButton.backgroundColor = HEXRGB(0xd3000f);
    ViewBorderRadius(hidenButton, 75 * 0.5, 1, HEXRGB(0xff0012));
    [self.view addSubview:hidenButton];
    [hidenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(75);
        make.right.equalTo(self.view).offset(-15);
        make.bottom.equalTo(self.view).offset(-42);
    }];
    
    @weakify(self)
    [[hidenButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        UIViewController *vc = [NSClassFromString(@"LSFuwaHiddenViewController") new];
        [self.navigationController pushViewController:vc animated:YES];
    }];

    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationButton addTarget:self
                       action:@selector(locationButtonAction:)
             forControlEvents:UIControlEventTouchUpInside];

    locationButton.titleLabel.font = SYSTEMFONT(16);
    [locationButton setTitle:@"开始捕抓" forState:UIControlStateNormal];
    [locationButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateNormal];
    locationButton.backgroundColor = HEXRGB(0xd3000f);
    ViewBorderRadius(locationButton, 75 * 0.5, 1, HEXRGB(0xff0012));
    [self.view addSubview:locationButton];
    [locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.width.height.offset(75);
        make.centerY.equalTo(hidenButton);
    }];

    //距离信息
    LSFuwaLocationInfoView *infoView = [LSFuwaLocationInfoView fuwaLocationView];
    infoView.frame = [UIScreen mainScreen].bounds;
    [infoView layoutIfNeeded];
    self.infoView = infoView;
    [self.view addSubview:infoView];

    [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.offset(CGRectGetMaxY(infoView.bottomLineView.frame));
        make.bottom.equalTo(self.mas_topLayoutGuide);
    }];
    
    //更新约束
    [infoView setUpdateViewBlock:^(void) {
        @strongify(self)
        [self.infoView layoutIfNeeded];
        CGFloat viewHeight = CGRectGetMaxY(self.infoView.bottomLineView.frame);
        [UIView animateWithDuration:0.2 animations:^{
             [self.infoView mas_updateConstraints:^(MASConstraintMaker *make) {
                 make.height.offset(viewHeight);
                 make.bottom.equalTo(self.mas_topLayoutGuide).offset(viewHeight);
             }];
        }];
    }];
    

    //详情按钮事件
    [infoView setDetailBlock:^{
        @strongify(self)
        LSFuwaActivityView *activityView = [LSFuwaActivityView showInView:self.view];
        activityView.delegate = self;
        [activityView setValue:self.infoView.model forKey:@"model"];
        
        [activityView setPlayClick:^(NSString *playUrl, UIImage *image) {
            UIViewController * vc = [NSClassFromString(@"LSVideoPlayerViewController") new];
            [vc setValue:[NSURL URLWithString:playUrl] forKey:@"playURL"];
            [vc setValue:image forKey:@"coverImage"];
            [self presentViewController:vc animated:YES completion:nil];
        }];
    }];
    
    
    
    [infoView setExpandBlock:^(BOOL expand){
        @strongify(self)
        expand ? [self showInfoView] : [self dismissInfoView];
    }];
    

    //附近福娃列表
    LSFuwaCatchListView *listView = [LSFuwaCatchListView LSFuwaCatchListView];
    listView.frame = [UIScreen mainScreen].bounds;
    [listView layoutIfNeeded];
    self.listView = listView;
    self.listView.hidden = YES;
    
    [self.listView setRefreshTableFootBlock:^(NSString * fuwaNum) {
        @strongify(self)
        if (![self.lastListFuwaNum isEqualToString:fuwaNum]) {
            [self loadNearByDataWithBiggest:fuwaNum];
        }
    }];
    [self.view addSubview:listView];
    
    [listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
//        make.height.offset(CGRectGetMaxY(listView.bottomLineView.frame));
        
        make.height.mas_equalTo(270);
        make.bottom.equalTo(self.mas_topLayoutGuide).offset(10);
    }];
    [listView setExpandBlock:^(BOOL expand){
        @strongify(self)
        expand ? [self showListView] : [self dismissListView];
    }];
    
    
    //附近捕获按钮事件
    [listView setCatchActionBlock:^(LSFuwaModel *model) {
        @strongify(self)
        LSFuwaCatchViewController *vc = [NSClassFromString(@"LSFuwaCatchViewController") new];
        [vc setValue:model forKey:@"model"];
        [vc setValue:@"0.2" forKey:@"screenShots"];
        @weakify(self)
        [vc setCatchSuccessBlock:^{
            @strongify(self)
//            if (listView.dataSource.count>2) {
//                LSFuwaModel * lastFuwaModel = self.listView.dataSource[self.listView.dataSource.count-1];
//                
//                if ([lastFuwaModel.gid isEqualToString:model.gid]) {
//                    LSFuwaModel * secondLastFuwaModel = self.listView.dataSource[self.listView.dataSource.count-2];
//                    NSArray *strArray = [secondLastFuwaModel.gid componentsSeparatedByString:@"_"];
//                    NSString *numStr =strArray[2];
//                    self.lastListFuwaNum =numStr;
//                }
//
//            }
            [self dismissInfoView];
            [self.mapView removeAnnotation:model.annotation];
            [self.annotations removeObject:model.annotation];
            [self.listView.dataSource removeObject:model];
            [self.listView reloadData];
            //移除绘制的线路
            [self.mapView removeOverlays:self.mapView.overlays];
            for (LSFuwaModel * fuwaModel in self.nearFuwaList) {
                if ([fuwaModel.gid isEqualToString:model.gid]) {
                    [self.nearFuwaList removeObject:fuwaModel];
                    break;
                }
            }
            self.listView.dataSource = self.nearFuwaList;
            [self.listView reloadData];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    //附近详情按钮事件
    [listView setDetailBlock:^(LSFuwaModel * model){
        @strongify(self)
        LSFuwaActivityView *activityView = [LSFuwaActivityView showInView:self.view];
        [activityView setValue:model forKey:@"model"];
        
        activityView.delegate = self;
        
        [activityView setPlayClick:^(NSString *playUrl, UIImage *image) {
            UIViewController * vc = [NSClassFromString(@"LSVideoPlayerViewController") new];
            [vc setValue:[NSURL URLWithString:playUrl] forKey:@"playURL"];
            [vc setValue:image forKey:@"coverImage"];
            [self presentViewController:vc animated:YES completion:nil];
        }];
        
    }];
    

}

-(void)pushWebViewWithView:(LSFuwaActivityView *)View urlStr:(NSString *)urlStr{
    [View removeFromSuperview];
    
    UIViewController *vc = [NSClassFromString(@"LSWebViewController") new];
    [vc setValue:urlStr forKey:@"urlString"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - Action
- (void)locationButtonAction:(UIButton *)button {
    [self.mapView removeOverlays:self.mapView.overlays];
    CLLocationCoordinate2D center = self.mapView.userLocation.location.coordinate;
    MACoordinateSpan span = self.mapView.region.span;
    MACoordinateRegion region = MACoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:YES];
    [self dismissInfoView];
    
    CGFloat MerRadius = 1000.f;
    CGFloat logNum = MerRadius/LSKeyWindow.height/2/maxLevelZoomMeter/2;
    CGFloat difference = log2(logNum);
    [self.mapView setZoomLevel:16-difference animated:YES];
    
    self.isCanCatch = YES;
    self.lastListFuwaNum = @"nil";
}

- (void)showInfoView {
    
    if (self.isShowInfoView) return;
    
    [self.infoView layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [self.infoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_topLayoutGuide).offset(self.infoView.height);
        }];
        [self.view layoutIfNeeded];
        [self.view bringSubviewToFront:self.infoView];

    } completion:^(BOOL finished) {
        self.isShowInfoView = YES;
        self.infoView.expandButton.selected = NO;
    }];
}

- (void)dismissInfoView {
    
    if (!self.isShowInfoView) return;
    
    [self.infoView layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [self.infoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_topLayoutGuide);
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isShowInfoView = NO;
    }];
}

- (void)showListView {
    
    if (self.isShowListView) return;
    self.listView.hidden = NO;
    [self.listView layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [self.listView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_topLayoutGuide).offset(self.listView.height);
        }];
        [self.view layoutIfNeeded];
        [self.view bringSubviewToFront:self.listView];

    } completion:^(BOOL finished) {
        self.isShowListView = YES;
        self.listView.expandButton.selected = NO;
    }];
}

- (void)dismissListView {
    
    if (!self.isShowListView) return;
    
    [self setCancatchType];
    
    [self.listView layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [self.listView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_topLayoutGuide).offset(-20);
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isShowListView = NO;
    }];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {

    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        
        MAAnnotationView *userAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:user_reuse_id];
        
        if (!userAnnotationView) {
            userAnnotationView =
            [[LSUserAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:user_reuse_id];
        }
        
        return userAnnotationView;
    }
    
    
    MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuse_id];
    
    if (!annotationView) {
        annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuse_id];
    }
    
    annotationView.annotation = annotation;
    annotationView.image = [UIImage imageNamed:@"fuwa_loca"];
    
    return annotationView;

}
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    
    [LSKeyWindow hideHUDAnimated:YES];
}
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[MAUserLocation class]]) return;
    
    //移除线路
    [self.mapView removeOverlays:self.mapView.overlays];
    
    NSUInteger index = [self.annotations indexOfObject:view.annotation];
    LSFuwaModel *model = self.models[index];
    
    CLLocationDistance totalDistance = [self.mapView.userLocation.location distanceFromLocation:[[CLLocation alloc] initWithLatitude:model.annotation.coordinate.latitude longitude:model.annotation.coordinate.longitude]];
    
    if (totalDistance>500 || !self.isCanCatch ) {
        [self showInfoView];
        [self dismissListView];
        //不需要重新计算、赋值
//        if ([self.infoView.model isEqual:model]) return;
        
        self.infoView.model = model;
        
        MAUserLocation *userLocation = self.mapView.userLocation;
        
        self.infoView.startLocation = userLocation.location;
        self.infoView.currentLocation = userLocation.location;
        
        //添加线路
        [self strokePath:self.mapView.userLocation];
    }else{
        self.listView.dataSource = self.nearFuwaList;
        [self.listView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(4*60+30);
            
        }];
        [self dismissInfoView];
        [self showListView];
    }

}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {

    MAPolylineRenderer *render = [[MAPolylineRenderer alloc] initWithOverlay:overlay];

    render.lineWidth = 5;
    render.strokeColor = [UIColor colorWithRGB:0xd3000f alpha:0.8];

    return render;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {

    if (updatingLocation) return;
    
    if (!self.isShowInfoView) return;
    
    CLLocationDistance Distance = [userLocation.location distanceFromLocation:[[CLLocation alloc] initWithLatitude:self.lastUserLoaction.coordinate.latitude longitude:self.lastUserLoaction.coordinate.longitude]];
    
    //更新信息
    //移动距离小于5米时不刷新
    if (Distance<5) return;
    
    [self reloadLocation];


    self.lastUserLoaction = userLocation;
    [self strokePath:userLocation];
    
    if(self.isCanCatch){
        CLLocationCoordinate2D center = self.mapView.userLocation.location.coordinate;
        MACoordinateSpan span = self.mapView.region.span;
        MACoordinateRegion region = MACoordinateRegionMake(center, span);
        [self.mapView setRegion:region animated:YES];
    }
    
}

- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
//第一次进入加载数据
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    
    [self dismissListView];
    self.lastCenterLoaction = mapView.centerCoordinate;
    [self performSelector:@selector(reloadLocation) withObject:nil afterDelay:1.0f];

}
//地图缩放加载数据
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction {
    if (!wasUserAction) return;
    NSLog(@"M-%f--------L%f",mapView.metersPerPointForCurrentZoom,mapView.zoomLevel)
    if (self.lastZoomLevel < mapView.zoomLevel) {
        self.lastZoomLevel = mapView.zoomLevel;
        return;
    }
    self.lastZoomLevel = mapView.zoomLevel;

    [self reloadLocation];
}

-(void)reloadLocation{
    self.lastListFuwaNum = @"nil";
    self.lastUserLoaction = self.mapView.userLocation;
    [self loadNearByDataWithBiggest:self.lastListFuwaNum];
}

-(BOOL)setCancatchType{
    CLLocationCoordinate2D userLocation = self.mapView.userLocation.coordinate;
    CLLocationCoordinate2D centerLocation = self.mapView.centerCoordinate;
    if (userLocation.latitude == centerLocation.latitude && userLocation.longitude == centerLocation.longitude) {
        self.isCanCatch = YES;
        return YES;
        
    }else{
        self.isCanCatch = NO;
        return NO;
    }
}


- (void)strokePath:(MAUserLocation *)startLocation {
    
    LSFuwaModel *model = self.infoView.model;
    
    if (!model || !startLocation) return;
    
    //计算线路，剩余时间
    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:startLocation.coordinate.latitude longitude:startLocation.coordinate.longitude];
    AMapNaviPoint *endPoint   = [AMapNaviPoint locationWithLatitude:model.annotation.coordinate.latitude longitude:model.annotation.coordinate.longitude];
    
    [self.naviManager calculateWalkRouteWithStartPoints:@[startPoint] endPoints:@[endPoint]];
}

- (void)loadNearByDataWithBiggest:(NSString *)biggest {
    
    if (self.isRequest || !self.mapView.userLocation.location) return;
    
    self.isRequest = YES;

    CLLocationDistance radius = [self radiusInCurrentMap];
    
    if ([biggest isEqualToString: @"nil"]) {
        biggest = @"0";
    }
    [LSKeyWindow showLoading];

    
    if (self.type == FuwaShowTypeBusiness && self.isMerchant == NO) {
        
        [LSFuwaModel fetchNearbyFuwaListByLongitude:self.mapView.centerCoordinate.longitude andLatitude:self.mapView.centerCoordinate.latitude radius:radius biggest:biggest success:^(LSFuwaMapListModel*mapListModel) {
            
            [self processingDataWithList:mapListModel Biggest:biggest];
            
        } failure:^(NSError *error) {
            [LSKeyWindow hideHUDAnimated:YES];
            [self.view showError:@"信息获取失败" hideAfterDelay:1.5];
            [self.listView endLoadFoot];
            self.isRequest = NO;
        }];
    }else if(self.type == FuwaShowTypePartner && self.isMerchant == NO){
        [LSFuwaModel fetchNearbyPartnerFuwaListByLongitude:self.mapView.centerCoordinate.longitude andLatitude:self.mapView.centerCoordinate.latitude radius:radius biggest:biggest success:^(LSFuwaMapListModel*mapListModel) {
            
            [self processingDataWithList:mapListModel Biggest:biggest];
            NSLog(@"M-%f--------L%f",self.mapView.metersPerPointForCurrentZoom,self.mapView.zoomLevel)
        } failure:^(NSError *error) {
            [LSKeyWindow hideHUDAnimated:YES];
            [self.view showError:@"信息获取失败" hideAfterDelay:1.5];
            [self.listView endLoadFoot];
            self.isRequest = NO;
        }];
    }else if (self.isMerchant == YES){
        
        
        if (self.MerchantRadius<250) {
            self.MerchantRadius = 250;
        }
        CGFloat MerRadius = self.isMerchantFirstShow?self.MerchantRadius*2:radius;
        
        if (self.type == FuwaShowTypeBusiness) {
            
            
            [LSFuwaModel fetchMerchantNearbyFuwaListByLongitude:self.mapView.centerCoordinate.longitude andLatitude:self.mapView.centerCoordinate.latitude radius:MerRadius userid:self.MerchantID biggest:biggest success:^(LSFuwaMapListModel *mapListModel) {
                if (self.isMerchantFirstShow) {
                    CGFloat logNum = MerRadius/LSKeyWindow.height/2/maxLevelZoomMeter/2;
                    CGFloat difference = log2(logNum);
                    [self.mapView setZoomLevel:16-difference animated:YES];
                    [self processingDataWithList:mapListModel Biggest:biggest];
                    self.isMerchantFirstShow = NO;
                }else{
                    
                    [self processingDataWithList:mapListModel Biggest:biggest];
                    
                }
                
            } failure:^(NSError *error) {
                [LSKeyWindow hideHUDAnimated:YES];
                [self.view showError:@"信息获取失败" hideAfterDelay:1.5];
                [self.listView endLoadFoot];
                self.isRequest = NO;
            }];
            
        }else if (self.type == FuwaShowTypePartner){
            
            
            [LSFuwaModel fetchOnePartnerNearbyFuwaListByLongitude:self.mapView.centerCoordinate.longitude andLatitude:self.mapView.centerCoordinate.latitude radius:MerRadius userid:self.MerchantID biggest:biggest success:^(LSFuwaMapListModel *mapListModel) {
                if (self.isMerchantFirstShow) {
                    CGFloat logNum = MerRadius/LSKeyWindow.height/2/maxLevelZoomMeter/2;
                    CGFloat difference = log2(logNum);
                    [self.mapView setZoomLevel:16-difference animated:YES];
                    [self processingDataWithList:mapListModel Biggest:biggest];
                    self.isMerchantFirstShow = NO;
                }else{
                    
                    [self processingDataWithList:mapListModel Biggest:biggest];
                    
                }
                
            } failure:^(NSError *error) {
                [LSKeyWindow hideHUDAnimated:YES];
                [self.view showError:@"信息获取失败" hideAfterDelay:1.5];
                [self.listView endLoadFoot];
                self.isRequest = NO;
            }];
            
        }
        
    }

}



-(void)processingDataWithList:(LSFuwaMapListModel *)mapListModel Biggest:(NSString *)biggest{
    
    if (![self.lastListFuwaNum isEqualToString:@"nil"]&& self.isCanCatch)
    {

        [self.nearFuwaList addObjectsFromArray:mapListModel.near];
        [self.listView.dataSource addObjectsFromArray:mapListModel.near];
        [self.listView endLoadFoot];
        [self.listView reloadData];
        [LSKeyWindow hideHUDAnimated:YES];
        self.isRequest = NO;

    }else
    {
        //先移除地图上的大头针
        [self.mapView removeAnnotations:self.annotations];
        
        self.annotations = [NSMutableArray array];
        self.nearFuwaList =[NSMutableArray array];
        //添加大头针
        
        if (mapListModel.far.count == 0 && mapListModel.near.count == 0) {
            [LSKeyWindow hideHUDAnimated:YES];
        }
        
        for (LSFuwaModel *model in mapListModel.far) {
            
            [self.mapView addAnnotation:model.annotation];
            [self.annotations addObject:model.annotation];
            
        }
        
        for (LSFuwaModel *model in mapListModel.near) {
            
            [self.mapView addAnnotation:model.annotation];
            [self.annotations addObject:model.annotation];

        }
        if (self.isCanCatch) {
            [self.nearFuwaList addObjectsFromArray:mapListModel.near];
            self.listView.dataSource = self.nearFuwaList;
            [self.listView reloadData];
            [self showListView];
        }
        
        self.lastListFuwaNum = biggest;
        
        [self.models removeAllObjects];
        [self.models addObjectsFromArray:mapListModel.far];
        [self.models addObjectsFromArray:mapListModel.near];
        self.isRequest = NO;

        
    }
    
}

- (CLLocationDistance)radiusInCurrentMap {
    
    CGFloat screenHeight =LSKeyWindow.frame.size.height/2;
    
    double metersLevel =  [self.mapView metersPerPointForZoomLevel:self.mapView.zoomLevel];
    
    CLLocationDistance radius =metersLevel*screenHeight;

    return radius;
}


-(void)setType:(FuwaShowType)type{
    _type = type;
    if (type == FuwaShowTypeBusiness) {
        self.title = @"找福娃";
    }else{
        self.title = @"找萌友";
    }
}

-(void)dealloc{
    [self.view removeAllSubviews];
    
}
@end
