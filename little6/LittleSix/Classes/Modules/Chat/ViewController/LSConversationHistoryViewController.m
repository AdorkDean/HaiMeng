//
//  LSConversationHistoryViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSConversationHistoryViewController.h"
#import "LSConversationHistoryCell.h"
#import "PopoverView.h"
#import "LSMessageManager.h"
#import "NSString+Util.h"
#import "LSGroupModel.h"
#import "LSChatViewController.h"
#import "LSQRCodeViewController.h"
#import "MMDrawerController.h"
#import "LSMenuDetailButton.h"

static NSString *reuseId = @"LSConversationHistoryCell";

@interface LSConversationHistoryViewController () <UITableViewDelegate,UITableViewDataSource,LSMessageManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray<LSConversationModel *> *dataSource;

@end

@implementation LSConversationHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"消息";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self tableViewConfig];
    
    [self naviBarItemConfig];
    
    //重新接收消息
    [self receiveNewMessageAction];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //重新刷新数据，调整界面
    kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
        [self loadData];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //重置消息代理对象
    ShareMessageManager.delegate = self;
}

- (void)tableViewConfig {
    
    self.tableView.backgroundColor = HEXRGB(0xefeff4);
    self.tableView.rowHeight = 70;
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    
    [self.tableView registerClass:[LSConversationHistoryCell class] forCellReuseIdentifier:reuseId];
    self.tableView.tableFooterView = [UIView new];
}

- (void)receiveNewMessageAction {
    
    [self loadData];
    
    ShareMessageManager.delegate = self;
    
    @weakify(self)
    [[self rac_signalForSelector:@selector(didReceiveNewMessage:) fromProtocol:@protocol(LSMessageManagerDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        
        LSMessageModel *message = tuple.first;
        if (message.messageType == LSMessageTypeTime || message.messageType == LSMessageTypeSystem) return;
        
        kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
            [self loadData];
        });
        
    }];
}

- (void)loadData {
    
    NSMutableArray<LSConversationModel *> *list = [NSMutableArray array];
    
    [[LSMessageManager sharedManager].conversationDict enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, LSConversationModel *_Nonnull obj, BOOL * _Nonnull stop) {
        [list addObject:obj];
    }];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdateTimeStamp" ascending:NO];
    
    NSArray<LSConversationModel *> *sortedArray = [list sortedArrayUsingDescriptors:@[descriptor]];
    
    self.dataSource = [NSMutableArray arrayWithArray:sortedArray];
}

- (void)naviBarItemConfig {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"navi_add_more"] forState:UIControlStateNormal];
    [button sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        @strongify(self)
        PopoverView *popoverView = [PopoverView popoverView];
        popoverView.showShade = YES; // 显示阴影背景
        popoverView.style = PopoverViewStyleMain;
        [popoverView showToView:button withActions:[self menuActions]];
    }];
    
    LSMenuDetailButton *leftButton = [LSMenuDetailButton buttonWithType:UIButtonTypeCustom];
    
    UIBarButtonItem *lefItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = lefItem;
    
    [[leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }];
}

- (NSArray<PopoverAction *> *)menuActions {

    PopoverAction *action1 = [PopoverAction actionWithImage:[UIImage imageNamed:@"home_menu_group_chat"] title:@"发起群聊" handler:^(PopoverAction *action) {
        UIViewController *vc = [NSClassFromString(@"LSSelectContactViewController") new];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
        [vc setValue:@(2) forKey:@"type"];
        [self presentViewController:naviVC animated:YES completion:nil];
    }];
    PopoverAction *action2 = [PopoverAction actionWithImage:[UIImage imageNamed:@"home_menu_add_contacts"] title:@"添加朋友" handler:^(PopoverAction *action) {
        [self performSegueWithIdentifier:@"AddContact" sender:nil];
    }];
    PopoverAction *action3 = [PopoverAction actionWithImage:[UIImage imageNamed:@"home_menu_qr_code"] title:@"扫一扫" handler:^(PopoverAction *action) {
        LSQRCodeViewController * vc = [LSQRCodeViewController new];
        vc.codeType = LSQRcodeTypeFriend;
        vc.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    return @[action1, action2, action3];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSConversationHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    LSConversationModel *model = self.dataSource[indexPath.row];
    
    cell.model = model;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSConversationModel *model = self.dataSource[indexPath.row];

    UIViewController *chatVC = [NSClassFromString(@"LSChatViewController") new];
    [chatVC setValue:model forKey:@"conversation"];
    chatVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:chatVC animated:YES];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        @strongify(self)
        LSConversationModel *model = self.dataSource[indexPath.row];
        
        NSUInteger row = [self.dataSource indexOfObject:model];
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        //同步数据
        [self.dataSource removeObject:model];
        [LSMessageManager deleteConversation:model];

        //刷新表格
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
    }];
    
    delete.backgroundColor = [UIColor redColor];
    
    return @[delete];
}

#pragma mark - Getter & Setter 
- (void)setDataSource:(NSMutableArray<LSConversationModel *> *)dataSource {
    _dataSource = dataSource;
    @weakify(self)
    kDISPATCH_MAIN_THREAD(^{
        @strongify(self)
        [self.tableView reloadData];
    })
}

@end
