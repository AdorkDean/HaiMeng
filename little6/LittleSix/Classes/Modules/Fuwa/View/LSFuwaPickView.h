//
//  LSFuwaPickView.h
//  LittleSix
//
//  Created by Jim huang on 17/3/23.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^sureButtonClickBlock) (int);
@interface LSFuwaPickView : UIView

@property (nonatomic, copy) sureButtonClickBlock sureButtonBlock;


@end


