//
//  LSNewAdressModel.h
//  LittleSix
//
//  Created by Jim huang on 17/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSFuwaNewAdressModel : NSObject<NSCoding>

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *city;
@property(nonatomic,copy)NSString *district;
@property(nonatomic,copy)NSString *adress;
@property(nonatomic,copy)NSString *totalAdress;


@end
