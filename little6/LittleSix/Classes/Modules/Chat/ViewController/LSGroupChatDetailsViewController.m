//
//  LSGroupChatDetailsViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSGroupChatDetailsViewController.h"
#import "LSContactDetailViewController.h"
#import "LSConversationModel.h"
#import "LSChangeNameViewController.h"
#import "LSPersonCodeView.h"
#import "LSGroupChatCell.h"
#import "LSGroupModel.h"
#import "LSMessageManager.h"
#import "UIView+HUD.h"

static NSString * reuse_id = @"GroupChatTableViewCell";
static NSString * identifier = @"GroupChat";


@interface LSGroupChatDetailsViewController ()<LSGroupChatTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@end

@implementation LSGroupChatDetailsViewController

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    [self queryGroup];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群聊";
    [self.tableView registerClass:NSClassFromString(@"GroupChatTableViewCell") forCellReuseIdentifier:reuse_id];
    self.nickNameLabel.text = ShareAppManager.loginUser.user_name;
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    self.tableView.tableFooterView = footerView;
    
    UIButton * bottom = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottom setTitle:@"删除并退出" forState:UIControlStateNormal];
    [bottom setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bottom addTarget:self action:@selector(bootomClick:) forControlEvents:UIControlEventTouchUpInside];
    bottom.backgroundColor = [UIColor redColor];
    [footerView addSubview:bottom];
    ViewRadius(bottom,5);
    [bottom mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.offset(20);
        make.right.offset(-20);
        make.height.equalTo(@(40));
        make.centerY.equalTo(footerView);
    }];
    
}

- (void)bootomClick:(UIButton *)sender {

    @weakify(self)
    [LSKeyWindow showAlertWithTitle:@"提示" message:@"你确定要退出这个群吗？" cancelAction:^{
        
    } doneAction:^{
        @strongify(self)
        [self removeMembers:ShareAppManager.loginUser.user_id withType:1];
    }];
    
}

- (void)queryGroup {

    [LSGroupModel queryGroupWithGroupid:self.groupid success:^(LSGroupModel * model) {

        self.gmodel = model;
        self.title = model.name;
        self.groupName.text = model.name;
        [self.tableView reloadData];
        
    } failure:^(NSError * error){
        [self.view showErrorWithError:error];
    }];
}


- (IBAction)switchClick:(UISwitch *)sender {

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 2;
            break;
        case 3:
            return 2;
            break;
        case 4:
            return 2;
            break;
        
        default:
            break;
    }
    return 0;
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
        
        if (self.gmodel.members.count < 29) {
            if ([self.gmodel.creator isEqualToString:ShareAppManager.loginUser.user_id]) {
                if ((self.gmodel.members.count+2)%5 == 0) {
                    return (self.gmodel.members.count+2)/5*90;
                }else{
                    return ((self.gmodel.members.count+2)/5+1)*90;
                }
            }else {
                
                if ((self.gmodel.members.count+1)%5 == 0) {
                    return (self.gmodel.members.count+1)/5*90;
                }else{
                    return ((self.gmodel.members.count+1)/5+1)*90;
                }
            }
        }else {
        
            return 30/5*90+20;
        }
    
    }else if(indexPath.section == 6){
        return 80;
    }else{
        return 45;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section != 0) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    GroupChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id forIndexPath:indexPath];
    cell.delegate = self;
    cell.userId = self.gmodel.creator;
    cell.list = self.gmodel.members;
    [cell setNextClick:^(NSArray * list){
        
        UIViewController * gcmVc = [NSClassFromString(@"LSGroupChatMembersViewController") new];
        [gcmVc setValue:self.gmodel forKey:@"gmodel"];
        [gcmVc setValue:self.gmodel.creator forKey:@"userId"];
        [self.navigationController pushViewController:gcmVc animated:YES];
    }];
    
    return cell;
    
}

- (void)removeMembers:(NSString *)members withType:(int)type{
    
    [LSGroupModel removeMembersWithGroupid:self.gmodel.groupid members:members success:^(NSString *message) {
        
        [self.view showSucceed:message hideAfterDelay:1.5];
        if (type == 1) {
            [LSMessageManager deleteConversation:self.conversation];
            self.tabBarController.selectedIndex = 0;
            [self.navigationController popToRootViewControllerAnimated:NO];
        }else{
            [self queryGroup];
        }
        
    } failure:^(NSError *error) {
        [self.view showError:@"退出失败" hideAfterDelay:1.5];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            LSChangeNameViewController * cnVc = [[LSChangeNameViewController alloc] init];
            cnVc.groupid = self.gmodel.groupid;
            cnVc.name = self.gmodel.name;
            cnVc.notic = self.gmodel.notice;
            if (indexPath.row == 0) {
                cnVc.type = 1;
            }else if (indexPath.row == 2){
                cnVc.type = 0;
            }
            @weakify(self)
            [cnVc setSureClick:^(NSString * name,NSInteger type) {
                @strongify(self)
                if (type == 1) {
                    self.groupName.text = name;
                    self.conversation.title = name;
                    [LSMessageManager syncConversations];
                }else {
                    self.describeLabel.text = name;
                }
            }];
            [self.navigationController pushViewController:cnVc animated:YES];
            
        }else if(indexPath.row == 1){
        
            [[LSPersonCodeView personCodeView] showInView:self.navigationController.view andType:@"gid" andUser_id:self.gmodel.groupid withAvatar:self.gmodel.snap withUser_name:self.gmodel.name withSex:@"" withDistrict_str:@"" enter:1];
            
        }
        
    }else if(indexPath.section == 4){
    
        if (indexPath.row == 0) {
            [self.view showAlertWithTitle:@"提示" message:@"您要清空聊天数据吗？" cancelAction:nil doneAction:^{
                [LSMessageManager deleteConversation:self.conversation];
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemoveMessagesInConversation object:nil];
            }];
        }
        else {
            UIViewController *reportVC = [NSClassFromString(@"WeiboReportViewController") new];
            UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:reportVC];
        
            [self presentViewController:naviVC animated:YES completion:nil];
        }
        
    }
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didClickRow:(NSIndexPath *)indexPath withArr:(NSArray *)list {
    
    if ([self.gmodel.creator isEqualToString:ShareAppManager.loginUser.user_id]) {
        if (list.count < 29) {
            [self selectIndexPath:indexPath withArr:list];
        }else {
            switch (indexPath.row) {
                case 28:
                    [self selectContact];
                    break;
                case 29:
                    [self selectGroup:list];
                    break;
                default:
                {
                    LSMembersModel * model = list[indexPath.row];
                    [self contactDetail:model.userid];
                }
                    break;
            }
        }
    }else {
        if (list.count < 30) {
            [self selectIndexPath:indexPath withArr:list];
        }else {
            if (indexPath.row == 29) {
                [self selectContact];
            }else{
                
                LSMembersModel * model = list[indexPath.row];
                [self contactDetail:model.userid];
            }
        }
    }
}

