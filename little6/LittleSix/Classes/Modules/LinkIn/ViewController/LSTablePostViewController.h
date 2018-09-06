//
//  LSTablePostViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/3/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LSPostTimeLineTypePhoto,
    LSPostTimeLineTypeVideo,
}LSPostTimeLineType;

@interface LSTablePostViewController : UITableViewController
-(void)setPostType:(LSPostTimeLineType)type WithModel:(id)model;

@property (assign,nonatomic)int sh_id;
@property (assign,nonatomic)int types;

@end

@interface LSImageCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UIButton *deleteButton;

@end
