//
//  LSFriendLabelManager.m
//  LittleSix
//
//  Created by Jim huang on 17/3/9.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFriendLabelManager.h"
#import <FMDB/FMDB.h>
#import "LSFriendModel.h"
static FMDatabase *FriendLabelDB;


@implementation LSFriendLabelManager

static LSFriendLabelManager *_instance;

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (void)initialManagerWithId:(NSString *)user_id {
    
    if (FriendLabelDB) [FriendLabelDB close];
    
    NSString *db_name = [NSString stringWithFormat:@"FriendLabel_%@.sqlite",user_id];
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:db_name];
    
    FriendLabelDB = [FMDatabase databaseWithPath:filePath];
    
    if (![FriendLabelDB open]) return;
    
    //好友标签表
    [FriendLabelDB executeUpdate:@"CREATE TABLE IF NOT EXISTS `friend_List_Label` (label text PRIMARY KEY NOT NULL, friendList blob);"];
    //好友列表
    [FriendLabelDB executeUpdate:@"CREATE TABLE IF NOT EXISTS `All_friend_List` (friend_id text PRIMARY KEY NOT NULL, fid text,avatar text,user_name text,first_letter text,selected bool);"];

}


#pragma mark labelList
+(BOOL)DBInsertLabelList:(LSFriendListLabelModel *)listLabel{
    
    NSData *listData = [NSKeyedArchiver archivedDataWithRootObject:listLabel.friendList];
    
    BOOL success =  [FriendLabelDB executeUpdate:@"INSERT INTO friend_List_Label (label,friendList) VALUES (?,?)",listLabel.label,listData];

    
    return success;

    
}

+(NSArray *)DBGetAllListLabel{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *FROM friend_List_Label"];
    
    FMResultSet *set = [FriendLabelDB executeQuery:sql];
    
    NSMutableArray<LSFriendListLabelModel *> *listArr = [NSMutableArray array];
    
    while ([set next]) {
        
        LSFriendListLabelModel *listModel = [LSFriendListLabelModel new];
        listModel.label = [set stringForColumn:@"label"];
        //pets
        NSData *listData = [set dataForColumn:@"friendList"];
        NSArray * list  = [NSKeyedUnarchiver unarchiveObjectWithData:listData];

        listModel.friendList = list;
        
        [listArr addObject:listModel];
    }
    
    [set close];
    
    return listArr;
    
}

#pragma mark AllFriendList
+(void)DBInsertFriendArr:(NSArray *)FriendArr{
    
//    [FriendLabelDB executeUpdate:@"ITruncate Table All_friend_List"];
    for (LSFriendModel * model in FriendArr) {
            [FriendLabelDB executeUpdate:@"INSERT INTO All_friend_List (fid,avatar,user_name,friend_id,first_letter) VALUES (?,?,?,?,?)",model.fid,model.avatar,model.user_name,model.friend_id,model.first_letter];

    }
    
}

+(BOOL)DBUpdateFriendWithFriendModel:(LSFriendModel *)model{

     NSString * sql = [NSString stringWithFormat:@"update FlightGoods set fid ='%@', avatar = '%@', user_name = '%@' , first_letter = '%@', selected = '%d' where friend_id = '%@'",model.fid,model.avatar,model.user_name,model.first_letter,model.selected,model.friend_id];
   BOOL success =  [FriendLabelDB executeQuery:sql];
    return success;
}

+(NSArray *)DBGetAllFriendList{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *FROM All_friend_List"];
    
    FMResultSet *set = [FriendLabelDB executeQuery:sql];
    
    NSMutableArray<LSFriendModel *> *listArr = [NSMutableArray array];
    
    while ([set next]) {
        
        LSFriendModel *listModel = [LSFriendModel new];
        listModel.fid = [set stringForColumn:@"fid"];
        listModel.avatar = [set stringForColumn:@"avatar"];
        listModel.user_name = [set stringForColumn:@"user_name"];
        listModel.friend_id = [set stringForColumn:@"friend_id"];
        listModel.first_letter = [set stringForColumn:@"first_letter"];
        
        [listArr addObject:listModel];
    }
    
    [set close];
    
    return listArr;
    
}

+(NSArray *)DBGetFriendsWithStr:(NSString *)str{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM All_friend_List WHERE user_name like '%%%@%%'",str];
    FMResultSet *set = [FriendLabelDB executeQuery:sql];



    NSMutableArray<LSFriendModel *> *listArr = [NSMutableArray array];
    
    while ([set next]) {
        
        LSFriendModel *listModel = [LSFriendModel new];
        listModel.fid = [set stringForColumn:@"fid"];
        listModel.avatar = [set stringForColumn:@"avatar"];
        listModel.user_name = [set stringForColumn:@"user_name"];
        listModel.friend_id = [set stringForColumn:@"friend_id"];
        listModel.first_letter = [set stringForColumn:@"first_letter"];
        
        [listArr addObject:listModel];
    }
    
    [set close];
    
    return listArr;
    
}


@end
