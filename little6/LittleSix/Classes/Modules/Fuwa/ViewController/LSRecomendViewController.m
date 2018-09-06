//
//  LSRecomendViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/6/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSRecomendViewController.h"
#import "LSQueryClass.h"
#import "LSRecomendModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import "UIView+HUD.h"
#import "LSFuwaShowViewController.h"
#import "LSIndexLinkInModel.h"
#import <CoreLocation/CLLocationManager.h>

static NSString *const reuseid = @"LSRecomendCell";

@interface LSRecomendViewController () <UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout,AMapLocationManagerDelegate>

@property (nonatomic,strong) LSRecomendMenuView *menuView;

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,strong) NSMutableArray<LSQueryClass *> *classes;

@property (nonatomic,strong) AMapLocationManager *locationManager;
@property (nonatomic,strong) CLLocation *location;
@property (nonatomic,strong) CLLocationManager *locManager;

@property (nonatomic,copy) NSString *classId;

@end

@implementation LSRecomendViewController

+ (void)load {
    kRecomendCellWidth = (kScreenWidth - 15 * 3) * 0.5;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"推荐";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configRightItem];
    
    [self installSubviews];
    
    [self initialLocation];
    
    if (!self.classId) return;
    [self loadVideoList:self.classId];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)configRightItem {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"跳过" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button sizeToFit];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        LSFuwaShowViewController * vc = [LSFuwaShowViewController new];
        if (self.type == LSRecomendTypeFuwa) {
            vc.type = FuwaShowTypeBusiness;
        }
        else {
            vc.type = FuwaShowTypePartner;
        }
        NSMutableArray *childVC = [NSMutableArray arrayWithArray:self.navigationController.childViewControllers];
        [childVC removeObject:self];
        [childVC addObject:vc];
        
        [self.navigationController setViewControllers:childVC animated:YES];
    }];
}

- (void)installSubviews {
    
    if (self.type == LSRecomendTypeFuwa) {
        LSRecomendMenuView *menuView = [LSRecomendMenuView new];
        self.menuView = menuView;
        [self.view addSubview:menuView];
        
        /**
         点击事件
         */
        @weakify(self)
        [menuView setItemSelect:^(NSString *classId){
            @strongify(self)
            self.classId = classId;
            [self loadVideoList:classId];
        }];
        
        [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
            make.height.offset(35);
        }];
    }
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    layout.minimumColumnSpacing = 5;
    layout.minimumInteritemSpacing = 5;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView = collectionView;
    
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[LSRecomendCell class] forCellWithReuseIdentifier:reuseid];
    
    [self.view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.type == LSRecomendTypeFuwa) {
            make.top.equalTo(self.menuView.mas_bottom).offset(10);
        }
        else {
            make.top.equalTo(self.mas_topLayoutGuide).offset(10);
        }
        make.left.right.bottom.equalTo(self.view);
    }];
    
}

- (void)initialLocation {
    
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusAuthorizedAlways||status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //请求数据
        [self loadData];
    }
    else if (status == kCLAuthorizationStatusNotDetermined) {
        self.locManager = [CLLocationManager new];
        [self.locManager requestAlwaysAuthorization];
    }
    else {
        //定位不能用
        [self.view showAlertWithTitle:@"系统提示" message:@"应用需要开启位置访问权限" cancelAction:nil doneAction:^{
            //跳转到应用的设置界面
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if (![[UIApplication sharedApplication] canOpenURL:url]) return;
            [[UIApplication sharedApplication] openURL:url];
        }];
    }
    
    @weakify(self)
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
        else if (status == kCLAuthorizationStatusAuthorizedAlways||status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            if (self.dataSource.count > 0) return;
            [self loadData];
        }
    }];
}


