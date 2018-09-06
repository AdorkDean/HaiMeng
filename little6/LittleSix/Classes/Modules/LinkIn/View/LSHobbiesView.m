//
//  LSHobbiesView.m
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSHobbiesView.h"
#import "LSHobbiesCollectionCell.h"
#import "LSHobbieModel.h"

@interface LSHobbiesView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIView *outSideView;
@property (weak, nonatomic) IBOutlet UIView *inSideView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (retain, nonatomic) UICollectionView *collectionView;

@property (retain,nonatomic) UILabel * titleLable;
@property (retain,nonatomic) UILabel * suTitleLabel;

@property (retain,nonatomic) NSMutableArray * dataArray;

@end

@implementation LSHobbiesView

-(NSMutableArray *)dataArray{

    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

+(instancetype)chooseMainV{
    
    return [[[NSBundle mainBundle] loadNibNamed:@"LSHobbiesView" owner:nil options:nil] lastObject];
}

-(void)showInView:(UIViewController *)view WithBlock:(void(^)(NSArray *list))sureBlock{
    
    
    self.frame = CGRectMake(0, 0,kScreenWidth , kScreenHeight);
    
    [view.navigationController.view addSubview:self];
    ViewRadius(self.outSideView,20);
    ViewRadius(self.saveBtn, 23);
    
    self.sureBlock = sureBlock;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [self.inSideView addGestureRecognizer:tap];
    [self initSourceData];
    
    [self setCollectionView];
}

-(void)initSourceData{

    [LSHobbieModel hobbieWithlistToken:ShareAppManager.loginUser.access_token success:^(NSArray * list) {
        
        [self.dataArray addObjectsFromArray:list];
        
        
        [self.collectionView reloadData];
        
    } failure:^(NSError *errer) {
        
    }];
}

-(void)setCollectionView{

    self.titleLable = [UILabel new];
    self.titleLable.font = [UIFont systemFontOfSize:18];
    self.titleLable.textAlignment = NSTextAlignmentCenter;
    self.titleLable.text = @"选择你的兴趣爱好";
    [self.outSideView addSubview:self.titleLable];
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.outSideView.mas_top).offset(20);
        make.left.equalTo(self.outSideView.mas_left).offset(20);
        make.right.equalTo(self.outSideView.mas_right).offset(-20);
        make.height.equalTo(@(20));
    }];
    
    self.suTitleLabel = [UILabel new];
    self.suTitleLabel.font = [UIFont systemFontOfSize:15];
    self.suTitleLabel.textColor = [UIColor blackColor];
    self.suTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.outSideView addSubview:self.suTitleLabel];
    self.suTitleLabel.text = @"(最多可选择3个)";
    [self.suTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLable.mas_bottom).offset(5);
        make.left.equalTo(self.outSideView.mas_left).offset(20);
        make.right.equalTo(self.outSideView.mas_right).offset(-20);
        make.height.equalTo(@(20));
    }];
    UIView * tagView = [UIView new];
    [self.outSideView addSubview:tagView];
    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.suTitleLabel.mas_bottom).offset(5);
        make.left.equalTo(self.outSideView.mas_left).offset(0);
        make.right.equalTo(self.outSideView.mas_right).offset(0);
        make.bottom.equalTo(self.saveBtn.mas_top).offset(-10);
    }];
    
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 1;
    flowLayout.minimumLineSpacing = 2;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LSHobbiesCollectionCell"
                                                    bundle:nil]
          forCellWithReuseIdentifier:@"LSHobbiesCell"];     // 通过xib创建cell
    [self.outSideView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.suTitleLabel.mas_bottom).offset(5);
        make.bottom.equalTo(self.saveBtn.mas_top).offset(-10);
        make.left.equalTo(self.outSideView.mas_left).offset(20);
        make.right.equalTo(self.outSideView.mas_right).offset(-20);
    }];
}

- (IBAction)saveClick:(UIButton *)sender {
    
    NSMutableArray * arr = [NSMutableArray array];
    for (LSHobbieModel * model in self.dataArray) {
        
        if (model.select_id == 1) {
            NSLog(@"%@",model.tag_name);
            [arr addObject:model];
        }
    }
    if (self.sureBlock) {
        self.sureBlock(arr);
    }
    [self removeFromSuperview];
    
}
-(void)tapClick:(UITapGestureRecognizer *)tap {

    [self removeFromSuperview];
}
#pragma mark - 定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

#pragma mark - 定义展示的Section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

#pragma mark - 每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * identifier = @"LSHobbiesCell";
    LSHobbiesCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    LSHobbieModel * model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.dataArray = self.dataArray;
    return cell;
}



#pragma mark - UICollectionViewDelegateFlowLayout 定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(self.outSideView.frame.size.width/3-30, 50);
}

#pragma mark - 定义每个UICollectionView 的 margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(1, 1, 1, 1);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

//    LSHobbiesCollectionCell *cell = (LSHobbiesCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//    cell.titleLable.backgroundColor = [UIColor lightGrayColor];
    
}



@end
