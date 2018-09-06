//
//  LSPhotoContainerView.h
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSLinkInCellModel,LSLinkInFileModel;
@protocol LSPhotoContainerViewDelegate <NSObject>

//点击播放视频
-(void)didClickVideo:(LSLinkInFileModel *)lFileModel;

@end

@interface LSPhotoContainerView : UIView

@property (nonatomic, strong) NSArray *picPathStringsArray;

@property (nonatomic, strong) LSLinkInCellModel *model;

@property (nonatomic, weak) id<LSPhotoContainerViewDelegate> delegate;

@end
