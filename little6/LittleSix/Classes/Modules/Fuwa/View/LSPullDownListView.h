//
//  LSPullDownListView.h
//  LittleSix
//
//  Created by Jim huang on 17/4/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSPullDownListView : UIView

@property (nonatomic,copy)NSString * selelctIndex;

+ (instancetype)PullDownListView;

@property (nonatomic,strong)NSArray * dataSource;


@end
