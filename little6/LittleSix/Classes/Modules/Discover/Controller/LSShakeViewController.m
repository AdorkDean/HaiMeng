//
//  LSShakeViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSShakeViewController.h"
#import "LSShakeModel.h"
#import "UIView+HUD.h"
#import "LSContactDetailViewController.h"

@interface LSShakeViewController () <CAAnimationDelegate>

@property (nonatomic,strong) UILabel *tipsLabel;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) LSShakeFirendView *friendView;



@end

@implementation LSShakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"摇一摇";
    
    [self becomeFirstResponder];
    
    [self installSubviews];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)installSubviews {
    
    self.view.backgroundColor = HEXRGB(0x2e3132);
    
    UIImageView *imageView = [UIImageView new];
    self.imageView = imageView;
    imageView.image = [UIImage imageNamed:@"shake_bigphone"];
    [self.view addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-30);
    }];
    
    UILabel *tipsLabel = [UILabel new];
    self.tipsLabel = tipsLabel;
    tipsLabel.text = @"摇晃手机，寻找好友";
    tipsLabel.font = SYSTEMFONT(16);
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.numberOfLines = 0;
    
    [self.view addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(imageView.mas_bottom).offset(25);
        make.width.offset(150);
    }];
    
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.loadingView = loadingView;
    loadingView.hidesWhenStopped = YES;
    
    [self.view addSubview:loadingView];
    [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tipsLabel);
        make.right.equalTo(tipsLabel.mas_left).offset(-6);
        make.width.height.offset(20);
    }];
    
    
    LSShakeFirendView * friendView = [LSShakeFirendView new];
    friendView.backgroundColor = [UIColor whiteColor];
    @weakify(self)
    [friendView setFriendViewBlock:^(LSShakeModel *shakeModel){
        
        LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
        lsvc.user_id = shakeModel.user_id;
        @strongify(self)
        [self.navigationController pushViewController:lsvc animated:YES];
    }];
    self.friendView = friendView;
    friendView.hidden = YES;
    [self.view addSubview:friendView];
    
    
    [friendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.tipsLabel.mas_bottom).offset(5);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(70);
    }];
    //
    //    [iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(friendView).offset(5);
    //        make.left.equalTo(friendView).offset(5);
    //        make.width.height.mas_equalTo(60);
    //    }];
    //    [arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(friendView).offset(5);
    //        make.bottom.equalTo(friendView).offset(-5);
    //        make.right.equalTo(friendView).offset(-5);
    //        make.width.mas_equalTo(15);
    //
    //    }];
    //
    //    [sexImage mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(iconImage);
    //        make.right.equalTo(arrowImage.mas_left).offset(-5);
    //        make.width.height.mas_equalTo(10);
    //    }];
    //
    //    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(iconImage);
    //        make.left.equalTo(iconImage.mas_right).offset(5);
    //        make.right.equalTo(sexImage.mas_left).offset(-5);
    //        make.height.mas_equalTo(16);
    //    }];
    //
    //    [distanceL mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(nameL.mas_bottom).offset(20);
    //        make.left.equalTo(iconImage.mas_right).offset(5);
    //        make.right.equalTo(arrowImage.mas_left).offset(-5);
    //        make.height.mas_equalTo(16);
    //    }];
    
#pragma mark 摇一摇设置
    /*
     UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     [button setImage:[UIImage imageNamed:@"shake_setup"] forState:UIControlStateNormal];
     [button sizeToFit];
     [button addTarget:self action:@selector(rightItemAction) forControlEvents:UIControlEventTouchUpInside];
     
     UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
     self.navigationItem.rightBarButtonItem = rightItem;
     */
    
}

#pragma mark - Action
- (void)rightItemAction {
    UIViewController *vc = [NSClassFromString(@"LSShakeSettingViewController") new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self shakeAnimation];
    
    
    
    [LSShakeModel shakeFriendSuccess:^(LSShakeModel *model) {
        
        
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)shakeAnimation {
    
    CABasicAnimation *momAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    momAnimation.fromValue = [NSNumber numberWithFloat:-0.3];
    momAnimation.toValue = [NSNumber numberWithFloat:0.3];
    momAnimation.duration = 0.3;
    momAnimation.repeatCount = 2;
    momAnimation.autoreverses = YES;
    momAnimation.delegate = self;
    [self.imageView.layer addAnimation:momAnimation forKey:@"animateLayer"];
}

- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.loadingView startAnimating];
    self.tipsLabel.text = @"正在搜寻同一时刻摇晃手机的人";
    
    [LSShakeModel shakeFriendSuccess:^(LSShakeModel *model) {
        self.friendView.model = model;
        self.friendView.hidden = NO;
    } failure:^(NSError *error) {
        [self.view showError:@"找不到好友" hideAfterDelay:1];
        self.friendView.hidden = YES;
    }];
    
    kDISPATCH_AFTER_BLOCK(1.5, ^{
        self.tipsLabel.text = @"摇晃手机，寻找好友";
        self.loadingView.hidden = YES;
    })
    
}

