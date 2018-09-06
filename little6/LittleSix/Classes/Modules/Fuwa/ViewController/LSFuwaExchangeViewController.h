//
//  LSFuwaExchangeViewController.h
//  LittleSix
//
//  Created by Jim huang on 17/3/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FuwaSaleType) {
    FuwaSaleTypeAll,
    FuwaSaleTypeMy
};

typedef NS_ENUM(NSUInteger, FuwaSortType) {
    FuwaSortTypeNone,
    FuwaSortTypeAsc, //升序
    FuwaSortTypeDesc //降序
};

@class LSFuwaExchangeModel;
@interface LSFuwaExchangeViewController : UIViewController

@end

@interface LSFuwaExchangeBuyCell : UICollectionViewCell

@property (nonatomic,strong) LSFuwaExchangeModel *model;
@property (assign,nonatomic) BOOL cellSelect;
@property (assign,nonatomic) BOOL cellEdit;

@end

@interface  LSFuwaBuyComfirmView : UIView

@property (nonatomic,strong) LSFuwaExchangeModel *model;

@property (nonatomic,copy) void(^buyButtonBlock)();

+ (instancetype)showInView:(UIView *)view withDataModel:(LSFuwaExchangeModel *)model comfirmBlock:(void(^)())block;

@end
