//
//  ZHRecordView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

typedef NS_ENUM(NSUInteger, LSRecordStatus) {
    LSRecordStatusShortTime,
    LSRecordStatusRecocation,
    LSRecordStatusSignalVol
};

@interface ZHRecordView : UIView

@property (nonatomic,assign) LSRecordStatus status;
singleton_interface(ZHRecordView)

+ (instancetype)showInKeyWindow;

+ (instancetype)showInView:(UIView *)view;

- (void)dismissHUD;

//1-8
- (void)updateMetersValue:(NSInteger)value;

@end
