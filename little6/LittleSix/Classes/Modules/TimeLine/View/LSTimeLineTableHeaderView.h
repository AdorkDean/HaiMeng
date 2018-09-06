//
//  LSTimeLineTableHeaderView.h
//  LittleSix
//
//  Created by Jim huang on 17/2/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSDevelopmentsView.h"

#define BGImageheight 256
@class LSUserModel;
@interface LSTimeLineTableHeaderView : UIView
@property (nonatomic,strong) LSDevelopmentsView *MyDevelopmentsView;
@property(nonatomic,strong) LSUserModel *model;
@property (nonatomic,copy) NSString * type;

-(void)reSetHeaderBGImage;
@end
