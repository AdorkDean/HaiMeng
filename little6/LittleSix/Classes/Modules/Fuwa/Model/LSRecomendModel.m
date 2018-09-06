//
//  LSRecomendVideoModel.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/6/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSRecomendModel.h"
#import "LSOBaseModel.h"

static CGFloat kRecomendCellWidth = 0;

@implementation LSRecomendModel

+ (void)load {
    kRecomendCellWidth = (kScreenWidth - 15 * 3) * 0.5;
}

- (CGSize)scaleSize {

    CGFloat scaleWidth = kRecomendCellWidth;
    
    CGFloat radio = self.width / self.height;
    CGFloat scaleHeight = scaleWidth / radio;
    
    return CGSizeMake(scaleWidth, scaleHeight);
}

- (void)setVideo:(NSString *)video {
    _video = video;
    
    NSString *name = [video stringByDeletingPathExtension];
    name = [name stringByAppendingString:@".jpg"];
    self.coverImage = name;
}

- (void)setDistance:(CGFloat)distance {
    _distance = distance;
    
    if (distance > 999) {
        CGFloat a = distance/1000;
        self.disString = [NSString stringWithFormat:@"%.1lf千米",a];
    }
    else {
        self.disString =  [NSString stringWithFormat:@"%.0lf米",distance];
    }
    
}

+ (void)recomendVideosWithType:(NSUInteger)type geo:(NSString *)geoString class:(NSString *)classes success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    
    NSString *path;
    
    if (type == 0) {
        path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwaQueryVideo];
    }
    else {
        path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwaQuerystrVideo];
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"geohash"] = geoString;
    param[@"class"] = classes;
    
    [LSOBaseModel BGET:path parameters:param success:^(LSOBaseModel *model) {
        
        if (success) {
            NSArray *arr = (NSArray *)model.data;
            NSMutableArray *list = [NSMutableArray array];
            for (NSDictionary *dict in arr) {
                LSRecomendModel *model = [LSRecomendModel modelWithJSON:dict];
                if (model.width>0&&model.height>0) {
                    [list addObject:model];
                }
            }
            success(list);
        }
        
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
    
}

+ (void)increasePlayCount:(LSRecomendModel *)videoModel class:(NSString *)class_id success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    
    NSString *uri = [NSString stringWithFormat:@"/hit?filemd5=%@&class=%@&time=%@&platform=boss66",videoModel.filemd5,class_id,@((NSUInteger)[[NSDate date] timeIntervalSince1970])];
    
    NSString *sign = [uri md5String];
    uri = [uri stringByAppendingString:[NSString stringWithFormat:@"&sign=%@",sign]];
    
    NSString *path = [kBaseFuwa2URL stringByAppendingString:@"/api"];
    path = [path stringByAppendingString:uri];
    path = [path stringByReplacingOccurrencesOfString:@"&platform=boss66" withString:@""];
    
    [LSOBaseModel BGETWithCache:path parameters:nil success:nil failure:nil];
}

@end
