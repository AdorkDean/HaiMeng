//
//  LSHomeTimeLineDetailContentView.h
//  LittleSix
//
//  Created by Jim huang on 17/3/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSTimeLineTableListModel;
@class LSHomeTimeLinePicContentView;
@protocol TimeLinePicContentViewDelegate <NSObject>

-(void)TimeLinePicContentViewClickDetailBtnWithView:(LSHomeTimeLinePicContentView *)view;

@end

@interface LSHomeTimeLinePicContentView : UIView
@property (nonatomic,strong) LSTimeLineTableListModel *model;

@property (nonatomic,weak) id<TimeLinePicContentViewDelegate> delegate;

@end
