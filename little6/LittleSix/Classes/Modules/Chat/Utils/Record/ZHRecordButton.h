//
//  ZHRecordButton.h
//  RecordTest
//
//  Created by AdminZhiHua on 16/4/11.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHRecordButton : UIButton

@property (nonatomic, copy) void (^recordComplete)(NSString *fileName);

@end
