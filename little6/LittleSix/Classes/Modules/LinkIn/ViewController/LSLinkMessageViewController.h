//
//  LSLinkMessageViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSLinkMessageModel;
@interface LSLinkMessageViewController : UIViewController

@end

@interface LSLinkMessageCell : UITableViewCell

@property (retain,nonatomic)UIImageView * iconImage;
@property (retain,nonatomic)UILabel * nameLabel;
@property (retain,nonatomic)UILabel * dateTimeLabel;
@property (retain,nonatomic)UIImageView * photoView;
@property (retain,nonatomic)UILabel *tipsLabel;

@property (retain,nonatomic)LSLinkMessageModel * messageModel;

@end
