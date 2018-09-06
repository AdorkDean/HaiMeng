//
//  LSPermissionViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSPermissionViewController;
@protocol LSPermissionVCDelegate <NSObject>

-(void)ViewController:(LSPermissionViewController *)VC selectDoneWithType:(SelectContactViewType)type LabelArr:(NSArray *)LabelArr otherArr:(NSArray *)otherArr;

@end

@interface LSPermissionViewController : UIViewController

@property (nonatomic,weak) id<LSPermissionVCDelegate> delegate;
@end

@class LSPermissionView;
@protocol LSPermissionViewDelegate <NSObject>

-(void)didsSelectPermissionView:(LSPermissionView *)View;

@end
@interface LSPermissionView : UIView

@property (nonatomic,strong) UIImageView *checkView;
@property (nonatomic,strong) UILabel *titleL;
@property (nonatomic,strong) UILabel *subTitleLabel;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign,getter=isOpen) BOOL open;
@property (nonatomic,weak) id<LSPermissionViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame index:(NSInteger)index;
-(void)didselectHeaderView:(LSPermissionView *)View;
@end
@class  LSPermissionSubModel;
@interface LSPermissionCell : UITableViewCell

@property (nonatomic,strong) UIButton *selectbutton;
@property (nonatomic,strong) UILabel *titleL;
@property (nonatomic,strong) UILabel *subTitleLabel;
@property (nonatomic,strong) UIButton * editBtn;
@property (nonatomic,strong) LSPermissionSubModel * model;

@property (nonatomic,assign,getter=isCellSelected) BOOL CellSelected;


@end

//@class LSFriendModel;
//@interface LSPermissionSubModel : NSObject
//
//@property (nonatomic,copy) NSString *title;
//@property (nonatomic,copy) NSString *subTitle;
//@property (nonatomic,assign) BOOL selected;
//@property (nonatomic,copy) NSString * friendIDStr;
//@property (nonatomic,strong) NSMutableArray *friendList;
//@property (nonatomic,assign,getter=isAddCell) BOOL addCell;
//@property (nonatomic,assign,getter=isSelected) BOOL modelSelected;
//
//@end
//
//@implementation LSPermissionSubModel
//
//@end
//
//@interface LSPermissionModel : NSObject
//
//@property (nonatomic,copy) NSString *title;
//@property (nonatomic,copy) NSString *subTitle;
//@property (nonatomic,strong) NSMutableArray<LSPermissionSubModel * >*sub;
//
//@end
//
//@implementation LSPermissionModel
//
//@end


