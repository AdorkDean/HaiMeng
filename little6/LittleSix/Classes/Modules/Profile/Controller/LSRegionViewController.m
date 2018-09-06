//
//  LSRegionViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSRegionViewController.h"
#import <CoreLocation/CoreLocation.h>

static NSString *const reuseId = @"LSRegionCell";

@interface LSRegionViewController ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (nonatomic,strong) CLLocationManager *manager;
@end

@implementation LSRegionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"地区";
    
    [self.tableView registerClass:[LSRegionCell class] forCellReuseIdentifier:reuseId];
    
    [self _initView];
}

- (void)_initView {

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
        _manager.distanceFilter = 1000;
        
        //开始定位方向
        [_manager startUpdatingHeading];
    }
    
    
}

#pragma mark - 定位代理
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //获取当前位置
    CLLocation *location = manager.location;
    
    // 地址的编码通过经纬度得到具体的地址
    CLGeocoder *gecoder = [[CLGeocoder alloc] init];
    
    [gecoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks firstObject];
        
        
        NSString * address = [NSString stringWithFormat:@"%@%@%@%@",placemark.addressDictionary[@"Country"],placemark.addressDictionary[@"State"],placemark.addressDictionary[@"City"],placemark.addressDictionary[@"SubLocality"]];
        self.regionLabel.text = address;
        //打印地址
        NSLog(@"%@%@%@%@",placemark.addressDictionary[@"Country"],placemark.addressDictionary[@"State"],placemark.addressDictionary[@"City"],placemark.addressDictionary[@"SubLocality"]);
    }];
    
    //停止定位
    [_manager stopUpdatingLocation];
    
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) return [super tableView:tableView numberOfRowsInSection:section];
    
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    LSRegionCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
    return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 50 : 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *tipsLabel = [UILabel new];
    tipsLabel.font = SYSTEMFONT(14);
    tipsLabel.textColor = HEXRGB(0x888888);
    
    NSString *title = section == 0 ? @"定位到的位置" : @"全部";
    tipsLabel.text = title;
    
    [headerView addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(15);
        make.bottom.equalTo(headerView).offset(-6);
    }];
    
    return headerView;
}


@end

@implementation LSRegionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = SYSTEMFONT(17);
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(15);
        }];
        
        UILabel *selectLabel = [UILabel new];
        selectLabel.font = SYSTEMFONT(15);
        selectLabel.textColor = HEXRGB(0x888888);
        
        [self addSubview:selectLabel];
        [selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-36);
        }];
        
        titleLabel.text = @"阿拉斯加";
        selectLabel.text = @"已选地区";
    }
    return self;
}

@end
