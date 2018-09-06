//
//  LSFuwaLocationInfoView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaLocationInfoView.h"
#import "LSFuwaModel.h"
#import "MLLinkLabel.h"
#import "LSPlayerVideoView.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import <MAMapKit/MAMapKit.h>
#import <YYKit/YYTextView.h>

@interface LSFuwaLocationInfoView () <AMapNaviWalkManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *locationButtom;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainLabel;


@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;

@end

@implementation LSFuwaLocationInfoView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentViewConstH.constant = 25;
    [self layoutIfNeeded];

    ViewBorderRadius(self.detailButton, 4, 1, HEXRGB(0xcccccc));
}

+ (instancetype)fuwaLocationView {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaLocationInfoView" owner:nil options:nil] lastObject];
}

- (void)setType:(LSFuwaLocationType)type {

    _type = type;
    self.tipsLabel.hidden = NO;
}

- (void)setModel:(LSFuwaModel *)model {
    _model = model;
    
    [self.locationButtom setTitle:model.pos forState:UIControlStateNormal];
    NSString *numberString;
    if (model.number>0) {
        numberString = [NSString stringWithFormat:@"%@个距离捕抓距离",model.number];

    }else
    {
//        numberString = [NSString stringWithFormat:@"%@号距离捕抓距离",model.id];
        numberString =@"1个距离捕抓距离";

    }

    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:numberString];
    
    if (model.number>0) {
        [attr addAttribute:NSForegroundColorAttributeName value:HEXRGB(0xd3000f) range:NSMakeRange(0, model.number.length)];
        
    }else
    {
        [attr addAttribute:NSForegroundColorAttributeName value:HEXRGB(0xd3000f) range:NSMakeRange(0, 1)];
        
    }
    self.numberLabel.attributedText = attr;
    
}


- (void)setCurrentLocation:(CLLocation *)currentLocation {
    _currentLocation = currentLocation;
    
    //距离起始位置
    CLLocationDistance distance = [self.startLocation distanceFromLocation:currentLocation];
    
    NSString *str = [NSString stringWithFormat:@"%d 米",(int)distance];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    [attr addAttribute:NSForegroundColorAttributeName value:HEXRGB(0xd3000f) range:NSMakeRange(0, str.length-1)];
    self.distanceLabel.attributedText = attr;
    
    //距离捕获
    CLLocationDistance totalDistance = [self.currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:self.model.annotation.coordinate.latitude longitude:self.model.annotation.coordinate.longitude]];
//    int totalDistance = self.model.distance;
    
    NSString *remainStr = [NSString stringWithFormat:@"还有%d米",(int)totalDistance];
    NSMutableAttributedString *remainAttr = [[NSMutableAttributedString alloc] initWithString:remainStr];
    [remainAttr addAttribute:NSForegroundColorAttributeName value:HEXRGB(0xd3000f) range:NSMakeRange(2, remainStr.length-3)];
    self.remainLabel.attributedText = remainAttr;
    
    if (totalDistance>=500) {
        self.tipsLabel.text =@"位置太远了，走近一点才可以捕抓哦~";
        self.tipsLabel.textColor = HEXRGB(0xed1318);
        
    }else{
        
        self.tipsLabel.text =@"您已经离目标很近了~点击开始捕抓来抓福娃吧~";
        self.tipsLabel.textColor = HEXRGB(0x05ed08);
    }
    self.type = LSFuwaLocationTypeToFar;
    self.contentViewConstH.constant = 25;
    [self layoutIfNeeded];
    !self.updateViewBlock?:self.updateViewBlock();
    
}



- (IBAction)detailAction:(id)sender {
    !self.detailBlock ? : self.detailBlock();
}

- (IBAction)expandAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    !self.expandBlock ? : self.expandBlock(!sender.selected);
}
    
- (void)setRouteTime:(NSInteger)routeTime {
    _routeTime = routeTime;
    
    NSInteger second = (long)routeTime/60;
    
    NSString *str = [NSString stringWithFormat:@"%ld 分钟",second];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    [attr addAttribute:NSForegroundColorAttributeName value:HEXRGB(0xd3000f) range:NSMakeRange(0, str.length-2)];
    self.timeLabel.attributedText = attr;
}

