//
//  LSRecomendViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/6/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat kRecomendCellWidth = 0;

typedef NS_ENUM(NSUInteger, LSRecomendType) {
    LSRecomendTypeFuwa,
    LSRecomendTypeMeng
};

@class LSRecomendModel;
@interface LSRecomendViewController : UIViewController

@property (nonatomic,assign) LSRecomendType type;

@end

@interface LSRecomendMenuView : UIView 

@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,strong) void(^itemSelect)(NSString *classId);

@end

@interface LSRecomendMenuCell : UICollectionViewCell

@property (nonatomic,strong) UILabel *titleLabel;

@end

@interface LSRecomendCell : UICollectionViewCell

@property (nonatomic,strong) LSRecomendModel *model;

@property (nonatomic,strong) UIControl *control;

@property (nonatomic,copy) void(^controlClick)(NSString * userid);

@end
