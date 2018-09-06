//
//  LSLocationModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSCityModel,LSLCitnModel;
@interface LSLocationModel : NSObject

@property (copy,nonatomic)NSString * region_id;
@property (copy,nonatomic)NSString * region_name;
@property (copy,nonatomic)NSArray<LSCityModel *> * list;

+(LSLocationModel *)createLSLocationModel:(NSDictionary *)dict;

@end

@interface LSCityModel : NSObject

@property (copy,nonatomic)NSString * region_id;
@property (copy,nonatomic)NSString * region_name;
@property (copy,nonatomic)NSArray<LSLCitnModel *> * list;

+(NSArray *)createLSCityModel:(NSArray *)arr;

@end

@interface LSLCitnModel : NSObject

@property (copy,nonatomic)NSString * region_id;
@property (copy,nonatomic)NSString * region_name;

+(NSArray *)createLSLCitnModel:(NSArray *)list;

@end
