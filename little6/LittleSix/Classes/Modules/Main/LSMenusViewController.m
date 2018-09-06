//
//  LSMenusViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/4/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMenusViewController.h"
#import "MMDrawerController.h"
#import "AppDelegate.h"
#import "LSConversationModel.h"
#import "LSChatViewController.h"
#import "LSGroupModel.h"
#import "LSMessageManager.h"
#import "LSContactModel.h"

static NSString *const reuseid = @"LSMenuCell";

@interface LSMenusViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic, copy) NSString * friendsCount;

@end

@implementation LSMenusViewController

+ (void)load {
    
    //设置全局样式
    NSDictionary *attribute = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [[UINavigationBar appearance] setTitleTextAttributes:attribute];
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    UIImage *bgImage = [UIImage imageWithColor:kMainColor];
    [[UINavigationBar appearance] setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
    //隐藏导航条的线
    [UINavigationBar appearance].shadowImage = [UIImage new];
    //    [[UINavigationBar appearance] setTranslucent:NO];
    
    NSMutableDictionary *selectAtt = [NSMutableDictionary dictionary];
    selectAtt[NSFontAttributeName] = [UIFont boldSystemFontOfSize:10];
    selectAtt[NSForegroundColorAttributeName] = kMainColor;
    
    [[UITabBarItem appearance] setTitleTextAttributes:selectAtt forState:UIControlStateSelected];
    
    NSMutableDictionary *normalAttr = [NSMutableDictionary dictionary];
    normalAttr[NSFontAttributeName] = [UIFont boldSystemFontOfSize:10];
    normalAttr[NSForegroundColorAttributeName] = HEXRGB(0x9a9a9a);
    [[UITabBarItem appearance] setTitleTextAttributes:normalAttr forState:UIControlStateNormal];
    
    //设置UIBarbuttonItem的大小样式
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    NSMutableDictionary *itemAttr = [NSMutableDictionary dictionary];
    itemAttr[NSForegroundColorAttributeName] = [UIColor whiteColor];
    itemAttr[NSFontAttributeName] = SYSTEMFONT(16);
    [item setTitleTextAttributes:itemAttr forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setMessageUnReadCount];
    [self friendslogCount];
}

- (void)setMessageUnReadCount {
    //设置未读消息
    NSInteger unReadCount = [LSMessageManager totalUnReadCount];
    
    LSMenusItem *messageItem = self.items.firstObject;
    if (![messageItem.title isEqualToString:@"消息"]) {
        messageItem = self.items[1];
    }
    
    NSInteger idx = [self.items indexOfObject:messageItem];
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
    LSMenuCell *cell = [self.tableView cellForRowAtIndexPath:idxPath];
    
    cell.notiView.hidden = !(unReadCount>0);
}

- (void)friendslogCount {
    [LSContactModel friendslogCountSuccess:^(NSString *messageCount) {
        self.friendsCount = messageCount;
        [self setFriendUnReadCount];
    } failure:nil];
}

- (void)setFriendUnReadCount {
    //设置通讯录未读消息
    
    LSMenusItem *messageItem = self.items[1];
    if (![messageItem.title isEqualToString:@"通讯录"]) {
        messageItem = self.items[2];
    }
    
    NSInteger idx = [self.items indexOfObject:messageItem];
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
    LSMenuCell *cell = [self.tableView cellForRowAtIndexPath:idxPath];
    
    cell.notiView.hidden = !([self.friendsCount intValue]>0);
}

- (void)registNotification {
    
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kInReviewNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        self.items = nil;
        [self.tableView reloadData];
        //显示中心控制器
        [self showCenterViewController:self.selectItem complete:nil];
    }];

    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kSendMessageNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        //切换到消息
        LSMenusItem *item = self.items.firstObject;
        if (![item.title isEqualToString:@"消息"]) {
            item = self.items[1];
        }
        
        self.selectItem = item;
        
        [self showCenterViewController:self.selectItem complete:^{
            //跳转到
            LSConversationModel *model = x.object;
            //是好友到聊天界面
            LSChatViewController *chatVC = [[LSChatViewController alloc] initWithConversation:model];
            
            MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *naviVC = (UINavigationController *)drawerController.centerViewController;

            [naviVC pushViewController:chatVC animated:YES];
        }];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kSendGroupMessageNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        //切换到消息
        LSMenusItem *item = self.items.firstObject;
        if (![item.title isEqualToString:@"消息"]) {
            item = self.items[1];
        }
        
        self.selectItem = item;
        
        [self showCenterViewController:self.selectItem complete:^{
            //跳转到
            LSGroupModel *gmodel = x.object;
            LSConversationModel *model = [LSConversationModel new];
            model.type = LSConversationTypeGroup;
            model.conversationId = gmodel.groupid;
            model.title = gmodel.name;
            model.avartar = gmodel.snap;
            
            MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *naviVC = (UINavigationController *)drawerController.centerViewController;
            
            //是好友到聊天界面
            LSChatViewController *chatVC = [[LSChatViewController alloc] initWithConversation:model];
            [naviVC pushViewController:chatVC animated:YES];
        }];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kMessageUnReadCountDidChange object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        kDISPATCH_MAIN_THREAD(^{
            [self setMessageUnReadCount];
        })
    }];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseid];
    
    cell.item = self.items[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSMenusItem *newItem = self.items[indexPath.row];
    
    if ([self.selectItem isEqual:newItem]) {
        MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        return;
    }
    
    self.selectItem = newItem;
    
    [self showCenterViewController:newItem complete:nil];
}

