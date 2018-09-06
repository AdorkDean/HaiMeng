//
//  LSAnimationView.m
//  LittleSix
//
//  Created by Jim huang on 17/5/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSAnimationView.h"

@implementation LSAnimationView

-(void)willMoveToSuperview:(UIView *)newSuperview{
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [super willMoveToSuperview:newSuperview];
    }];
    
}

//-(void)removeFromSuperview{
//    [UIView animateWithDuration:0.3 animations:^{
//        self.alpha = 0;
//    } completion:^(BOOL finished) {
//        [super removeFromSuperview];
//    }];
//}
@end