- (void)loadData {
    
    [LSKeyWindow showLoading:@"正在请求"];
    
    //获取分类
    @weakify(self)
    RACSignal *classSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        [LSQueryClass queryClassWithSuccess:^(NSArray *list) {
            self.classes = [NSMutableArray arrayWithArray:list];
            [subscriber sendNext:list];
            [subscriber sendCompleted];
        } failure:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
    
    RACSignal *locationSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self.locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            if (error) {
                [subscriber sendError:error];
            }
            else {
                self.location = location;
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
    
    //获取视频
    RACSignal *videoSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        
        LSQueryClass *class = self.classes.firstObject;
        self.classId = class.classid;
        
        NSString *geoString = [NSString stringWithFormat:@"%lf-%lf",self.location.coordinate.longitude,self.location.coordinate.latitude];
        
        [LSRecomendModel recomendVideosWithType:self.type geo:geoString class:class.classid success:^(NSArray *list) {
            
            [subscriber sendNext:list];
            [subscriber sendCompleted];

        } failure:^(NSError *error) {
            [subscriber sendError:error];
        }];
        
        return nil;
    }];
    
    RACSignal *newSignal = [[classSignal combineLatestWith:locationSignal] then:^RACSignal * _Nonnull{
        return videoSignal;
    }];
    
    [newSignal subscribeNext:^(NSArray  *_Nullable list) {
        @strongify(self)
        [LSKeyWindow hideHUDAnimated:YES];
        self.menuView.dataSource = self.classes;
        self.dataSource = [NSMutableArray arrayWithArray:list];
        [self.collectionView reloadData];
    } error:^(NSError * _Nullable error) {
        [self.navigationController popViewControllerAnimated:YES];
        [LSKeyWindow showError:@"获取失败" hideAfterDelay:2.0];
    }];
    
}

- (void)loadVideoList:(NSString *)classId {
    
    [LSKeyWindow showLoading:@"正在请求"];
    
    self.dataSource = nil;
    [self.collectionView reloadData];
    
    NSString *geoString = [NSString stringWithFormat:@"%lf-%lf",self.location.coordinate.longitude,self.location.coordinate.latitude];
    
    [LSRecomendModel recomendVideosWithType:self.type geo:geoString class:classId success:^(NSArray *list) {
        
        [LSKeyWindow hideHUDAnimated:YES];
        self.dataSource = [NSMutableArray arrayWithArray:list];
        [self.collectionView reloadData];
        
    } failure:^(NSError *error) {
        [LSKeyWindow showError:@"获取失败" hideAfterDelay:2.0];
    }];
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSRecomendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseid forIndexPath:indexPath];
    LSRecomendModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    
    @weakify(self)
    [cell setControlClick:^(NSString * userid){
        @strongify(self)
        [self jumpTribaWithUserId:userid];
    }];
    
    return cell;
}

- (void)jumpTribaWithUserId:(NSString *)userid{

    [LSIndexLinkInModel indexLinkWithTribalCreateId:userid success:^(NSArray *list) {
        if (list.count > 0) {
            LSIndexLinkInModel * model = list[0];
            UIViewController *vc = [NSClassFromString(@"LSClanCofcViewController") new];
            [vc setValue:@(model.stribe_id) forKey:@"sh_id"];
            [vc setValue:@(5) forKey:@"type"];
            [vc setValue:model.name forKey:@"titleStr"];
            [vc setValue:@"isFuwa" forKey:@"isFuwa"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } failure:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSRecomendModel *model = self.dataSource[indexPath.row];
    CGSize imageSize = [model scaleSize];
    
    return CGSizeMake(imageSize.width, imageSize.height+25);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [NSClassFromString(@"LSVideoPlayViewController") new];
    LSRecomendModel *model = self.dataSource[indexPath.row];
    [vc setValue:model forKey:@"videoModel"];
    [vc setValue:self.dataSource forKey:@"dataSource"];
    [vc setValue:self.classId forKey:@"classId"];
    [vc setValue:@(self.type) forKey:@"type"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

static NSString *const reuse_id = @"LSRecomendMenuCell";

@interface LSRecomendMenuView () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;

@property (nonatomic,strong) UIView *scrollBar;

@property (nonatomic,assign) CGFloat offsetX;

@end

@implementation LSRecomendMenuView 

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        self.layout = layout;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self addSubview:collectionView];
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.collectionView = collectionView;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[LSRecomendMenuCell class] forCellWithReuseIdentifier:reuse_id];
        
        UIView *scrollBar = [UIView new];
        self.scrollBar = scrollBar;
        scrollBar.backgroundColor = HEXRGB(0xd3000f);
        [self addSubview:scrollBar];
        [scrollBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self).offset(-(kScreenWidth/5)*2);
            make.bottom.equalTo(self);
            make.height.offset(2);
            make.width.offset(28);
        }];
        scrollBar.hidden = YES;
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSRecomendMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_id forIndexPath:indexPath];
    
    LSQueryClass *model = self.dataSource[indexPath.row];
    
    cell.titleLabel.text = model.name;
    
    if (model.selected) {
        cell.titleLabel.textColor = HEXRGB(0xd3000f);
    }
    else {
        cell.titleLabel.textColor = HEXRGB(0x333333);
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect rect = [cell convertRect:cell.bounds toView:self];

    [UIView animateWithDuration:0.25 animations:^{
        self.scrollBar.transform = CGAffineTransformMakeTranslation(rect.origin.x, 0);
    }];
    
    for (LSQueryClass *model in self.dataSource) {
        model.selected = NO;
    }
    LSQueryClass *model = self.dataSource[indexPath.row];
    model.selected = YES;
    
    [collectionView reloadData];
    
    //回调
    !self.itemSelect?:self.itemSelect(model.classid);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat delta = scrollView.contentOffset.x - self.offsetX;
    self.scrollBar.transform = CGAffineTransformTranslate(self.scrollBar.transform, -delta, 0);
    self.offsetX = scrollView.contentOffset.x;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = kScreenWidth / 5;
    self.layout.itemSize = CGSizeMake(width, self.height);
    [self.collectionView reloadData];
    
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    _dataSource = dataSource;
    [self.collectionView reloadData];
    self.scrollBar.hidden = NO;
    LSQueryClass *model = dataSource.firstObject;
    model.selected = YES;
}

