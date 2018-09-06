//
//  LSMorePannel.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/24.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSFeatureModel;
@protocol LSMorePannelDelegate <NSObject>

@optional
- (void)morePannelClickWithItem:(LSFeatureModel *)model;

@end

@interface LSMorePannel : UIView

@property (nonatomic,weak) id<LSMorePannelDelegate> delegate;

@end

@interface LSFeatureCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) LSFeatureModel *model;

@end

@interface LSFeatureModel : NSObject

@property (nonatomic,copy) NSString *icon_name;
@property (nonatomic,copy) NSString *title;

+ (instancetype)modelWithIcon:(NSString *)icon title:(NSString *)title;
+ (NSArray<LSFeatureModel *> *)features;

@end
