//
//  LSLinkCompleteInfoViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkCompleteInfoViewController.h"
#import "LSNickNameViewController.h"
#import "LSSchoolViewController.h"
#import "LSChoosePickVeiw.h"
#import "NSDate+Util.h"
#import "LSHobbiesView.h"
#import "LSHobbieModel.h"
#import "LSLSLinkInModel.h"
#import "UIView+HUD.h"
#import "LSPersonsModel.h"

static NSString *const reuse_id = @"LSLinkCompleteInfoCell";

@interface LSLinkCompleteInfoViewController () <UITableViewDelegate,UITableViewDataSource>

@property (copy,nonatomic) NSString * username; //  姓名
@property (copy,nonatomic) NSString * sex;  //性别
@property (copy,nonatomic) NSString * intBirthday; //生日

@property (copy,nonatomic) NSString * district; //所在地
@property (copy,nonatomic) NSString * hometown; //家乡
@property (copy,nonatomic) NSString * work; //工作
@property (copy,nonatomic) NSString * workId;
@property (copy,nonatomic) NSString * hobbies; //兴趣爱好

@property (copy,nonatomic) NSString * hometown_pid;//家乡省ID
@property (copy,nonatomic) NSString * hometown_pname;
@property (copy,nonatomic) NSString * hometown_cid;//家乡市ID
@property (copy,nonatomic) NSString * hometown_cname;
@property (copy,nonatomic) NSString * hometown_tid;//家乡区ID
@property (copy,nonatomic) NSString * hometown_tname;

@property (copy,nonatomic) NSString * live_pid;//居住省ID
@property (copy,nonatomic) NSString * live_pname;
@property (copy,nonatomic) NSString * live_cid;//居住市ID
@property (copy,nonatomic) NSString * live_cname;
@property (copy,nonatomic) NSString * live_tid;//居住区ID
@property (copy,nonatomic) NSString * live_tname;

@property (copy,nonatomic) NSString * school;//  学校
@property (copy,nonatomic) NSString * school_en;

@property (nonatomic, strong) LSChoosePickVeiw *cityChoose;
@property (nonatomic, strong) LSPersonsModel *personsModel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;

@end

@implementation LSLinkCompleteInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"完善资料";
        
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initSourceData];
}

