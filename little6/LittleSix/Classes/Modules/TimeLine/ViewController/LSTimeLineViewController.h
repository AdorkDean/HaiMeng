//
//  LSTimeLineViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSTimeLineViewController : UIViewController

@end



@class LSTimeLineTableListModel;
@class LSGoodAndCommentView;
@class LSTimeLineTableListModel;

typedef void(^pushToUserViewBlock)(int);
typedef void(^deletewBlock)();

@interface LSTimeLineTableViewCell : UITableViewCell
@property(nonatomic,strong) LSGoodAndCommentView *goodAndCommentView;

@property (nonatomic,strong) LSTimeLineTableListModel *model;
@property (nonatomic, copy) pushToUserViewBlock ToUserViewBlock;
@property (nonatomic, copy) deletewBlock deleteBlock;

@property(nonatomic,assign) int index;
@property (nonatomic,copy) void (^contentClick)(LSTimeLineTableListModel *model);

-(void)configCellWithModel:(LSTimeLineTableListModel *)model;

@end


