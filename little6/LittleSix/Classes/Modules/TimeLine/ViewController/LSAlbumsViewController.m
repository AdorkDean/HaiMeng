//
//  LSImageSelectedViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSAlbumsViewController.h"
#import "UIView+HUD.h"
#import "LSPickImagesViewController.h"

static NSString *const reuse_id = @"cell";

@interface LSAlbumsViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataSource;

@end

@implementation LSAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.title = @"照片";

    //判断系统权限
    [LSQRCodeViewController photoLibraryAuthor:^(PHAuthorizationStatus status) {
        
        if (status != PHAuthorizationStatusAuthorized) {
            [self.view showAlertWithTitle:@"系统提示" message:@"您已关闭相册使用权限，请至手机“设置->隐私->相册”中打开"];
        }
        else {
            kDISPATCH_MAIN_THREAD(^{
                NSArray *list = [self allAlbumsInPhotoLibrary];
                self.dataSource = list;
                [self.tableView reloadData];
                
                kDISPATCH_AFTER_BLOCK(3, ^{
                    [self.tableView reloadData];
                })
            })
        }
    }];
    
    [self _naivRightItem];
}

- (NSMutableArray<LSAlbum *> *)allAlbumsInPhotoLibrary {
    
    NSMutableArray<LSAlbum *> *list = [NSMutableArray array];
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //允许图片
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    // 获得相机胶卷的图片
    PHFetchResult<PHAssetCollection *> *collectionResult1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (PHAssetCollection *collection in collectionResult1) {
        
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;

        if ([self isCameraRollAlbum:collection.localizedTitle]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            LSAlbum *album = [LSAlbum albumWithName:@"所有照片" fetchResult:fetchResult];
            [list addObject:album];
            [self pushPickImagesVCWithAlbum:album animate:YES];
        }
    }
    
    // 遍历所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collectionResult0 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (PHAssetCollection *collection in collectionResult0) {
        
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        LSAlbum *album = [LSAlbum albumWithName:collection.localizedTitle fetchResult:fetchResult];
        [list addObject:album];
        
    }
    
    return list;
}

- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:@"最近添加"] || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
    }
}


- (void)_naivRightItem {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    button.titleLabel.font = SYSTEMFONT(16);
    [button sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    
    LSAlbum *album = self.dataSource[indexPath.row];
    NSString *title = [NSString stringWithFormat:@"%@(%ld)",album.name,album.result.count];
    cell.textLabel.text = title;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSAlbum *album = self.dataSource[indexPath.row];
    [self pushPickImagesVCWithAlbum:album animate:YES];
}

- (void)pushPickImagesVCWithAlbum:(LSAlbum *)album animate:(BOOL)animate {
    
    LSPickImagesViewController *vc = [LSPickImagesViewController new];
    vc.album = album;
    vc.maxImageCount = self.maxImageCount;
    [vc setDoneButtonAction:^(NSArray<LSPhotoAsset *> *list) {
        
        if (!self.didSelectAction) return;
        
        NSMutableArray *array = [NSMutableArray array];
        for (LSPhotoAsset *model in list) {
            //获取高清图片
            [LSPhotoAsset requestImageForAsset:model.asset maxImageWidth:300 maxImageHeight:300 completion:^(UIImage *photo, NSDictionary *info) {
                [array addObject:photo];
            }];
        }
        self.didSelectAction(self,array);
    }];
    
    [self.navigationController pushViewController:vc animated:animate];
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView = tableView;
        [self.view addSubview:tableView];
        
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 44;
        
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuse_id];
        
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];
    }
    return _tableView;
}

+ (void)presentImageSelected:(UIViewController *)vc maxImageCount:(NSInteger)count didSelectAction:(void (^)(LSAlbumsViewController *, NSArray *))action {
    LSAlbumsViewController *selectedImagesVC = [LSAlbumsViewController new];
    
    selectedImagesVC.didSelectAction = action;
    selectedImagesVC.maxImageCount = count;
    
    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:selectedImagesVC];
    
    [vc presentViewController:naviVC animated:YES completion:nil];
}

@end

@implementation LSAlbum

+ (instancetype)albumWithName:(NSString *)name fetchResult:(PHFetchResult *)result {
    LSAlbum *album = [LSAlbum new];
    album.name = name;
    album.result = result;
    return album;
}

@end

@implementation LSPhotoAsset

+ (instancetype)asset:(PHAsset *)asset {
    LSPhotoAsset *model = [LSPhotoAsset new];
    model.asset = asset;
    return model;
}

+ (void)getPhotoWithAsset:(PHAsset *)asset photoMaxWH:(CGFloat)photoMaxWH completion:(void (^)(UIImage *, NSDictionary *))completion {
    
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.networkAccessAllowed = YES;
    
    // 图片原尺寸
    CGFloat imageW;
    CGFloat imageH;
    
    CGFloat scale = (CGFloat)asset.pixelHeight/asset.pixelWidth;
    
    if (asset.pixelWidth>photoMaxWH) {
        imageW = photoMaxWH;
        imageH = photoMaxWH*scale;
    }
    else if (asset.pixelHeight>photoMaxWH) {
        imageH = photoMaxWH;
        imageW = photoMaxWH / scale;
    }
    else {
        imageW = asset.pixelWidth;
        imageH = asset.pixelHeight;
    }
    
    CGSize targetSize = CGSizeMake(imageW, imageH);
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        !completion?:completion(result,info);
    }];
}

+ (void)requestImageForAsset:(PHAsset *)asset maxImageWidth:(CGFloat)maxImageWidth maxImageHeight:(CGFloat)maxImageHeight completion:(void (^)(UIImage *, NSDictionary *))completion {
    
    if (asset.mediaType != PHAssetMediaTypeImage) return;
    
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    
    // 图片原尺寸
    CGFloat imageW;
    CGFloat imageH;
    CGFloat scale = (CGFloat)asset.pixelWidth/asset.pixelHeight;
    
    if (asset.pixelWidth >= asset.pixelHeight) {
        if (asset.pixelWidth>maxImageWidth) {
            imageW = maxImageWidth;
            imageH = maxImageWidth/scale;
        }
        else {
            imageW = asset.pixelWidth;
            imageH = asset.pixelHeight;
        }
    }
    else {
        if (asset.pixelWidth > maxImageHeight) {
            imageH = maxImageHeight;
            imageW = maxImageHeight * scale;
        }
        else {
            imageW = asset.pixelWidth;
            imageH = asset.pixelHeight;
        }
    }
    
    CGSize targetSize = CGSizeMake(imageW, imageH);
    
    // 请求图片
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        !completion?:completion(result,info);
    }];
}

@end
