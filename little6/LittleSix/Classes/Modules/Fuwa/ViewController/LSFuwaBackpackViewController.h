//
//  LSFuwaBackpackViewController.h
//  LittleSix
//
//  Created by Jim huang on 17/3/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSFuwaBackPackModel.h"
#import "LSAnimationView.h"
@class LSFuwaBackPackListModel,LSFuwaModel;
;



@interface LSFuwaBackpackViewController : UIViewController

@end

@interface LSFuwaPresentView : LSAnimationView

@property (nonatomic,strong) LSFuwaModel *model;
@property (nonatomic,copy) void(^pushQCodeBlock)(void);
@property (nonatomic,copy) NSString * userB64;
@property (nonatomic,weak) UIView * detailView;

+ (instancetype)FuwaPresentView;

@end

@interface LSFuwaSaleView : LSAnimationView

@property (nonatomic,strong) LSFuwaModel *model;
@property (nonatomic,weak) UIView * detailView;

+ (instancetype)FuwaSaleView;

@end



@interface LSFuwaDetailView : LSAnimationView

@property (nonatomic,strong) NSArray * dataSource;
@property (nonatomic,assign) FuwaBackPickertype listType;
@property (nonatomic,copy) void(^pushQCodeBlock)(void);
@property (nonatomic,copy) void(^pushTribalBlock)(NSString * creatorid);
@property (nonatomic,copy) NSString * userB64;

+ (instancetype)FuwaDetailView;

@end

@interface LSFuwaBackPackActivityView :LSAnimationView

@property (nonatomic,strong) LSFuwaModel *fuwaModel;

+ (instancetype)BackPackActivityView;

@end

@interface LSFuwaDetailCatchCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (nonatomic,assign) FuwaBackPickertype listType;
@property (nonatomic,strong)LSFuwaBackPackModel * model;
@property (nonatomic,copy) void(^pushTribalBlock)(NSString * creatorid);
-(void)timerInvalidate;
@end

@interface LSFuwaDetailApplyCollectionCell : UICollectionViewCell

@property (nonatomic,strong)LSFuwaBackPackModel * model;

@end


