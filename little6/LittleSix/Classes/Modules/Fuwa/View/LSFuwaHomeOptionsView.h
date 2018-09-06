//
//  LSFuwaHomeOptionsView.h
//  LittleSix
//
//  Created by Jim huang on 17/4/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSFuwaHomeOptionsView : UIView

+ (instancetype)fuwaHomeOptionsView;

@property (nonatomic,copy) void(^checkFuwaBlock)(void);

@property (nonatomic,copy) void(^showPasswordBlock)(void);

@end
