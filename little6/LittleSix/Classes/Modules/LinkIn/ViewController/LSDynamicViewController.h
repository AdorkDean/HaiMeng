//
//  LSDynamicViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/4/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSDynamicViewController : UIViewController

@property (assign,nonatomic)int sh_id;
@property (assign,nonatomic)int type;

@end

@interface LSDynamicModel : NSObject

@property (nonatomic,assign)int id;
@property (nonatomic,assign)int pid;
@property (nonatomic,copy)NSString * title;
@property (nonatomic,strong)NSArray * pics;
@property (nonatomic,copy)NSString * content;

+(void)dynamicWithlistToken:(NSString *)access_token
                    school_id:(int)sh_id
                         type:(int)type
                      success:(void (^)(NSArray * list))success
                      failure:(void (^)(NSError *))failure;

@end
