//
//  LSTimeLineHomeDetailViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTimeLineHomePicViewController.h"
#import "LSTimeLineHomeDetailViewController.h"
#import "LSHomeTimeLinePicContentView.h"
#import "LSTimeLineTableListModel.h"


static NSString *const reuse_id = @"cell";

@interface LSTimeLineHomePicViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,TimeLinePicContentViewDelegate>

@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) LSHomeTimeLinePicContentView *contentView;

@end

@implementation LSTimeLineHomePicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"相册详情";
    self.view.backgroundColor = [UIColor lightGrayColor];

    [self makeConstrains];
    [self setAllContent];

}

-(void)makeConstrains{
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.contentView =[LSHomeTimeLinePicContentView new];
    self.contentView.delegate =self;
    [self.view addSubview:self.contentView];
    
    [self.view addSubview:self.collectionView];
    
    [self.view bringSubviewToFront:self.contentView];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.top.left.right.bottom.equalTo(self.view);
    }];
//    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
    }];
}
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing =0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[LSTimeLinDetailCollectionViewCell class] forCellWithReuseIdentifier:reuse_id];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}

-(void)TimeLinePicContentViewClickDetailBtnWithView:(LSHomeTimeLinePicContentView *)view{
    LSTimeLineHomeDetailViewController *Vc = [LSTimeLineHomeDetailViewController new];
    Vc.feed_Id =self.model.feed_id;
    Vc.user_id = self.model.user_id;
    [self.navigationController pushViewController:Vc animated:YES];
}

#pragma mark --)<UICollectionViewDataSource,UICollectionViewDelegate>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.model.files.count;
    
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0,0,0,0);//分别为上、左、下、右
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LSTimeLinDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_id forIndexPath:indexPath];
    LSTimeLineImageModel * model = self.model.files[indexPath.row];
    [cell.picView setImageWithURL:[NSURL URLWithString:model.file_url] placeholder:timeLineSmallPlaceholderName];
    return cell;
    
}


-(void)setAllContent{
    self.contentView.model = self.model;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@interface LSTimeLinDetailCollectionViewCell()


@end

@implementation LSTimeLinDetailCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setConstrains];
    }
    return self;
}

-(void)setConstrains{
    
    self.picView = [UIImageView new];
    self.picView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.picView];
    
    [self.picView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.contentView);
    }];
}

@end
