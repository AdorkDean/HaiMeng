//
//  WeiboReportViewController.h
//  SixtySixBoss
//
//  Created by ZhiHua on 2016/10/5.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeiboMessageModel;
@interface WeiboReportViewController : UIViewController

@end

@interface WeiboReasonCell : UICollectionViewCell

@property (nonatomic,strong) UIButton *item;

@end

@interface ReportReason : NSObject

@property (nonatomic,assign) BOOL select;

@property (nonatomic,copy) NSString *reson;

+ (instancetype)reasonWith:(NSString *)title;

@end
