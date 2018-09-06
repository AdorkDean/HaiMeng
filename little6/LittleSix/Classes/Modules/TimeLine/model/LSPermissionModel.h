//
//  LSPermissionModel.h
//  LittleSix
//
//  Created by Jim huang on 17/3/10.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LSPermissionSubModel;
@interface LSPermissionModel : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subTitle;
@property (nonatomic,strong) NSMutableArray<LSPermissionSubModel * >*sub;

@end@class LSFriendModel;
@interface LSPermissionSubModel : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subTitle;
@property (nonatomic,assign) BOOL selected;
@property (nonatomic,copy) NSString * friendIDStr;
@property (nonatomic,strong) NSMutableArray *friendList;
@property (nonatomic,assign,getter=isAddCell) BOOL addCell;
@property (nonatomic,assign,getter=isSelected) BOOL modelSelected;

@end
