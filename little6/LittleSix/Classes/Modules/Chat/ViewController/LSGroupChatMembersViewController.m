//
//  LSGroupChatMembersViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/6/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSGroupChatMembersViewController.h"
#import "LSContactDetailViewController.h"
#import "LSGroupChatCell.h"
#import "LSGroupModel.h"

static NSString * identifier = @"GroupChat";

@interface LSGroupChatMembersViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)UICollectionView * collectionView;

@end

@implementation LSGroupChatMembersViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self queryGroup];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initmemberUI];
    
}

- (void)initmemberUI {

    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 1;
    flowLayout.minimumLineSpacing = 2;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LSGroupChatCell"
                                                    bundle:nil]
          forCellWithReuseIdentifier:identifier];     // 通过xib创建cell
    
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.left.right.equalTo(self.view);
    }];
}

- (void)queryGroup {
    
    [LSGroupModel queryGroupWithGroupid:self.gmodel.groupid success:^(LSGroupModel * model) {
        
        self.list = model.members;
        self.title = [NSString stringWithFormat:@"群成员(%ld)",self.list.count];
        [self.collectionView reloadData];
        
    } failure:nil];
}

//#pragma mark - 定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [self.userId isEqualToString:ShareAppManager.loginUser.user_id] ? self.list.count+2 : self.list.count+1;
    
}

#pragma mark - 定义展示的Section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

#pragma mark - 每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LSGroupChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row<self.list.count) {
        LSMembersModel * model = self.list[indexPath.row];
        cell.model = model;
        
    }else if(indexPath.row == self.list.count){
        
        cell.headerImage.image = [UIImage imageNamed:@"timeline_add_photos"];
        cell.nameLabel.text = @"";
    }else{
        
        cell.headerImage.image = [UIImage imageNamed:@"reduce"];
        cell.nameLabel.text = @"";
    }
    
    
    return cell;
}
#pragma mark - UICollectionViewDelegateFlowLayout 定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(kScreenWidth/5-5, 80);//kScreenWidth/5+10
}

#pragma mark - 定义每个UICollectionView 的 margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == self.list.count) {
        
        UIViewController *vc = [NSClassFromString(@"LSSelectContactViewController") new];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
        [vc setValue:self.gmodel.groupid forKey:@"groupid"];
        [vc setValue:@(1) forKey:@"type"];
        [self presentViewController:naviVC animated:YES completion:nil];
        
    }else if (indexPath.row == self.list.count+1){
        
        UIViewController *vc = [NSClassFromString(@"LSSelectGroupViewController") new];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
        [vc setValue:self.gmodel.groupid forKey:@"groupid"];
        [vc setValue:self.list forKey:@"listArr"];
        [self presentViewController:naviVC animated:YES completion:nil];
        
    }else{
        
        LSMembersModel * model = self.list[indexPath.row];
        LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
        lsvc.user_id = model.userid;
        
        [self.navigationController pushViewController:lsvc animated:YES];
    }
}

@end
