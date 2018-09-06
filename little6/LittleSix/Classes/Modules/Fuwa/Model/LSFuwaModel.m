//
//  LSFuwaModel.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaModel.h"
#import "LSOBaseModel.h"

@implementation LSFuwaModel

- (void)setGeo:(NSString *)geo {
    _geo = geo;
    
    NSArray *list = [geo componentsSeparatedByString:@"-"];
    
    LSAnnotation *annotation = [LSAnnotation new];
    annotation.coordinate = CLLocationCoordinate2DMake([list.lastObject doubleValue], [list.firstObject doubleValue]);
    self.annotation = annotation;
}

+ (void)fetchNearbyFuwaListByLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude radius:(CGFloat)radius biggest:(NSString *)biggest success:(void (^)(LSFuwaMapListModel*mapListModel))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kNearbyFuwaPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"geohash"] = [NSString stringWithFormat:@"%lf-%lf",longitude,latitude];
    NSInteger intRadius = (int)radius;
    params[@"radius"] = @(intRadius);
    params[@"biggest"] = biggest;

    
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        
        NSArray *farList = [NSArray modelArrayWithClass:[LSFuwaModel class] json:model.data[@"far"]];
        NSArray *nearList = [NSArray modelArrayWithClass:[LSFuwaModel class] json:model.data[@"near"]];
        
        LSFuwaMapListModel * mapListModel = [LSFuwaMapListModel new];
        mapListModel.far = farList;
        mapListModel.near = nearList;


        !success?:success(mapListModel);
    
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
}


+ (void)fetchNearbyPartnerFuwaListByLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude radius:(CGFloat)radius biggest:(NSString *)biggest success:(void (^)(LSFuwaMapListModel*mapListModel))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kNearbyPartnerFuwaPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"geohash"] = [NSString stringWithFormat:@"%lf-%lf",longitude,latitude];
    NSInteger intRadius = (int)radius;
    params[@"radius"] = @(intRadius);
    params[@"biggest"] = biggest;

    
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        
        NSArray *farList = [NSArray modelArrayWithClass:[LSFuwaModel class] json:model.data[@"far"]];
        NSArray *nearList = [NSArray modelArrayWithClass:[LSFuwaModel class] json:model.data[@"near"]];
        
        LSFuwaMapListModel * mapListModel = [LSFuwaMapListModel new];
        mapListModel.far = farList;
        mapListModel.near = nearList;
        
        
        !success?:success(mapListModel);
        
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
}

+ (void)fetchMerchantNearbyFuwaListByLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude radius:(CGFloat)radius userid:(NSString *)userid biggest:(NSString *)biggest success:(void (^)(LSFuwaMapListModel*mapListModel))success failure:(void (^)(NSError *))failure{

    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kNearMerchantbyFuwaPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"geohash"] = [NSString stringWithFormat:@"%lf-%lf",longitude,latitude];
    NSInteger intRadius = (int)radius;
    params[@"radius"] = @(intRadius);
    params[@"biggest"] = biggest;
    params[@"userid"] = userid;

    
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        
        NSArray *farList = [NSArray modelArrayWithClass:[LSFuwaModel class] json:model.data[@"far"]];
        NSArray *nearList = [NSArray modelArrayWithClass:[LSFuwaModel class] json:model.data[@"near"]];
        
        LSFuwaMapListModel * mapListModel = [LSFuwaMapListModel new];
        mapListModel.far = farList;
        mapListModel.near = nearList;
        
        
        !success?:success(mapListModel);
        
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];


}

+ (void)fetchOnePartnerNearbyFuwaListByLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude radius:(CGFloat)radius userid:(NSString *)userid biggest:(NSString *)biggest success:(void (^)(LSFuwaMapListModel*mapListModel))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kNearOnePartnerbyFuwaPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"geohash"] = [NSString stringWithFormat:@"%lf-%lf",longitude,latitude];
    NSInteger intRadius = (int)radius;
    params[@"radius"] = @(intRadius);
    params[@"biggest"] = biggest;
    params[@"userid"] = userid;
    
    
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        
        NSArray *farList = [NSArray modelArrayWithClass:[LSFuwaModel class] json:model.data[@"far"]];
        NSArray *nearList = [NSArray modelArrayWithClass:[LSFuwaModel class] json:model.data[@"near"]];
        
        LSFuwaMapListModel * mapListModel = [LSFuwaMapListModel new];
        mapListModel.far = farList;
        mapListModel.near = nearList;
        
        
        !success?:success(mapListModel);
        
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
    
    
}

