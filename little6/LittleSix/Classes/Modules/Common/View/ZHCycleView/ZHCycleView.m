//
//  ZHCycleView.m
//  ZHCycleView
//
//  Created by AdminZhiHua on 16/2/23.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ZHCycleView.h"

static NSString *const reuseId = @"ZHCycleViewCell";

@interface ZHCycleView ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>

@property (nonatomic,weak) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic,strong) UIPageControl *pageControl;

@property (nonatomic,strong) NSLayoutConstraint *pagecontrolBottomConst;

//占位图
@property (nonatomic,strong) UIImage *placeHolderImage;

//CollectionView的个数
@property (nonatomic,assign) NSUInteger totalItemsCount;

//Cell点击的block
@property (nonatomic,copy) void(^selectBlock)(NSInteger index);

//定时器
@property (nonatomic,copy) NSTimer *timer;

@end

@implementation ZHCycleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if ([super initWithFrame:frame])
    {
        [self initialProperties];
        [self addConstraintToSubviews];
    }
    
    return self;
}

/*!
 *  @author zhihua, 16-02-23 15:02:32
 *
 *  初始化属性
 */
- (void)initialProperties {
    
    if (self.autoScrollTimeInterval==0)
    {
        self.autoScrollTimeInterval = 5;
    }
    
    self.currentPageTintColor = [UIColor whiteColor];
    self.pageTintColor = [UIColor grayColor];
}

+ (instancetype)cycleViewWithFrame:(CGRect)frame imageUrlGroups:(NSArray *)group placeHolderImage:(UIImage *)image selectAction:(void(^)(NSInteger index))block {
    
    ZHCycleView *cycleView = [[ZHCycleView alloc] initWithFrame:frame];
    
    cycleView.placeHolderImage = image;
    cycleView.imageUrlGroups = group;
    
    cycleView.selectBlock = block;
    
    [cycleView reloadData];
    
    //将pagecontrol提前
    [cycleView bringSubviewToFront:cycleView.pageControl];
    
    return cycleView;
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.totalItemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZHCycleViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    
    long itemIndex = indexPath.item%self.imageUrlGroups.count;
    NSString *imagePath = self.imageUrlGroups[itemIndex];
    
    if ([imagePath isKindOfClass:[NSString class]])
    {
        if ([imagePath hasPrefix:@"http"])
        {
            [cell.imageView setImageWithURL:[NSURL URLWithString:imagePath] placeholder:self.placeHolderImage];
        }
        else
        {
            UIImage *image = [UIImage imageNamed:imagePath];
            image = image?image:self.placeHolderImage;
            cell.imageView.image = image;
        }
    }
    else if ([imagePath isKindOfClass:[UIImage class]])
    {
        cell.imageView.image = (UIImage *)imagePath;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectBlock)
    {
        NSInteger index = indexPath.item % self.imageUrlGroups.count;
        self.selectBlock(index);
    }
    
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    int itemIndex = (scrollView.contentOffset.x+self.flowLayout.itemSize.width*0.5)/self.flowLayout.itemSize.width;
    
    if (!self.imageUrlGroups.count) return;
    
    int indexOnPageControl = itemIndex % self.imageUrlGroups.count;

    [self setCurrentPage:indexOnPageControl];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self destoryTimer];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self setupTimer];
    
}

#pragma mark - Public

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - Private
/*!
 *  @author zhihua, 16-02-23 15:02:07
 *
 *  给子控件添加约束
 */
