//
//  LSLinkInCellModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkInCellModel.h"
#import <UIKit/UIKit.h>
#import "LSBaseModel.h"
#import "ConstKeys.h"

extern const CGFloat contentLabelFontSize;
extern CGFloat maxContentLabelHeight;

@implementation LSLinkInCellModel {
    
    CGFloat _lastContentWidth;
}

- (void)setIsOpening:(BOOL)isOpening {
    
    if (!_shouldShowMoreButton) {
        _isOpening = NO;
    } else {
        _isOpening = isOpening;
    }
}

@synthesize content = _content;

-(void)setContent:(NSString *)content {

    _content = content;
}

- (NSString *)content
{
    CGFloat contentW = [UIScreen mainScreen].bounds.size.width - 70;
    if (contentW != _lastContentWidth) {
        _lastContentWidth = contentW;
        CGRect textRect = [_content boundingRectWithSize:CGSizeMake(contentW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:contentLabelFontSize]} context:nil];
        if (textRect.size.height > maxContentLabelHeight) {
            _shouldShowMoreButton = YES;
        } else {
            _shouldShowMoreButton = NO;
        }
    }
    return _content;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"praise_list" : [LSLinkInCellLikeItemModel class],
             @"comment_list" : [LSLinkInCellCommentItemModel class],
             @"files" : [LSLinkInFileModel class]};
}

+(void)linkInWithlistToken:(NSString *)access_token
                       id_value:(int)id_value
                   id_value_ext:(int)id_value_ext
                           page:(int)page
                           size:(int)size
                        success:(void (^)(NSArray *array))success
                        failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@?page=%d&size=%d&id_value=%d&id_value_ext=%d",kBaseUrl,kContactsfeedPath,page,size,id_value,id_value_ext];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        NSArray * modelArr = [NSArray modelArrayWithClass:[LSLinkInCellModel class] json:model.result];
        !success?:success(modelArr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)linkInCenterWithlistToken:(NSString *)access_token
                        user_id:(NSString *)user_id
                            page:(int)page
                            size:(int)size
                         success:(void (^)(NSArray *array))success
                         failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@?user_id=%@&page=%d&size=%d",kBaseUrl,kContactscPath,user_id,page,size];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        NSArray * modelArr = [NSArray modelArrayWithClass:[LSLinkInCellModel class] json:model.result];
        !success?:success(modelArr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)linkInMessageDetails:(NSString *)feed_id
                    success:(void (^)(LSLinkInCellModel *model))success
                    failure:(void (^)(NSError *))failure {

    NSString *path = [NSString stringWithFormat:@"%@%@?feed_id=%@",kBaseUrl,kContDateilsfeedPath,feed_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        LSLinkInCellModel * Message = [LSLinkInCellModel modelWithJSON:model.result];
        !success?:success(Message);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)linkInMessageCountSuccess:(void (^)(LSLinkInCellModel *model))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kGetNeWestPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        LSLinkInCellModel * Message = [LSLinkInCellModel modelWithJSON:model.result];
        !success?:success(Message);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end

@implementation LSLinkInCellLikeItemModel

@end

@implementation LSLinkInCellCommentItemModel

@end

@implementation LSLinkInFileModel

@end
