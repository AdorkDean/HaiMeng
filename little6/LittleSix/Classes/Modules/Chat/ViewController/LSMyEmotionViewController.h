//
//  LSMyEmotionViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/9.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LSEmotionOperation) {
    LSEmotionOperationSend,
    LSEmotionOperationAdd
};

@interface LSMyEmotionViewController : UIViewController

@property (nonatomic,copy) void(^editComplteBlock)(LSEmotionOperation operation,UIImage *image);

@end

@interface LSMyEmotionCateCell : UICollectionViewCell

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,assign) BOOL choose;

@end

@interface LSMyEmotionCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;

@end
