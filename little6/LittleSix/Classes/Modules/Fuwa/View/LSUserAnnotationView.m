//
//  LSUserAnnotationView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSUserAnnotationView.h"

@interface LSUserAnnotationView ()

@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) UIView *placeImageView;

@property (nonatomic,strong) UIView *shadowView;

@end

@implementation LSUserAnnotationView

- (instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        
        UIView *placeImageView = [UIView new];
        self.placeImageView = placeImageView;
        placeImageView.backgroundColor = HEXRGB(0x1897e8);
        
        ViewBorderRadius(placeImageView, 8, 3, [UIColor whiteColor]);
        [self addSubview:placeImageView];
        [placeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_bottom);
            make.centerX.equalTo(self);
            make.width.height.offset(16);
        }];
        
        UIView *contentView = [UIView new];
        contentView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_me_loca"].CGImage);
        
        [self addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.offset(40);
            make.height.offset(50);
            make.centerX.equalTo(self);
            make.bottom.equalTo(placeImageView.mas_centerY).offset(-2);
        }];
        
        //添加用户头像
        UIImageView *iconView = [UIImageView new];
        self.iconView = iconView;
        [iconView setImageURL:[NSURL URLWithString:ShareAppManager.loginUser.avatar]];
        ViewRadius(iconView, 17);
        
        [contentView addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(contentView);
            make.width.height.offset(34);
            make.top.equalTo(contentView).offset(3);
        }];
    }
    return self;
}

- (void)setRegion:(MACoordinateRegion)region {
    
    CLLocationDegrees delta = region.span.longitudeDelta;
    
    CGFloat scale = 0;
    
    if (delta > 0.1) {
        scale = 0;
    }
    else {
        scale = 0.1-delta;
    }

    scale = scale * 10;
    
    kDISPATCH_MAIN_THREAD(^{
        self.shadowView.transform = CGAffineTransformMakeScale(scale, scale);
    })
}

@end