+ (void)catchFuwaWith:(UIImage *)image gid:(NSString *)gid success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    
    
    NSString *uri = [NSString stringWithFormat:@"/capture?user=%@&gid=%@&platform=boss66",ShareAppManager.loginUser.user_id,gid];
    NSString *sign = [uri md5String];
    
    uri = [uri stringByReplacingOccurrencesOfString:@"platform=boss66" withString:@""];
    uri = [uri stringByAppendingString:[NSString stringWithFormat:@"sign=%@",sign]];
    
    NSString *path = [kBaseFuwa2URL stringByAppendingString:@"/api"];
    path = [path stringByAppendingString:uri];
    
    NSData *data = UIImageJPEGRepresentation(image, 0.4);

    [LSOBaseModel uploadFiles:path parameters:nil files:@[data] keys:@[@"file"] fileNames:@[@"file.jpg"] mimeType:@"image/jpeg" uploadProgress:nil success:^(LSOBaseModel *model) {
        
        BOOL matching = [model.data boolValue];
        
        if (matching) {
            !success?:success();
        }
        else {
            !failure?:failure(nil);
        }
        
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
}

//新抓福娃接口
+ (void)catchFuwaWithGid:(NSString *)gid
                 success:(void (^)(LSFuwaModel * model))success
                 failure:(void (^)(NSError *error))failure {

    NSString *uri = [NSString stringWithFormat:@"/capturev2?user=%@&gid=%@&platform=boss66",ShareAppManager.loginUser.user_id,gid];
    NSString *sign = [uri md5String];
    
    uri = [uri stringByReplacingOccurrencesOfString:@"platform=boss66" withString:@""];
    uri = [uri stringByAppendingString:[NSString stringWithFormat:@"sign=%@",sign]];
    
    NSString *path = [kBaseFuwa2URL stringByAppendingString:@"/api"];
    path = [path stringByAppendingString:uri];

    
    [LSOBaseModel BGET:path parameters:nil success:^(LSOBaseModel *model) {

        NSDictionary * dic = @{@"code":@(model.code),@"message":model.message};
        LSFuwaModel * fmodel  = [LSFuwaModel modelWithJSON:dic];
        !success?:success(fmodel);
        
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
}

+ (void)querymyWithAutoComplete:(BOOL)autoComplete ssuccess:(void (^)(NSArray<LSFuwaModel *> *))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent: kQueryFuwaPath];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"user"] = ShareAppManager.loginUser.user_id;
    
    [LSOBaseModel BGET:path parameters:dict success:^(LSOBaseModel *model) {
        
        NSArray<LSFuwaModel *> *list = [NSArray modelArrayWithClass:[LSFuwaModel class] json:model.data];
        
        NSMutableArray<LSFuwaModel *> *array = [NSMutableArray array];
        
        for (LSFuwaModel *model in list) {
            
            LSFuwaModel *hasItem;
            
            for (LSFuwaModel *item in array) {
                if ([item.id isEqualToString:model.id]) {
                    hasItem = item;
                }
            }
            if (hasItem) {
                hasItem.count++;
            }
            else {
                model.count = 1;
                [array addObject:model];
            }
        }
        
        //数组排序
        [array sortUsingComparator:^NSComparisonResult(LSFuwaModel *obj1, LSFuwaModel *obj2) {
            NSComparisonResult result = [obj1.id compare:obj2.id options:NSNumericSearch];
            return result;
        }];
        
        if (autoComplete) {
            
            NSMutableArray *allList = [NSMutableArray array];
            
            for (int i = 1; i<67; i++) {
                
                NSString *number = [NSString stringWithFormat:@"%d",i];
                
                LSFuwaModel *hasItem;
                for (LSFuwaModel *item in array) {
                    if ([item.id isEqualToString:number]) {
                        hasItem = item;
                    }
                }
                if (hasItem) {
                    [allList addObject:hasItem];
                }
                else {
                    LSFuwaModel *model = [LSFuwaModel new];
                    model.id = number;
                    model.count = 0;
                    [allList addObject:model];
                }
            }
            
            !success?:success(allList);
        }
        else {
            !success?:success(array);
        }
        
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
}

+ (void)saveFuwaVideoWith:(NSString *)position location:(CLLocation *)location Fuwacount:(NSString *)count cluesImage:(UIImage *)image detail:(NSString *)detail videoModel:(LSCaptureModel *)videoModel validtime:(NSString *)validtime type:(NSString *)type class:(NSString *)Class uploadProgress:(void(^)(NSProgress *progress))Progress success:(void (^)(void))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent: kHiddenFuwaPath];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"owner"] = ShareAppManager.loginUser.user_id;
    param[@"number"] = count;
    param[@"pos"] = position;
    param[@"geohash"] = [NSString stringWithFormat:@"%lf-%lf",location.coordinate.longitude,location.coordinate.latitude];
    param[@"detail"] = detail;
    param[@"validtime"] = validtime;
    param[@"type"] = type;

    param[@"class"] = Class;
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    NSURL * videoUrl = [videoModel localVideoFileURL];
    NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
    
    NSString * fileStr =[videoUrl.absoluteString lastPathComponent];
    NSString * videoMimeType;
    NSString * formatStr;
    [fileStr stringByReplacingOccurrencesOfString:@".MOV" withString:@".mov"];
    if ([fileStr containsString:@".mov" ]||[fileStr containsString:@".MOV"]) {
        videoMimeType = @"video/quicktime";
        formatStr = @"files.mov";
    }
    else if ([fileStr containsString:@".mp4"]||[fileStr containsString:@".MP4"]) {
        videoMimeType = @"video/mp4";
        formatStr = @"files.mp4";
    }
    
    [LSOBaseModel uploadFilesAndVideo:path parameters:param files:@[videoData,data] keys:@[@"video",@"file"] fileNames:@[formatStr,@"file.jpg"] mimeTypes:@[videoMimeType,@"image/jpeg"] uploadProgress:^(NSProgress *progress) {
        Progress(progress);
    } success:^(LSOBaseModel *model) {
        !success?:success();

    } failure:^(NSError *error) {
        !failure?:failure(error);

    }];
}

