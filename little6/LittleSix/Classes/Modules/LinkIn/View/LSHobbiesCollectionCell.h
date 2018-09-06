//
//  LSHobbiesCollectionCell.h
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSHobbieModel.h"

@interface LSHobbiesCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *tagBtn;

@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@property (retain,nonatomic)LSHobbieModel * model;

@property (copy,nonatomic)void(^sureClick)(LSHobbieModel * model);
@property (copy,nonatomic) NSArray * dataArray;

@end
