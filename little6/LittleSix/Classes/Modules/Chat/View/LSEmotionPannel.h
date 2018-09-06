//
//  LSEmotionPannel.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/22.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSEmotionCatory,LSEmotionPackage,LSEmotionModel;

@protocol LSEmotionPannelDelegate <NSObject>

@optional
- (void)emotionPannelDidClickSettingButton;
- (void)emotionPannelDidClickAddButton;
- (void)emotionPannelDidClickEditButton;

@end

@interface LSEmotionPannel : UIView

@property (nonatomic,weak) id<LSEmotionPannelDelegate> delegate;

@end

@interface LSEmotionCategoryCell : UICollectionViewCell

@property (nonatomic,strong) UILabel *itemLabel;

@property (nonatomic,strong) LSEmotionCatory *category;

@end

@protocol LSPackageViewDelegate <NSObject>

@optional
- (void)packageClickItemAdd;
- (void)packageClickItemEdit;

@end

@interface LSPackageView : UIView

@property (nonatomic,weak) id<LSPackageViewDelegate> delegate;
@property (nonatomic,strong) UIButton *customButton;

@property (nonatomic,strong) NSArray<LSEmotionPackage *> *packages;

@property (nonatomic,copy) void(^didSelectPackageBlock)(LSEmotionPackage *package);

@end

@interface LSPackageCell : UICollectionViewCell

@property (nonatomic,strong) NSIndexPath *idxPath;
@property (nonatomic,strong) UIImageView *iconView;

@property (nonatomic,strong) LSEmotionPackage *package;

@end

@interface LSEmotionContentView : UIView

@property (nonatomic,strong) NSArray<LSEmotionModel *> *emotions;

@end

@interface LSEmotionPageCell : UICollectionViewCell

@property (nonatomic,strong) NSArray<LSEmotionModel *> *dataSource;

@end

@interface LSEmotionCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) LSEmotionModel *model;

@end
