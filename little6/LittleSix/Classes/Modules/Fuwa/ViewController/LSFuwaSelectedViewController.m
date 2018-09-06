//
//  LSFuwaSelectedViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaSelectedViewController.h"
//#import "LSFuwaComfirmView.h"
#import "LSFuwaModel.h"
#import "UIView+HUD.h"
#import "LSFuwaActivityInputView.h"
#import "LSFuwaBackPackModel.h"
#import "LSFuwaBackpackViewController.h"
#import "LSCaptureViewController.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "LFUITips.h"

static NSString *const reuse_id = @"LSFuwaSelectedCell";

@interface LSFuwaSelectedViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic,strong) LSFuwaActivityInputView * actView;

@end

@implementation LSFuwaSelectedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    self.title = @"选择你要藏的福娃";
    self.view.backgroundColor = [UIColor whiteColor];

    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_obg"].CGImage);

    [self loadData];
}

- (void)loadData {
    
    [self.view showLoading:@"正在请求"];
    
//    [LSFuwaBackPackModel searchBackPackAutoComplete:NO Success:^(NSArray *modelList) {
//        [self.view hideHUDAnimated:YES];
//        self.dataSource = modelList;
//        [self.collectionView reloadData];
//    } failure:^(NSError *error) {
//        [self.view showError:@"请求失败" hideAfterDelay:1];
//        
//    }];

}

#pragma mark - TableView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    LSFuwaSelectedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_id forIndexPath:indexPath];
    
    LSFuwaBackPackListModel * listModel = self.dataSource[indexPath.row];
    LSFuwaModel * Model = [LSFuwaModel new];
    LSFuwaModel *fuwaModel = listModel.fuwaListArr.firstObject;
    Model.id = fuwaModel.id;
    Model.count = listModel.fuwaListArr.count;
    
    cell.model = Model;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    LSFuwaModel *model = self.dataSource[indexPath.row];
    @weakify(self)

    LSFuwaDetailView * detailView = [LSFuwaDetailView FuwaDetailView];
    LSFuwaBackPackListModel * listModel = self.dataSource[indexPath.row];
    detailView.dataSource = listModel.fuwaListArr;
//    detailView.listType = LSFuwaListTypeHidden;
    detailView.frame = LSKeyWindow.bounds;

    [LSKeyWindow addSubview:detailView];
}

- (void)sendSaveRequest:(LSFuwaModel *)model activityDetail:(NSString *)detail videoModel:(LSCaptureModel *)videoModel day:(NSString *)day{
    

    
}

#pragma mark - Gette & Setter

- (UICollectionView *)collectionView {
    if (!_collectionView) {

        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        
        CGFloat itemW = 100;
        NSInteger count = kScreenWidth / itemW;
        CGFloat margin = (kScreenWidth - itemW*count)/(count+1);
        
//        if (margin < 10) {
//            count = count - 1;
//            margin = (kScreenWidth - itemW*count)/(count+1);
//        }

        layout.itemSize = CGSizeMake(100, 145);
        layout.minimumLineSpacing = margin;
        layout.minimumInteritemSpacing = margin;
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, 0, margin);

        UICollectionView *collectionView =
            [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView = collectionView;
        [collectionView registerClass:[LSFuwaSelectedCell class] forCellWithReuseIdentifier:reuse_id];

        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];

        [self.view addSubview:collectionView];
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];
    }
    return _collectionView;
}

- (NSString *)copyAssetToCaptureFolder:(NSURL *)sourceUrl withImage:(UIImage *)image{
    
    //沙盒中没有目录则新创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:kCaptureFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:kCaptureFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString * fileStr =[sourceUrl.absoluteString lastPathComponent];
    NSString * newFileStr;
    NSString * formatStr ;
    
    if ([fileStr containsString:@".mov" ]||[fileStr containsString:@".MOV"]) {
        newFileStr =[fileStr stringByReplacingOccurrencesOfString:@".MOV" withString:@".mov"];;
        formatStr = @".mov";
    }
    else if ([fileStr containsString:@".mp4"]||[fileStr containsString:@".MP4"]) {
        newFileStr = [fileStr stringByReplacingOccurrencesOfString:@".MP4" withString:@".mp4"];
        formatStr = @".mp4";
    }
    
    NSString *destinationPath = [kCaptureFolder stringByAppendingPathComponent:newFileStr];
    
    NSError	*error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:destinationPath];
    if (!result) {
        [fileManager copyItemAtURL:sourceUrl toURL:[NSURL fileURLWithPath:destinationPath] error:&error];
    }

    NSData * imageData = UIImageJPEGRepresentation(image, 1);
    NSString * imagePath = [destinationPath stringByReplacingOccurrencesOfString:formatStr withString:@".jpg"];
    if ([imageData writeToFile:imagePath atomically:YES]) {
        NSLog(@"写入成功");
    };
    
    return destinationPath;
}


@end

@implementation LSFuwaSelectedCell


@end
