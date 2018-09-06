//
//  LSHobbiesCollectionCell.m
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSHobbiesCollectionCell.h"

@implementation LSHobbiesCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    ViewBorderRadius(self.tagBtn, 15,1,[UIColor lightGrayColor]);
}
- (IBAction)tagClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    NSMutableArray * arr = [NSMutableArray array];
    if (sender.selected) {
        for (LSHobbieModel * lmodel in self.dataArray) {
            if (lmodel.select_id == 1) {
                [arr addObject:sender];
            }
        }
    }else {
    
        for (LSHobbieModel * lmodel in self.dataArray) {
            if (lmodel.select_id == 1) {
                [arr addObject:sender];
            }
        }
        [arr removeObject:sender];
    }
    if (arr.count > 2) {
        sender.selected = NO;
        return;
    }
    if (sender.selected) {
        sender.backgroundColor = [UIColor lightGrayColor];
        self.model.select_id = 1;
        
    }else{
        sender.backgroundColor = [UIColor whiteColor];
        self.model.select_id = 0;
    }
}

-(void)setModel:(LSHobbieModel *)model{

    _model = model;
    
    [self.tagBtn setTitle:model.tag_name forState:UIControlStateNormal];
    
    
    if (model.select_id == 1) {
        
        self.tagBtn.selected = YES;
    }else{
    
        self.tagBtn.selected = NO;
    }
}
-(void)setDataArray:(NSArray *)dataArray {

    _dataArray = dataArray;
}


@end
