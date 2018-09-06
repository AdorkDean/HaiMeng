//
//  LSMorePannel.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/24.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMorePannel.h"

static NSString *const reuse_id = @"LSFeatureCell";

@interface LSMorePannel () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@property (nonatomic,strong) UICollectionView *featuresView;

@property (nonatomic,strong) NSArray *dataSource;

@end

@implementation LSMorePannel

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = HEXRGB(0xd7d7d9);
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.offset(0.5);
        }];

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        self.layout = layout;
        layout.itemSize = CGSizeMake(50, 50);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        UICollectionView *featuresView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        featuresView.pagingEnabled = YES;
        self.featuresView = featuresView;
        featuresView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        featuresView.bounces = NO;
        featuresView.showsHorizontalScrollIndicator = NO;
        [featuresView registerClass:[LSFeatureCell class] forCellWithReuseIdentifier:reuse_id];
        featuresView.delegate = self;
        featuresView.dataSource = self;
        [self addSubview:featuresView];
        [featuresView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(lineView.mas_bottom);
        }];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSFeatureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_id forIndexPath:indexPath];
    
    LSFeatureModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(morePannelClickWithItem:)]) {
        LSFeatureModel *model = self.dataSource[indexPath.row];
        [self.delegate morePannelClickWithItem:model];
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat topMargin = 10;
    CGFloat itemH = (self.height-topMargin*2)*0.5;
    CGFloat itemW = 60;
    self.layout.itemSize = CGSizeMake(itemW, itemH);
    self.layout.minimumLineSpacing = 0;
    CGFloat margin = (self.width-itemW*4)/5;
    self.layout.minimumInteritemSpacing = margin;
    self.layout.sectionInset = UIEdgeInsetsMake(topMargin, margin, topMargin, margin);
    
    [self.featuresView reloadData];
}

#pragma mark - Getter & Setter 
- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [LSFeatureModel features];
    }
    return _dataSource;
}

@end

@implementation LSFeatureCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIImageView *imageView = [UIImageView new];
        self.imageView = imageView;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.equalTo(self);
            make.top.equalTo(self).offset(15);
            make.height.equalTo(imageView.mas_width);
        }];
        
        UILabel *titleLabel = [UILabel new];
        self.titleLabel = titleLabel;
        titleLabel.textColor = HEXRGB(0x888888);
        titleLabel.font = SYSTEMFONT(13);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.top.equalTo(imageView.mas_bottom);
        }];
    }
    return self;
}

- (void)setModel:(LSFeatureModel *)model {
    _model = model;
    
    self.imageView.image = [UIImage imageNamed:model.icon_name];
    self.titleLabel.text = model.title;
}

@end

@implementation LSFeatureModel

+ (instancetype)modelWithIcon:(NSString *)icon title:(NSString *)title {
    
    LSFeatureModel *model = [LSFeatureModel new];
    model.icon_name = icon;
    model.title = title;
    
    return model;
}

+ (NSArray<LSFeatureModel *> *)features {
    
    LSFeatureModel *model1 = [LSFeatureModel modelWithIcon:@"feature_ch_photos" title:@"照片"];
    LSFeatureModel *model2 = [LSFeatureModel modelWithIcon:@"feature_ch_camera" title:@"拍摄"];
    LSFeatureModel *model3 = [LSFeatureModel modelWithIcon:@"feature_ch_video" title:@"小视频"];
    LSFeatureModel *model4 = [LSFeatureModel modelWithIcon:@"feature_ch_red" title:@"红包"];
    LSFeatureModel *model5 = [LSFeatureModel modelWithIcon:@"feature_ch_card" title:@"个人名片"];
    LSFeatureModel *model6 = [LSFeatureModel modelWithIcon:@"feature_ch_collect" title:@"收藏"];

    return @[model1,model2,model3,model4,model5,model6];
}

@end
