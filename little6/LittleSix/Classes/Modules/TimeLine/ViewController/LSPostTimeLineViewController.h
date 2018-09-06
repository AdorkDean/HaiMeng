//
//  LSPostTimeLineViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    LSPostTimeLineTypePhoto,
    LSPostTimeLineTypeVideo,
}LSPostTimeLineType;

@interface LSPostTimeLineViewController : UITableViewController
-(void)setPostType:(LSPostTimeLineType)type WithModel:(id)model;

@end

@interface LSShowImageCell : UICollectionViewCell


@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UIButton *deleteButton;

@end
