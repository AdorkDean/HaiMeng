//
//  LSMenusViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/4/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSMenusItem;
@interface LSMenusViewController : UIViewController

@property (nonatomic,strong) NSArray *items;

@property (nonatomic,strong) LSMenusItem *selectItem;

- (void)showCenterViewController:(LSMenusItem *)newItem complete:(void(^)(void))block;

@end

@interface LSMenusItem : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *iconN;
@property (nonatomic,copy) NSString *iconH;
@property (nonatomic,assign) Class cls;
@property (nonatomic,copy) NSString *storyboard;

@property (nonatomic,assign) BOOL selected;

+ (instancetype)itemWith:(NSString *)title normalIcon:(NSString *)iconN heightlightIcon:(NSString *)iconH class:(Class)cls storyboard:(NSString *)storyboard;


@end

@interface LSMenuCell : UITableViewCell

@property (nonatomic,strong) LSMenusItem *item;

@property (nonatomic,strong) UIButton *itemButton;

@property (nonatomic,strong) UIView *notiView;

@end

@interface LSMenuHeaderView : UIView

@end


