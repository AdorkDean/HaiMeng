//
//  LittleSix
//
//  Created by Jim huang on 17/3/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSTimeLineTableListModel;
@interface LSTimeLineHomePicViewController : UIViewController
@property (nonatomic,strong) LSTimeLineTableListModel *model;

@end

@interface LSTimeLinDetailCollectionViewCell : UICollectionViewCell


@property (nonatomic,strong) UIImageView *picView;

@end
