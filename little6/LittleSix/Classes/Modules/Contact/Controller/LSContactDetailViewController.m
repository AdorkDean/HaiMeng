//
//  LSContactDetailViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSContactDetailViewController.h"
#import "LSPersonalDataTableViewController.h"
#import "LSContactModel.h"
#import <YYKit/YYKit.h>
#import "UIView+HUD.h"
#import "LSChatViewController.h"
#import "LSTimeLineHomeViewController.h"
#import "LSUserModel.h"
#import "LSConversationModel.h"
#import "LSPersonsModel.h"
#import "LSUMengHelper.h"
#import "ComfirmView.h"
#import "YYPhotoGroupView.h"
#import "NSString+Util.h"
#import "UIAlertController+LSAlertController.h"


@interface LSContactDetailViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (retain, nonatomic) LSContactModel *contactModel;
@property (strong, nonatomic) LSPersonsModel * personsModel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UIImageView *firstIconView;
@property (weak, nonatomic) IBOutlet UIImageView *secondIconView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdIconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdtViewWidth;
@property (strong,nonatomic) UIButton * moreButton;

@end

@implementation LSContactDetailViewController

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [self initDataSource];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详细资料";
    
    ViewRadius(self.sendButton, 5);
    self.iconImage.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconImageClick:)];
    [self.iconImage addGestureRecognizer:tap];
    [self _initFace];
    [self requestPersonData];
    [self naviBarConfig];
}

//点击头像
- (void)iconImageClick:(UITapGestureRecognizer *)tap {

    NSMutableArray<YYPhotoGroupItem *> *items = [NSMutableArray array];
    YYPhotoGroupItem *item = [YYPhotoGroupItem new];
    item.largeImageURL = [NSURL URLWithString:self.personsModel.avatar];
    item.thumbView = self.iconImage;
    [items addObject:item];
    YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
    [v presentFromImageView:self.iconImage toContainer:[UIApplication sharedApplication].keyWindow animated:YES completion:nil];
}

- (void)naviBarConfig {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"navi_chat_more"] forState:UIControlStateNormal];
    [button sizeToFit];
    self.moreButton = button;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        @strongify(self);
        NSArray * array;
        if (self.contactModel.is_friend != 0) {
            ModelComfirm *item1 = [ModelComfirm comfirmModelWith:@"删除" titleColor:[UIColor redColor] fontSize:16];
            ModelComfirm *item2 = [ModelComfirm comfirmModelWith:@"举报" titleColor:HEXRGB(0x666666) fontSize:16];
            array = @[item1,item2];
        }else {
            ModelComfirm *item2 = [ModelComfirm comfirmModelWith:@"举报" titleColor:HEXRGB(0x666666) fontSize:16];
            array = @[item2];
        }
        ModelComfirm *cancelItem = [ModelComfirm comfirmModelWith:@"取消" titleColor:HEXRGB(0x666666) fontSize:16];
        //确认提示框
        [ComfirmView showInView:LSKeyWindow cancelItemWith:cancelItem dataSource:array actionBlock:^(ComfirmView *view, NSInteger index) {
            
            if (self.contactModel.is_friend != 0) {
                if (index == 0) {
                    [LSContactModel deleteFriendsWithlistToken:ShareAppManager.loginUser.access_token fid:self.contactModel.fid success:^{
                        //发送通知刷新
                        [[NSNotificationCenter defaultCenter] postNotificationName:kContactInfoNoti object:nil];
                        [self.view showSucceed:@"删除成功" hideAfterDelay:1.5];
                        [self initDataSource];
                    } failure:nil];
                }else {
                    UIViewController *reportVC = [NSClassFromString(@"WeiboReportViewController") new];
                    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:reportVC];
                    
                    [self presentViewController:naviVC animated:YES completion:nil];
                }
            }else {
                if (index == 0) {
                    UIViewController *reportVC = [NSClassFromString(@"WeiboReportViewController") new];
                    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:reportVC];
                    
                    [self presentViewController:naviVC animated:YES completion:nil];
                }
            }
        }];
    }];
    
    if ([self.user_id isEqualToString:ShareAppManager.loginUser.user_id]) {
        self.sendButton.hidden = YES;
    }
}

- (void)requestPersonData {

    [LSPersonsModel personerWithUser_id:self.user_id success:^(LSPersonsModel *model) {
        
        [self.iconImage setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:timeLineSmallPlaceholderName];
        self.nameLabel.text = model.user_name;
        self.regionLabel.text = model.district_str;
        self.signatureLabel.text = model.signature;
        self.nameLabel.width = [NSString countingSize:model.user_name fontSize:16 height:18].width > kScreenWidth-130 ? kScreenWidth-130:[NSString countingSize:model.user_name fontSize:16 height:18].width;
        self.sexImageView.left = self.nameLabel.right + 5;
        self.personsModel = model;
        if ([model.sex isEqualToString:@"男"]) [self.sexImageView setImage:[UIImage imageNamed:@"man"]];
        else [self.sexImageView setImage:[UIImage imageNamed:@"lady"]];
        [self _iconView:model];

    } failure:nil];
    
}

