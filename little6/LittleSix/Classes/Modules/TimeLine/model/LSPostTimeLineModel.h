//
//  LSPostTimeLineModel.h
//  LittleSix
//
//  Created by Jim huang on 17/3/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>


@class LSCaptureModel;
@interface LSPostTimeLineModel : NSObject

@property (nonatomic,assign) int feed_id;

+ (void)postTimeLineWithContent:(NSString *)content files:(NSArray *)imageArray whoSeeType:(SelectContactViewType)type whoSeeExt:(NSString*)ext position:(NSString *)position remindUser:(NSString *)remindUser success:(void (^)(LSPostTimeLineModel * model))success failure:(void (^)(NSError *error))failure;

+ (void)postVideoTimeLineWithContent:(NSString *)content videoModel:(LSCaptureModel *)videoModel whoSeeType:(SelectContactViewType)type whoSeeExt:(NSString*)ext position:(NSString *)position remindUser:(NSString *)remindUser Progress:(void (^)(NSProgress * Progress))Progress success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