@end
@interface LSShakeFirendView ()

@property (nonatomic,strong) UIImageView * iconImageView;
@property (nonatomic,strong) UIImageView * sexImageView;
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UILabel * distanceLabel;
@end

@implementation LSShakeFirendView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setConstraints];
        self.backgroundColor = HEXRGB(0xdddddd);
    }
    return self;
}


-(void)setConstraints{
    UIImageView * iconImage = [UIImageView new];
    self.iconImageView = iconImage;
    [self addSubview:iconImage];
    
    UIControl * control = [UIControl new];
    [control addTarget:self action:@selector(controlClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:control];
    
    UIImageView * sexImage = [UIImageView new];
    self.sexImageView = sexImage;
    [self addSubview:sexImage];
    
    UILabel * nameL = [UILabel new];
    self.nameLabel = nameL;
    [self addSubview:nameL];
    
    UILabel * distanceL = [UILabel new];
    self.distanceLabel = distanceL;
    [self addSubview:distanceL];
    
    UIImageView * arrowImage = [UIImageView new];
    [self addSubview:arrowImage];
    
    [control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    [iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.left.equalTo(self).offset(5);
        make.width.height.mas_equalTo(60);
    }];
    [arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.bottom.equalTo(self).offset(-5);
        make.right.equalTo(self).offset(-5);
        make.width.mas_equalTo(15);
        
    }];
    
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconImage);
        make.left.equalTo(iconImage.mas_right).offset(5);
        make.right.lessThanOrEqualTo(arrowImage).offset(-30);
        make.height.mas_equalTo(16);
    }];
    
    [sexImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(nameL.mas_right).offset(5);
        make.width.height.mas_equalTo(10);
    }];
    
    
    
    [distanceL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameL.mas_bottom).offset(20);
        make.left.equalTo(iconImage.mas_right).offset(5);
        make.right.equalTo(arrowImage.mas_left).offset(-5);
        make.height.mas_equalTo(16);
    }];
}


-(void)controlClick{
    self.friendViewBlock(self.model);
}

-(void)setModel:(LSShakeModel *)model{
    _model = model;
    self.nameLabel.text = model.user_name;
    [self.iconImageView setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:timeLineSmallPlaceholderName];
    self.distanceLabel.text = [NSString stringWithFormat:@"%@米",model.distance];
    
    if ([model.sex isEqualToString:@"1"]) [self.sexImageView setImage:[UIImage imageNamed:@"man"]];
    else [self.sexImageView setImage:[UIImage imageNamed:@"lady"]];
}

@end

@implementation LSShakeView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIView *bgView = [UIView new];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.7;
        [self addSubview:bgView];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UIImageView *avaterView = [UIImageView new];
        self.avaterView = avaterView;
        [self addSubview:avaterView];
        [avaterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(10);
            make.height.width.offset(40);
            make.centerY.equalTo(self);
        }];
        
        UILabel * nameLabel = [UILabel new];
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(avaterView.mas_right).offset(10);
            make.height.offset(20);
            make.right.equalTo(self.mas_right).offset(-10);
            make.top.equalTo(self.mas_top).offset(10);
        }];
        
        UILabel * desLabel = [UILabel new];
        self.desLabel = desLabel;
        [self addSubview:desLabel];
        [desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(avaterView.mas_right).offset(10);
            make.height.offset(20);
            make.right.equalTo(self.mas_right).offset(-10);
            make.top.equalTo(nameLabel.mas_bottom).offset(10);
        }];
        
        UIImageView * rightImage = [UIImageView new];
        rightImage.image = [UIImage imageNamed:@"rightw_arrows"];
        [self addSubview:rightImage];
        [rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.offset(8);
            make.height.offset(15);
            make.right.equalTo(self.mas_right).offset(-10);
            make.centerY.equalTo(self);
        }];
        
    }
    
    return self;
}

@end

