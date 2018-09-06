//
//  LSEmotionModel.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSEmotionPackage,LSEmotionModel;
@interface LSEmotionCatory : NSObject

@property (nonatomic, copy) NSString * cate_desc;
@property (nonatomic, copy) NSString * cate_id;
@property (nonatomic, copy) NSString * cate_name;
@property (nonatomic, assign) BOOL cate_system;
@property (nonatomic, copy) NSArray<LSEmotionPackage *> * group;

@property (nonatomic, assign) BOOL selected;

@end

@interface LSEmotionPackage : NSObject

@property (nonatomic, copy) NSString * cate_id;
@property (nonatomic, strong) NSArray<LSEmotionModel *> * emo;
@property (nonatomic, assign) NSInteger group_count;
@property (nonatomic, copy) NSString * group_cover;
@property (nonatomic, assign) BOOL group_custom;
@property (nonatomic, copy) NSString * group_desc;
@property (nonatomic, copy) NSString * group_format;
@property (nonatomic, copy) NSString * group_icon;
@property (nonatomic, copy) NSString * group_id;
@property (nonatomic, copy) NSString * group_name;
@property (nonatomic, assign) BOOL group_system;
@property (nonatomic, copy) NSString * url;
@property (nonatomic, copy) NSString * download;

+ (void)packageInfo:(NSString *)packageId success:(void (^)(LSEmotionPackage *package))success failure:(void (^)(NSError *error))failure;

- (NSString *)iconPath;

@end

@interface LSEmotionModel : NSObject

@property (nonatomic, copy) NSString * emo_cate_id;
@property (nonatomic, copy) NSString * emo_code;
@property (nonatomic, copy) NSString * emo_desc;
@property (nonatomic, copy) NSString * emo_format;
@property (nonatomic, copy) NSString * emo_group_id;
@property (nonatomic, copy) NSString * emo_id;
@property (nonatomic, copy) NSString * emo_name;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, copy) NSString * url;

- (NSString *)filePath;

@end

@interface LSHotEmotionModel : NSObject

@property (nonatomic,copy) NSString *group_id;
@property (nonatomic,copy) NSString *group_name;
@property (nonatomic,copy) NSString *cate_id;
@property (nonatomic,copy) NSString *group_cover;
@property (nonatomic,copy) NSString *url;

@end

@interface LSEmotionShopModel : NSObject

@property (nonatomic,strong) NSArray<LSHotEmotionModel *> *hot;

@property (nonatomic,strong) NSArray<LSEmotionPackage *> *groups;

+ (void)emotionStoreInfo:(NSInteger)page size:(NSInteger)size success:(void (^)(LSEmotionShopModel *emoShop))success failure:(void (^)(NSError *error))failure;

@end

@interface LSPackageSearchModel : NSObject

@property (nonatomic,copy) NSString *group_id;
@property (nonatomic,copy) NSString *emo_id;
@property (nonatomic,copy) NSString *sname;
@property (nonatomic,copy) NSString *sdesc;
@property (nonatomic,copy) NSString *icon;

+ (void)searchWithKeyword:(NSString *)keyword success:(void (^)(NSArray *list))success failure:(void (^)(NSError *error))failure;

@end



