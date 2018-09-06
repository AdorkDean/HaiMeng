//
//  LSMyEmotionViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/9.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMyEmotionViewController.h"
#import "LSEmotionManager.h"
#import "LSEditEmotionViewController.h"

#define kMargin 8
static NSString *const reuse_id = @"LSMyEmotionCateCell";
static NSString *const emo_reuse_id = @"LSMyEmotionCell";

@interface LSMyEmotionViewController () <UISearchResultsUpdating,UISearchControllerDelegate,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UISearchController *searchControl;
@property (nonatomic,strong) UICollectionView *emotionsView;
@property (nonatomic,strong) UICollectionView *packagesView;
@property (nonatomic,strong) UICollectionViewFlowLayout *emotinsLayout;
@property (nonatomic,strong) NSArray<LSEmotionPackage *> *packages;
@property (nonatomic,strong) LSEmotionPackage *package;

@end

@implementation LSMyEmotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"制作表情";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setTranslucent:YES];

    [self naviBarConfig];
    
    [self initialSubviews];
}

- (void)naviBarConfig {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    button.titleLabel.font = SYSTEMFONT(15);
    [button sizeToFit];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)initialSubviews {
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UITableView *searchContentView = [UITableView new];
    [self.view addSubview:searchContentView];
    [searchContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.equalTo(self.view);
        make.height.offset(44);
    }];
    searchContentView.tableHeaderView = self.searchControl.searchBar;
    
    UIView *pacContentView = [UIView new];
    [self.view addSubview:pacContentView];
    [pacContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(searchContentView.mas_bottom);
        make.height.offset(51);
    }];
    
    UIView *scrollBar = [UIView new];
    scrollBar.backgroundColor = HEXRGB(0xff9f00);
    [pacContentView addSubview:scrollBar];
    
    UICollectionViewFlowLayout *packagesLayout = [UICollectionViewFlowLayout new];
    packagesLayout.minimumLineSpacing = 0;
    packagesLayout.minimumInteritemSpacing = 0;
    UICollectionView *packagesView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:packagesLayout];
    self.packagesView = packagesView;
    [pacContentView addSubview:packagesView];
    packagesView.backgroundColor = HEXRGB(0xfafafa);
    [packagesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(pacContentView);
    }];
    packagesView.delegate = self;
    packagesView.dataSource = self;
    [packagesView registerClass:NSClassFromString(@"LSMyEmotionCateCell") forCellWithReuseIdentifier:reuse_id];
    self.packages = [LSEmotionManager allPackages];
    self.package = self.packages.firstObject;
    
    UICollectionViewFlowLayout *emotinsLayout = [UICollectionViewFlowLayout new];
    self.emotinsLayout = emotinsLayout;
    emotinsLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    emotinsLayout.minimumLineSpacing = kMargin;
    emotinsLayout.minimumInteritemSpacing = kMargin;
    CGFloat itemW = (kScreenWidth - 4*kMargin) / 3;
    emotinsLayout.itemSize = CGSizeMake(itemW, itemW);
    emotinsLayout.sectionInset = UIEdgeInsetsMake(kMargin, kMargin, kMargin, kMargin);
    UICollectionView *emotionsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:emotinsLayout];
    self.emotionsView = emotionsView;
    emotionsView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [emotionsView registerClass:NSClassFromString(@"LSMyEmotionCell") forCellWithReuseIdentifier:emo_reuse_id];
    emotionsView.delegate = self;
    emotionsView.dataSource = self;
    [self.view addSubview:emotionsView];
    [emotionsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(pacContentView.mas_bottom);
    }];
    
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.packagesView]) {
        return self.packages.count;
    }
    else {
        return self.package.emo.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.packagesView]) {
        LSMyEmotionCateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_id forIndexPath:indexPath];
        
        LSEmotionPackage *package = self.packages[indexPath.row];
        
        cell.titleLabel.text = package.group_name;
        
        return cell;
    }
    else {
        LSMyEmotionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:emo_reuse_id forIndexPath:indexPath];
        
        LSEmotionModel *model = self.package.emo[indexPath.row];
        
        cell.imageView.image = [UIImage imageWithContentsOfFile:[model filePath]];
        
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.packagesView]) {
        LSEmotionPackage *package = self.packages[indexPath.row];
        
        CGSize size = [package.group_name sizeForFont:SYSTEMFONT(15) size:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping];
        
        return CGSizeMake(size.width + 16, collectionView.size.height);
    }
    else {
        return self.emotinsLayout.itemSize;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.packagesView]) {
        
    }
    else {
        LSEmotionModel *model = self.package.emo[indexPath.row];
        LSEditEmotionViewController *vc = [LSEditEmotionViewController new];
        [vc setValue:model forKey:@"model"];
        [vc setCompleteBlock:^(LSEmotionOperation operation, UIImage *image) {
            !self.editComplteBlock?:self.editComplteBlock(operation,image);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - SearchControl
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
}
- (void)willPresentSearchController:(UISearchController *)searchController {
    [searchController.searchBar setBackgroundImage:[UIImage imageWithColor:kMainColor] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIButton *button = [searchController.searchBar valueForKey:@"cancelButton"];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];

}

- (void)didPresentSearchController:(UISearchController *)searchController {
    
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    [searchController.searchBar setBackgroundImage:[UIImage imageWithColor:HEXRGB(0xefeff4)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = YES;
    
    UIButton *button = [searchBar valueForKey:@"cancelButton"];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTintColor:[UIColor orangeColor]];
    
    return YES;
}

#pragma mark - Getter & Setter
- (UISearchController *)searchControl {
    if (!_searchControl) {
        UIViewController *vc = [UIViewController new];
        vc.view.backgroundColor = [UIColor redColor];
        UISearchController *searchControl = [[UISearchController alloc] initWithSearchResultsController:vc];
        _searchControl = searchControl;
        searchControl.searchResultsUpdater = self;
        searchControl.searchBar.placeholder = @"搜索";
        searchControl.delegate = self;
        searchControl.searchBar.delegate = self;
        [searchControl.searchBar setBackgroundImage:[UIImage imageWithColor:HEXRGB(0xefeff4)]];
    }
    return _searchControl;
}

@end

@implementation LSMyEmotionCateCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = SYSTEMFONT(15);
        self.titleLabel = label;
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        label.text = @"中文";
    }
    return self;
}

- (void)setChoose:(BOOL)choose {
    _choose = choose;
    
    if (choose) {
        self.titleLabel.textColor = HEXRGB(0xff9ff0);
    }
    else {
        self.titleLabel.textColor = HEXRGB(0x000000);
    }
}

@end

@implementation LSMyEmotionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        UIImageView *imageView = [UIImageView new];
        self.imageView = imageView;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

@end
