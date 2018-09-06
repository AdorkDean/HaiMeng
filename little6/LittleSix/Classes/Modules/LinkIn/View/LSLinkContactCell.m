//
//  LSLinkContactCell.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkContactCell.h"

@interface LSLinkContactCell ()

@property (weak, nonatomic) IBOutlet UILabel *contactRateLabel;

@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (weak, nonatomic) IBOutlet UIButton *concernButton;


@end

@implementation LSLinkContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //卡顿感明显
//    ViewRadius(self.contactRateLabel,2);
//    ViewRadius(self.addButton,4);
//    ViewRadius(self.concernButton,4);
}

@end
