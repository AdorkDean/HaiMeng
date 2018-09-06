//
//  LSImageSelectedViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSQRCodeViewController.h"

@class LSPhotoAsset;
@interface LSAlbumsViewController : UIViewController

@property (nonatomic,assign) NSInteger maxImageCount;

@property (nonatomic,strong) void(^didSelectAction)(LSAlbumsViewController *vc,NSArray *images);

+ (void)presentImageSelected:(UIViewController *)vc maxImageCount:(NSInteger)count didSelectAction:(void(^)(LSAlbumsViewController *vc, NSArray *images))action;

@end

@interface LSAlbum : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) PHFetchResult *result;

@property (nonatomic,strong) NSMutableArray<LSPhotoAsset *>* assets;

//初始化方法
+ (instancetype)albumWithName:(NSString *)name fetchResult:(PHFetchResult *)result;


@end

@interface LSPhotoAsset : NSObject

@property (nonatomic,strong) PHAsset *asset;

@property (nonatomic,strong) UIImage *image;

@property (nonatomic,assign) BOOL selected;

+ (instancetype)asset:(PHAsset *)asset;

//根据result获取image //获取缩略图
+ (void)getPhotoWithAsset:(PHAsset *)asset photoMaxWH:(CGFloat)photoMaxWH completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

//获取原图
+ (void)requestImageForAsset:(PHAsset *)asset maxImageWidth:(CGFloat)maxImageWidth maxImageHeight:(CGFloat)maxImageHeight completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

@end
