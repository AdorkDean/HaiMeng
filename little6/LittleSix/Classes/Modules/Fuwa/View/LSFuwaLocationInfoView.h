//
//  LSFuwaLocationInfoView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LSAnimationView.h"
typedef NS_ENUM(NSUInteger, LSFuwaLocationType) {
    LSFuwaLocationTypeUnkonw,
    LSFuwaLocationTypeToFar,
    LSFuwaLocationTypeNearby
};

@class LSFuwaModel;
//155 182
@interface LSFuwaLocationInfoView : LSAnimationView

@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewConstH;

@property (nonatomic,assign) LSFuwaLocationType type;

@property (nonatomic,strong) LSFuwaModel *model;

@property (nonatomic,strong) CLLocation *startLocation;
@property (nonatomic,strong) CLLocation *currentLocation;
    
/**
 *  导航路径所需的时间(单位:秒)
 */
@property (nonatomic, assign) NSInteger routeTime;

@property (weak, nonatomic) IBOutlet UIButton *expandButton;

@property (nonatomic,copy) void(^updateViewBlock)(void);
@property (nonatomic,copy) void(^detailBlock)(void);
@property (nonatomic,copy) void(^expandBlock)(BOOL expand);

+ (instancetype)fuwaLocationView;

@end
@class LSFuwaModel;
@class LSFuwaActivityView;

@protocol  LSFuwaActivityViewDelegate<NSObject>

-(void)pushWebViewWithView:(LSFuwaActivityView *)View urlStr:(NSString *)urlStr;

@end

@interface LSFuwaActivityView : LSAnimationView
@property (nonatomic,copy) void(^webBlock)(NSString * url);

+ (instancetype)showInView:(UIView *)view;
@property (nonatomic,weak) id<LSFuwaActivityViewDelegate> delegate;

@property (nonatomic,strong) LSFuwaModel *model;

@property (nonatomic,copy) void (^playClick)(NSString * playUrl,UIImage * image);

@end