- (void)selectIndexPath:(NSIndexPath *)indexPath withArr:(NSArray *)list {

    if (indexPath.row == list.count) {
        [self selectContact];
    }else if (indexPath.row == list.count+1){
        [self selectGroup:list];
    }else{
        LSMembersModel * model = list[indexPath.row];
        [self contactDetail:model.userid];
    }
}

- (void)selectContact {

    UIViewController *vc = [NSClassFromString(@"LSSelectContactViewController") new];
    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [vc setValue:self.gmodel.groupid forKey:@"groupid"];
    [vc setValue:@(1) forKey:@"type"];
    [self presentViewController:naviVC animated:YES completion:nil];
}

- (void)selectGroup:(NSArray *)list {

    UIViewController *vc = [NSClassFromString(@"LSSelectGroupViewController") new];
    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [vc setValue:self.gmodel.groupid forKey:@"groupid"];
    [vc setValue:list forKey:@"listArr"];
    [self presentViewController:naviVC animated:YES completion:nil];
}

- (void)contactDetail:(NSString *)userId {

    LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
    lsvc.user_id = userId;
    
    [self.navigationController pushViewController:lsvc animated:YES];
}

@end

@interface GroupChatTableViewCell ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)UICollectionView * collectionView;
@property (nonatomic,strong)UIButton * footerView;
@end

@implementation GroupChatTableViewCell

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
        
        UIButton * footerView = [UIButton buttonWithType:UIButtonTypeCustom];
        [footerView setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [footerView setTitle:@"查看更多群成员>>" forState:UIControlStateNormal];
        footerView.titleLabel.font = [UIFont systemFontOfSize:17];
        self.footerView = footerView;
        footerView.hidden = YES;
        [self addSubview:footerView];
        [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.bottom.left.right.equalTo(self);
            make.height.offset (50);
        }];
        
        @weakify(self)
        [[footerView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            
            if (self.nextClick) {
                self.nextClick(self.list);
            }
        }];
    }
    return self;
}

- (void)setList:(NSArray *)list {
    
    _list = list;
    
    [self.collectionView reloadData];
}

- (void)setUserId:(NSString *)userId {

    _userId = userId;
    
    [self.collectionView reloadData];
}

//#pragma mark - 定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (self.list.count < 29) {
        self.footerView.hidden = YES;
        return [self.userId isEqualToString:ShareAppManager.loginUser.user_id] ? self.list.count+2 : self.list.count+1;
    }else {
        self.footerView.hidden = NO;
        return [self.userId isEqualToString:ShareAppManager.loginUser.user_id] ? 28+2 : 29+1;
    }
    
}

#pragma mark - 定义展示的Section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

#pragma mark - 每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LSGroupChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSInteger counts = [self.userId isEqualToString:ShareAppManager.loginUser.user_id] ? 28 : 29;
    
    if (self.list.count < 29) {
        if (indexPath.row<self.list.count) {
            LSMembersModel * model = self.list[indexPath.row];
            cell.model = model;
            @weakify(self)
            [cell setDelectClick:^(NSString * members) {
                @strongify(self)
                if (self.removeClick) {
                    self.removeClick(members);
                }
            }];
            
        }else if(indexPath.row == self.list.count){
            
            cell.headerImage.image = [UIImage imageNamed:@"timeline_add_photos"];
            cell.nameLabel.text = @"";
        }else{
            
            cell.headerImage.image = [UIImage imageNamed:@"reduce"];
            cell.nameLabel.text = @"";
        }
    }else {
    
        if (indexPath.row < counts) {
            LSMembersModel * model = self.list[indexPath.row];
            cell.model = model;
            @weakify(self)
            [cell setDelectClick:^(NSString * members) {
                @strongify(self)
                if (self.removeClick) {
                    self.removeClick(members);
                }
            }];
            
        }else if(indexPath.row == counts){
            
            cell.headerImage.image = [UIImage imageNamed:@"timeline_add_photos"];
            cell.nameLabel.text = @"";
        }else{
            
            cell.headerImage.image = [UIImage imageNamed:@"reduce"];
            cell.nameLabel.text = @"";
        }
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

    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickRow:withArr:)]) {
        [self.delegate didClickRow:indexPath withArr:self.list];
    }
}

@end

