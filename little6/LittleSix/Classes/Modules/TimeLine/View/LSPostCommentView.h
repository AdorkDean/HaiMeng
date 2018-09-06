//
//  LSPostCommentView.h
//  LittleSix
//
//  Created by Jim huang on 17/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    postCommentTypeNew,
    postCommentTypeAnswer,
}postCommentType;

@class LSTimeLineTableListModel;
@class LSTimeLineCommentModel;
@interface LSPostCommentView : UIView
@property (nonatomic,strong) LSTimeLineTableListModel *model;
@property (nonatomic,strong) LSTimeLineCommentModel *commentModel;
@property (nonatomic,assign) int index;
@property (nonatomic,assign) postCommentType type;
@property (nonatomic,strong)UITextField *commentTextField;

@end
