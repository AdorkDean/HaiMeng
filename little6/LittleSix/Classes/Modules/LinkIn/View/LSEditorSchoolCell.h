//
//  LSEditorSchoolCell.h
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSEditorSchoolCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *suTextF;

@property (copy,nonatomic) void (^stringClick)(NSString * schText,NSIndexPath * index);

@property (nonatomic, strong) NSIndexPath *indexPath;

@end