//没有视频藏福娃
+ (void)saveFuwaWith:(NSString *)position location:(CLLocation *)location Fuwacount:(NSString *)count cluesImage:(UIImage *)image detail:(NSString *)detail validtime:(NSString *)validtime type:(NSString *)type class:(NSString *)Class uploadProgress:(void(^)(NSProgress *progress))Progress success:(void (^)(void))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent: kHiddenFuwaPath];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"owner"] = ShareAppManager.loginUser.user_id;
    param[@"number"] = count;
    param[@"pos"] = position;
    param[@"geohash"] = [NSString stringWithFormat:@"%lf-%lf",location.coordinate.longitude,location.coordinate.latitude];
    param[@"detail"] = detail;
    param[@"validtime"] = validtime;
    param[@"type"] = type;
    param[@"class"] = Class;

    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    

    
    [LSOBaseModel uploadFilesAndVideo:path parameters:param files:@[data] keys:@[@"file"] fileNames:@[@"file.jpg"] mimeTypes:@[@"image/jpeg"] uploadProgress:^(NSProgress *progress) {
        
        Progress(progress);
        
    } success:^(LSOBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSError *error) {
        
        !failure?:failure(error);
        
    }];


}

+ (void)fuwaDetailWithGid:(NSString *)gid Success:(void (^)(LSFuwaDetailModel*detailModel))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwaDetailPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"fuwagid"] =gid;
    
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        LSFuwaDetailModel * detailModel  = [LSFuwaDetailModel modelWithJSON:model.data];
        !success?:success(detailModel);
        
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
    
}

+(void)saleFuwaWithID:(NSString *)id Gid:(NSString *)gid amount:(NSString *)amount Success:(void (^)(void))success failure:(void (^)(NSError *error))failure{
    
    NSString *uri = [NSString stringWithFormat:@"/sell?id=%@&owner=%@&amount=%@&fuwagid=%@&platform=boss66",id,ShareAppManager.loginUser.user_id,amount,gid];
    NSString *sign = [uri md5String];
    uri = [uri stringByReplacingOccurrencesOfString:@"platform=boss66" withString:@""];
    uri = [uri stringByAppendingString:[NSString stringWithFormat:@"sign=%@",sign]];
    
    NSString *path = [kBaseFuwa2URL stringByAppendingString:@"/msg"];
    path = [path stringByAppendingString:uri];
    
    [LSOBaseModel BGET:path parameters:nil success:^(LSOBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSError *error) {
        
        !failure?:failure(error);
        
    }];
}

+(void)presentFuwaWithtoken:(NSString *)token Gid:(NSString *)gid Success:(void (^)(void))success failure:(void (^)(NSError *error))failure{
    
    NSString *uri = [NSString stringWithFormat:@"/donate?token=%@&fuwagid=%@&fromuser=%@&platform=boss66",token,gid,ShareAppManager.loginUser.user_id];
    NSString *sign = [uri md5String];
    uri = [uri stringByReplacingOccurrencesOfString:@"platform=boss66" withString:@""];
    uri = [uri stringByAppendingString:[NSString stringWithFormat:@"sign=%@",sign]];
    NSString *path = [kBaseFuwa2URL stringByAppendingString:@"/api"];
    path = [path stringByAppendingString:uri];
    
    [LSOBaseModel BGET:path parameters:nil success:^(LSOBaseModel *model) {
        
        success();
        
    } failure:^(NSError *error) {
        
        !failure?:failure(error);
        
    }];
}

+ (void)appleFuwaWith:(LSFuwaApplyModel *)model success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwaApplyPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = ShareAppManager.loginUser.user_id;
    params[@"name"] = model.name;
    params[@"phone"] = model.phone;
    params[@"shop"] = @(model.shop);
    params[@"purpose"] = model.purpose;
    params[@"region"] = model.region;
    params[@"number"] = model.number;
    
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        !success ? : success();
    } failure:^(NSError *error) {
        !failure ? : failure(error);
    }];
    
}

+(void)awardFuwaWithGid:(NSString *)gid  Success:(void (^)(NSString *))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwaAwardPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = ShareAppManager.loginUser.user_id;
    params[@"fuwagid"] = gid;

    
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        !success ? : success(model.message);
    } failure:^(NSError *error) {
        !failure ? : failure(error);
    }];
    
    
    
}

@end

@implementation LSAnnotation

@end

@implementation LSFuwaDetailModel

@end

@implementation LSFuwaApplyModel

@end


@implementation LSFuwaMapListModel

@end

