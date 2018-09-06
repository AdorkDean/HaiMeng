//
//  LSTLSelectContactViewController.h
//  LittleSix
//
//  Created by Jim huang on 17/3/9.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSTLSelectContactViewController;
@class LSFriendModel;

typedef void(^changeAddressListBlock)(NSArray*,SelectContactViewType);
typedef void(^changeRemindListBlock)(NSArray*);


@interface LSTLSelectContactViewController : UIViewController
@property (nonatomic,assign) SelectContactViewType type;
@property (nonatomic, copy) changeAddressListBlock AddressListBlock;
@property (nonatomic, copy) changeRemindListBlock remindListBlock;


@end

@interface LSTLSelectContactCell : UITableViewCell
@property(nonatomic,strong) UIButton * selectBtn;
@property (nonatomic,strong) LSFriendModel * model;
@property (nonatomic,assign,getter=isCellSelected) BOOL cellSelected;

@end

@interface LSTLSelectContactNormalCell : UITableViewCell

@end
