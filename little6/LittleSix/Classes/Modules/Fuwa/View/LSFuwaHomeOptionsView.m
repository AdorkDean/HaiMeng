//
//  LSFuwaHomeOptionsView.m
//  LittleSix
//
//  Created by Jim huang on 17/4/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaHomeOptionsView.h"
@interface LSFuwaHomeOptionsView ()
@property (weak, nonatomic) IBOutlet UIButton *passwordBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkFuwa;

@end


@implementation LSFuwaHomeOptionsView

+ (instancetype)fuwaHomeOptionsView {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaHomeOptionsView" owner:nil options:nil]lastObject];
}


- (IBAction)passwordAction:(id)sender {
    self.showPasswordBlock();
}

- (IBAction)checkFuwaAction:(id)sender {
    self.checkFuwaBlock();
}

@end
