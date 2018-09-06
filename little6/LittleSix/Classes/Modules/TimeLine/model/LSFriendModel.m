//
//  LSFriendListModel.m
//  LittleSix
//
//  Created by Jim huang on 17/3/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFriendModel.h"
#import "LSAppManager.h"
#import "LSFriendLabelManager.h"
#import "LSBaseModel.h"

@implementation LSFriendModel

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.fid forKey:@"fid"];
    [encoder encodeObject:self.avatar forKey:@"avatar"];
    [encoder encodeObject:self.user_name forKey:@"user_name"];
    [encoder encodeObject:self.friend_id forKey:@"friend_id"];
    [encoder encodeObject:self.first_letter forKey:@"first_letter"];

}
- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self!=nil) {
        self.fid = [decoder decodeObjectForKey:@"fid"];
        self.avatar = [decoder decodeObjectForKey:@"avatar"];
        self.user_name = [decoder decodeObjectForKey:@"user_name"];
        self.friend_id = [decoder decodeObjectForKey:@"friend_id"];
        self.first_letter = [decoder decodeObjectForKey:@"first_letter"];
    }
    return self;
}


+ (void)getFriendListSuccess:(void (^)(NSArray * modelArr))success failure:(void (^)(NSError *error))failure{
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kFriendListPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSArray * Arr = [NSArray modelArrayWithClass:[LSFriendModel class] json:model.result];

        NSMutableDictionary * listDic = [NSMutableDictionary dictionary];
        
        [LSFriendLabelManager DBInsertFriendArr:Arr];
        
        for (LSFriendModel * FriendModel in Arr) {
            if ([[listDic allKeys]  containsObject: FriendModel.first_letter]) {
                NSMutableArray * listArr =listDic[FriendModel.first_letter];
                [listArr addObject:FriendModel];
             }else{
                 NSMutableArray * listArr = [NSMutableArray array];
                 [listArr addObject:FriendModel];
                 [listDic setObject:listArr forKey:FriendModel.first_letter];
             }
        }
        NSMutableArray *orderbByArr = [NSMutableArray array];

        for (NSString *key in listDic) {
            LSFriendListModel * listModel = [[LSFriendListModel alloc]init];
            listModel.first_letter = key;
            NSArray * flArr =listDic[key];
            listModel.friendList = flArr;
            [orderbByArr addObject:listModel];
        }

        success(orderbByArr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        
        
        !failure?:failure(error);
        
        
    }];
}

@end

@implementation LSFriendListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"friendList" : [LSFriendModel class]};
}


@end

@implementation LSFriendListLabelModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"friendList" : [LSFriendModel class]};
}


@end
