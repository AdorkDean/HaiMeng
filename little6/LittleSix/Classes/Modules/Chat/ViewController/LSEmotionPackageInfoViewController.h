//
//  LSEmotionPackageInfoViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSEmotionModel;
@interface LSEmotionPackageInfoViewController : UIViewController

@property (nonatomic,copy) NSString *packid;

@end

@interface LSEmotionPackageInfoCell : UICollectionViewCell

@property (nonatomic,strong) UIButton *emotionButton;
@property (nonatomic,strong) YYAnimatedImageView *animateView;
@property (nonatomic,strong) LSEmotionModel *model;

@end
