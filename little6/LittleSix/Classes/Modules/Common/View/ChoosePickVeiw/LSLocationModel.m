//
//  LSLocationModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLocationModel.h"

@implementation LSLocationModel



+(LSLocationModel *)createLSLocationModel:(NSDictionary *)dict{

    LSLocationModel * model = [LSLocationModel new];
    
    model.region_id = dict[@"region_id"];
    model.region_name = dict[@"region_name"];
    
    model.list = [LSCityModel createLSCityModel:dict[@"list"]];
    
    return model;
    
}

@end

@implementation LSCityModel

+(NSArray *)createLSCityModel:(NSArray *)arr{

    NSMutableArray * muAr = [NSMutableArray array];
    for (NSDictionary * dic in arr) {
        
        LSCityModel * city_M = [LSCityModel new];
        city_M.region_id = dic[@"region_id"];
        city_M.region_name = dic[@"region_name"];
        
        city_M.list = [LSLCitnModel createLSLCitnModel:dic[@"list"]];
        
        [muAr addObject:city_M];
    }
    return muAr;
}

@end

@implementation LSLCitnModel

+(NSArray *)createLSLCitnModel:(NSArray *)list{

    NSMutableArray * muAr = [NSMutableArray array];
    for (NSDictionary * dic in list) {
        
        LSCityModel * city_M = [LSCityModel new];
        city_M.region_id = dic[@"region_id"];
        city_M.region_name = dic[@"region_name"];
        
        [muAr addObject:city_M];
    }
    return muAr;
}

@end
