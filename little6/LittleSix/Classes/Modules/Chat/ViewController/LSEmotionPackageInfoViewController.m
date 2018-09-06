//
//  LSEmotionPackageInfoViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEmotionPackageInfoViewController.h"
#import "LSEmotionModel.h"
#import "UIView+HUD.h"
#import "LSEmotionInfoHeaderView.h"

static NSString *const headerIdentifier = @"LSEmotionInfoHeader";
static NSString *const reuse_id = @"LSEmotionPackageInfoCell";

@interface LSEmotionPackageInfoViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,strong) LSEmotionPackage *package;

@end

@implementation LSEmotionPackageInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadData];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.collectionView.hidden = NO;
}

- (void)loadData {
    
    [self.view showLoading:@"正在请求"];
    
    [LSEmotionPackage packageInfo:self.packid success:^(LSEmotionPackage *package) {
        
        [self.view hideHUDAnimated:YES];
        self.package = package;
        
    } failure:^(NSError *error) {
        [self.view showError:@"请求失败" hideAfterDelay:1.5];
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    LSEmotionInfoHeaderView *headerView = [LSEmotionInfoHeaderView emotionInfoHeaderView];
    
    headerView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);

    return CGSizeMake(kScreenWidth, [headerView viewHeight:self.package]);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionInfoHeaderView *headerView = (LSEmotionInfoHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
    
    headerView.package = self.package;
    
    return headerView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.package.emo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionPackageInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_id forIndexPath:indexPath];
    
    cell.model = self.package.emo[indexPath.row];
    
    return cell;
}

#pragma mark - Getter & Setter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        
        CGFloat itemW = 75;
        NSInteger count = kScreenWidth / itemW;
        CGFloat margin = (kScreenWidth - itemW*count)/(count+1);
        
        if (margin < 10) {
            count = count - 1;
            margin = (kScreenWidth - itemW*count)/(count+1);
        }

        layout.itemSize = CGSizeMake(itemW, itemW);
        layout.sectionInset = UIEdgeInsetsMake(15, margin, 0, margin);
        layout.minimumLineSpacing = margin;
        layout.minimumInteritemSpacing = margin;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView = collectionView;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:collectionView];
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];
        
        [collectionView registerNib:[UINib nibWithNibName:@"LSEmotionInfoHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];
        
        [collectionView registerClass:[LSEmotionPackageInfoCell class] forCellWithReuseIdentifier:reuse_id];
    }
    return _collectionView;
}

- (void)setPackage:(LSEmotionPackage *)package {
    _package = package;
    
    self.title = package.group_name;
    [self.collectionView reloadData];
}

@end


@implementation LSEmotionPackageInfoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        UIButton *emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.emotionButton = emotionButton;
        [self addSubview:emotionButton];
        [emotionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        //添加事件
        [emotionButton addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
        [emotionButton addTarget:self action:@selector(touchExist) forControlEvents:UIControlEventTouchUpInside];
        [emotionButton addTarget:self action:@selector(touchExist) forControlEvents:UIControlEventTouchUpOutside];
        [emotionButton addTarget:self action:@selector(touchExist) forControlEvents:UIControlEventTouchCancel];
    }
    return self;
}

- (void)setModel:(LSEmotionModel *)model {
    _model = model;
    
    [self.emotionButton setImageWithURL:[NSURL URLWithString:model.url] forState:UIControlStateNormal placeholder:nil];
}

- (void)touchDown {
    
    CGRect frame = [self.emotionButton convertRect:self.emotionButton.bounds toViewOrWindow:LSKeyWindow];

    YYAnimatedImageView *animateView = [[YYAnimatedImageView alloc] init];
    self.animateView = animateView;
    [LSKeyWindow addSubview:animateView];
    [animateView setImageURL:[NSURL URLWithString:self.model.url]];
    
    CGFloat margin = 20;
    
    animateView.frame = CGRectMake(0, 0, 120, 120);
    animateView.centerX = frame.origin.x + frame.size.width*0.5;
    animateView.bottom = frame.origin.y - margin;
    
    if (animateView.right > kScreenWidth) {
        animateView.right = kScreenWidth - 20;
    }
    if (animateView.left < margin) {
        animateView.left = margin;
    }
}

- (void)touchExist {
    [self.animateView removeFromSuperview];
    self.animateView = nil;
}


@end
