//
//  LSPersonInfoTableViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPersonInfoViewController.h"
#import "LSAlbumsViewController.h"
#import "LSNickNameViewController.h"
#import "LSSignatureViewController.h"
#import "LSGenderViewController.h"
#import "UIView+HUD.h"
#import "LSChoosePickVeiw.h"
#import "ComfirmView.h"
#import "ImagePickerManager.h"

@interface LSPersonInfoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;
@property (weak, nonatomic) IBOutlet UILabel *adressLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;


@end

@implementation LSPersonInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人信息";
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
    }];
    [self.introduceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
    }];
    [self.adressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
    }];

    //验证账号异地登录
    [LSUserModel searchUserWithUserID:0 Success:nil failure:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //修改个人信息刷新
    [self configPersonInfo];
}

-(void)configPersonInfo {
    
    self.title = @"个人信息";
    self.nameLabel.text = ShareAppManager.loginUser.user_name;
//    self.numLabel.text = [NSString stringWithFormat:@"六六号:%@",self.myModel.user_id];
    [self.iconView setImageWithURL:[NSURL URLWithString:ShareAppManager.loginUser.avatar] placeholder:timeLineSmallPlaceholderName];
    
    self.sexLabel.text = ShareAppManager.loginUser.sex;
    self.introduceLabel.text = ShareAppManager.loginUser.signature;
    self.adressLabel.text = ShareAppManager.loginUser.district_str;
    
    [self managerStoreUser];
}

- (void)managerStoreUser {

    //异步将用户信息保存到本地
    kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
        [LSAppManager storeUser:ShareAppManager.loginUser];
    })
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15 : 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    if(indexPath.section == 0 && indexPath.row == 0){

        ModelComfirm *item1 = [ModelComfirm comfirmModelWith:@"拍照" titleColor:HEXRGB(0x666666) fontSize:16];
        ModelComfirm *item2 = [ModelComfirm comfirmModelWith:@"相册中选择" titleColor:HEXRGB(0x666666) fontSize:16];
        
        ModelComfirm *cancelItem = [ModelComfirm comfirmModelWith:@"取消" titleColor:HEXRGB(0x666666) fontSize:16];
        //确认提示框
        [ComfirmView showInView:LSKeyWindow cancelItemWith:cancelItem dataSource:@[ item1 ,item2] actionBlock:^(ComfirmView *view, NSInteger index) {
            
            @weakify(self)

            if (index == 0) {
                [[ImagePickerManager new] takePhotoWithPresentedVC:self allocEditing:YES finishPicker:^(NSDictionary *info) {
                    @strongify(self)
                    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
                    [self modifyPersonHeaderImage:image];
                }];
            }else {
                [[ImagePickerManager new] pickPhotoWithPresentedVC:self allocEditing:YES finishPicker:^(NSDictionary *info) {
                    @strongify(self)
                    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
                    [self modifyPersonHeaderImage:image];
                }];
            }
        }];
        
    }else if(indexPath.section == 0 && indexPath.row == 1){
        @strongify(self)

        LSNickNameViewController * nickVC =  [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"nickNameVC"];
        [nickVC setChangeNameBlock:^(NSString * name){
            self.nameLabel.text = name;
        }];
        [self.navigationController pushViewController:nickVC animated:YES];
        
    }else if (indexPath.section == 0 && indexPath.row == 2) {
        UIViewController *vc = [NSClassFromString(@"LSMyQRCodeViewController") new];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.section == 1 && indexPath.row ==0){
        
        LSGenderViewController * vc =[[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"LSGenderViewController"];
        vc.sex = self.myModel.sex;
        @weakify(self)
        [vc setChangeSex:^(int sexIndex){
            @strongify(self)
            if (sexIndex == 1)
                self.sexLabel.text =@"男";
            else
                self.sexLabel.text = @"女";
            [self managerStoreUser];
        }];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if(indexPath.section == 1 && indexPath.row == 1){
        
        LSChoosePickVeiw * addressPickView = [LSChoosePickVeiw new];
        [addressPickView ininSoureData:1];
        [addressPickView setConfig:^(NSString * address,NSString * province_Id,NSString * city_Id,NSString * town_Id){
            @strongify(self)
            [LSUserModel changeUserInfoProvinceId:province_Id cityId:city_Id districtId:town_Id Success:^{
                self.adressLabel.text = address;
                ShareAppManager.loginUser.district_str = address;
                [self managerStoreUser];
            } failure:nil];
        }];
        [self.view addSubview:addressPickView];

    }else if(indexPath.section == 1 && indexPath.row == 2){

        LSSignatureViewController * signatureVC =  [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"SignatureVC"];
        [signatureVC setSignatureBlock:^(NSString * signatureStr){
            self.introduceLabel.text = signatureStr;
            [self managerStoreUser];
        }];
        [self.navigationController pushViewController:signatureVC animated:YES];
    }else if(indexPath.section == 1 && indexPath.row == 3){
        
        NSString * urlString = [NSString stringWithFormat:@"http://www.boss89.com/stat/%@",ShareAppManager.loginUser.user_id];
        UIViewController *vc = [NSClassFromString(@"LSWebViewController") new];
        [vc setValue:urlString forKey:@"urlString"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)modifyPersonHeaderImage:(UIImage *)image {
    
    [self.view showLoading:@"正在上传"];
    
    [LSUserModel changeIconWithImage:image Success:^(NSString *imageUrl) {
        [[YYImageCache sharedCache] setImage:image forKey:imageUrl];
        [self.iconView setImageWithURL:[NSURL URLWithString:imageUrl] placeholder:timeLineSmallPlaceholderName];
        ShareAppManager.loginUser.avatar = imageUrl;
        //异步将用户信息保存到本地
        kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
            [LSAppManager storeUser:ShareAppManager.loginUser];
        })
        [self.view showSucceed:@"修改头像成功" hideAfterDelay:1];
    } failure:^(NSError *error) {
        [self.view showError:@"修改头像失败" hideAfterDelay:1];
    }];

}

@end
