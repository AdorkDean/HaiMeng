//
//  LSOptionsView.h
//  LittleSix
//
//  Created by Jim huang on 17/2/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selectCellBlock)(NSString*);


@interface LSOptionsView : UIView

-(instancetype)initWithFrame:(CGRect)frame WithData:(NSArray *)data;

@property (nonatomic,copy) selectCellBlock selectCellBlock;



@end