- (void)_iconView:(LSPersonsModel *)model {

    switch (model.photos.count) {
        case 1:
        {
            [self.firstIconView setImageWithURL:model.photos[0] placeholder:timeLineSmallPlaceholderName];
        }
            break;
        case 2:
        {
        
            [self.firstIconView setImageWithURL:model.photos[0] placeholder:timeLineSmallPlaceholderName];
            [self.secondIconView setImageWithURL:model.photos[1] placeholder:timeLineSmallPlaceholderName];
        }
            break;
        case 3:
        {
            
            [self.firstIconView setImageWithURL:model.photos[0] placeholder:timeLineSmallPlaceholderName];
            [self.secondIconView setImageWithURL:model.photos[1] placeholder:timeLineSmallPlaceholderName];
            [self.thirdIconView setImageWithURL:model.photos[2] placeholder:timeLineSmallPlaceholderName];
        }
            break;
        default:
            break;
    }
}

-(void)initDataSource{
    [LSContactModel isFriendsWithlistToken:ShareAppManager.loginUser.access_token uid_to:self.user_id success:^(LSContactModel *model) {
        self.contactModel = model;
        if (model.is_friend == 0) {
            [self.sendButton setTitle:@"添加通讯录" forState:UIControlStateNormal];
            
        }else{
            [self.sendButton setTitle:@"发送消息" forState:UIControlStateNormal];
        }
    } failure:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15 : 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row == 2) {
        LSTimeLineHomeViewController * vc = [LSTimeLineHomeViewController new];
        vc.userID = [self.user_id intValue];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)sendClick:(UIButton *)sender {
    
    if (self.contactModel.is_friend == 0) {
        //不是好友发送好友请求
        [self sendFriend];
    }else{
        self.tabBarController.selectedIndex = 0;
        [self.navigationController popToRootViewControllerAnimated:NO];
        LSConversationModel *model = [LSConversationModel new];
        model.type = LSConversationTypeChat;
        model.conversationId = self.personsModel.user_id;
        model.title = self.personsModel.user_name;
        model.avartar = self.personsModel.avatar;
        [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageNoti object:model userInfo:nil];
    }
}

- (void)sendFriend {

    [UIAlertController alertTitle:@"温馨提示" mesasge:@"说一句成为好友的机率更大哦!" withOK:@"发送" preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *alertAction, UITextField *textField) {
        [self sendFriendRequest:textField.text];
    } cancleHandler:^(UIAlertAction *alert) {
        
    } viewController:self];
    
}

-(void)sendFriendRequest:(NSString *)title{

    NSString * titleStr = [title isEqualToString:@""] ? @"加一下呗":title;
    
    [LSContactModel sendFriendsWithlistToken:ShareAppManager.loginUser.access_token uid_to:self.personsModel.user_id friend_note:titleStr success:^(LSContactModel* cmodel){
        
        [LSUMengHelper pushNotificationWithUsers:@[cmodel.uid_to] message:[NSString stringWithFormat:@"%@邀请你添加为好友",ShareAppManager.loginUser.user_name] extension:@{@"contactTpye":kAddContactPath,@"user_id":cmodel.uid_to} success:^{
            
        } failure:nil];
        [self.view showSucceed:@"发送成功" hideAfterDelay:1.5];
        
    } failure:^(NSError *error ) {
        
        [self.view showSucceed:@"发送失败" hideAfterDelay:1.5];
    }];
}

- (void)_initFace {
    
    self.firstIconView.contentMode = UIViewContentModeScaleToFill;
    self.secondIconView.contentMode = UIViewContentModeScaleToFill;
    self.thirdIconView.contentMode = UIViewContentModeScaleToFill;
    self.firstIconView.backgroundColor = [UIColor whiteColor];
    self.secondIconView.backgroundColor = [UIColor whiteColor];
    self.thirdIconView.backgroundColor = [UIColor whiteColor];
    self.nameLabel.width = kScreenWidth/2;
    if (isiPhone5||isiPhone4) {
        self.firstViewWidth.constant = 55;
        self.secondViewWidth.constant = 55;
        self.thirdtViewWidth.constant = 55;
    }else {
        self.firstViewWidth.constant = kScreenWidth/5-5;
        self.secondViewWidth.constant = kScreenWidth/5-5;
        self.thirdtViewWidth.constant = kScreenWidth/5-5;
    }
    
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
