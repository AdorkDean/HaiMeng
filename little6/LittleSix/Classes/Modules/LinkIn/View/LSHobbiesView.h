//
//  LSHobbiesView.h
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSHobbiesView : UIView

+(instancetype)chooseMainV;


-(void)showInView:(UIViewController *)view WithBlock:(void(^)(NSArray *list))sureBlock;
@property (copy,nonatomic)void(^sureBlock)(NSArray * list);


@end
