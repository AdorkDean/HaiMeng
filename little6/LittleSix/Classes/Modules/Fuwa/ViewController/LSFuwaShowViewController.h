//
//  LSFuwaShowViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    FuwaShowTypeBusiness,
    FuwaShowTypePartner,
}FuwaShowType;

@interface LSFuwaShowViewController : UIViewController

@property(nonatomic,assign) FuwaShowType type;
@property(nonatomic,assign) BOOL isMerchant;
@property(nonatomic,copy) NSString *MerchantID;
@property(nonatomic,assign) CGFloat MerchantRadius;


@end
