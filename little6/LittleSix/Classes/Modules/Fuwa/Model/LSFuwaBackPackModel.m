//
//  LSFuwaBackPackModel.m
//  LittleSix
//
//  Created by Jim huang on 17/4/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaBackPackModel.h"
#import "LSOBaseModel.h"


@implementation LSFuwaBackPackModel

+(void)searchBackPackWithListType:(FuwaBackPickertype)listType AutoComplete:(BOOL)autoComplete Success:(void (^)(NSArray* modelList))success failure:(void (^)(NSError *error))failure{
    NSString * listPath;
    if (listType == FuwaBackPickertypeCatch)
        listPath = kFuwaBackPackCatchPath;
    else
        listPath = kFuwaBackPackApplyPath;
    
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:listPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"user"] =ShareAppManager.loginUser.user_id;
    
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        NSArray * fuwaList = [NSArray modelArrayWithClass:[LSFuwaBackPackModel class] json:model.data];
        
        
        NSMutableDictionary * listDic = [NSMutableDictionary dictionary];
        
        for (LSFuwaBackPackModel * BackPackModel in fuwaList) {
            if ([[listDic allKeys]  containsObject: BackPackModel.id]) {
                NSMutableArray * listArr =listDic[BackPackModel.id];
                [listArr addObject:BackPackModel];
            }else{
                NSMutableArray * listArr = [NSMutableArray array];
                [listArr addObject:BackPackModel];
                [listDic setObject:listArr forKey:BackPackModel.id];
            }
        }
        NSMutableArray *orderbByArr = [NSMutableArray array];
        
        for (NSString *key in listDic) {
            LSFuwaBackPackListModel * listModel = [[LSFuwaBackPackListModel alloc]init];
            listModel.id = key;
            NSArray * flArr =listDic[key];
            listModel.fuwaListArr = flArr;
            [orderbByArr addObject:listModel];
        }
        
        
        [orderbByArr sortUsingComparator:^NSComparisonResult(LSFuwaBackPackListModel *obj1, LSFuwaBackPackListModel *obj2) {
            NSComparisonResult result = [obj1.id compare:obj2.id options:NSNumericSearch];
            return result;
        }];
        if (autoComplete) {
            NSMutableArray *allList = [NSMutableArray array];
            
            for (int i = 1; i<67; i++) {
                
                NSString *number = [NSString stringWithFormat:@"%d",i];
                
                LSFuwaBackPackListModel *hasModel;
                for (LSFuwaBackPackListModel *listModel in orderbByArr) {
                    if ([listModel.id isEqualToString:number]) {
                        hasModel = listModel;
                    }
                }
                if (hasModel) {
                    [allList addObject:hasModel];
                }
                else {
                    LSFuwaBackPackListModel *newmodel = [LSFuwaBackPackListModel new];
                    newmodel.id = number;
                    newmodel.fuwaListArr = [NSArray array];
                    [allList addObject:newmodel];
                    
                }
            }
            
            !success?:success(allList);
        }else{
            !success?:success(orderbByArr);

        }

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
        
        success();
    } failure:^(NSError *error) {
        
        failure(error);
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
        
        failure(error);
        
    }];
    
}

+(void)searchApplyFuwaCountSuccess:(void (^)(int personCount,int MerChantCount))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwaBackPackApplyPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"user"] =ShareAppManager.loginUser.user_id;
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        
        NSArray * fuwaList = [NSArray modelArrayWithClass:[LSFuwaBackPackModel class] json:model.data];
        
        NSMutableArray * personArray = [NSMutableArray array];
        NSMutableArray * merchantArray = [NSMutableArray array];
        
        for (LSFuwaBackPackModel * BackPackModel in fuwaList) {
            
            if ([BackPackModel.gid containsString:@"_i_"]) {
                [personArray addObject:BackPackModel];
            }else{
                [merchantArray addObject:BackPackModel];
            }
            
        }

        !success?:success((int)personArray.count,(int)merchantArray.count);

    } failure:^(NSError *error) {
        failure(error);

    }];
}

+(void)FuwaActivityWithfuwaId:(NSString *)gid Success:(void (^)(NSString *activityStr))success failure:(void (^)(NSError *error))failure{
    
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwaActivityPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"fuwagid"] =gid;
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {

        NSString * activityStr = model.data;
        !success?:success(activityStr);
        
    } failure:^(NSError *error) {
        failure(error);
        
    }];
}

@end

@implementation LSFuwaBackPackListModel

@end

