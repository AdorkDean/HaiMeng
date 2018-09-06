//
//  LSAddLinkViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
//添加人脉
@interface LSAddLinkViewController : UIViewController

@end
//同乡
@interface LSCountryMenViewController : UIViewController

- (void)_initDataSource ;

@end
//同学
@interface LSClassMatesViewController : UIViewController

@end

@interface LSLinkInSearchView : UIView

+(instancetype)searchMainV;


-(void)showInView:(UIViewController *)view andPage:(int)page WithBlock:(void(^)(NSArray *list))sureBlock;
@property (copy,nonatomic)void(^sureBlock)(NSArray * list);

@end
