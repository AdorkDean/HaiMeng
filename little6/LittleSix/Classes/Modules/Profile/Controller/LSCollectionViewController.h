//
//  LSCollectionViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/4/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSCollectModel;
@interface LSCollectionViewController : UIViewController

@end

@interface LSCollectBaseCell : UITableViewCell

@property (strong,nonatomic) UIImageView * iconView;
@property (strong,nonatomic) UILabel * timeLabel;
@property (strong,nonatomic) UILabel * nameLabel;

@property (strong,nonatomic) LSCollectModel * model;
@property (strong,nonatomic) LSCollectModel * dmodel;
@end

@interface LSCollectTextCell : LSCollectBaseCell

@property (strong,nonatomic) UILabel * contentLabel;

@end

@interface LSCollectImageCell : LSCollectBaseCell

@property (strong,nonatomic)UIImageView * bodyImage;

@end

@interface LSCollectVideoCell : LSCollectBaseCell

@property (strong,nonatomic)UIImageView * bodyImage;

@end

@interface LSCollectModel : NSObject

@property (assign,nonatomic) int type;
@property (copy,nonatomic) NSString * group_name;
@property (copy,nonatomic) NSString * thum;
@property (copy,nonatomic) NSString * from_name;
@property (copy,nonatomic) NSString * from_avatar;
@property (copy,nonatomic) NSString * id;
@property (copy,nonatomic) NSString * uid;
@property (copy,nonatomic) NSString * from_id;
@property (copy,nonatomic) NSString * url;
@property (copy,nonatomic) NSString * text;
@property (copy,nonatomic) NSString * add_time;

+(void)userCollectListWithPage:(int)page
                       success:(void (^)(NSArray * list))success
                       failure:(void (^)(NSError *))failure;

+(void)userAddCollectListWithFromid:(int)fromid
                              gname:(NSString *)gname
                               thum:(NSString *)thum
                                url:(NSString *)url
                               type:(NSString *)type
                               text:(NSString *)text
                            success:(void (^)(LSCollectModel * model))success
                            failure:(void (^)(NSError *))failure;

+(void)userDeleteCollectListWithFid:(NSString *)fid
                            success:(void (^)())success
                            failure:(void (^)(NSError *))failure;

@end
