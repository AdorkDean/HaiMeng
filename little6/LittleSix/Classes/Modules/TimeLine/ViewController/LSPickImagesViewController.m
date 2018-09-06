//
//  LSPickImagesViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPickImagesViewController.h"
#import "UIView+HUD.h"

static NSString *const reuse_id = @"LSPickImageCell";

@interface LSPickImagesViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) NSMutableArray *list;

@property (nonatomic,assign) BOOL isMaxCount;

@property (nonatomic,strong) UIButton *doneButton;

@end

@implementation LSPickImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.album.name;

    self.list = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self installSubviews];
    
    [self getDataSource];
    
    [self.collectionView reloadData];
}

- (void)getDataSource {
    
    if (!self.album) return;
    
    NSMutableArray *assetArr = [NSMutableArray array];
    
    [self.album.result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        if (asset.mediaType != PHAssetMediaTypeImage) return;
        LSPhotoAsset *model = [LSPhotoAsset asset:asset];
        [assetArr addObject:model];
    }];
    NSMutableArray * assArr = [NSMutableArray array];
    [assArr addObjectsFromArray:[[assetArr reverseObjectEnumerator] allObjects]];
    self.album.assets =assArr;
}

- (void)installSubviews {
    UIView *bottomView = [UIView new];
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    bottomView.backgroundColor = HEXRGB(0xf9f9f9);
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.offset(45);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = HEXRGB(0xb2b2b2);
    [bottomView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(bottomView);
        make.height.offset(0.5);
    }];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneButton = doneButton;
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton setTitleColor:kMainColor forState:UIControlStateNormal];
    [bottomView addSubview:doneButton];
    [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(bottomView);
        make.right.equalTo(bottomView).offset(-8);
    }];
    
    @weakify(self)
    [[doneButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        if (self.list.count == 0) return;
        !self.doneButtonAction?:self.doneButtonAction(self.list);
    }];
    
    [self _naivRightItem];
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

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.album.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSPickImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_id forIndexPath:indexPath];
    
    LSPhotoAsset *asset = self.album.assets[indexPath.row];
    cell.model = asset;
    
    cell.selectButton.selected = asset.selected;
    
    if (!self.isMaxCount) {
        cell.coverView.alpha = 0.0;
    }
    else {
        if (asset.selected) {
            cell.coverView.alpha = 0.0;
        }
        else {
            cell.coverView.alpha = 0.4;
        }
    }
    
    [cell.selectButton addTarget:self action:@selector(selectedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectButton.tag = indexPath.row;
    
    return cell;
}

- (void)selectedButtonAction:(UIButton *)button {
    
    LSPhotoAsset *asset = self.album.assets[button.tag];

    button.selected ? [self.list removeObject:asset] : [self.list addObject:asset];
    
    button.selected = !button.selected;
    asset.selected = button.selected;
    
    if (asset.selected) {
        LSPickImageCell *cell = (LSPickImageCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:button.tag inSection:0]];
        asset.image = cell.imageView.image;
    }
    else {
        asset.image = nil;
    }
    
    self.isMaxCount = (self.list.count == self.maxImageCount);
    
    if (self.list.count == self.maxImageCount) {
        self.isMaxCount = YES;
        [self.collectionView reloadData];
    }
    else if (self.list.count == (self.maxImageCount-1)) {
        self.isMaxCount = NO;
        [self.collectionView reloadData];
    }
    else {
        self.isMaxCount = NO;
    }
    
    NSString *title = self.list.count == 0 ? @"完成" : [NSString stringWithFormat:@"完成(%ld)",self.list.count];
    [self.doneButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - Getter & Setter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CGFloat margin = 4;
        CGFloat count = 4;
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        self.layout = layout;
        CGFloat itemW = (kScreenWidth - (count+1) * margin) / count;
        layout.itemSize = CGSizeMake(itemW, itemW);
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, 0, margin);
        layout.minimumLineSpacing = margin;
        layout.minimumInteritemSpacing = margin;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView = collectionView;
        
        [self.view addSubview:collectionView];
        
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuide);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.bottomView.mas_top);
        }];
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [collectionView registerClass:[LSPickImageCell class] forCellWithReuseIdentifier:reuse_id];
    }
    return _collectionView;
}

@end

@implementation LSPickImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIImageView *imageView = [UIImageView new];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.selectButton = button;
        [button setImage:[UIImage imageNamed:@"timeline_selected_off"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"timeline_selected_on"] forState:UIControlStateSelected];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(self);
            make.width.height.offset(35);
        }];
        
        UIView *coverView = [UIView new];
        self.coverView = coverView;
        coverView.backgroundColor = [UIColor whiteColor];
        [self addSubview:coverView];
        [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    return self;
}

- (void)setModel:(LSPhotoAsset *)model {
    _model = model;
    
    //获取image
    [LSPhotoAsset getPhotoWithAsset:model.asset photoMaxWH:kScreenWidth*0.5 completion:^(UIImage *photo, NSDictionary *info) {
        self.imageView.image = photo;
    }];
}

@end
