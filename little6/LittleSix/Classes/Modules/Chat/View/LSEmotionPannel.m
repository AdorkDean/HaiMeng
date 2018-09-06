//
//  LSEmotionPannel.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/22.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEmotionPannel.h"
#import "LSEmotionModel.h"
#import "LSEmotionManager.h"
#import "LSChatInputView.h"

static NSString *reuseId = @"LSEmotionCategoryCell";

@interface LSEmotionPannel () <UICollectionViewDelegate,UICollectionViewDataSource,LSPackageViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) NSArray<LSEmotionCatory *> *categories;
@property (nonatomic,strong) LSPackageView *packageView;
@property (nonatomic,strong) LSEmotionContentView *contentView;
@property (nonatomic,strong) UICollectionView *categoryView;

@end

@implementation LSEmotionPannel

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = HEXRGB(0xd7d7d9);
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.offset(0.5);
        }];
        
        //分类
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(75, 36);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *categoryView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.categoryView = categoryView;
        categoryView.backgroundColor = [UIColor whiteColor];
        [categoryView registerClass:[LSEmotionCategoryCell class] forCellWithReuseIdentifier:reuseId];
        categoryView.delegate = self;
        categoryView.dataSource = self;
        [self addSubview:categoryView];
        [categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.offset(36);
            make.top.equalTo(lineView.mas_bottom);
        }];
        
        //表情包
        LSPackageView *packageView = [LSPackageView new];
        self.packageView = packageView;
        packageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:packageView];
        [packageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.offset(36);
        }];
        packageView.delegate = self;
        
        //添加点击事件
        [self addActions];
        
        LSEmotionContentView *contentView = [LSEmotionContentView new];
        self.contentView = contentView;
        [self addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(categoryView.mas_bottom);
            make.bottom.equalTo(packageView.mas_top);
        }];
        
        //分类点击事件,切换分类
        [packageView setDidSelectPackageBlock:^(LSEmotionPackage *package) {
            contentView.emotions = package.emo;
        }];
        
        [self loadData];
        
        @weakify(self)
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kEmotionPackageUpdateNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
            @strongify(self)
            [self loadData];
        }];
    }
    return self;
}

- (void)loadData {
    self.categories = [LSEmotionManager fetchCategories];
    self.categories.firstObject.selected = YES;
    self.packageView.packages = self.categories.firstObject.group;
    self.contentView.emotions = self.categories.firstObject.group.firstObject.emo;
    [self.categoryView reloadData];
}

- (void)addActions {
    @weakify(self);
    [[self rac_signalForSelector:@selector(packageClickItemAdd) fromProtocol:@protocol(LSPackageViewDelegate)] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(emotionPannelDidClickAddButton)]) {
            [self.delegate emotionPannelDidClickAddButton];
        }
    }];
    [[self rac_signalForSelector:@selector(packageClickItemEdit) fromProtocol:@protocol(LSPackageViewDelegate)] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(emotionPannelDidClickEditButton)]) {
            [self.delegate emotionPannelDidClickEditButton];
        }
    }];
    [[self.packageView.customButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(emotionPannelDidClickSettingButton)]) {
            [self.delegate emotionPannelDidClickSettingButton];
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    
    LSEmotionCatory *category = self.categories[indexPath.row];
    
    cell.itemLabel.text = category.cate_name;
    cell.category = category;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionCatory *category = self.categories[indexPath.row];
    CGFloat width = [category.cate_name widthForFont:SYSTEMFONT(16)];
    
    return CGSizeMake(width+18, collectionView.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionCatory *category = self.categories[indexPath.row];
    if (category.selected) return;
    
    for (LSEmotionCatory *category in self.categories) {
        category.selected = NO;
    }
    
    category.selected = YES;
    [collectionView reloadData];
    
    self.packageView.packages = category.group;
    self.contentView.emotions = category.group.firstObject.emo;
}

@end

@implementation LSEmotionCategoryCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UILabel *itemLabel = [UILabel new];
        self.itemLabel = itemLabel;
        itemLabel.font = SYSTEMFONT(16);
        itemLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:itemLabel];
        [itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UIView *seperView = [UIView new];
        seperView.backgroundColor = HEXRGB(0xececec);
        [self addSubview:seperView];
        [seperView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.width.offset(0.5);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
        }];
    }
    return self;
}

