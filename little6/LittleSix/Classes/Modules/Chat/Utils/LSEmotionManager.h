//
//  LSEmotionManager.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSEmotionModel.h"


@interface LSEmotionManager : NSObject

//根据用户ID来初始化数据库表
+ (void)initialManagerWithId:(NSString *)user_id;

//是否初始化完成自定义表情包
+ (BOOL)hasInitialDefaultEmotions;
//初始化默认表情包
+ (void)initialDefaultEmotions;

//表情包版本
+ (NSString *)emtionVersion;
+ (void)setEmotionVersion:(NSString *)version;

//获取表情包分类模型
+ (NSMutableArray<LSEmotionCatory *> *)fetchCategories;
+ (NSMutableArray<LSEmotionPackage *> *)packagesOfCategoryById:(NSString *)categoryId;
+ (NSMutableArray<LSEmotionModel *> *)emotionsOfPackageById:(NSString *)packageId;
+ (NSMutableArray<LSEmotionPackage *> *)allPackages;

// 操作表情分类
+ (BOOL)saveEmotionCategory:(LSEmotionCatory *)model;
+ (BOOL)exitEmotionCategoryById:(NSString *)cate_id;
+ (BOOL)deleteEmotionCategoryById:(NSString *)cate_id;

//表情包操作
+ (BOOL)saveEmotionPackage:(LSEmotionPackage *)model;
+ (BOOL)exitEmotionPackageById:(NSString *)package_id;
+ (BOOL)deleteEmotionPackageById:(NSString *)package_id;
+ (LSEmotionPackage *)emotionPackageById:(NSString *)package_id;

//解压表情包，入库
+ (NSDictionary *)unPackEmotionPackage:(NSString *)filePath removeSourceFile:(BOOL)remove;

//表情图片操作
+ (BOOL)saveEmotion:(LSEmotionModel *)model;
+ (BOOL)exitEmotionById:(NSString *)emotion_id;
+ (BOOL)deleteEmotionById:(NSString *)emotion_id;
+ (LSEmotionModel *)findEmoitonModelByCode:(NSString *)code;


@end