- (void)initSourceData {
    
    [LSPersonsModel personerWithUser_id:ShareAppManager.loginUser.user_id success:^(LSPersonsModel *model) {
        
        [self.dataSource removeAllObjects];
        self.personsModel = nil;
        self.personsModel = model;
        [self _initDataSource];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSLinkCompleteInfoCell *cell =[tableView dequeueReusableCellWithIdentifier:reuse_id];
    LSCompleteInfoModel *model = self.dataSource[indexPath.row];
    cell.infoModel = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LSLinkCompleteInfoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    switch (indexPath.row) {
        case 0:
        {
            LSNickNameViewController * nickVC =  [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"nickNameVC"];
            [nickVC setChangeNameBlock:^(NSString * name){
                cell.titleLable.text = name;
            }];
            [self.navigationController pushViewController:nickVC animated:YES];
        }
            break;
        case 1:
        {
            self.cityChoose = [[LSChoosePickVeiw alloc] init];
            [self.cityChoose ininSoureData:0];
            self.cityChoose.config = ^(NSString * sex,NSString *sexId, NSString *yId, NSString *nId){
                cell.titleLable.text = sex;
                weakSelf.sex = sexId;
            };
            [self.view addSubview:self.cityChoose];
        }
            break;
        case 2:
        {
            HMDatePickView * pick = [HMDatePickView new];
            pick.completeBlock = ^(NSString * date){
                
                NSTimeInterval interval = [NSDate timeIntervalWithString:date format:@"yyyy-MM"];
                NSString * timestr = [NSString stringWithFormat:@"%.f",interval];
                weakSelf.intBirthday = timestr;
                cell.titleLable.text = date;
            };
            [self.view addSubview:pick];
        }
            break;
        case 3:
        case 5:
        {
            self.cityChoose = [[LSChoosePickVeiw alloc] init];
            [self.cityChoose ininSoureData:1];
            self.cityChoose.config = ^(NSString * address,NSString *provinceId, NSString *cityId, NSString *townId){
                if (indexPath.row == 3) {
                    weakSelf.live_pid = provinceId;
                    weakSelf.live_cid = cityId;
                    weakSelf.live_tid = townId;
                }else{
                    weakSelf.hometown_pid = provinceId;
                    weakSelf.hometown_cid = cityId;
                    weakSelf.hometown_tid = townId;
                }
                cell.titleLable.text = address;
            };
            [self.view addSubview:self.cityChoose];
        }
            break;
        case 4:
        {
            LSSchoolViewController * schoolVc = [[LSSchoolViewController alloc] init];
            [schoolVc setFristClick:^(NSString * schoolName) {
                
                cell.titleLable.text = schoolName;
            }];
            [self.navigationController pushViewController:schoolVc animated:YES];
        }
            break;
        case 6:
        {
            self.cityChoose = [[LSChoosePickVeiw alloc] init];
            [self.cityChoose ininSoureData:2];
            self.cityChoose.config = ^(NSString * work,NSString *workId, NSString *yId, NSString *nId){
                cell.titleLable.text = work;
                weakSelf.work = work;
                weakSelf.workId = workId;
            };
            [self.view addSubview:self.cityChoose];
        }
            break;
        case 7:
        {
            LSHobbiesView * hobbies = [LSHobbiesView chooseMainV];
            [hobbies showInView:self WithBlock:^(NSArray *list) {
                for (int i = 0;i < list.count;i++) {
                    LSHobbieModel * hmodel = list[i];
                    if (i == 0) {
                        self.hobbies = [NSString stringWithFormat:@"%@",hmodel.tag_name];
                    }else{
                        self.hobbies = [NSString stringWithFormat:@"%@|%@",self.hobbies,hmodel.tag_name];
                    }
                    cell.titleLable.text = self.hobbies;
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView new];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [UIView new];
    
    footerView.backgroundColor = [UIColor whiteColor];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setTitle:@"完成并添加人脉" forState:UIControlStateNormal];
    nextButton.backgroundColor = kMainColor;
    nextButton.titleLabel.font = SYSTEMFONT(18);
    ViewRadius(nextButton, 5);
    [nextButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:nextButton];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView).offset(20);
        make.right.equalTo(footerView).offset(-20);
        make.top.equalTo(footerView).offset(30);
        make.height.offset(47);
    }];
    
    UILabel *tipsLabel = [UILabel new];
    tipsLabel.text = @"注：标注*号的选项为必填选项";
    tipsLabel.font = SYSTEMFONT(16);
    tipsLabel.textColor = HEXRGB(0xbcbcbc);
    
    [footerView addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(footerView);
        make.top.equalTo(nextButton.mas_bottom).offset(15);
    }];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 150;
}

#pragma mark - Getter & Setter
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView = tableView;
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 44;
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [tableView registerClass:[LSLinkCompleteInfoCell class] forCellReuseIdentifier:reuse_id];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)_initDataSource {
    
    LSCompleteInfoModel *model1 = [LSCompleteInfoModel modelWithDispalyName:@"姓名*" andValue:self.personsModel.user_name];
    LSCompleteInfoModel *model2 = [LSCompleteInfoModel modelWithDispalyName:@"性别*"andValue:self.personsModel.sex];
    NSString * dates = [NSDate dateWithTimeInterval:[self.personsModel.birthday integerValue]format:@"yyyy-MM"];
    LSCompleteInfoModel *model3 = [LSCompleteInfoModel modelWithDispalyName:@"出生年月*"andValue:dates];
    LSCompleteInfoModel *model4 = [LSCompleteInfoModel modelWithDispalyName:@"所在地*"andValue:self.personsModel.district_str];
    
    LSCompleteInfoModel *model5 = [LSCompleteInfoModel modelWithDispalyName:@"学校*"andValue:self.personsModel.school];
    LSCompleteInfoModel *model6 = [LSCompleteInfoModel modelWithDispalyName:@"家乡*"andValue:self.personsModel.ht_district_str];
    LSCompleteInfoModel *model7 = [LSCompleteInfoModel modelWithDispalyName:@"工作"andValue:self.personsModel.industry];
    LSCompleteInfoModel *model8 = [LSCompleteInfoModel modelWithDispalyName:@"兴趣爱好"andValue:self.personsModel.interest];
    
    [self.dataSource addObjectsFromArray:@[model1,model2,model3,model4,model5,model6,model7,model8]];
    
}

