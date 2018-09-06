//
//  LSCelebrityViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSBaseModel.h"
#import "ConstKeys.h"
@class LSCelebrityModel,LSDynamicModel;
@interface LSCelebrityViewController : UIViewController

@property (assign,nonatomic)int sh_id;
@property (assign,nonatomic)int type;
@property (nonatomic,copy) NSString *user_id;

@end

@interface LSCelebrityCell : UITableViewCell

@property (retain,nonatomic)UIImageView *iconImage;
@property (retain,nonatomic)UILabel *nameLabel;
@property (retain,nonatomic)UILabel *ageLabel;
@property (retain,nonatomic)UILabel *detailLabel;

@property (retain,nonatomic)LSCelebrityModel * celebrityModel;
@property (retain,nonatomic)LSDynamicModel * dynamicModel;

@end

@interface LSCelebrityModel : NSObject

@property (assign,nonatomic)int id;
@property (assign,nonatomic)int pid;
@property (retain,nonatomic)NSString * name;
@property (retain,nonatomic)NSString * photo;
@property (retain,nonatomic)NSString * desc;

+(void)celebrityWithlistToken:(NSString *)access_token
                    school_id:(int)school_id
                         type:(int)type
                         success:(void (^)(NSArray * list))success
                         failure:(void (^)(NSError *))failure;


@end