@end

@implementation LSRecomendMenuCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [UILabel new];
        self.titleLabel = titleLabel;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

@end

@interface LSRecomendCell ()

@property (nonatomic,strong) UIImageView *coverView;
@property (nonatomic,strong) UIImageView *avatarView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UIImageView *genderView;
@property (nonatomic,strong) UILabel *distanceLabel;

@end

@implementation LSRecomendCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *coverView = [UIImageView new];
        self.coverView = coverView;
        [self.contentView addSubview:coverView];
        [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.offset(0);
        }];
        
        UIImageView *avatarView = [UIImageView new];
        self.avatarView = avatarView;
        avatarView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:avatarView];
        [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
            make.top.equalTo(coverView.mas_bottom).offset(10);
            make.width.height.offset(25);
        }];
        
        ViewRadius(avatarView, 25*0.5);

        UILabel *nameLabel = [UILabel new];
        self.nameLabel = nameLabel;
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = HEXRGB(0x333333);

        [self.contentView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(avatarView);
            make.left.equalTo(avatarView.mas_right).offset(5);
            CGFloat offset = kRecomendCellWidth - 90;
            make.width.mas_lessThanOrEqualTo(offset);
        }];

        UIImageView *genderView = [UIImageView new];
        self.genderView = genderView;
        [self.contentView addSubview:genderView];
        [genderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(nameLabel);
            make.left.equalTo(nameLabel.mas_right).offset(4);
        }];

        UILabel *distanceLabel = [UILabel new];
        distanceLabel.textColor = HEXRGB(0x999999);
        distanceLabel.font = [UIFont systemFontOfSize:12];
        self.distanceLabel = distanceLabel;
        
        [self.contentView addSubview:distanceLabel];
        [distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(nameLabel);
            make.right.equalTo(self).offset(-5);
            make.width.mas_lessThanOrEqualTo(50);
        }];
        
        UIControl *control = [UIControl new];
        self.control = control;
        [self.contentView addSubview:control];
        [control mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(avatarView);
            make.right.equalTo(nameLabel.mas_right);
        }];
        
        @weakify(self)
        [[control rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            !self.controlClick?:self.controlClick(self.model.userid);
        }];
        
    }
    return self;
}

- (void)setModel:(LSRecomendModel *)model {
    _model = model;
    
    CGSize size = [model scaleSize];
    
    [self.coverView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(size.height);
    }];
    
    [self layoutIfNeeded];
    
    [self.coverView setImageWithURL:[NSURL URLWithString:model.coverImage] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:nil transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
        return [image imageByRoundCornerRadius:4];
    } completion:nil];
    
    [self.avatarView setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:nil];
    self.nameLabel.text = model.name;
    self.distanceLabel.text = model.disString;
    
    if ([model.gender isEqualToString:@"男"]) {
        self.genderView.image = [UIImage imageNamed:@"home_man"];
    }
    else {
        self.genderView.image = [UIImage imageNamed:@"home_lady"];
    }
    
}


@end
