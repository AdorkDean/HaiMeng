//
//  LSUserModel.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSUserModel.h"
#import "LSBaseModel.h"
#import "ConstKeys.h"
#import "LSOBaseModel.h"

@implementation LSUserModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self modelInitWithCoder:aDecoder];
}

+ (void)loginWithPhone:(NSString *)phone password:(NSString *)pwd success:(void (^)(LSUserModel *))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [CenterUri stringByAppendingPathComponent:kLoginPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile_phone"] = phone;
    params[@"password"] = pwd;

    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSUserModel *user = [LSUserModel modelWithJSON:model.result];
        !success?:success(user);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

+ (void)QQAuthWithToken:(NSString *)accessToken nickName:(NSString *)nickName avartar:(NSString *)avartar success:(void (^)(LSUserModel *))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [CenterUri stringByAppendingPathComponent:kQQAuthPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"qq_access_token"] = accessToken;
    params[@"qq_username"] = nickName;
    params[@"qq_avatar"] = avartar;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSUserModel *user = [LSUserModel modelWithJSON:model.result];
        !success?:success(user);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+ (void)WechatAuthWithUnionid:(NSString *)unionid nickName:(NSString *)nickName avartar:(NSString *)avartar success:(void (^)(LSUserModel *))success failure:(void (^)(NSError *))failure {

    NSString *path = [CenterUri stringByAppendingPathComponent:kWechatAuthPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"wx_unionid"] = unionid;
    params[@"wx_username"] = nickName;
    params[@"wx_avatar"] = avartar;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSUserModel *user = [LSUserModel modelWithJSON:model.result];
        !success?:success(user);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+ (void)sendVerifyCode:(NSString *)mobile_phone type:(NSInteger)type success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [CenterUri stringByAppendingPathComponent:kSMSPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile"] = mobile_phone;
    params[@"type"] = @(type);
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

+ (void)registCode:(NSString *)mobile_phone WithPassword:(NSString *)password verify:(NSString *)mobile_verifycode success:(void(^)(void))success failure:(void(^)(NSError *error))failure{
    
    NSString *path = [CenterUri stringByAppendingPathComponent:kRegPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile_phone"] = mobile_phone;
    params[@"password"] = password;
    params[@"mobile_verifycode"] = mobile_verifycode;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];

}

+ (void)validateCodeWithPhone:(NSString *)phone code:(NSString *)code success:(void(^)(void))success failure:(void(^)(NSError *error))failure{
    
     NSString *path = [CenterUri stringByAppendingPathComponent:kSmsValidatePath];
     NSDictionary *params = @{@"mobile_phone":phone,
                              @"mobile_verifycode":code};
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+ (void)findPwdCode:(NSString *)mobile_phone WithNewPassword:(NSString *)Npassword verify:(NSString *)mobile_verifycode success:(void(^)(void))success failure:(void(^)(NSError *error))failure{
    
    NSString *path = [CenterUri stringByAppendingPathComponent:kPwdFindPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile_phone"] = mobile_phone;
    params[@"new_pass"] = Npassword;
    params[@"mobile_verifycode"] = mobile_verifycode;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}


+(void)searchUserWithUserID:(int)UserID Success:(void(^)(LSUserModel * userModel))success failure:(void(^)(NSError *error))failure{
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kSearchUserPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = [LSAppManager sharedAppManager].loginUser.access_token;
    params[@"user_id"] = [NSNumber numberWithInt:UserID];
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSUserModel * userModel = [LSUserModel modelWithJSON:model.result];
        !success?:success(userModel);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)changeIconWithImage:(UIImage *)image Success:(void(^)(NSString * imageUrl))success failure:(void(^)(NSError *error))failure{
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kChangeUserIconPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    
    UIGraphicsBeginImageContext(CGSizeMake(640.0,640.0));
    [image drawInRect:CGRectMake(0, 0, 640.0, 640.0)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [LSBaseModel uploadImages:path parameters:params images:@[scaledImage] keys:@[@"avatar"] success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSString * imageUrl = model.result[@"avatar"];
        
        !success?:success(imageUrl);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)changeUserNameWithStr:(NSString *)str Success:(void(^)(void))success failure:(void(^)(NSError *error))failure{
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kChangeUserNamePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = [LSAppManager sharedAppManager].loginUser.access_token;
    params[@"user_name"] = str;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)changeSignatureWithStr:(NSString *)str Success:(void(^)(void))success failure:(void(^)(NSError *error))failure{
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kChangeSignaturePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = [LSAppManager sharedAppManager].loginUser.access_token;
    params[@"signature"] = str;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)bindmobileWithPhoneNum:(NSString *)phoneNum verifycode:(NSString *)verifycode Success:(void(^)(void))success failure:(void(^)(NSError *error))failure{
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kBindmobilePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = [LSAppManager sharedAppManager].loginUser.access_token;
    params[@"mobile_phone"] = phoneNum;
    params[@"mobile_verifycode"] = verifycode;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

+(void)changePWDWithNewPWD:(NSString *)PWDNew OldPWD:(NSString *)PWDOld Success:(void(^)(void))success failure:(void(^)(NSError *error))failure{
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kChangePWDPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = [LSAppManager sharedAppManager].loginUser.access_token;
    params[@"old_pass"] = PWDOld;
    params[@"new_pass"] = PWDNew;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];

}


+(void)changeUserInfoSex:(int)sex Success:(void(^)(void))success failure:(void(^)(NSError *error))failure{

    NSString *path = [kBaseUrl stringByAppendingPathComponent:kUpdateInfoPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = [LSAppManager sharedAppManager].loginUser.access_token;
    params[@"sex"] = [NSNumber numberWithInt:sex];
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)changeUserInfoProvinceId:(NSString *)provinceId cityId:(NSString*)cityId districtId:(NSString *)districtId  Success:(void(^)(void))success failure:(void(^)(NSError *error))failure{
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kUpdateInfoPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = [LSAppManager sharedAppManager].loginUser.access_token;
    params[@"province"] = provinceId;
    params[@"city"] = cityId;
    params[@"districtId"] = districtId;

    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)queryBalancesSuccess:(void(^)(NSString* ))success failure:(void(^)(NSError *error))failure{
    
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kqueryMoneyPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = [LSAppManager sharedAppManager].loginUser.user_id;

    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        
        NSNumber * balanceNum = model.data;
        NSString * balanceStr = balanceNum.stringValue;
        
        !success?:success(balanceStr);

    } failure:^(NSError *error) {
        
        !failure?:failure(error);
        
    }];
}

+(void)getMoneyWithAmount:(NSString *)amount alipay:(NSString *)alipay name:(NSString *)name Success:(void(^)(NSString* ))success failure:(void(^)(NSError *error))failure{
    
    
    NSString *uri = [NSString stringWithFormat:@"/money?userid=%@&amount=%@&alipay=%@&name=%@&platform=boss66",ShareAppManager.loginUser.user_id,amount,alipay,name];
    NSString * uriEncoding =[uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *sign = [uriEncoding md5String];
    uriEncoding = [uriEncoding stringByReplacingOccurrencesOfString:@"platform=boss66" withString:@""];
    uriEncoding = [uriEncoding stringByAppendingString:[NSString stringWithFormat:@"sign=%@",sign]];
    
    NSString *path = [kBaseFuwa2URL stringByAppendingString:@"/msg"];
    path = [path stringByAppendingString:uriEncoding];
    
    
    [LSOBaseModel BGET:path parameters:nil success:^(LSOBaseModel *model) {
        
        !success?:success(nil);
        
    } failure:^(NSError *error) {
        
        !failure?:failure(error);
        
    }];
    
    
}
@end

@implementation LSUserwWithDrawModel



@end
