//
//  LSGoodAndCommentView.h
//  LittleSix
//
//  Created by Jim huang on 17/2/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSTimeLineTableListModel;
@class LSTimeLineCommentModel;
@protocol LSGoodAndCommentViewDelegate <NSObject>

-(void)CommentViewLongPressWithCommentModel:(LSTimeLineCommentModel *)model cellIndex:(int)cellIndex;

@end
typedef void(^pushUserIDBlock)(int);

@interface LSGoodAndCommentView : UIView
@property(nonatomic,weak) id <LSGoodAndCommentViewDelegate> delegate;
@property(nonatomic,assign) int index;
@property(nonatomic,strong) LSTimeLineTableListModel * model;
@property(nonatomic,copy) pushUserIDBlock pushUserIDBlock;

@property(nonatomic,strong) UIView * marginView;


@end

@class YYLabel;
@class LSTimeLineCommentModel;
@interface LSCommentLabel : YYLabel
@property(nonatomic,strong) LSTimeLineCommentModel * commentModel;
@property(nonatomic,assign) int cellIndex;


@end