- (void)showCenterViewController:(LSMenusItem *)newItem complete:(void(^)(void))block {
    //控制器切换
    if (newItem.storyboard) {
        
        UIViewController *vc = [[UIStoryboard storyboardWithName:newItem.storyboard bundle:nil] instantiateInitialViewController];
        
        //添加阴影view
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [vc.view addSubview:delegate.shadowView];
        [delegate.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(vc.view);
        }];
        
        MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [drawerController setCenterViewController:vc withCloseAnimation:YES completion:^(BOOL finished) {
            !block ? : block();
        }];
    }
    else {
        UIViewController *rootVC = [newItem.cls new];
        UINavigationController *centerNaviVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
        
        //添加阴影view
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [centerNaviVC.view addSubview:delegate.shadowView];
        [delegate.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(centerNaviVC.view);
        }];
        
        MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [drawerController setCenterViewController:centerNaviVC withCloseAnimation:YES completion:^(BOOL finished) {
            !block ? : block();
        }];
    }
}

#pragma mark - Getter & Setter 
- (UITableView *)tableView {
    if (!_tableView) {
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 60;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [tableView registerClass:[LSMenuCell class] forCellReuseIdentifier:reuseid];
        
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        LSMenuHeaderView *headerView = [LSMenuHeaderView new];
        headerView.height = 188;
        tableView.tableHeaderView = headerView;
        
        tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (void)setSelectItem:(LSMenusItem *)selectItem {
    
    _selectItem.selected = NO;
    _selectItem = selectItem;
    _selectItem.selected = YES;
    
    [self.tableView reloadData];
}

- (NSArray *)items {
    if (!_items) {
        
        LSMenusItem *item1 = [LSMenusItem itemWith:@"寻宝" normalIcon:@"menu_game" heightlightIcon:@"menu_game-click" class:NSClassFromString(@"LSFuwaHomeViewController") storyboard:nil];
        LSMenusItem *item2 = [LSMenusItem itemWith:@"消息" normalIcon:@"menu_new" heightlightIcon:@"menu_new-click" class:nil storyboard:@"Chat"];
        LSMenusItem *item3 = [LSMenusItem itemWith:@"通讯录" normalIcon:@"menu_address" heightlightIcon:@"menu_address-click" class:nil storyboard:@"Contact"];
        LSMenusItem *item4 = [LSMenusItem itemWith:@"人脉" normalIcon:@"menu_connection" heightlightIcon:@"menu_connection-click" class:nil storyboard:@"LinkIn"];
        LSMenusItem *item5 = [LSMenusItem itemWith:@"发现" normalIcon:@"menu_find" heightlightIcon:@"menu_find-click" class:nil storyboard:@"Discover"];
        LSMenusItem *item6 = [LSMenusItem itemWith:@"个人中心" normalIcon:@"menu_personal" heightlightIcon:@"menu_personal-click" class:nil storyboard:@"Profile"];

        if ([LSAppManager isInReview]) {
            _items = @[item2,item3,item4,item5,item6];
            self.selectItem = item2;
        }
        else {
            _items = @[item1,item2,item3,item4,item5,item6];
            self.selectItem = item1;
        }
    }
    return _items;
}

@end

@implementation LSMenusItem

+ (instancetype)itemWith:(NSString *)title normalIcon:(NSString *)iconN heightlightIcon:(NSString *)iconH class:(Class)cls storyboard:(NSString *)storyboard{
    
    LSMenusItem *item = [LSMenusItem new];
    item.title = title;
    item.iconN = iconN;
    item.iconH = iconH;
    item.cls = cls;
    item.storyboard = storyboard;
    
    return item;
}

@end

@implementation LSMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.itemButton = itemButton;
        itemButton.userInteractionEnabled = NO;
        itemButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        itemButton.titleLabel.font = SYSTEMFONT(15);
        itemButton.contentEdgeInsets = UIEdgeInsetsMake(0, 25, 0, 0);
        itemButton.titleEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);

        [itemButton setTitleColor:HEXRGB(0x333333) forState:UIControlStateNormal];
        [itemButton setTitleColor:HEXRGB(0xf69600) forState:UIControlStateSelected];
        
        [self addSubview:itemButton];
        [itemButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UIView *notiView = [UIView new];
        self.notiView = notiView;
        notiView.backgroundColor = HEXRGB(0xd42136);
        [self addSubview:notiView];
        [notiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-30);
            make.width.height.offset(10);
        }];
        ViewRadius(notiView, 5);
        
        notiView.hidden = YES;
    }
    
    return self;
}

