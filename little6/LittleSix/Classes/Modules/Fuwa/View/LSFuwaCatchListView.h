//
//  LSFuwaCatchListView.h
//  LittleSix
//
//  Created by Jim huang on 17/4/12.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSFuwaModel;
@interface LSFuwaCatchListView : UIView
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

@property (nonatomic,copy) void(^expandBlock)(BOOL expand);
@property (nonatomic,copy) void(^catchActionBlock)(LSFuwaModel *model);
@property (nonatomic,copy) void(^detailBlock)(LSFuwaModel *model);

@property (nonatomic,copy) void(^refreshTableFootBlock)(NSString *lastFuwaNum);


@property (nonatomic,strong) NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;


+ (instancetype)LSFuwaCatchListView;
- (void)reloadData;
-(void)endLoadFoot;
@end

@interface LSFuwaCatchListCell : UITableViewCell
@property (nonatomic,strong) LSFuwaModel *model;
@property (nonatomic,copy) void(^detailBlock)(void);

@end
