//
//  LSFriendListModel.h
//  LittleSix
//
//  Created by Jim huang on 17/3/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSFriendModel : NSObject<NSCoding>

@property (nonatomic,copy) NSString *fid;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *user_name;
@property (nonatomic,copy) NSString *friend_id;
@property (nonatomic,copy) NSString *first_letter;
@property (nonatomic,assign) BOOL selected;

+ (void)getFriendListSuccess:(void (^)(NSArray * modelArr))success failure:(void (^)(NSError *error))failure;

@end

@interface LSFriendListModel : NSObject

@property (nonatomic,copy) NSString *first_letter;
@property (nonatomic,strong) NSArray *friendList;

@end

@interface LSFriendListLabelModel : NSObject

@property (nonatomic,copy) NSString *label;
@property (nonatomic,strong) NSArray *friendList;

@end
