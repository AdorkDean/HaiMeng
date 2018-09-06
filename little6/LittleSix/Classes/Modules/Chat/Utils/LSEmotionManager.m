//
//  LSEmotionManager.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEmotionManager.h"
#import <FMDB/FMDB.h>
#import <SSZipArchive/SSZipArchive.h>
#import "NSString+Util.h"
#import "LSEmotionModel.h"

#define kInitialEmotion @"kInitialEmotion"
#define kHadInitialEmotionKey [NSString stringWithFormat:@"initial_%@",ShareAppManager.loginUser.user_id]

static FMDatabase *emotionDB;

@implementation LSEmotionManager
    
+ (void)initialManagerWithId:(NSString *)user_id {
    
    if (emotionDB) [emotionDB close];
    
    NSString *db_name = [NSString stringWithFormat:@"emotion_%@.sqlite",user_id];
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:db_name];
    
    emotionDB = [FMDatabase databaseWithPath:filePath];
    
    if (![emotionDB open]) return;
    
    //表情包分类表
    [emotionDB executeUpdate:@"CREATE TABLE IF NOT EXISTS `emo_category` (`cate_id` INTEGER PRIMARY KEY NOT NULL,`cate_name` varchar(100) NOT NULL ,`cate_desc` varchar(150) NOT NULL ,`cate_system` tinyint(1) NOT NULL DEFAULT '0');"];
    
    //表情包表数据表
    [emotionDB executeUpdate:@"CREATE TABLE IF NOT EXISTS `emo_packets` (`group_id` INTEGER PRIMARY KEY NOT NULL,`cate_id` INTEGER NOT NULL ,`group_name` varchar(80) NOT NULL ,`group_count` smallint(6) NOT NULL ,`group_desc` varchar(150) NOT NULL ,`group_cover` varchar(150) NOT NULL ,`group_icon` varchar(150) NOT NULL ,`group_format` varchar(10) NOT NULL ,`group_custom` tinyint(1) NOT NULL ,`group_system` tinyint(1) NOT NULL);"];
    
    //表情数据表
    [emotionDB executeUpdate:@"CREATE TABLE IF NOT EXISTS `emo_emotions` (`emo_id` INTEGER PRIMARY KEY NOT NULL,`emo_name` varchar(80) NOT NULL ,`emo_desc` varchar(150) NOT NULL ,`emo_cate_id` INTEGER NOT NULL,`emo_group_id` INTEGER NOT NULL,`emo_format` varchar(10) NOT NULL ,`emo_code` varchar(150) NOT NULL,`width` float(10,3) NOT NULL,`height` float(10,3) NOT NULL); "];
    
    kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
        [self initialDefaultEmotions];
    })
}


+ (BOOL)saveEmotionCategory:(LSEmotionCatory *)model {
    
    if (!ShareAppManager.loginUser.user_id) return NO;
    //分类下可能有不同的包
//    if ([self exitEmotionCategoryById:model.cate_id]) return YES;
    
    BOOL success = [emotionDB executeUpdate:@"insert into emo_category (cate_id,cate_name,cate_desc,cate_system) values(?,?,?,?)",model.cate_id,model.cate_name,model.cate_desc,@(model.cate_system)];
    
    for (LSEmotionPackage *package in model.group) {
        [self saveEmotionPackage:package];
    }
    
    return success;
}

+ (BOOL)exitEmotionCategoryById:(NSString *)cate_id {
    
    if (!ShareAppManager.loginUser.user_id) return NO;
    FMResultSet *set = [emotionDB executeQuery:@"select * from emo_category where cate_id = ? ",cate_id];

    while ([set next]) {
        [set close];
        return YES;
    }
    return NO;
}

+ (BOOL)deleteEmotionCategoryById:(NSString *)cate_id {
    if (!ShareAppManager.loginUser.user_id) return NO;
    BOOL success = [emotionDB executeUpdate:@"delete from emo_category where cate_id = ? ", cate_id];
    return success;
}

+ (BOOL)saveEmotionPackage:(LSEmotionPackage *)model {
    
    if (!ShareAppManager.loginUser.user_id) return NO;
    if ([self exitEmotionPackageById:model.group_id]) return YES;
    
    BOOL success = [emotionDB executeUpdate:@"insert into emo_packets (group_id,cate_id,group_name,group_count,group_desc,group_cover,group_icon,group_format,group_custom,group_system) values(?,?,?,?,?,?,?,?,?,?)",model.group_id,model.cate_id,model.group_name,@(model.group_count),model.group_desc,model.group_cover,model.group_icon,model.group_format,@(model.group_custom),@(model.group_system)];
    
    for (LSEmotionModel *emtion in model.emo) {
        [self saveEmotion:emtion];
    }
    
    return success;
}