- (void)setCategory:(LSEmotionCatory *)category {
    _category = category;
    
    if (category.selected) {
        self.itemLabel.textColor = HEXRGB(0xd42136);
        self.itemLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    else {
        self.itemLabel.textColor = [UIColor blackColor];
        self.itemLabel.backgroundColor = [UIColor whiteColor];
    }
}

@end

static NSString *const packet_reuse_id = @"LSPackageCell";

@interface LSPackageView () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *packagesView;

@end

@implementation LSPackageView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        //自定义表情按钮
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.customButton = customButton;
        customButton.backgroundColor = [UIColor whiteColor];
        [customButton setImage:[UIImage imageNamed:@"emotion_ch_setup"] forState:UIControlStateNormal];
        [self addSubview:customButton];
        [customButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self);
            make.width.offset(48);
        }];

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(45, 36);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *packagesView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.packagesView = packagesView;
        packagesView.bounces = NO;
        packagesView.backgroundColor = [UIColor whiteColor];
        packagesView.showsHorizontalScrollIndicator = NO;
        [packagesView registerClass:[LSPackageCell class] forCellWithReuseIdentifier:packet_reuse_id];
        packagesView.delegate = self;
        packagesView.dataSource = self;
        [self addSubview:packagesView];
        [packagesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self);
            make.height.offset(36);
            make.right.equalTo(customButton.mas_left);
        }];
        
        //渐变view
        UIView *gradientView = [UIView new];
        gradientView.backgroundColor = [UIColor lightGrayColor];
        gradientView.alpha = 0.6;
        [self addSubview:gradientView];
        [gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.right.equalTo(customButton.mas_left);
            make.width.offset(0.5);
        }];
        gradientView.layer.shadowColor = [UIColor blackColor].CGColor;
        gradientView.layer.shadowOffset = CGSizeMake(-4,0);
        gradientView.layer.shadowOpacity = 1;
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.packages.count+2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==0) {
        if ([self.delegate respondsToSelector:@selector(packageClickItemAdd)]) {
            [self.delegate packageClickItemAdd];
        }
    }
    else if (indexPath.row == 1) {
        if ([self.delegate respondsToSelector:@selector(packageClickItemEdit)]) {
            [self.delegate packageClickItemEdit];
        }
    }
    else {
        LSEmotionPackage *package = self.packages[indexPath.row-2];
        //分类点击事件
        !self.didSelectPackageBlock?:self.didSelectPackageBlock(package);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSPackageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:packet_reuse_id forIndexPath:indexPath];
    
    if (indexPath.row<2) {
        cell.idxPath = indexPath;
    }else {
        cell.package = self.packages[indexPath.row-2];
    }
    
    return cell;
}

#pragma mark - Getter & Setter
- (void)setPackages:(NSArray<LSEmotionPackage *> *)packages {
    _packages = packages;
    [self.packagesView reloadData];
}

@end

@implementation LSPackageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIImageView *iconView = [UIImageView new];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.clipsToBounds = YES;
        self.iconView = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
            make.width.equalTo(iconView);
            make.centerX.equalTo(self);
        }];
        
        UIView *seperView = [UIView new];
        seperView.backgroundColor = HEXRGB(0xececec);
        [self addSubview:seperView];
        [seperView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.width.offset(0.5);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
        }];

    }
    return self;
}

- (void)setIdxPath:(NSIndexPath *)idxPath {
    _idxPath = idxPath;
    
    if (idxPath.row == 0) {
        self.iconView.image = [UIImage imageNamed:@"emotion_add_bq"];
    }
    else if (idxPath.row == 1) {
        self.iconView.image = [UIImage imageNamed:@"emotion_add_pics"];
    }
}

- (void)setPackage:(LSEmotionPackage *)package {
    _package = package;
    
    UIImage *image = [UIImage imageWithContentsOfFile:[package iconPath]];
    self.iconView.image = image;
}

@end

static NSString *const emotion_page_reuse_id = @"LSEmotionPageCell";

@interface LSEmotionContentView () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *emotionsPageView;
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@property (nonatomic,strong) UIPageControl *pageControl;

@property (nonatomic,assign) NSInteger numberOfPage;

@end