//保存并下一步
- (void)saveButtonClick:(UIButton *)sender{
    
    [LSCompleteInfoModel completeInfoWithlistToken:ShareAppManager.loginUser.access_token sex:self.sex birthday:self.intBirthday province:self.live_pid city:self.live_cid district:self.live_tid ht_province:self.hometown_pid ht_city:self.hometown_cid ht_district:self.hometown_tid industry:self.work interest:self.hobbies success:^{
        
        [LSKeyWindow showSucceed:@"保存成功" hideAfterDelay:1.5];
        [LSUserModel searchUserWithUserID:[ShareAppManager.loginUser.user_id intValue] Success:^(LSUserModel *userModel) {
            ShareAppManager.loginUser.sex = userModel.sex;
            ShareAppManager.loginUser.user_name = userModel.user_name;
            ShareAppManager.loginUser.birthday = userModel.birthday;
            ShareAppManager.loginUser.ht_district_str = userModel.ht_district_str;
            ShareAppManager.loginUser.industry = userModel.industry;
            ShareAppManager.loginUser.interest = userModel.interest;
            ShareAppManager.loginUser.district_str = userModel.district_str;
            //异步将用户信息保存到本地
            kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
                [LSAppManager storeUser:ShareAppManager.loginUser];
            })
        } failure:nil];
        
        //发送通知刷新人脉首页
        [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteLinkInInfoNoti object:nil];
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *errer) {
        [self.view showErrorWithError:errer];
    }];
}

@end


@interface LSLinkCompleteInfoCell ()

@end

@implementation LSLinkCompleteInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.nameLabel = [UILabel new];
//        self.nameLabel = nameLabel;
        self.nameLabel.font = SYSTEMFONT(15);
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(20);
            make.width.offset(85);
        }];
        
        
        UIImageView * iconImage = [UIImageView new];
        iconImage.image = [UIImage imageNamed:@"right_arrows"];
        [self addSubview:iconImage];
        [iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-20);
            make.width.offset(8);
            make.height.offset(13);
        }];
        
        UILabel *titleLable = [UILabel new];
        titleLable.textAlignment = UITextAlignmentRight;
        titleLable.textColor = [UIColor lightGrayColor];
        titleLable.font = SYSTEMFONT(15);
        self.titleLable = titleLable;
        [self addSubview:titleLable];
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self.nameLabel.mas_right).offset(10);
            make.right.equalTo(iconImage.mas_left).offset(-10);
        }];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = HEXRGB(0xbcbcbc);
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.bottom.right.equalTo(self);
            make.height.offset(0.5);
        }];
        
        
    }
    return self;
}

- (void)setInfoModel:(LSCompleteInfoModel *)infoModel{

    _infoModel = infoModel;
    NSLog(@"%@ === %@",infoModel.displayName,infoModel.value)
    self.nameLabel.text = infoModel.displayName;
    self.titleLable.text = infoModel.value;
}

@end

@implementation LSCompleteInfoModel

+ (instancetype)modelWithDispalyName:(NSString *)name andValue:(NSString *)value{
    LSCompleteInfoModel *model = [LSCompleteInfoModel new];
    model.displayName = name;
    model.value = value;
    return model;
}

+ (void)completeInfoWithlistToken:(NSString *)access_token
                             sex:(NSString *)sex
                        birthday:(NSString *)birthday
                        province:(NSString *)province
                            city:(NSString *)city
                        district:(NSString *)district
                     ht_province:(NSString *)ht_province
                         ht_city:(NSString *)ht_city
                     ht_district:(NSString *)ht_district
                        industry:(NSString *)industry
                        interest:(NSString *)interest
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kUpdateInfoPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    if (![sex isEqualToString:@""]) {
        params[@"sex"] = sex;
    }
    if (![birthday isEqualToString:@""]) {
        params[@"birthday"] = birthday;
    }
    if (![province isEqualToString:@""]) {
        params[@"province"] = province;
    }
    if (![city isEqualToString:@""]) {
        params[@"city"] = city;
    }
    if (![district isEqualToString:@""]) {
        params[@"district"] = district;
    }
    if (![ht_province isEqualToString:@""]) {
        params[@"ht_province"] = ht_province;
    }
    if (![ht_city isEqualToString:@""]) {
        params[@"ht_city"] = ht_city;
    }
    if (![ht_district isEqualToString:@""]) {
        params[@"ht_district"] = ht_district;
    }
    if (![industry isEqualToString:@""]) {
        params[@"industry"] = industry;
    }
    if (![interest isEqualToString:@""]) {
        params[@"interest"] = interest;
    }
    
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}


@end
