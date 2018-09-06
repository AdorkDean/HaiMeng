//
//  LSTimeLineCellOperationMenu.h
//  LittleSix
//
//  Created by Jim huang on 17/3/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSTimeLineTableListModel;
@interface LSTimeLineCellOperationMenu : UIView

@property (nonatomic,assign) int index;
@property (nonatomic, assign, getter = isShowing) BOOL show;
@property (nonatomic,strong) LSTimeLineTableListModel * model;
@end
