//
//  LSShakeViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSShakeModel;
@interface LSShakeViewController : UIViewController

@end



typedef void (^friendViewClickBlock)(LSShakeModel *);
@interface LSShakeFirendView : UIView

@property(nonatomic,strong) LSShakeModel * model;

@property(nonatomic,copy) friendViewClickBlock friendViewBlock;

@end

@interface LSShakeView : UIView

@property (retain,nonatomic) UILabel * nameLabel;
@property (retain,nonatomic) UILabel * desLabel;
@property (retain,nonatomic) UIImageView *avaterView;


@end
