//
//  LSTimeLineTableModel.h
//  LittleSix
//
//  Created by Jim huang on 17/3/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LSTimeLineImageModel;
@class LSTimeLinePraiseModel;
@class LSTimeLineCommentModel;

typedef enum{
    timeLinePriseTypeNo=0,
    timeLinePriseTypeIs,
}timeLinePriseType;

@class LSGetNewMsgFirstModel;
@class LSGetNewMsgModel;
@interface LSTimeLineTableListModel : NSObject<NSCoding>

@property (nonatomic,assign) int did;
@property (nonatomic,assign) int feed_id;
@property (nonatomic,copy) NSString * user_id;
@property (nonatomic,assign) int feed_uid;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,assign) int feed_type;
@property (nonatomic,copy) NSString *share_url;
@property (nonatomic,copy) NSString *position;
@property (nonatomic,copy) NSString *remind_user;
@property (nonatomic,copy) NSString *feed_avatar;
@property (nonatomic,copy) NSString *feed_username;
@property (nonatomic,strong) NSArray * files;
@property (nonatomic,copy) NSString *add_time;
@property (nonatomic,strong) NSArray * praise_list;
@property (nonatomic,strong) NSMutableArray * comment_list;
@property (nonatomic,assign) timeLinePriseType is_praise;

@property (nonatomic,assign) BOOL isSelected;

+ (void)getTimeLineListWithPage:(int)page pageSize:(int)pageSize success:(void (^)(NSArray * modelArr))success failure:(void (^)(NSError *error))failure;

+ (void)PriseToTimeLineWithfeed_id:(int)feed_id type:(timeLinePriseType)type success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

+ (void)loadTimeLineDetailWithfeed_id:(int)feed_id success:(void (^)(LSTimeLineTableListModel * model))success failure:(void (^)(NSError *error))failure;

+ (void)addTimeLineCommentWithfeed_id:(int)feed_id content:(NSString *)content pid:(int)pid uid_to:(int)uid_to success:(void (^)(NSString *string))success failure:(void (^)(NSError *error))failure;

+ (void)searchGalleryWithuserID:(int)userID page:(int)page success:(void (^)(NSArray *modelArr))success failure:(void (^)(NSError *error))failure;

+ (void)deleteTimeLineWithFeed_id:(int)feed_id success:(void (^)(void))success failure:(void (^)(NSError *error))failure ;

+(void)changeHeadBGImageWithImage:(UIImage *)image success:(void (^)(NSString * BGimageUrl))success failure:(void (^)(NSError *error))failure ;
+(void)getFirstMsgSuccess:(void (^)(LSGetNewMsgModel * NewMsgModel))success failure:(void (^)(NSError *error))failure;

+ (void)deleteTimeLineCommentWithcomm_id:(int)comm_id success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end


@interface LSTimeLineImageModel : NSObject

@property (nonatomic,copy) NSString *file_url;
@property (nonatomic,copy) NSString *file_thumb;

@end

@interface LSTimeLineCommentModel : NSObject

@property (nonatomic,assign) int comm_id;
@property (nonatomic,assign) int feed_id;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,assign) int uid_from;
@property (nonatomic,copy) NSString *uid_from_name;
@property (nonatomic,assign) int uid_to;
@property (nonatomic,copy) NSString *uid_to_name;
@property (nonatomic,assign) int pid;


@end

@interface LSTimeLinePraiseModel : NSObject

@property (nonatomic,assign) int user_id;
@property (nonatomic,copy) NSString *user_name;

@end

@interface LSGetNewMsgModel : NSObject

@property (nonatomic,copy) NSString *count;
@property (nonatomic,strong) LSGetNewMsgFirstModel *frist_user;




@end


@interface LSGetNewMsgFirstModel : NSObject

@property (nonatomic,assign) int user_id;
@property (nonatomic,copy) NSString *user_name;
@property (nonatomic,copy) NSString *avatar;




@end
