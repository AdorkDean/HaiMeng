//
//  LSLinkCommunityViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSBaseModel.h"
#import "ConstKeys.h"

@class LSLinkCommunityModel;
@interface LSLinkCommunityViewController : UIViewController

@property (assign,nonatomic)int sh_id;
@property (assign,nonatomic)int type;

@end

@interface LSLinkCommunityCell : UITableViewCell

@property (retain,nonatomic)UIImageView *iconImage;
@property (retain,nonatomic)UILabel *nameLabel;
@property (retain,nonatomic)UILabel *detailLabel;

@property (retain,nonatomic)LSLinkCommunityModel * communityModel;

@end

@interface LSLinkCommunityModel : NSObject

@property (assign,nonatomic)int id;
@property (retain,nonatomic)NSString * name;
@property (retain,nonatomic)NSString * logo;
@property (assign,nonatomic)int pid;
@property (retain,nonatomic)NSString * short_desc;

+(void)linkCommunityWithlistToken:(NSString *)access_token
                    school_id:(int)school_id
                         type:(int)type
                      success:(void (^)(NSArray * list))success
                      failure:(void (^)(NSError *))failure;

@end

