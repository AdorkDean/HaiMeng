//
//  LSChatMessagesTableController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/23.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSChatMessagesTableController.h"
#import "LSContactDetailViewController.h"
#import "LSConversationModel.h"
#import "LSMessageManager.h"
#import "LSGroupChatCell.h"
#import "UIView+HUD.h"
#import "LSPersonsModel.h"

static NSString * reuse_id = @"PersonsChat";
static NSString * identifier = @"GroupChat";

@interface LSChatMessagesTableController ()<LSPersonsChatTableViewCellDelegate>

@property (retain, nonatomic) NSMutableArray * dataSorce;

@end

@implementation LSChatMessagesTableController

- (NSMutableArray *)dataSorce {

    if (!_dataSorce) {
        _dataSorce = [NSMutableArray array];
    }
    return _dataSorce;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self queryPersons];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"聊天信息";
    
    [self.tableView registerClass:NSClassFromString(@"LSPersonsChatTableViewCell") forCellReuseIdentifier:reuse_id];
}

- (void)queryPersons {
    
    [LSPersonsModel personerWithUser_id:self.user_id success:^(LSPersonsModel *model) {
        
        [self.dataSorce removeAllObjects];
        [self.dataSorce addObject:model];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    LSPersonsChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id forIndexPath:indexPath];
    cell.delegate = self;
    cell.list = self.dataSorce;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0.1;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        if ((self.dataSorce.count+1)%5 == 0) {
            return (self.dataSorce.count+1)/5*90;
        }else{
            return ((self.dataSorce.count+1)/5+1)*90;
        }
        
    }else if(indexPath.section == 6){
        
        return 80;
    }else{
        
        return 45;
    }
}

- (void)didClickRow:(NSIndexPath *)indexPath withArr:(NSArray *)list {
    
    if (indexPath.row == list.count) {
        
        UIViewController *vc = [NSClassFromString(@"LSSelectContactViewController") new];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:naviVC animated:YES completion:nil];
        
    }else{
        
        LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
        lsvc.user_id = self.user_id;
        
        [self.navigationController pushViewController:lsvc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 2) {
        [self.view showAlertWithTitle:@"提示" message:@"您要清空聊天数据吗？" cancelAction:nil doneAction:^{
            [LSMessageManager deleteConversation:self.conversation];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRemoveMessagesInConversation object:nil];
        }];
    }
    else if (indexPath.section == 3) {
        UIViewController *reportVC = [NSClassFromString(@"WeiboReportViewController") new];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:reportVC];
        
        [self presentViewController:naviVC animated:YES completion:nil];
    }
}

@end

@interface LSPersonsChatTableViewCell ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,retain)UICollectionView * collectionView;

@end

@implementation LSPersonsChatTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
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
        
        
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        
    }
    return self;
}

- (void)setList:(NSArray *)list {
    
    _list = list;
    
    [self.collectionView reloadData];
}

//#pragma mark - 定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.list.count+1;
}

#pragma mark - 定义展示的Section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

#pragma mark - 每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LSGroupChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row<self.list.count) {
        LSPersonsModel * model = self.list[indexPath.row];
        cell.personModel = model;
        
    }else{
        
        cell.headerImage.image = [UIImage imageNamed:@"timeline_add_photos"];
        cell.nameLabel.text = @"";
    }
    
    
    return cell;
}
#pragma mark - UICollectionViewDelegateFlowLayout 定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(kScreenWidth/5-5, 80);
}

#pragma mark - 定义每个UICollectionView 的 margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickRow:withArr:)]) {
        [self.delegate didClickRow:indexPath withArr:self.list];
    }
}



@end