@end

@interface LSFuwaActivityView () <YYTextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *loactionLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;


@property (copy,nonatomic) UIView * activityView;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (nonatomic,strong) YYTextView * detailTextView;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;

@end

@implementation LSFuwaActivityView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_obg"].CGImage);
    self.contentView.layer.contentMode = UIViewContentModeBottom;
    ViewRadius(self.contentView, 3);
    
    self.detailTextView = [YYTextView new];
    self.detailTextView.backgroundColor = [UIColor clearColor];
    self.detailTextView.textColor = [UIColor whiteColor];
    self.detailTextView.font = [UIFont systemFontOfSize:15];
    self.detailTextView.delegate = self;
    self.detailTextView.editable = NO;
    [self.contentView addSubview:self.detailTextView];
    
    [self.detailTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.introduceLabel.mas_bottom).offset(5);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];
    

    ViewBorderRadius(self.videoBtn, 6, 1, HEXRGB(0xff0012));
}

+ (instancetype)showInView:(UIView *)view {
    
    LSFuwaActivityView *activityView = [[NSBundle mainBundle] loadNibNamed:@"LSFuwaComfirmView" owner:nil options:nil][3];
    
    [view addSubview:activityView];
    activityView.frame = view.bounds;
    
    return activityView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self removeFromSuperviews];
}

- (void)removeFromSuperviews {

    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



-(void)setModel:(LSFuwaModel *)model{
    _model = model;

    
    YYTextBorder *highlightBorder = [YYTextBorder new];
    highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = [UIColor lightGrayColor];
    
    
    NSString * detailStr ;
    if (!model.detail || model.detail.length == 0)
        detailStr = @"暂无相关活动介绍";
    else
        detailStr = model.detail;
    
    NSMutableAttributedString *ATTtext =[[NSMutableAttributedString alloc]initWithString:detailStr];
    
    [ATTtext setColor:[UIColor whiteColor] range:NSMakeRange(0, ATTtext.length)];
    
    YYTextHighlight *highlight = [YYTextHighlight new];
    [highlight setBackgroundBorder:highlightBorder];
    @weakify(self)
    
    [highlight setTapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
        @strongify(self)
        NSString * contentStr = text.string;
        
       NSString * urlStr =[contentStr substringWithRange:range];
        if ([self.delegate respondsToSelector:@selector(pushWebViewWithView:urlStr:)]) {
            [self.delegate pushWebViewWithView:self urlStr:urlStr];
        }
    }];
    
    NSRange range = [model.detail rangeOfString:@"((http|ftp|https)://)(([a-zA-Z0-9\._-]+\.[a-zA-Z]{2,6})|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\&%_\./-~-]*)?" options:NSRegularExpressionSearch];
    
    [ATTtext setColor:[UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000] range:range];
    [ATTtext setTextHighlight:highlight range:range];
    
    self.detailTextView.attributedText = ATTtext;

    
    

    
    
    self.videoBtn.hidden = [model.video isEqualToString:@""];
    
    
    self.nameLabel.text = model.name;
    self.loactionLabel.text = model.location;
    self.infoLabel.text = model.signature;
    [self.iconImageView setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:timeLineBigPlaceholderName];
    if ([model.gender isEqualToString:@"男"]) {
        [self.sexImageView setImage:[UIImage imageNamed:@"man"]];
    }else{
        [self.sexImageView setImage:[UIImage imageNamed:@"lady"]];

    }
}


-(void)didAllClickLinkLabel:(MLLinkLabel *)linkLabel {
}


- (IBAction)videoAction:(UIButton *)sender {
    
    !self.playClick?:self.playClick(self.model.video,nil);
//    [LSPlayerVideoView showFromView:LSKeyWindow withCoverImage:nil playURL:[NSURL URLWithString:self.model.video]];
    
}


- (BOOL)textView:(YYTextView *)textView shouldTapHighlight:(YYTextHighlight *)highlight inRange:(NSRange)characterRange{
    
    


    return YES;
}

@end
