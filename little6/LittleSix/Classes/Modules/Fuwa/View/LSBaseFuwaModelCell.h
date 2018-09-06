//
//  LSBaseFuwaModelCell.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSFuwaModel;

@interface LSBaseFuwaModelCell : UICollectionViewCell

@property (nonatomic,strong) UILabel *numLabel;
@property (nonatomic,strong) UILabel *countLabel;
@property (nonatomic,strong) UIImageView *numBgView;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIView *lineView1;
@property (nonatomic,strong) UIView *lineView2;

@property (nonatomic,assign) BOOL disable;

@property (nonatomic,strong) LSFuwaModel *model;


@end
