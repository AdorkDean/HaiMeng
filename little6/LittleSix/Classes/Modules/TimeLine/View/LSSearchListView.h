//
//  LSSearchListView.h
//  LittleSix
//
//  Created by Jim huang on 17/3/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSSearchListView;
@class LSFriendModel;
@protocol LSSearchListViewDelegate <NSObject>

-(void)searchView:(LSSearchListView *)view didSelectedWithModel:(LSFriendModel *)model;

@end

@interface LSSearchListView : UIView

@property (nonatomic,weak) id<LSSearchListViewDelegate> delegate;
-(void)searchFriendWithStr:(NSString *)str;

@end
