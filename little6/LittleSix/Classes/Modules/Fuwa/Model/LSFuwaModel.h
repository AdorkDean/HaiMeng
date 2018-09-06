//
//  LSFuwaModel.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import "LSCaptureViewController.h"

@class LSAnnotation,LSFuwaDetailModel,LSFuwaApplyModel,LSFuwaMapListModel;
@interface LSFuwaModel : NSObject

@property (nonatomic,assign) CGFloat distance;

@property (nonatomic,copy) NSString *pic;

@property (nonatomic,copy) NSString *gid;

@property (nonatomic,copy) NSString *geo;

@property (nonatomic,copy) NSString *pos;

@property (nonatomic,copy) NSString *id;

@property (nonatomic,copy) NSString *detail;

@property (nonatomic,strong) LSAnnotation *annotation;

@property (nonatomic,copy) NSString *avatar;

@property (nonatomic,assign) NSInteger redevlp;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *gender;

@property (nonatomic,copy) NSString *signature;

@property (nonatomic,copy) NSString *location;

@property (nonatomic,copy) NSString *video;

@property (nonatomic,copy) NSString *hider;

//地图福娃组内含福娃数量
@property (nonatomic,copy) NSString * number;

//背包用到
@property (nonatomic,assign) NSInteger count;
//抓福娃
@property (nonatomic,assign) NSInteger code;
@property (nonatomic,copy) NSString *message;

//查询周边的福娃
+ (void)fetchNearbyFuwaListByLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude radius:(CGFloat)radius biggest:(NSString *)biggest success:(void (^)(LSFuwaMapListModel*mapListModel))success failure:(void (^)(NSError *error))failure;

//查询缘分的福娃
+ (void)fetchNearbyPartnerFuwaListByLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude radius:(CGFloat)radius biggest:(NSString *)biggest success:(void (^)(LSFuwaMapListModel*mapListModel))success failure:(void (^)(NSError *))failure;

//查找特定商家福娃
+ (void)fetchMerchantNearbyFuwaListByLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude radius:(CGFloat)radius userid:(NSString *)userid biggest:(NSString *)biggest success:(void (^)(LSFuwaMapListModel*mapListModel))success failure:(void (^)(NSError *))failure;
//查找特定萌友福娃
+ (void)fetchOnePartnerNearbyFuwaListByLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude radius:(CGFloat)radius userid:(NSString *)userid biggest:(NSString *)biggest success:(void (^)(LSFuwaMapListModel*mapListModel))success failure:(void (^)(NSError *))failure;

//旧抓福娃接口
+ (void)catchFuwaWith:(UIImage *)image gid:(NSString *)gid success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
//新抓福娃接口
+ (void)catchFuwaWithGid:(NSString *)gid success:(void (^)(LSFuwaModel * model))success failure:(void (^)(NSError *error))failure;

+ (void)querymyWithAutoComplete:(BOOL)autoComplete ssuccess:(void (^)(NSArray<LSFuwaModel *> *))success failure:(void (^)(NSError *))failure;
//没有视频藏福娃
+ (void)saveFuwaWith:(NSString *)position location:(CLLocation *)location Fuwacount:(NSString *)count cluesImage:(UIImage *)image detail:(NSString *)detail validtime:(NSString *)validtime type:(NSString *)type class:(NSString *)Class uploadProgress:(void(^)(NSProgress *progress))Progress success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
//有视频藏福娃
+ (void)saveFuwaVideoWith:(NSString *)position location:(CLLocation *)location Fuwacount:(NSString *)count cluesImage:(UIImage *)image detail:(NSString *)detail videoModel:(LSCaptureModel *)videoModel validtime:(NSString *)validtime type:(NSString *)type class:(NSString *)Class uploadProgress:(void(^)(NSProgress *progress))Progress success:(void (^)(void))success failure:(void (^)(NSError *))failure;


//福娃详情
+ (void)fuwaDetailWithGid:(NSString *)gid Success:(void (^)(LSFuwaDetailModel*detailModel))success failure:(void (^)(NSError *error))failure;

//出售福娃
+(void)saleFuwaWithID:(NSString *)id Gid:(NSString *)gid amount:(NSString *)amount Success:(void (^)(void))success failure:(void (^)(NSError *error))failure;


//赠送福娃
+(void)presentFuwaWithtoken:(NSString *)token Gid:(NSString *)gid Success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

//申请福娃
+ (void)appleFuwaWith:(LSFuwaApplyModel *)model success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

//验证福娃
+(void)awardFuwaWithGid:(NSString *)gid  Success:(void (^)(NSString *))success failure:(void (^)(NSError *error))failure;

@end

@interface LSAnnotation : NSObject <MAAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end

@interface LSFuwaDetailModel : NSObject

@property (nonatomic,strong) NSString * pos;
@property (nonatomic,strong) NSString * creator;
@property (nonatomic,strong) NSString * awarded;
@property (nonatomic,strong) NSString * gid;
@property (nonatomic,strong) NSString * id;


@end

@interface LSFuwaApplyModel : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *phone;
@property (nonatomic,assign) NSInteger shop;
@property (nonatomic,copy) NSString *purpose;
@property (nonatomic,copy) NSString *region;
@property (nonatomic,copy) NSString *number;

@end


@interface LSFuwaMapListModel : NSObject

@property (nonatomic,copy) NSArray<LSFuwaModel *> * far;
@property (nonatomic,copy) NSArray<LSFuwaModel *> * near ;

@end
