//
//  LSFuwaHiddenViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSBaseFuwaCamerViewController.h"
#import "LSAnimationView.h"
@class LSFuwaNewAdressModel;
@interface LSFuwaHiddenViewController : LSBaseFuwaCamerViewController

@end

@interface LSFuwaLocationCell : UITableViewCell

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subLabel;

@property (nonatomic,strong) LSFuwaNewAdressModel *model;

@end

typedef void (^fuwaSearchBlock)(void);

@interface LSFuwaSearchView : UIView

@property(nonatomic,copy) fuwaSearchBlock searchBlock;

@end

typedef void(^hiddenFuwaBlock)(NSString * count);


typedef  enum {
    fuwaHiddenCountTypeMerChant,
    fuwaHiddenCountTypePerson,
}fuwaHiddenCountType;

@interface LSFuwaHiddenCountView : LSAnimationView

@property (nonatomic,copy) void(^hiddenFuwaCount)(NSString * count,fuwaHiddenCountType type);

+ (instancetype)fuwaHiddenCountView;

@end
