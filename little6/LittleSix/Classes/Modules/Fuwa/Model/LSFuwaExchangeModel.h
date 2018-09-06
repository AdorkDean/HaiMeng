//
//  LSFuwaExchangeModel.h
//  LittleSix
//
//  Created by Jim huang on 17/3/22.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSFuwaExchangeModel : NSObject

@property (nonatomic,strong) NSString *orderid;
@property (nonatomic,strong) NSString *owner;
@property (nonatomic,strong) NSString *amount;
@property (nonatomic,strong) NSString *fuwagid;
@property (nonatomic,strong) NSString *fuwaid;
@property (nonatomic,assign) BOOL cellSelect;
@property (nonatomic,strong) NSIndexPath *index;


+ (void)getFuwaExchangeListSuccess:(void (^)(NSArray * listArr))success failure:(void (^)(NSError *error))failure;

+ (void)getFuwaExMyListSuccess:(void (^)(NSArray * listArr))success failure:(void (^)(NSError *error))failure;

+ (void)requestWechatPayWithOrderId:(NSString *)order_id amount:(float)amount goodsId:(NSString *)goodsId success:(void (^)(NSDictionary *dict))success failure:(void (^)(NSError *error))failure;

+ (void)requestAlipay:(NSString *)orderId amount:(NSString *)amount gid:(NSString *)fuwaId success:(void (^)(NSString *info))success failure:(void (^)(NSError *error))failure;

+(void)revokeFuwaWithOrderID:(NSString *)orderId Gid:(NSString *)gid Success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
