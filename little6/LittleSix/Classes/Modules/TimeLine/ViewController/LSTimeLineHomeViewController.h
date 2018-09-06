//
//  LSMyTimeLineViewController.h
//  LittleSix
//
//  Created by Jim huang on 17/3/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSTimeLineTableListModel;

@interface LSTimeLineHomeViewController : UIViewController
@property (nonatomic,assign) int userID;

@end

typedef enum {
    MyTimeLineCellTypepic=0,
    MyTimeLineCellTypeVideo,
    MyTimeLineCellTypeText,
    MyTimeLineCellTypeUrl,
}MyTimeLineCellType;


@interface LSHomeTimeLineTableViewCell : UITableViewCell

@property(nonatomic,strong) LSTimeLineTableListModel*model;

@property(nonatomic,assign) MyTimeLineCellType type;

-(void)setCellDateWithDateStr:(NSString *)DateStr;

-(void)setToday;

@end

@interface LSNewHomeTimeLineTableViewCell : UITableViewCell

@end
