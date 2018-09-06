//
//  LSShareView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSShareView.h"
#import "UpDownButton.h"

#define kBottomPannelHeight 200

@interface LSShareView ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *bottomPannel;
@property (nonatomic, strong) UIStackView *stackView;

@end

@implementation LSShareView

+ (instancetype)showInView:(UIView *)view
                 withItems:(NSArray<LSShareItem *> *)items
               actionBlock:(void (^)(SSDKPlatformType))block {

    LSShareView *shareView = [[LSShareView alloc] initWithFrame:view.bounds];
    shareView.items = items;
    shareView.actionBlock = block;

    [view addSubview:shareView];
    [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];

    [shareView showAnimation];

    return shareView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {

        self.backgroundColor = [UIColor clearColor];

        UIView *bgView = [UIView new];
        self.bgView = bgView;
        bgView.backgroundColor = [UIColor blackColor];
        [self addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        UIView *bottomPannel = [UIView new];
        bottomPannel.backgroundColor = HEXRGB(0xeeeeee);
        self.bottomPannel = bottomPannel;
        [self addSubview:bottomPannel];
        [bottomPannel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.offset(kBottomPannelHeight);
            make.top.equalTo(self.mas_bottom).offset(-kBottomPannelHeight);
        }];

        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.backgroundColor = [UIColor whiteColor];
        cancelButton.titleLabel.font = SYSTEMFONT(16);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:HEXRGB(0x333333) forState:UIControlStateNormal];
        [bottomPannel addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(bottomPannel);
            make.height.offset(40);
        }];

        @weakify(self)[[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside]
            subscribeNext:^(__kindof UIControl *_Nullable x) {
                @strongify(self)[self dismissAnimation];
            }];

        UIStackView *stackView = [UIStackView new];
        self.stackView = stackView;
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.alignment = UIStackViewAlignmentFill;
        stackView.distribution = UIStackViewDistributionFillEqually;
        [bottomPannel addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(bottomPannel);
            make.bottom.equalTo(cancelButton.mas_top);
        }];
    }
    return self;
}

- (void)showAnimation {
    [self layoutIfNeeded];
    self.bgView.alpha = 0;
    self.bottomPannel.transform = CGAffineTransformMakeTranslation(0, kBottomPannelHeight);
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                         self.bgView.alpha = 0.5;
                         self.bottomPannel.transform = CGAffineTransformIdentity;
                     }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissAnimation];
}

- (void)dismissAnimation {

    [UIView animateWithDuration:kAnimationDuration
        animations:^{
            self.bgView.alpha = 0;
            self.bottomPannel.transform = CGAffineTransformMakeTranslation(0, kBottomPannelHeight);
        }
        completion:^(BOOL finished) {
            //移除父控件
            [self removeFromSuperview];
        }];
}

- (void)setItems:(NSArray<LSShareItem *> *)items {
    _items = items;

    for (LSShareItem *item in items) {
        UpDownButton *button = [UpDownButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = SYSTEMFONT(12);
        button.margin = 15;
        [button setImage:[UIImage imageNamed:item.iconName] forState:UIControlStateNormal];
        [button setTitleColor:HEXRGB(0x999999) forState:UIControlStateNormal];
        [button setTitle:item.title forState:UIControlStateNormal];
        [self.stackView addArrangedSubview:button];
        @weakify(self)[[button rac_signalForControlEvents:UIControlEventTouchUpInside]
            subscribeNext:^(__kindof UIControl *_Nullable x) {
                @strongify(self) !self.actionBlock ?: self.actionBlock(item.type);
                [self dismissAnimation];
            }];
    }
}

+ (NSArray<LSShareItem *> *)shareItems {

    NSMutableArray *array = [NSMutableArray array];

    if ([LSShareView isInstallQQPlatform]) {
        LSShareItem *item1 =
            [LSShareItem shareItemWith:@"QQ好友" iconName:@"share.bundle/qq" platformType:SSDKPlatformSubTypeQQFriend];
        LSShareItem *item2 = [LSShareItem shareItemWith:@"QQ空间"
                                               iconName:@"share.bundle/zone"
                                           platformType:SSDKPlatformSubTypeQQFriend];

        [array addObject:item1];
        [array addObject:item2];
    }
    if ([LSShareView isInstallWechatPlatform]) {
        LSShareItem *item1 = [LSShareItem shareItemWith:@"微信好友"
                                               iconName:@"share.bundle/weixin"
                                           platformType:SSDKPlatformSubTypeWechatSession];
        LSShareItem *item2 = [LSShareItem shareItemWith:@"微信朋友圈"
                                               iconName:@"share.bundle/timeline"
                                           platformType:SSDKPlatformSubTypeWechatTimeline];

        [array addObject:item1];
        [array addObject:item2];
    }

    return array;
}

///判断是否安装QQ
+ (BOOL)isInstallQQPlatform {
    return [ShareSDK isClientInstalled:SSDKPlatformTypeQQ];
}

+ (BOOL)isInstallWechatPlatform {
    return [ShareSDK isClientInstalled:SSDKPlatformTypeWechat];
}

+ (void)shareTo:(SSDKPlatformType)platformType
        withParams:(NSMutableDictionary *)params
    onStateChanged:(SSDKShareStateChangedHandler)stateChangedHandler {

    [ShareSDK share:platformType
            parameters:params
        onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity,
                         NSError *error) {
            !stateChangedHandler ?: stateChangedHandler(state, userData, contentEntity, error);
        }];
}

@end

@implementation LSShareItem

+ (instancetype)shareItemWith:(NSString *)title iconName:(NSString *)iconName platformType:(SSDKPlatformType)type {

    LSShareItem *item = [LSShareItem new];
    item.title = title;
    item.iconName = iconName;
    item.type = type;

    return item;
}

@end
