//
//  LSGroupChatCell.m
//  LittleSix
//
//  Created by GMAR on 2017/3/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSGroupChatCell.h"
#import "LSGroupModel.h"
#import "LSPersonsModel.h"

@interface LSGroupChatCell()

@property (retain,nonatomic)UIButton * delBtn;

@end

@implementation LSGroupChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headerImage.layer.cornerRadius = 5;
    self.headerImage.clipsToBounds = YES;
    self.headerImage.layer.borderWidth = 0.5;
    self.headerImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.headerImage.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPressReger = [[UILongPressGestureRecognizer alloc]
                                                    
                                                    initWithTarget:self action:@selector(handleLongPress:)];
    
    [self.headerImage addGestureRecognizer:longPressReger];
    
    
//    self.delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.headerImage addSubview:self.delBtn];
//    [self.delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//       
//        make.top.right.equalTo(self.headerImage);
//        make.width.height.equalTo(@(20));
//    }];
}



-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{


    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
        
    {
        NSLog(@"mimimimimimi");
        if (self.delectClick) {
            self.delectClick(self.model.userid);
        }
    }
}

- (void)setModel:(LSMembersModel *)model{

    _model = model;
    
    [self.headerImage setImageWithURL:[NSURL URLWithString:model.snap] placeholder:timeLineSmallPlaceholderName];
    self.nameLabel.text = model.nickname;
    
//    [self.delBtn setImage:[UIImage imageNamed:@"capture_shoot_confirm"] forState:UIControlStateNormal];
}

- (void)setPersonModel:(LSPersonsModel *)personModel {

    _personModel = personModel;
    
    [self.headerImage setImageWithURL:[NSURL URLWithString:_personModel.avatar] placeholder:timeLineSmallPlaceholderName];
    self.nameLabel.text = _personModel.user_name;
}
@end
