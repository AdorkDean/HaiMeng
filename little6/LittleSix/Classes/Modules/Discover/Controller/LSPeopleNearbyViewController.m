//
//  LSPeopleNearbyViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPeopleNearbyViewController.h"
#import "LSPersonsModel.h"
#import "UIView+HUD.h"
#import <YYKit/YYKit.h>
#import "LSLinkInPopView.h"
#import <CoreLocation/CoreLocation.h>
#import "LSContactDetailViewController.h"

static NSString *const reuseId = @"LSPeopleNearbyCell";

@interface LSPeopleNearbyViewController () <UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>

@property (nonatomic,strong) UITableView *tabelView;


@property (retain,nonatomic)NSMutableArray * dataSource;
@property (retain,nonatomic)UIView * footerView;
@property (retain,nonatomic)UILabel * footTitle;

@property (nonatomic,strong) CLLocationManager *manager;
@property (nonatomic,retain) NSString * longitude;
@property (nonatomic,retain) NSString * latitude;


@end

@implementation LSPeopleNearbyViewController

- (NSMutableArray *)dataSource  {

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"附近的人";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    [self.view addSubview:self.tabelView];
    [self.tabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self naviBarConfig];
    
    [self _initPosition];
}
- (void)_initPosition {
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位服务当前可能尚未打开，请设置打开！");
        return;
    }
    // 实例化对象
    _manager = [[CLLocationManager alloc] init];
    
    _manager.delegate = self;
    
    // 请求授权
    [_manager requestAlwaysAuthorization];
}

#pragma mark - 代理方法，当授权改变时调用
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    // 获取授权后，通过
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        
        //开始定位(具体位置要通过代理获得)
        [_manager startUpdatingLocation];
        
        //设置精确度
        _manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        //设置过滤距离
        _manager.distanceFilter = 100.0;
        
        //开始定位方向
        [_manager startUpdatingHeading];
    }
    
}

#pragma mark - 定位代理
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //获取当前位置
    CLLocation *location = manager.location;
    
    CLLocationCoordinate2D coordinate = location.coordinate;//位置坐标
    
    self.longitude = [NSString stringWithFormat:@"%f",coordinate.longitude];
    self.latitude = [NSString stringWithFormat:@"%f",coordinate.latitude];
    
    [LSPersonsModel positioningLongitude:self.longitude latitude:self.latitude success:^{
        
        [self requestDataSource:@"0"];
        
    } failure:nil];
    
    //停止定位
    [_manager stopUpdatingLocation];
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
        
        [[LSLinkInPopView linkInMainView] showInView:self andArray:@[@[@"只看男的",@"只看女的",@"男女都看"],@[@"取消"]] withBlock:^(NSString *title) {
            
            if ([title isEqualToString:@"只看男的"]) {
                
                [self requestDataSource:@"1"];
                
            }else if ([title isEqualToString:@"只看女的"]) {
            
                [self requestDataSource:@"2"];
                
            }else if ([title isEqualToString:@"男女都看"]) {
            
                [self requestDataSource:@"0"];
            }
        }];
    }];
}

- (void)requestDataSource:(NSString *)sex {

    [self.view showLoading];
    [LSPersonsModel peopleNearbyWithSex:sex success:^(NSArray * list) {
        
        if (list.count > 0) {
            self.footTitle.text = @"";
            self.footerView.height = 0;
        }else {
            self.footerView.height = kScreenHeight/4;
        }
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:list];
        [self.view hideHUDAnimated:YES];
        [self.tabelView reloadData];
        
    } failure:^(NSError *error) {
        self.footerView.height = kScreenHeight/4;
        [self.view hideHUDAnimated:YES];
    }];
    
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSPeopleNearbyCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    LSPersonsModel * model = self.dataSource[indexPath.row];
    
    cell.personsModel = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LSPersonsModel * model = self.dataSource[indexPath.row];
    LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
    lsvc.user_id = model.user_id;
    [self.navigationController pushViewController:lsvc animated:YES];
}


#pragma mark - Getter & Setter
- (UITableView *)tabelView {
    if (!_tabelView) {
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tabelView = tableView;
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[LSPeopleNearbyCell class] forCellReuseIdentifier:reuseId];
        tableView.rowHeight = 65;
        
        tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        tableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
        
        UIView * footerView = [UIView new];
        footerView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight/4);
        
        self.footTitle = [UILabel new];
        self.footTitle.text = @"附近的人空空的";
        [footerView addSubview:self.footTitle];
        self.footTitle.textAlignment = NSTextAlignmentCenter;
        [self.footTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(footerView);
        }];
        
        tableView.tableFooterView = footerView;
        
    }
    return _tabelView;
}

@end

@implementation LSPeopleNearbyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [UIImageView new];
        iconView.backgroundColor = [UIColor lightGrayColor];
        self.iconView = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(8);
            make.width.height.offset(46);
        }];
        
        YYLabel *detailLabel = [YYLabel new];
        self.detailLabel = detailLabel;
        detailLabel.text = @"众里寻他千百度，想要几度就几度";
        detailLabel.numberOfLines = 2;
        detailLabel.backgroundColor = HEXRGB(0xf2f2f2);
        ViewRadius(detailLabel, 5);
        detailLabel.textContainerInset = UIEdgeInsetsMake(0, 5, 0, 4);
        
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:detailLabel.text];
        attrText.lineSpacing = 2;
        attrText.font = SYSTEMFONT(12);
        attrText.color = HEXRGB(0x888888);
        
        detailLabel.attributedText = attrText;
        
        [self addSubview:detailLabel];
        [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.height.offset(40);
            make.width.offset(95);
            make.right.equalTo(self).offset(-10);
        }];
        
        UILabel *nameLabel = [UILabel new];
        nameLabel.text = @"西门吹雪";
        nameLabel.font = SYSTEMFONT(16);
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.mas_right).offset(12);
            make.right.lessThanOrEqualTo(detailLabel.mas_left).offset(-30);
            make.top.equalTo(iconView).offset(3);
        }];
        
        UIImageView * sexView = [UIImageView new];
        self.sexImageView = sexView;
        [self addSubview:sexView];
        
        [sexView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.mas_right).offset(5);
            make.centerY.equalTo(nameLabel);
            make.width.height.mas_equalTo(15);
        }];
        
        UILabel *distanceLabel = [UILabel new];
        distanceLabel.font = SYSTEMFONT(12);
        distanceLabel.textColor = HEXRGB(0x888888);
        distanceLabel.text = @"200米以内";
        self.distanceLabel = distanceLabel;
        [self addSubview:distanceLabel];
        [distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel);
            make.bottom.equalTo(iconView).offset(-3);
        }];
        
    }
    return self;
}

- (void)setPersonsModel:(LSPersonsModel *)personsModel {

    _personsModel = personsModel;
    [self.iconView setImageWithURL:[NSURL URLWithString:personsModel.avatar] placeholder:timeLineSmallPlaceholderName];
    self.nameLabel.text = personsModel.user_name;
    self.distanceLabel.text = [NSString stringWithFormat:@"%@米以内",personsModel.distance];
    
    if ([personsModel.signature isEqualToString:@""]) {
        
        self.detailLabel.hidden = YES;
        
    }else {
    
        self.detailLabel.hidden = NO;
        self.detailLabel.text = personsModel.signature;
    }
    if ([personsModel.sex isEqualToString:@"1"]) [self.sexImageView setImage:[UIImage imageNamed:@"man"]];
    else [self.sexImageView setImage:[UIImage imageNamed:@"lady"]];
}

@end
