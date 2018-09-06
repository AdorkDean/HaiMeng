//
//  LSLinkCompleteInfoViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSBaseModel.h"
#import "ConstKeys.h"

@class LSCompleteInfoModel;
@interface LSLinkCompleteInfoViewController : UIViewController


@end

@interface LSLinkCompleteInfoCell : UITableViewCell

@property (nonatomic,retain) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *titleLable;

@property (retain,nonatomic) LSCompleteInfoModel * infoModel;

@end

@interface LSCompleteInfoModel : NSObject

@property (nonatomic,copy) NSString *displayName;

@property (nonatomic,copy) NSString *value;

+ (instancetype)modelWithDispalyName:(NSString *)name andValue:(NSString *)value;


+(void)completeInfoWithlistToken:(NSString *)access_token
                             sex:(NSString *)sex
                        birthday:(NSString *)birthday
                        province:(NSString *)province
                            city:(NSString *)city
                        district:(NSString *)district
                     ht_province:(NSString *)ht_province
                         ht_city:(NSString *)ht_city
                     ht_district:(NSString *)ht_district
                        industry:(NSString *)industry
                        interest:(NSString *)interest
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure;

@end

