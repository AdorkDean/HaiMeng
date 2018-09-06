//
//  LSFuwaBackPackModel.h
//  LittleSix
//
//  Created by Jim huang on 17/4/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSFuwaDetailModel;
typedef enum{
    FuwaBackPickertypeCatch = 1,
    FuwaBackPickertypeApply = 2,
}FuwaBackPickertype;

@interface LSFuwaBackPackModel : NSObject

@property (nonatomic,strong) NSString * gid;
@property (nonatomic,strong) NSString * id;
@property (nonatomic,strong) NSString * creator;
@property (nonatomic,strong) NSString * awarded;
@property (nonatomic,strong) NSString * creatorid;
@property (nonatomic,strong) NSString * pos;

+(void)searchBackPackWithListType:(FuwaBackPickertype)listType AutoComplete:(BOOL)autoComplete Success:(void (^)(NSArray* modelList))success failure:(void (^)(NSError *error))failure;

+(void)saleFuwaWithID:(NSString *)id Gid:(NSString *)gid amount:(NSString *)amount Success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

+(void)presentFuwaWithtoken:(NSString *)token Gid:(NSString *)gid Success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

+(void)searchApplyFuwaCountSuccess:(void (^)(int personCount,int MerChantCount))success failure:(void (^)(NSError *error))failure;

+(void)FuwaActivityWithfuwaId:(NSString *)gid Success:(void (^)(NSString *activityStr))success failure:(void (^)(NSError *error))failure;

@end

@interface LSFuwaBackPackListModel : NSObject

@property (nonatomic,strong) NSArray * fuwaListArr;
@property (nonatomic,strong) NSString * id;

@end