@implementation LSEmotionContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat pageControlH = 25;
        UIPageControl *pageControl = [UIPageControl new];
        self.pageControl = pageControl;
        [self addSubview:pageControl];
        [pageControl setCurrentPageIndicatorTintColor:HEXRGB(0x8b8b8b)];
        [pageControl setPageIndicatorTintColor:HEXRGB(0xd6d6d6)];
        [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.offset(pageControlH);
        }];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        self.layout = layout;
        layout.itemSize = CGSizeMake(50, 50);
        
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *emotionsPageView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        emotionsPageView.pagingEnabled = YES;
        self.emotionsPageView = emotionsPageView;
        emotionsPageView.backgroundColor = [UIColor clearColor];
        emotionsPageView.bounces = NO;
        emotionsPageView.showsHorizontalScrollIndicator = NO;
        [emotionsPageView registerClass:[LSEmotionPageCell class] forCellWithReuseIdentifier:emotion_page_reuse_id];
        emotionsPageView.delegate = self;
        emotionsPageView.dataSource = self;
        [self addSubview:emotionsPageView];
        [emotionsPageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.bottom.equalTo(pageControl.mas_top);
        }];

    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfPage;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:emotion_page_reuse_id forIndexPath:indexPath];
    
    if (indexPath.row == self.numberOfPage-1) {
        NSRange range = NSMakeRange(indexPath.row*8, self.emotions.count-indexPath.row*8);
        cell.dataSource = [self.emotions subarrayWithRange:range];
    }
    else {
        cell.dataSource = [self.emotions subarrayWithRange:NSMakeRange(indexPath.row*8, 8)];
    }
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int itemIndex = (scrollView.contentOffset.x+kScreenWidth*0.5)/kScreenWidth;
    int indexOnPageControl = itemIndex % self.numberOfPage;
    self.pageControl.currentPage = indexOnPageControl;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layout.itemSize = CGSizeMake(self.emotionsPageView.width, self.emotionsPageView.height);
    self.layout.minimumLineSpacing = 0;
    self.layout.minimumInteritemSpacing = 0;
    [self.emotionsPageView reloadData];
}

#pragma mark - Getter & Setter 
- (void)setEmotions:(NSArray<LSEmotionModel *> *)emotions {
    _emotions = emotions;
    
    self.numberOfPage = (emotions.count + 7)/8;
    self.pageControl.numberOfPages = self.numberOfPage;
    self.pageControl.currentPage = 0;
    
    [self.emotionsPageView reloadData];
}

@end

static NSString *const emotion_reuse_id = @"LSEmotionCell";

@interface LSEmotionPageCell () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *emotionsView;
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;

@end

@implementation LSEmotionPageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        self.layout = layout;
        layout.itemSize = CGSizeMake(50, 50);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        UICollectionView *emotionsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        emotionsView.pagingEnabled = YES;
        self.emotionsView = emotionsView;
        emotionsView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        emotionsView.bounces = NO;
        emotionsView.showsHorizontalScrollIndicator = NO;
        [emotionsView registerClass:[LSEmotionCell class] forCellWithReuseIdentifier:emotion_reuse_id];
        emotionsView.delegate = self;
        emotionsView.dataSource = self;
        [self addSubview:emotionsView];
        [emotionsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:emotion_reuse_id forIndexPath:indexPath];
    
    LSEmotionModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionModel *model = self.dataSource[indexPath.row];
    //表情图片点击的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectEmotionNoti object:model];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat viewHeight = self.emotionsView.height;
    CGFloat viewWidth = self.emotionsView.width;
    
    CGFloat titleH = 25;
    CGFloat lineMargin = 8;
    
    CGFloat itemH = (viewHeight-lineMargin*2) * 0.5;
    CGFloat itemW = itemH - titleH;
    
    CGFloat interMargin = (viewWidth - 4 * itemW) / 5;
    
    self.layout.itemSize = CGSizeMake((int)itemW, (int)itemH);
    self.layout.minimumLineSpacing = lineMargin;
    self.layout.minimumInteritemSpacing = interMargin;
    
    self.layout.sectionInset = UIEdgeInsetsMake(lineMargin, interMargin, 0, interMargin);
    
    [self.emotionsView reloadData];
}

- (void)setDataSource:(NSArray<LSEmotionModel *> *)dataSource {
    _dataSource = dataSource;
    [self.emotionsView reloadData];
}

@end

@implementation LSEmotionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIImageView *imageView = [UIImageView new];
        self.imageView = imageView;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.equalTo(imageView.mas_width);
            make.top.equalTo(self);
        }];
        
        UILabel *titleLabel = [UILabel new];
        self.titleLabel = titleLabel;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = HEXRGB(0x888888);
        titleLabel.font = SYSTEMFONT(12);
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(imageView.mas_bottom);
        }];
    }
    return self;
}

- (void)setModel:(LSEmotionModel *)model {
    _model = model;
    
    self.imageView.image = [UIImage imageWithContentsOfFile:[model filePath]];
    self.titleLabel.text = model.emo_name;
}

@end
