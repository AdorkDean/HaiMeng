//
//  LSIndexLinkInModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSIndexLinkInModel : NSObject

//学校
@property (assign, nonatomic)NSInteger school_id;
@property (copy, nonatomic)NSString * name;
@property (copy, nonatomic)NSString * logo;
@property (copy, nonatomic)NSString * banner;
@property (copy, nonatomic)NSString * brief_desc;
@property (assign, nonatomic)NSInteger count;

@property (copy, nonatomic)NSString * user_id;
//家乡列表
@property (assign, nonatomic)NSInteger hometown_id;

@property (assign, nonatomic)NSInteger cofc_id;

@property (assign, nonatomic)NSInteger clan_id;

@property (assign, nonatomic)NSInteger stribe_id;

+(void)indexLinkWithlistToken:(NSString *)access_token
                      success:(void (^)(NSArray *schoolArray,NSArray *regionArray,NSArray *clanArr,NSArray *cofcArr,NSArray *stribeArr))success
                      failure:(void (^)(NSError *))failure;

+(void)indexLinkWithTribalCreateId:(NSString *)user_id
                         success:(void (^)(NSArray *list))success
                         failure:(void (^)(NSError *))failure;

@end
