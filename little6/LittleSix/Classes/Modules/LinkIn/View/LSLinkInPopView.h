//
//  LSLinkInPopView.h
//  LittleSix
//
//  Created by GMAR on 2017/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSLinkInPopView : UIView

+(instancetype)linkInMainView;

- (void)showInView:(UIViewController *)view andArray:(NSArray *)list withBlock:(void(^)(NSString *title))sureBlock;
@property (copy,nonatomic)void(^sureBlock)(NSString *title);

@end

@interface LSLinkInPopCell : UITableViewCell

@property (retain,nonatomic)UILabel * titleLabel;

@end