- (void)setItem:(LSMenusItem *)item {
    _item = item;
    
    UIImage *imageN = [UIImage imageNamed:item.iconN];
    UIImage *imageH = [UIImage imageNamed:item.iconH];
    
    [self.itemButton setImage:imageN forState:UIControlStateNormal];
    [self.itemButton setImage:imageH forState:UIControlStateSelected];
    
    [self.itemButton setTitle:item.title forState:UIControlStateNormal];
    
    self.itemButton.selected = item.selected;
    
    self.notiView.hidden = YES;
}

@end

@implementation LSMenuHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        UIImageView *iconView = [UIImageView new];
        iconView.contentMode = UIViewContentModeScaleAspectFill;
        [iconView setImageURL:[NSURL URLWithString:ShareAppManager.loginUser.avatar]];
        
        ViewRadius(iconView, 75*0.5);
        
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.offset(50);
            make.width.height.offset(75);
        }];
        
        UILabel *nameLabel = [UILabel new];
        nameLabel.font = SYSTEMFONT(15);
        nameLabel.textColor = HEXRGB(0x333333);
        nameLabel.text = ShareAppManager.loginUser.user_name;
        
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(iconView.mas_bottom).offset(10);
        }];
        
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kUserInfoChangeNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
            kDISPATCH_MAIN_THREAD(^{
                nameLabel.text = ShareAppManager.loginUser.user_name;
                [iconView setImageURL:[NSURL URLWithString:ShareAppManager.loginUser.avatar]];
            })
        }];
        
    }
    return self;
}

@end


