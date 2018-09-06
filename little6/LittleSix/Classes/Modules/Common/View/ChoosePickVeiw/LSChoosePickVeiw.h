//
//  LSChoosePickVeiw.h
//  LittleSix
//
//  Created by GMAR on 2017/3/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^sureButtonClick) (NSString * address,NSString * province_Id,NSString * city_Id,NSString * town_Id);
@interface LSChoosePickVeiw : UIView

@property (nonatomic, strong) NSString *province;           /** 省 */
@property (strong,nonatomic) NSString * provinceId;
@property (nonatomic, strong) NSString *city;               /** 市 */
@property (strong,nonatomic) NSString * cityId;
@property (nonatomic, strong) NSString *town;               /** 县 */
@property (strong,nonatomic) NSString * townId;

@property (nonatomic, copy) sureButtonClick config;

@property (assign,nonatomic) NSInteger index;

-(void)ininSoureData:(NSInteger)index;

@end

typedef void (^MyBlockType)(NSString *selectDate);
@interface HMDatePickView : UIView

/** 距离当前日期最大年份差（>0小于当前日期，<0 当前日期） */
@property(assign, nonatomic) NSInteger maxYear;

/** 距离当前日期最小年份差 */
@property(assign, nonatomic) NSInteger minYear;

/** 默认显示日期 */
@property (strong, nonatomic) NSDate *date;

/** 日期回调 */
@property(copy, nonatomic) MyBlockType completeBlock;

/** 设置确认/取消字体颜色(默认为黑色) */

@property (strong, nonatomic) UIColor *fontColor;

//配置
- (void)configuration;

@end

//只有年月
@interface LSDatePickerView : UIView
//row 为 0 时只有年   row为1时显示年月
- (instancetype)initDatePackerRow:(int)row WithResponse:(void(^)(NSString*))block;

- (void)show;

@end

