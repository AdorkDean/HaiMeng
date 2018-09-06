//
//  LSFuwaSuccessFriendView.m
//  LittleSix
//
//  Created by Jim huang on 17/4/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaSuccessFriendView.h"
#import "LSFuwaModel.h"
#import "LSPlayerVideoView.h"
#import "LSContactModel.h"
#import "UIView+HUD.h"
@interface LSFuwaSuccessFriendView ()
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet UIImageView *videoIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoSexImage;
@property (weak, nonatomic) IBOutlet UILabel *videoAdressLabel;
@property (weak, nonatomic) IBOutlet UIButton *videoAddFriendBtn;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UIView *videoContentView;


@property (weak, nonatomic) IBOutlet UIView *friendContentView;
@property (weak, nonatomic) IBOutlet UIButton *friendAddFriendBtn;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *friendSexImage;
@property (weak, nonatomic) IBOutlet UILabel *friendAdressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *friendIconImage;

@end

@implementation LSFuwaSuccessFriendView


+ (instancetype)SuccessFriendView{
    return [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaSuccessFriendView" owner:nil options:nil]lastObject];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.friendContentView.hidden = YES;
    ViewBorderRadius(self.videoIconImageView, self.videoIconImageView.width/2, 1, HEXRGB(0x999999));
    ViewBorderRadius(self.videoAddFriendBtn,5 , 1, HEXRGB(0xff0012));
    
    ViewBorderRadius(self.friendIconImage, self.friendIconImage.width/2, 1, HEXRGB(0x999999));
    ViewBorderRadius(self.friendAddFriendBtn,5 , 1, HEXRGB(0xff0012));

}

-(void)setModel:(LSFuwaModel *)model{
    _model = model;
    
    
    if ([model.video isEqualToString:@""]) {
        self.videoContentView.hidden = YES;
        self.friendContentView.hidden = NO;
        [self.friendIconImage setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:timeLineBigPlaceholderName];
        self.friendNameLabel.text = model.name;
        self.friendAdressLabel.text = model.location;
        
        
        
        if ([model.gender isEqualToString:@"男"]) {
            [self.friendSexImage setImage:[UIImage imageNamed:@"man"]];
        }else{
            [self.friendSexImage setImage:[UIImage imageNamed:@"lady"]];
            
        }

    }else{
        self.videoContentView.hidden = NO;
        self.friendContentView.hidden = YES;
        [self.videoIconImageView setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:timeLineBigPlaceholderName];
        self.videoNameLabel.text = model.name;
        self.videoAdressLabel.text = model.location;
        self.videoImageView.backgroundColor =[UIColor blackColor];
        
        
        NSString * videoStr =[model.video lastPathComponent];
        NSString * picLastStr;
        NSString * picStr;
        
        if ([videoStr containsString:@".mov" ]) {
            picLastStr =[videoStr stringByReplacingOccurrencesOfString:@".mov" withString:@".jpg"];
        }
        else if ([videoStr containsString:@".mp4"]) {
            picLastStr = [videoStr stringByReplacingOccurrencesOfString:@".mp4" withString:@".jpg"];
        }
        picStr = [model.video stringByReplacingOccurrencesOfString:videoStr withString:picLastStr];
        
        [self.videoImageView setImageWithURL:[NSURL URLWithString:picStr] placeholder:timeLineBigPlaceholderName];
        
        if ([model.gender isEqualToString:@"男"]) {
            [self.videoSexImage setImage:[UIImage imageNamed:@"man"]];
        }else{
            [self.videoSexImage setImage:[UIImage imageNamed:@"lady"]];
            
        }

    }

    //捕抓自己的福娃
    if ([model.hider isEqualToString:ShareAppManager.loginUser.user_id]) {
        self.videoAddFriendBtn.hidden = YES;
        return;
    }

    [LSContactModel isFriendsWithlistToken:ShareAppManager.loginUser.access_token uid_to:model.hider success:^(LSContactModel *model) {
        if (model.is_friend == 0 && model.friend_id != ShareAppManager.loginUser.user_id.integerValue) {
            
            [self.videoAddFriendBtn setBackgroundColor:HEXRGB(0xd3000f)];
            self.videoAddFriendBtn.enabled = YES;

            [self.friendAddFriendBtn setBackgroundColor:HEXRGB(0xd3000f)];
            self.friendAddFriendBtn.enabled = YES;
            
            [self.friendAddFriendBtn setTitle:@"+好友" forState:UIControlStateNormal];
            [self.videoAddFriendBtn setTitle:@"+好友" forState:UIControlStateNormal];
            
        }else{
            [self.videoAddFriendBtn setTitle:@"已是好友" forState:UIControlStateNormal];
            [self.friendAddFriendBtn setTitle:@"已是好友" forState:UIControlStateNormal];
            [self.videoAddFriendBtn setBackgroundColor:HEXRGB(0x999999)];
            self.videoAddFriendBtn.enabled = NO;

            [self.friendAddFriendBtn setBackgroundColor:HEXRGB(0x999999)];
            self.friendAddFriendBtn.enabled = NO;
        }
    } failure:^(NSError *error) {
        [self showError:@"请求失败" hideAfterDelay:1];
    } ];

}

- (IBAction)bgBtnAction:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)closeAction:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)addFriendAction:(UIButton *)sender {
    [self showLoading];
    [LSContactModel sendFriendsWithlistToken:ShareAppManager.loginUser.access_token uid_to:self.model.hider friend_note:nil success:^(LSContactModel *cmodel) {
        [self showSucceed:@"发送好友请求成功" hideAfterDelay:1];
    } failure:^(NSError * error) {
        [self showError:@"发送好友请求失败" hideAfterDelay:1 ];
    }];

}

- (IBAction)playVideoAction:(id)sender {
    
    !self.playClick?:self.playClick(self.model.video,self.model.pic);
//    [LSPlayerVideoView showFromView:self withCoverImage:nil playURL:[NSURL URLWithString:self.model.video]];
    
}

@end
