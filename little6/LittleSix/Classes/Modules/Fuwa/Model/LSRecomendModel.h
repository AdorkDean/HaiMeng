//
//  LSRecomendVideoModel.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/6/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSRecomendModel : NSObject

@property (nonatomic,assign) CGFloat distance;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *gender;
@property (nonatomic,copy) NSString *userid;
@property (nonatomic,copy) NSString *filemd5;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,copy) NSString *video;
@property (nonatomic,copy) NSString *avatar;

@property (nonatomic,copy) NSString *disString;

@property (nonatomic,copy) NSString *coverImage;

- (CGSize)scaleSize;

+ (void)recomendVideosWithType:(NSUInteger)type geo:(NSString *)geoString class:(NSString *)classes success:(void (^)(NSArray *list))success failure:(void (^)(NSError *error))failure;

+ (void)increasePlayCount:(LSRecomendModel *)videoModel class:(NSString *)class_id success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