- (void)addConstraintToSubviews {
    
    //CollectionView的约束
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UICollectionView *view = self.collectionView;
    
    NSString *hVFL = @"H:|-(0)-[view]-(0)-|";
    NSString *vVFL = @"V:|-(0)-[view]-(0)-|";
    
    NSArray *hConsts = [NSLayoutConstraint constraintsWithVisualFormat:hVFL options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
    NSArray *vConsts = [NSLayoutConstraint constraintsWithVisualFormat:vVFL options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
    
    [self addConstraints:hConsts];
    [self addConstraints:vConsts];
    
    //PageControl的约束
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constCenterX = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    self.pagecontrolBottomConst = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    [self addConstraint:constCenterX];
    [self addConstraint:self.pagecontrolBottomConst];
}

/*!
 *  @author zhihua, 16-02-23 15:02:17
 *
 *  创建定时器
 */
- (void)setupTimer {
    
    if (self.timer) [self destoryTimer];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

/*!
 *  @author zhihua, 16-02-23 15:02:52
 *
 *  销毁定时器
 */
- (void)destoryTimer {
    [self.timer invalidate];
    self.timer = nil;
}

/*!
 *  @author zhihua, 16-02-23 15:02:12
 *
 *  设置pagecontrol当前显示的页码
 *
 */
- (void)setCurrentPage:(int)pageIndex {
    
    self.pageControl.numberOfPages = self.imageUrlGroups.count;
    
    self.pageControl.currentPage = pageIndex;
}

/*!
 *  @author zhihua, 16-02-23 15:02:31
 *
 *  定时器执行的方法
 */
- (void)automaticScroll {
    
    if (self.totalItemsCount==0) return;
    
    int currentIndex = self.collectionView.contentOffset.x/self.flowLayout.itemSize.width;
    int targetIndex = currentIndex+1;
    
    if (targetIndex==self.totalItemsCount)
    {
        targetIndex = self.totalItemsCount*0.5;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        return;
    }
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

/*!
 *  @author zhihua, 16-02-23 15:02:09
 *
 *  重新布局子控件
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.collectionView.contentOffset.x==0&&self.totalItemsCount)
    {
        int targetIndex = self.totalItemsCount*0.5;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
}

#pragma mark - Getter&Setter
- (UICollectionView *)collectionView {
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout = layout;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        CGSize viewSize = self.bounds.size;
        layout.itemSize = CGSizeMake(viewSize.width, viewSize.height);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView = collectionView;
        [self addSubview:_collectionView];
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.pagingEnabled = YES;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        
        collectionView.backgroundColor = [UIColor whiteColor];
        
        [collectionView registerClass:[ZHCycleViewCell class] forCellWithReuseIdentifier:reuseId];
        
    }
    return _collectionView;
}

- (void)setImageUrlGroups:(NSArray *)imageUrlGroups {
    _imageUrlGroups = imageUrlGroups;
    
    _totalItemsCount = self.imageUrlGroups.count * 10000;
    
    [self setCurrentPage:0];
}

- (UIPageControl *)pageControl {
    if (!_pageControl)
    {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.numberOfPages = 0;
        pageControl.currentPageIndicatorTintColor = self.currentPageTintColor;
        pageControl.pageIndicatorTintColor = self.pageTintColor;
        pageControl.userInteractionEnabled = NO;
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (void)setCurrentPageTintColor:(UIColor *)currentPageTintColor {
    _currentPageTintColor = currentPageTintColor;
    
    self.pageControl.currentPageIndicatorTintColor = self.currentPageTintColor;
}

- (void)setPageTintColor:(UIColor *)pageTintColor {
    _pageTintColor = pageTintColor;
 
    self.pageControl.pageIndicatorTintColor = pageTintColor;
}

- (void)setPagecontrolConstBottom:(NSInteger)pagecontrolConstBottom {
    _pagecontrolConstBottom = pagecontrolConstBottom;
    
    self.pagecontrolBottomConst.constant = pagecontrolConstBottom;
}

- (void)setAutoScrollTimeInterval:(int)autoScrollTimeInterval {
    _autoScrollTimeInterval = autoScrollTimeInterval;
    
    [self setupTimer];
}

- (void)dealloc {
    [self destoryTimer];
}

@end

@implementation ZHCycleViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame])
    {
        [self addConstraintToSubViews];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)addConstraintToSubViews {
    
    UIImageView *imageView = self.imageView;
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *hVFL = @"H:|-(0)-[imageView]-(0)-|";
    NSString *vVFL = @"V:|-(0)-[imageView]-(0)-|";
    
    NSArray *hConsts = [NSLayoutConstraint constraintsWithVisualFormat:hVFL options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)];
    NSArray *vConsts = [NSLayoutConstraint constraintsWithVisualFormat:vVFL options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)];
    
    [self.contentView addConstraints:hConsts];
    [self.contentView addConstraints:vConsts];
}

- (UIImageView *)imageView {
    if (!_imageView)
    {
        UIImageView *imageView = [UIImageView new];
        [self.contentView addSubview:imageView];
        _imageView = imageView;
        imageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _imageView;
}

@end
