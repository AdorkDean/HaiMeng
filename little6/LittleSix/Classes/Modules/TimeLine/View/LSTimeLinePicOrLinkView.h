//
//  LSTimeLinePicOrLinkView.h
//  LittleSix
//
//  Created by Jim huang on 17/2/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LSPicOrLinkTypePic=0,
    LSPicOrLinkTypeLink,
    LSPicOrLinkTypeVideo,
} LSPicOrLinkType;
@class LSTimeLineTableListModel;
@interface LSTimeLinePicOrLinkView : UIView

@property (nonatomic,assign)LSPicOrLinkType type;

@property(nonatomic,strong)LSTimeLineTableListModel * model;

@end
