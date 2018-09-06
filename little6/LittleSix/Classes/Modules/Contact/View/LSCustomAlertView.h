//
//  LSCustomAlertView.h
//  LittleSix
//
//  Created by GMAR on 2017/3/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSCustomAlertView;

@protocol LSCustomAlertViewDelegate <NSObject>

- (void) customAlertView:(LSCustomAlertView *) customAlertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface LSCustomAlertView : UIView

@property (nonatomic, copy) NSString *titleStr;

@property (nonatomic, strong) UIView *middleView;

@property(nonatomic, weak) id<LSCustomAlertViewDelegate> delegate;

/**
 * 弹窗在视图中的中心点
 **/
@property (nonatomic, assign) CGFloat centerY;

- (instancetype) initAlertViewWithFrame:(CGRect)frame andSuperView:(UIView *)superView;

- (void) dissMiss;

@end
