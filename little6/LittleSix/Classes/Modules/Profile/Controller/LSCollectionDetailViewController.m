//
//  LSCollectionDetailViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/5/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSCollectionDetailViewController.h"
#import "LSCollectionViewController.h"
#import "YYPhotoGroupView.h"
#import "LSPlayerVideoView.h"
#import "NSString+Util.h"

static NSString * textReuse_id = @"LSCollectTextCell";
static NSString * imageReuse_id = @"LSCollectImageCell";
static NSString * videoReuse_id = @"LSCollectVideoCell";

@interface LSCollectionDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UITableView *tableView;

@end

@implementation LSCollectionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"收藏详情";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self createTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (self.model.type == 0) {
        return [NSString countingSize:self.model.text fontSize:15 width:kScreenWidth-80].height+60;
    }else {
        UIImageView * imageView = [UIImageView new];
        NSURL * url = [NSURL URLWithString:self.model.thum];
        [imageView setImageWithURL:url placeholder:timeLineBigPlaceholderName];
        
        UIImage *image = [[YYImageCache sharedCache] getImageForKey:url.absoluteString];
        return image.size.height > 150 ? image.size.height : 150;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * cell_reuse_id;
    if (self.model.type == 0) {
        cell_reuse_id = textReuse_id;
    }else if (self.model.type == 1){
        cell_reuse_id = imageReuse_id;
    }else{
        cell_reuse_id = videoReuse_id;
    }
    
    LSCollectBaseCell * cell = [tableView dequeueReusableCellWithIdentifier:cell_reuse_id];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dmodel = self.model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    //预览照片
    if (self.model.type == 1) {
        LSCollectImageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        NSMutableArray<YYPhotoGroupItem *> *items = [NSMutableArray array];
        
        YYPhotoGroupItem *item = [YYPhotoGroupItem new];
        item.largeImageURL = [NSURL URLWithString:self.model.thum];
        
        [items addObject:item];
        
        YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
        [v presentFromImageView:cell.bodyImage toContainer:[UIApplication sharedApplication].keyWindow animated:YES completion:nil];
        
    }else if(self.model.type == 2){
        
        NSURL * url = [NSURL URLWithString:self.model.thum];
        UIImageView * imageView = [UIImageView new];
        [imageView setImageWithURL:url placeholder:timeLineBigPlaceholderName];
        UIImage *image = [[YYImageCache sharedCache] getImageForKey:url.absoluteString];

        UIViewController * vc = [NSClassFromString(@"LSVideoPlayerViewController") new];
        [vc setValue:[NSURL URLWithString:self.model.url] forKey:@"playURL"];
        [vc setValue:image forKey:@"coverImage"];
        [self presentViewController:vc animated:YES completion:nil];
    }
    
}
#pragma mark - Getter & Setter
- (void)createTableView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView = tableView;
    
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerClass:[LSCollectTextCell class] forCellReuseIdentifier:textReuse_id];
    [tableView registerClass:[LSCollectImageCell class] forCellReuseIdentifier:imageReuse_id];
    [tableView registerClass:[LSCollectVideoCell class] forCellReuseIdentifier:videoReuse_id];
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
}

@end

