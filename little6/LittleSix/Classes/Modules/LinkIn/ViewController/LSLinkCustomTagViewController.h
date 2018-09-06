//
//  LSLinkCustomTagViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSLinkCustomTagViewController : UIViewController

@end

@interface LSLinkInCustomSearchView : UIView

+(instancetype)searchMainV;

-(void)showInView:(UIViewController *)view andPage:(int)page WithBlock:(void(^)(NSArray *clanArray,NSArray *homeArray,NSArray *userArray,NSArray *schArray))sureBlock;
@property (copy,nonatomic)void(^sureBlock)(NSArray *clanArray,NSArray *homeArray,NSArray *userArray,NSArray *schArray);

@end