+ (BOOL)exitEmotionPackageById:(NSString *)package_id {
    
    if (!ShareAppManager.loginUser.user_id) return NO;
    FMResultSet *set = [emotionDB executeQuery:@"select * from emo_packets where group_id = ? ",package_id];
    while ([set next]) {
        [set close];
        return YES;
    }
    return NO;
}

+ (BOOL)deleteEmotionPackageById:(NSString *)package_id {
    
    if (!ShareAppManager.loginUser.user_id) return NO;
    
    LSEmotionPackage *package = [self emotionPackageById:package_id];
    //删除表情包下的表情记录
    for (LSEmotionModel *emotion in package.emo) {
        [self deleteEmotionById:emotion.emo_id];
    }
    
    BOOL success = [emotionDB executeUpdate:@"delete from emo_packets where group_id = ? ", package_id];
    
    if (success) {
        NSString *filePath = [kEmotionFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",package.cate_id,package.group_id]];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    return success;
}

+ (LSEmotionPackage *)emotionPackageById:(NSString *)package_id {
    
    if (!ShareAppManager.loginUser.user_id) return nil;
    
    FMResultSet *set = [emotionDB executeQuery:@"select * from emo_packets where group_id = ? ",package_id];
    
    LSEmotionPackage *package = [LSEmotionPackage new];
    
    while ([set next]) {
        
        NSString *group_id = [set stringForColumn:@"group_id"];
        NSString *cate_id = [set stringForColumn:@"cate_id"];
        NSString *group_name = [set stringForColumn:@"group_name"];
        NSInteger group_count = [set intForColumn:@"group_count"];
        NSString *group_desc = [set stringForColumn:@"group_desc"];
        NSString *group_cover = [set stringForColumn:@"group_cover"];
        NSString *group_icon = [set stringForColumn:@"group_icon"];
        NSString *group_format = [set stringForColumn:@"group_format"];
        BOOL group_custom = [set boolForColumn:@"group_custom"];
        BOOL group_system = [set boolForColumn:@"group_system"];
        
        package.group_id = group_id;
        package.cate_id = cate_id;
        package.group_name = group_name;
        package.group_count = group_count;
        package.group_desc = group_desc;
        package.group_cover = group_cover;
        package.group_icon = group_icon;
        package.group_format = group_format;
        package.group_custom = group_custom;
        package.group_system = group_system;
        
        NSArray *emotions = [self emotionsOfPackageById:group_id];
        package.emo = emotions;
    }
    
    [set close];
    
    return package;
}

+ (BOOL)saveEmotion:(LSEmotionModel *)model {
    
    if (!ShareAppManager.loginUser.user_id) return NO;
    if ([self exitEmotionById:model.emo_id]) return YES;
    
    BOOL success = [emotionDB executeUpdate:@"insert into emo_emotions (emo_id,emo_name,emo_desc,emo_cate_id,emo_group_id,emo_format,emo_code,width,height) values(?,?,?,?,?,?,?,?,?)",model.emo_id,model.emo_name,model.emo_desc,model.emo_cate_id,model.emo_group_id,model.emo_format,model.emo_code,@(model.width),@(model.height)];

    return success;
}

+ (BOOL)exitEmotionById:(NSString *)emotion_id {
    
    if (!ShareAppManager.loginUser.user_id) return NO;
    
    FMResultSet *set = [emotionDB executeQuery:@"select * from emo_emotions where emo_id = ? ",emotion_id];
    while ([set next]) {
        [set close];
        return YES;
    }
    
    return NO;
}

+ (BOOL)deleteEmotionById:(NSString *)emotion_id {
    
    if (!ShareAppManager.loginUser.user_id) return NO;
    BOOL success = [emotionDB executeUpdate:@"delete from emo_emotions where emo_id = ? ", emotion_id];
    return success;
}

+ (LSEmotionModel *)findEmoitonModelByCode:(NSString *)code {
    
    if (!ShareAppManager.loginUser.user_id) return nil;
    
    FMResultSet *set = [emotionDB executeQuery:@"select * from emo_emotions where emo_code = ? ",code];
    
    LSEmotionModel *model = [LSEmotionModel new];
    
    while ([set next]) {
        model.emo_id = [set stringForColumn:@"emo_id"];
        model.emo_name = [set stringForColumn:@"emo_name"];
        model.emo_desc = [set stringForColumn:@"emo_desc"];
        model.emo_cate_id = [set stringForColumn:@"emo_cate_id"];
        model.emo_group_id = [set stringForColumn:@"emo_group_id"];
        model.emo_format = [set stringForColumn:@"emo_format"];
        model.emo_code = code;
        model.width = [set doubleForColumn:@"width"];
        model.height = [set doubleForColumn:@"height"];
    }
    
    return model;
}

+ (NSMutableArray<LSEmotionCatory *> *)fetchCategories {
    
    if (!ShareAppManager.loginUser.user_id) return nil;

    FMResultSet *set = [emotionDB executeQuery:@"select * from emo_category"];
    
    NSMutableArray<LSEmotionCatory *> *list = [NSMutableArray array];
    
    while ([set next]) {
        //将数据组合成对象
        LSEmotionCatory *category = [LSEmotionCatory new];
        
        NSString *cate_id = [set stringForColumn:@"cate_id"];
        NSString *cate_name = [set stringForColumn:@"cate_name"];
        NSString *cate_desc = [set stringForColumn:@"cate_desc"];
        BOOL cate_system = [set boolForColumn:@"cate_system"];
        
        category.cate_id = cate_id;
        category.cate_name = cate_name;
        category.cate_desc = cate_desc;
        category.cate_system = cate_system;
        
        NSArray *array = [self packagesOfCategoryById:cate_id];
        
        //当该分类下没有表情包，删除该分类
        if (array.count == 0) {
            [self deleteEmotionCategoryById:cate_id];
        }
        else {
            category.group = array;
            [list addObject:category];
        }
    }
    
    [set close];
    
    return list;
}

+ (NSMutableArray<LSEmotionPackage *> *)packagesOfCategoryById:(NSString *)categoryId {
    
    if (!ShareAppManager.loginUser.user_id) return nil;
    
    FMResultSet *set = [emotionDB executeQuery:@"select * from emo_packets where cate_id = ? ",categoryId];
    
    NSMutableArray<LSEmotionPackage *> *list = [NSMutableArray array];

    while ([set next]) {
        LSEmotionPackage *package = [LSEmotionPackage new];
        
        NSString *group_id = [set stringForColumn:@"group_id"];
        NSString *cate_id = [set stringForColumn:@"cate_id"];
        NSString *group_name = [set stringForColumn:@"group_name"];
        NSInteger group_count = [set intForColumn:@"group_count"];
        NSString *group_desc = [set stringForColumn:@"group_desc"];
        NSString *group_cover = [set stringForColumn:@"group_cover"];
        NSString *group_icon = [set stringForColumn:@"group_icon"];
        NSString *group_format = [set stringForColumn:@"group_format"];
        BOOL group_custom = [set boolForColumn:@"group_custom"];
        BOOL group_system = [set boolForColumn:@"group_system"];
        
        package.group_id = group_id;
        package.cate_id = cate_id;
        package.group_name = group_name;
        package.group_count = group_count;
        package.group_desc = group_desc;
        package.group_cover = group_cover;
        package.group_icon = group_icon;
        package.group_format = group_format;
        package.group_custom = group_custom;
        package.group_system = group_system;
        
        NSArray *emotions = [self emotionsOfPackageById:group_id];
        
        if (emotions.count == 0) {
            [self deleteEmotionPackageById:group_id];
        }
        else {
            package.emo = emotions;
            [list addObject:package];
        }
    }
    
    [set close];
    
    return list;
}

+ (NSMutableArray<LSEmotionPackage *> *)allPackages {
    
    if (!ShareAppManager.loginUser.user_id) return nil;
    
    FMResultSet *set = [emotionDB executeQuery:@"select * from emo_packets"];
    
    NSMutableArray<LSEmotionPackage *> *list = [NSMutableArray array];
    
    while ([set next]) {
        LSEmotionPackage *package = [LSEmotionPackage new];
        
        NSString *group_id = [set stringForColumn:@"group_id"];
        NSString *cate_id = [set stringForColumn:@"cate_id"];
        NSString *group_name = [set stringForColumn:@"group_name"];
        NSInteger group_count = [set intForColumn:@"group_count"];
        NSString *group_desc = [set stringForColumn:@"group_desc"];
        NSString *group_cover = [set stringForColumn:@"group_cover"];
        NSString *group_icon = [set stringForColumn:@"group_icon"];
        NSString *group_format = [set stringForColumn:@"group_format"];
        BOOL group_custom = [set boolForColumn:@"group_custom"];
        BOOL group_system = [set boolForColumn:@"group_system"];
        
        package.group_id = group_id;
        package.cate_id = cate_id;
        package.group_name = group_name;
        package.group_count = group_count;
        package.group_desc = group_desc;
        package.group_cover = group_cover;
        package.group_icon = group_icon;
        package.group_format = group_format;
        package.group_custom = group_custom;
        package.group_system = group_system;
        
        NSArray *emotions = [self emotionsOfPackageById:group_id];
        
        if (emotions.count == 0) {
            [self deleteEmotionPackageById:group_id];
        }
        else {
            package.emo = emotions;
            [list addObject:package];
        }
    }
    
    [set close];
    
    return list;
}

+ (NSMutableArray<LSEmotionModel *> *)emotionsOfPackageById:(NSString *)packageId {
    
    if (!ShareAppManager.loginUser.user_id) return nil;
    
    FMResultSet *set = [emotionDB executeQuery:@"select * from emo_emotions where emo_group_id = ? ",packageId];
    
    
    NSMutableArray<LSEmotionModel *> *list = [NSMutableArray array];
    
    while ([set next]) {
        
        LSEmotionModel *model = [LSEmotionModel new];
        
        NSString *emo_id = [set stringForColumn:@"emo_id"];
        NSString *emo_name = [set stringForColumn:@"emo_name"];
        NSString *emo_desc = [set stringForColumn:@"emo_desc"];
        NSString *emo_cate_id = [set stringForColumn:@"emo_cate_id"];
        NSString *emo_group_id = [set stringForColumn:@"emo_group_id"];
        NSString *emo_format = [set stringForColumn:@"emo_format"];
        NSString *emo_code = [set stringForColumn:@"emo_code"];
        
        model.emo_id = emo_id;
        model.emo_name = emo_name;
        model.emo_desc = emo_desc;
        model.emo_cate_id = emo_cate_id;
        model.emo_group_id = emo_group_id;
        model.emo_format = emo_format;
        model.emo_code = emo_code;
        
        model.width = [set doubleForColumn:@"width"];
        model.height = [set doubleForColumn:@"height"];
                
        [list addObject:model];
    }
    
    [set close];
    
    return list;
}

+ (BOOL)hasInitialDefaultEmotions {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHadInitialEmotionKey];
}

+ (void)initialEmotionComplete {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHadInitialEmotionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)initialDefaultEmotions {
    
    if (!ShareAppManager.loginUser.user_id) return;
    if ([self hasInitialDefaultEmotions]) return;
    
    NSString *fileName = @"e6dfde0406f1590c267df1ce9975beb3.zip";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    NSDictionary *dict = [self unPackEmotionPackage:filePath removeSourceFile:NO];
    if (!dict) return;
    
    [self setEmotionVersion:dict[@"version"]];
    
    //设置初始化完成
    [self initialEmotionComplete];
}

+ (NSDictionary *)unPackEmotionPackage:(NSString *)filePath removeSourceFile:(BOOL)remove {
    
    BOOL success = [SSZipArchive unzipFileAtPath:filePath toDestination:kEmotionFolder];
    
    if (!success) return nil;
    
    NSString *fileName = [filePath lastPathComponent];
    
    //获取表情包信息
    NSString *infoFile = [[fileName componentsSeparatedByString:@"."].firstObject stringByAppendingString:@".json"];
    NSString *infoFilePath = [kEmotionFolder stringByAppendingPathComponent:infoFile];
    
    NSStringEncoding encoding;
    NSError *error;
    NSString *json = [NSString stringWithContentsOfFile:infoFilePath usedEncoding:&encoding error:&error];
    NSDictionary *dict = [json toDictionary];
    
    NSArray<LSEmotionCatory *> *list = [NSArray modelArrayWithClass:[LSEmotionCatory class] json:dict[@"category"]];
    
    //将表情包信息入库
    for (LSEmotionCatory *category in list) {
        [self saveEmotionCategory:category];
    }
    
    if (remove) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    return dict;
}

+ (NSString *)emtionVersion {
    NSString *key = [NSString stringWithFormat:@"emotion_version_%@",ShareAppManager.loginUser.user_id];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)setEmotionVersion:(NSString *)version {
    NSString *key = [NSString stringWithFormat:@"emotion_version_%@",ShareAppManager.loginUser.user_id];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
