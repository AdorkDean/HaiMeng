//
//  LSPhotoContainerView.m
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPhotoContainerView.h"
#import "LSLinkInCellModel.h"
#import "UIView+SDAutoLayout.h"
#import "LSLinkInCellModel.h"
#import "YYPhotoGroupView.h"

@interface LSPhotoContainerView(){

    UIImageView * _iconImage;
}

@property (nonatomic, strong) NSArray *imageViewsArray;
@property (nonatomic, strong) NSMutableArray * bigImageArray;
//@property (nonatomic, strong) UIImageView * adapterImage;
@property (nonatomic, strong) NSMutableArray *file_thumbArr;
@property (nonatomic, strong) NSMutableArray *file_urlArr;

@end

@implementation LSPhotoContainerView

- (NSMutableArray *)bigImageArray {

    if (!_bigImageArray) {
        _bigImageArray = [NSMutableArray array];
    }
    return _bigImageArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    NSMutableArray *temp = [NSMutableArray new];
    
    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = [UIImageView new];
        [self addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:tap];
        [temp addObject:imageView];
    }
    UIImageView *imageView = [temp objectAtIndex:0];
    _iconImage = [UIImageView new];
    _iconImage.tag = 10001;
    
    [imageView addSubview:_iconImage];
    [_iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(50);
        make.center.equalTo(imageView);
    }];
    self.imageViewsArray = [temp copy];
}

-(void)setModel:(LSLinkInCellModel *)model {

    _model = model;
    
    if (self.model.feed_type == 2) {
        _iconImage.image = [UIImage imageNamed:@"play"];
    }else{
        _iconImage.image = [UIImage imageNamed:@""];
        
    }
    
}


- (void)setPicPathStringsArray:(NSArray *)picPathStringsArray {
    
    _picPathStringsArray = [NSMutableArray arrayWithArray:picPathStringsArray];
    
    NSMutableArray * photoArr = [NSMutableArray array];
    [self.bigImageArray removeAllObjects];
    for (LSLinkInFileModel * model in picPathStringsArray) {
        
        if([model.file_thumb rangeOfString:@"jpeg"].location != NSNotFound || [model.file_thumb rangeOfString:@"jpg"].location != NSNotFound )
        {
            [photoArr addObject:model.file_thumb];
            [self.bigImageArray addObject:model.file_url];
        }
    }
    
    _picPathStringsArray = photoArr;
    
    for (long i = _picPathStringsArray.count; i < self.imageViewsArray.count; i++) {
        UIImageView *imageView = [self.imageViewsArray objectAtIndex:i];
        imageView.hidden = YES;
    }
    
    if (_picPathStringsArray.count == 0) {
        self.height = 0;
        self.fixedHeight = @(0);
        return;
    }
    
    CGFloat itemW = [self itemWidthForPicPathArray:_picPathStringsArray];
    CGFloat itemH = 0;
    if (_picPathStringsArray.count == 1) {
        
        UIImageView * imageView = [UIImageView new];
        NSURL * url = [NSURL URLWithString:_picPathStringsArray.firstObject];
        [imageView setImageWithURL:url placeholder:timeLineBigPlaceholderName];
        
        UIImage *image = [[YYImageCache sharedCache] getImageForKey:url.absoluteString];
        if (!image) {
            NSData *data = [NSData dataWithContentsOfURL:url];
            image = [UIImage imageWithData:data];
        }
        //根据image的比例来设置高度
        if (image.size.width) {
            itemH = image.size.height / image.size.width * itemW;
            if (itemH >= itemW) {
                itemW = 120;
                itemH = image.size.height / image.size.width * itemW;
            }
        }
        
    } else {
        itemH = itemW;
    }
    long perRowItemCount = [self perRowItemCountForPicPathArray:_picPathStringsArray];
    CGFloat margin = 5;
    
    [_picPathStringsArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        long columnIndex = idx % perRowItemCount;
        long rowIndex = idx / perRowItemCount;
        UIImageView *imageView = [_imageViewsArray objectAtIndex:idx];
        imageView.hidden = NO;
        imageView.contentMode = UIViewContentModeScaleToFill;
        [imageView setImageWithURL:[NSURL URLWithString:obj] placeholder:timeLineSmallPlaceholderName];
        imageView.frame = CGRectMake(columnIndex * (itemW + margin), rowIndex * (itemH + margin), itemW, itemH);
        
    }];
    
    CGFloat w = perRowItemCount * itemW + (perRowItemCount - 1) * margin;
    int columnCount = ceilf(_picPathStringsArray.count * 1.0 / perRowItemCount);
    CGFloat h = columnCount * itemH + (columnCount - 1) * margin;
    self.width = w;
    self.height = h;
    
    self.fixedHeight = @(h);
    self.fixedWith = @(w);
}

#pragma mark - private actions

- (void)tapImageView:(UITapGestureRecognizer *)tap {
    
    if (self.model.feed_type == 2) {
        //播放视频
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickVideo:)]) {
            [self.delegate didClickVideo:self.model.files[0]];
        }
        
    }else{
        //预览照片
        UIView *imageView = tap.view;
        NSMutableArray<YYPhotoGroupItem *> *items = [NSMutableArray array];
        
        for (int i = 0; i<self.bigImageArray.count; i++) {
            YYPhotoGroupItem *item = [YYPhotoGroupItem new];
            item.largeImageURL = [NSURL URLWithString:self.bigImageArray[i]];
            item.thumbView = [self viewWithTag:i];
            [items addObject:item];
        }
        
        YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
        
        [v presentFromImageView:imageView toContainer:[UIApplication sharedApplication].keyWindow animated:YES completion:nil];
    }
    
}

- (CGFloat)itemWidthForPicPathArray:(NSArray *)array {
    
    if (array.count == 1) {
        return 120;
    } else {
        CGFloat w = [UIScreen mainScreen].bounds.size.width > 320 ? 80 : 70;
        return w;
    }
}

- (NSInteger)perRowItemCountForPicPathArray:(NSArray *)array {
    
    if (array.count < 3) {
        return array.count;
    } else if (array.count <= 4) {
        return 2;
    } else {
        return 3;
    }
}


@end
