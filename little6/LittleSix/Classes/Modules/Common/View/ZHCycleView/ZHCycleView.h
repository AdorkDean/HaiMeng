//
//  ZHCycleView.h
//  ZHCycleView
//
//  Created by AdminZhiHua on 16/2/23.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHCycleView : UIView

//定时时间，默认是5秒
@property (nonatomic,assign) int autoScrollTimeInterval;

//pagecontrol颜色设置
@property (nonatomic,strong) UIColor *currentPageTintColor;
@property (nonatomic,strong) UIColor *pageTintColor;

//pagecontrol到底部的距离
@property (nonatomic,assign) NSInteger pagecontrolConstBottom;

//图片URL数组
@property (nonatomic,strong) NSArray *imageUrlGroups;

+ (instancetype)cycleViewWithFrame:(CGRect)frame imageUrlGroups:(NSArray *)group placeHolderImage:(UIImage *)image selectAction:(void(^)(NSInteger index))block;

- (void)reloadData;

- (void)destoryTimer;

@end

@interface ZHCycleViewCell : UICollectionViewCell

@property (nonatomic,weak) UIImageView *imageView;

@end
