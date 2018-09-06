//
//  UIViewController+Runtime.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "UIViewController+Runtime.h"
#import <objc/runtime.h>

@implementation UIViewController (Runtime)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [self class];
        Method ori_method = class_getInstanceMethod(cls, @selector(viewDidLoad));
        Method my_method = class_getInstanceMethod(cls, @selector(runtime_viewDidLoad));
        
        method_exchangeImplementations(ori_method, my_method);
    });
}

- (void)runtime_viewDidLoad {
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(naviBackAction)];
    
    //状态栏高亮
    [self runtime_viewDidLoad];
}

- (void)naviBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
