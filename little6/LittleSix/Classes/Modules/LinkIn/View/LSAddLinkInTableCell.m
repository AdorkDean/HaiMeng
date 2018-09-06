//
//  LSAddLinkInTableCell.m
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSAddLinkInTableCell.h"
#import "LSSearchMatchModel.h"

@implementation LSAddLinkInTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSearchModel:(LSSearchMatchModel *)searchModel{

    _searchModel = searchModel;
    
    [self.icomImage setImageWithURL:[NSURL URLWithString:searchModel.avatar] placeholder:[UIImage imageNamed:@""]];
    self.nameLabel.text= searchModel.user_name;
    self.percentLabel.text = [NSString stringWithFormat:@"相似度%@%%",searchModel.similar];
    if (searchModel.school.count != 0) {
        LSSchModel * model = searchModel.school[0];
        self.desLabel.text = [NSString stringWithFormat:@"%@届 %@",model.edu_year,model.name];
    }
    if (self.searchModel.isSelect) {
        self.addButton.backgroundColor = [UIColor clearColor];
        [self.addButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
        [self.addButton setTitle:@"已发送" forState:UIControlStateSelected];
        self.addButton.selected = YES;
        self.addButton.enabled = NO;
    }else {
        self.addButton.backgroundColor = [UIColor redColor];
        self.addButton.selected = NO;
        self.addButton.enabled = YES;
    }
}

- (IBAction)addFriedsClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.searchModel.isSelect = YES;
        self.addButton.backgroundColor = [UIColor clearColor];
        [self.addButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
        [self.addButton setTitle:@"已发送" forState:UIControlStateSelected];
    }
    if (self.addFriendsClick) {
        self.addFriendsClick(self.searchModel);
    }
}

@end
