//
//  LSWalletsViewController.h
//  LittleSix
//
//  Created by Jim huang on 17/4/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSUserModel;
@interface LSWalletsViewController : UIViewController

@end

@interface LSWalletsAlterView : UIView

+ (instancetype)walletsAlterView;

-(void)show;
-(void)hidden;
@property (nonatomic,strong) LSUserwWithDrawModel * model;
@property (nonatomic,copy) void(^successBlock)(void);

@end

@interface LSWalletsSuccessAlterView : UIView
-(void)show;
-(void)hidden;
@property (nonatomic,copy) void(^successBlock)(void);

+ (instancetype)walletsSuccessAlterView;

@end
