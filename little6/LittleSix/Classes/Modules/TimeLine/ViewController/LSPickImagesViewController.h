//
//  LSPickImagesViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSAlbumsViewController.h"

@interface LSPickImagesViewController : UIViewController

@property (nonatomic,assign) NSInteger maxImageCount;

@property (nonatomic,strong) LSAlbum *album;

@property (nonatomic,strong) void(^doneButtonAction)(NSArray<LSPhotoAsset *> *);

@end

@interface LSPickImageCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIButton *selectButton;
@property (nonatomic,strong) UIView *coverView;

@property (nonatomic,strong) LSPhotoAsset *model;

@end
