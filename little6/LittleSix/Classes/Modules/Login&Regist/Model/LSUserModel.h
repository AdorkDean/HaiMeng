//
//  LSUserModel.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    userLoginTypeSelf,
    userLoginTypeQQ,
    userLoginTypeWeChat,
}userLoginType;
@interface LSUserModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString * access_token;
@property (nonatomic, copy) NSString * avatar;
@property (nonatomic, assign) NSInteger city;
@property (nonatomic, assign) NSInteger district;
@property (nonatomic, copy) NSString * district_str;
@property (nonatomic, copy) NSString * lastlogin_time;
@property (nonatomic, copy) NSString * mobile_phone;
@property (nonatomic, assign) NSInteger province;
@property (nonatomic, copy) NSString * sex;
@property (nonatomic, copy) NSString * signature;
@property (nonatomic, copy) NSString * user_id;
@property (nonatomic, copy) NSString * user_name;
@property (nonatomic, copy) NSString * cover_pic;
@property (nonatomic,assign) userLoginType loginType;
@property (nonatomic, copy) NSString * birthday;
@property (nonatomic, copy) NSString * ht_district_str;
@property (nonatomic, copy) NSString * industry;
@property (nonatomic, copy) NSString * interest;

+ (void)loginWithPhone:(NSString *)phone password:(NSString *)pwd success:(void(^)(LSUserModel *user))success failure:(void(^)(NSError *error))failure;

+ (void)QQAuthWithToken:(NSString *)accessToken nickName:(NSString *)nickName avartar:(NSString *)avartar success:(void(^)(LSUserModel *user))success failure:(void(^)(NSError *error))failure;

+ (void)WechatAuthWithUnionid:(NSString *)unionid nickName:(NSString *)nickName avartar:(NSString *)avartar success:(void(^)(LSUserModel *user))success failure:(void(^)(NSError *error))failure;

//发送注册验证码 	1:注册 2：找回密码 3：找回支付密码 4：绑定手机号 5:通用
+ (void)sendVerifyCode:(NSString *)mobile_phone type:(NSInteger)type success:(void(^)(void))success failure:(void(^)(NSError *error))failure;
//完成注册保存
+ (void)registCode:(NSString *)mobile_phone WithPassword:(NSString *)password verify:(NSString *)mobile_verifycode success:(void(^)(void))success failure:(void(^)(NSError *error))failure;
//验证码
+ (void)validateCodeWithPhone:(NSString *)phone code:(NSString *)code success:(void(^)(void))success failure:(void(^)(NSError *error))failure;
//找回密码
+ (void)findPwdCode:(NSString *)mobile_phone WithNewPassword:(NSString *)Npassword verify:(NSString *)mobile_verifycode success:(void(^)(void))success failure:(void(^)(NSError *error))failure;
//查找用户
+(void)searchUserWithUserID:(int)UserID Success:(void(^)(LSUserModel * userModel))success failure:(void(^)(NSError *error))failure;

//修改头像
+(void)changeIconWithImage:(UIImage *)image Success:(void(^)(NSString * imageUrl))success failure:(void(^)(NSError *error))failure;
//修改名字
+(void)changeUserNameWithStr:(NSString *)str Success:(void(^)(void))success failure:(void(^)(NSError *error))failure;
//修改个性签名
+(void)changeSignatureWithStr:(NSString *)str Success:(void(^)(void))success failure:(void(^)(NSError *error))failure;

//绑定手机
+(void)bindmobileWithPhoneNum:(NSString *)phoneNum verifycode:(NSString *)verifycode Success:(void(^)(void))success failure:(void(^)(NSError *error))failure;
//修改密码
+(void)changePWDWithNewPWD:(NSString *)PWDNew OldPWD:(NSString *)PWDOld Success:(void(^)(void))success failure:(void(^)(NSError *error))failure;

//修改性别
+(void)changeUserInfoSex:(int)sex Success:(void(^)(void))success failure:(void(^)(NSError *error))failure;


//修改地区
+(void)changeUserInfoProvinceId:(NSString *)provinceId cityId:(NSString*)cityId districtId:(NSString *)districtId  Success:(void(^)(void))success failure:(void(^)(NSError *error))failure;

//查询余额
+(void)queryBalancesSuccess:(void(^)(NSString* ))success failure:(void(^)(NSError *error))failure;

//提现
+(void)getMoneyWithAmount:(NSString *)amount alipay:(NSString *)alipay name:(NSString *)name Success:(void(^)(NSString* ))success failure:(void(^)(NSError *error))failure;
@end

@interface LSUserwWithDrawModel : NSObject

@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *account;
@property (nonatomic,copy) NSString *amount;


@end
