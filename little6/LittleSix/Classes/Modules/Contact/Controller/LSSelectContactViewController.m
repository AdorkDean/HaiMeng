//
//  LSSelectContactViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSelectContactViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "LSContactModel.h"
#import "LSChineseSort.h"
#import "LSGroupModel.h"
#import "UIView+HUD.h"
#import "LSForwardView.h"
#import "LSMessageManager.h"

static NSString *const reuseId = @"LSSelectContactCell";
static NSString *const normal_reuseId = @"LSSelectContactNormalCell";

@interface LSSelectContactViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

//排序后的出现过的拼音首字母数组
@property(nonatomic, strong) NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic, strong) NSMutableArray *letterResultArr;

@end

@implementation LSSelectContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择联系人";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configNaviBar];
    [self _installSubViews];
    [self _initDataSource];
}

-(void)_initDataSource {
    
    [LSContactModel friendsWithlistToken:ShareAppManager.loginUser.access_token success:^(NSArray *array) {
        
        //根据LSContactModel对象的 user_name 属性 按中文 对 LSContactModel数组 排序
        self.indexArray = [LSChineseSort IndexWithArray:array Key:@"first_letter"];
        self.letterResultArr = [LSChineseSort sortObjectArray:array Key:@"first_letter"];
        
        [self.tableView reloadData];
        
    } failure:nil];
}

- (void)configNaviBar {
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.titleLabel.font = SYSTEMFONT(16);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    @weakify(self)
    [[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.titleLabel.font = SYSTEMFONT(16);
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:sureButton];
    self.navigationItem.rightBarButtonItem = rightItem;

    [[sureButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)

        NSMutableArray * members = [NSMutableArray array];
        NSMutableArray * nameArr = [NSMutableArray array];
        
        LSContactModel *selectModel = nil;
        
        for (NSArray * arr in self.letterResultArr) {
            for (LSContactModel * model in arr) {
                if (model.is_select) {
                    [members addObject:[NSString stringWithFormat:@"%ld",model.friend_id]];
                    [nameArr addObject:[NSString stringWithFormat:@"%@",model.user_name]];
                    selectModel = model;
                }
            }
        }
        
        //消息转发
        if (self.message) {
            [self forwardAction];
            return;
        }
        
        //群增加成员
        if (self.type == 1) {
            [self increaseGroupMembers:members];
        }//发起群聊
        else {
            if (members.count == 1) {
                LSConversationModel *model = [LSConversationModel new];
                model.type = LSConversationTypeChat;
                model.conversationId = [NSString stringWithFormat:@"%ld",selectModel.friend_id];
                model.title = selectModel.user_name;
                model.avartar = selectModel.avatar;
                [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageNoti object:model userInfo:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [self requestDataSource:members withNameArr:nameArr];
            }
        }
    }];
}

- (void)requestDataSource:(NSArray *)members withNameArr:(NSArray *)nameArr{
    
    NSString * memStr = @"";
    NSString * nameStr = @"";
    for (int i = 0; i < members.count; i ++) {
        if (i == 0) {
            memStr = [NSString stringWithFormat:@"%@,%@",ShareAppManager.loginUser.user_id,members[i]];
            nameStr = [NSString stringWithFormat:@"%@,%@",ShareAppManager.loginUser.user_name,nameArr[i]];
        }else{
            memStr = [NSString stringWithFormat:@"%@,%@",memStr,members[i]];
            if (i < 3) {
                nameStr = [NSString stringWithFormat:@"%@,%@",nameStr,nameArr[i]];
            }
        }
    }
    
    [LSGroupModel createGroupWithUser_Id:ShareAppManager.loginUser.user_id creator:memStr name:nameStr success:^(LSGroupModel *message) {
        
        [self.view showWithText:[NSString stringWithFormat:@"创建%@群成功",nameStr] hideAfterDelay:1.5];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kSendGroupMessageNoti object:message userInfo:nil];
        
    } failure:^(NSError *error) {
        
        [self.view showWithText:@"创建群失败" hideAfterDelay:1.5];
    }];
}

- (void)increaseGroupMembers:(NSArray *)members {

    NSString * memStr = @"";
    
    for (int i = 0; i < members.count; i ++) {
        
        if (i == 0) {
            memStr = [NSString stringWithFormat:@"%@",members[i]];
        }else{
            
            memStr = [NSString stringWithFormat:@"%@,%@",memStr,members[i]];
        }
    }
    
    [LSGroupModel increaseMembersWithGroupid:self.groupid members:memStr success:^(NSString *message) {
        
        [self.view showInfo:message hideAfterDelay:1];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(NSError *error) {
        
        [self.view showError:@"添加失败" hideAfterDelay:1];
    }];
}

- (void)forwardAction {
    
    NSMutableArray *list = [NSMutableArray array];
    for (NSArray * arr in self.letterResultArr) {
        for (LSContactModel * model in arr) {
            if (model.is_select) {
                [list addObject:model];
            }
        }
    }

    [LSForwardView showInView:LSKeyWindow senders:list withMessage:self.message comfirmActon:^(NSString *leaveMessage) {
        
        for (LSContactModel *model in list) {
            
            LSConversationModel *conver = [LSConversationModel new];
            conver.type = LSConversationTypeChat;
            conver.conversationId = [NSString stringWithFormat:@"%ld",model.friend_id];
            conver.title = model.user_name;
            conver.avartar = model.avatar;
            
            LSConversationModel *newConver = [LSMessageManager conversation:conver];
            
            LSMessageModel *copyMessage = [self copyMessage:self.message inConversation:newConver];
            [LSMessageManager forwardMessage:copyMessage conversation:newConver];
            
            if ([ShareMessageManager.delegate respondsToSelector:@selector(didReceiveNewMessage:)]) {
                [ShareMessageManager.delegate didReceiveNewMessage:copyMessage];
            }
            
            if (leaveMessage&&leaveMessage.length > 0) {
                LSTextMessageModel *leaveMessageModel = [LSTextMessageModel new];
                leaveMessageModel.text = leaveMessage;
                [self configMessageInfo:leaveMessageModel inConversation:newConver];
                [LSMessageManager sendTextMessage:leaveMessageModel conversation:newConver];
                //发送消息
                if ([ShareMessageManager.delegate respondsToSelector:@selector(didReceiveNewMessage:)]) {
                    [ShareMessageManager.delegate didReceiveNewMessage:leaveMessageModel];
                }
            }
            
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (LSMessageModel *)copyMessage:(LSMessageModel *)message inConversation:(LSConversationModel *)conversation {
    
    LSMessageModel *newMessage;
    
    switch (message.messageType) {
        case LSMessageTypeText:
        {
            LSTextMessageModel *oriTextMessage = (LSTextMessageModel *)message;
            LSTextMessageModel *textMessage = [LSTextMessageModel new];
            newMessage = textMessage;
            textMessage.text = oriTextMessage.text;
            textMessage.richTextAttributedString = oriTextMessage.richTextAttributedString;
            textMessage.textWidth = oriTextMessage.textWidth;
            textMessage.textHeight = oriTextMessage.textHeight;
            textMessage.cellHeight = oriTextMessage.cellHeight;
        }
            break;
        case LSMessageTypeVideo:
        {
            LSVideoMessageModel *oriVideoMessage = (LSVideoMessageModel *)message;
            LSVideoMessageModel *videoMessage = [LSVideoMessageModel new
                                                 ];
            newMessage = videoMessage;
            videoMessage.remoteVideoURL = oriVideoMessage.remoteVideoURL;
            videoMessage.remoteThumURL = oriVideoMessage.remoteThumURL;
            videoMessage.localFileName = oriVideoMessage.localFileName;
            videoMessage.localThumName = oriVideoMessage.localThumName;
            videoMessage.originWidth = oriVideoMessage.originWidth;
            videoMessage.originHeight = oriVideoMessage.originHeight;
            videoMessage.scaleWidth = oriVideoMessage.scaleWidth;
            videoMessage.scaleHeight = oriVideoMessage.scaleHeight;
            videoMessage.cellHeight = oriVideoMessage.cellHeight;
        }
            break;
            
        case LSMessageTypeEmotion:
        {
            LSEmotionMessageModel *oriEmotionMessage = (LSEmotionMessageModel *)message;
            LSEmotionMessageModel *emotionMessage = [LSEmotionMessageModel new];
            newMessage = emotionMessage;
            emotionMessage.originWidth = oriEmotionMessage.originWidth;
            emotionMessage.originHeight = oriEmotionMessage.originHeight;
            emotionMessage.scaleWidth = oriEmotionMessage.scaleWidth;
            emotionMessage.scaleHeight = oriEmotionMessage.scaleHeight;
            emotionMessage.code = oriEmotionMessage.code;
            emotionMessage.localFilePath = oriEmotionMessage.localFilePath;
            emotionMessage.cellHeight = oriEmotionMessage.cellHeight;
        }
            break;
            
        case LSMessageTypePicture:
        {
            LSPictureMessageModel *oriPicMessage = (LSPictureMessageModel *)message;
            LSPictureMessageModel *picMessage = [LSPictureMessageModel new];
            newMessage = picMessage;
            picMessage.picUrl = oriPicMessage.picUrl;
            picMessage.image = oriPicMessage.image;
            picMessage.scaleWidth = oriPicMessage.scaleWidth;
            picMessage.scaleHeight = oriPicMessage.scaleHeight;
            picMessage.originWidth = oriPicMessage.originWidth;
            picMessage.originHeight = oriPicMessage.originHeight;
            
            picMessage.cellHeight = oriPicMessage.cellHeight;
        }
            break;
            
        default:
            break;
    }

    [self configMessageInfo:newMessage inConversation:conversation];
    
    return newMessage;
}

- (void)configMessageInfo:(LSMessageModel *)message inConversation:(LSConversationModel *)conversation {
    
    message.conversation_id = conversation.conversationId;
    message.senderId = ShareAppManager.loginUser.user_id;
    message.sender = ShareAppManager.loginUser.user_name;
    message.senderAvartar = ShareAppManager.loginUser.avatar;
    message.timeStamp = [[NSDate date] timeIntervalSince1970];
    message.conversation_type = conversation.type;
    message.extension = [self messageExtentionOfConversation:conversation];
    
}

- (NSMutableDictionary *)messageExtentionOfConversation:(LSConversationModel *)conversation {
    
    NSMutableDictionary *ext = [NSMutableDictionary dictionary];
    ext[@"sender"] = ShareAppManager.loginUser.user_name;
    ext[@"senderAvartar"] = ShareAppManager.loginUser.avatar;
    ext[@"senderID"] = ShareAppManager.loginUser.user_id;
    
    if (conversation.type == LSConversationTypeGroup) {
        ext[@"conversation"] = conversation.title;
        ext[@"conversationAvartar"] = [conversation avartar];
    }
    else {
        ext[@"conversation"] = ShareAppManager.loginUser.user_name;
        ext[@"conversationAvartar"] = ShareAppManager.loginUser.avatar;
    }
    
    return ext;
}

- (void)_installSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *searchView = [UIView new];
    [self.view addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.offset(55);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    
    UIImageView *searchImageView = [UIImageView new];
    [self.view addSubview:searchImageView];
    searchImageView.image = [UIImage imageNamed:@"addcontact_group_search"];
    [searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView).offset(10);
        make.centerY.equalTo(searchView);
        make.width.offset(searchImageView.image.size.width);
        make.height.offset(searchImageView.image.size.height);
    }];
    
    UITextField *searchTextField = [UITextField new];
    searchTextField.placeholder = @"搜索";
    searchTextField.delegate = self;
    searchTextField.returnKeyType = UIReturnKeySearch;
    [searchView addSubview:searchTextField];
    [searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(searchView);
        make.left.equalTo(searchImageView.mas_right).offset(4);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = HEXRGB(0xe9e9ec);
    [searchView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(searchView);
        make.height.offset(0.8);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (![textField.text isEqualToString:@""]) {
        NSString * key = [textField.text stringByTrim];
        NSMutableArray * arr = [NSMutableArray array];
        for (NSArray * array in self.letterResultArr) {
            for (LSContactModel * model  in array) {
                if ([model.user_name rangeOfString:key].location != NSNotFound) {
                    [arr addObject:model];
                }
            }
        }
        self.indexArray = [LSChineseSort IndexWithArray:arr Key:@"user_name"];
        self.letterResultArr = [LSChineseSort sortObjectArray:arr Key:@"user_name"];
        [self.tableView reloadData];
    }else {
        
        [self _initDataSource];
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.letterResultArr.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section==0?1:[[self.letterResultArr objectAtIndex:section-1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        LSSelectContactNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:normal_reuseId];
        return cell;
    }
    
    LSSelectContactCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    LSContactModel * model = [[self.letterResultArr objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        UIViewController *vc = [NSClassFromString(@"LSPickGroupViewController") new];
        if (self.message) {
            [vc setValue:self.message forKey:@"message"];
        }
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        LSContactModel * model = [[self.letterResultArr objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        model.is_select = !model.is_select;
        LSSelectContactCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.cellSelected = !cell.isCellSelected;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView new];
    headerView.backgroundColor = HEXRGB(0xefeff4);
    
    UILabel *indexLabel = [UILabel new];
    indexLabel.font = SYSTEMFONT(14);
    indexLabel.textColor = HEXRGB(0x8e8e93);
    indexLabel.text = self.indexArray[section-1];
    
    [headerView addSubview:indexLabel];
    [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView);
        make.left.equalTo(headerView).offset(10);
    }];
    
    return headerView;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0.0;
            
        default:
            return 22;
    }
}

#pragma mark - Getter & Setter
- (UITableView *)tableView {
    if (!_tableView) {
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView = tableView;
        
        tableView.tableFooterView = [UIView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 55;
        tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        tableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
        tableView.sectionIndexColor = HEXRGB(0x555555);
        tableView.backgroundColor = HEXRGB(0xefeff4);
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        
        [tableView registerClass:[LSSelectContactCell class] forCellReuseIdentifier:reuseId];
        [tableView registerClass:[LSSelectContactNormalCell class] forCellReuseIdentifier:normal_reuseId];
    }
    return _tableView;
}

@end

@implementation LSSelectContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *selectBtn = [UIButton new];
        [selectBtn setImage:[UIImage imageNamed:@"addcontact_checkbox"] forState:UIControlStateNormal];
        [selectBtn setImage:[UIImage imageNamed:@"addcontact_checkbox_on"] forState:UIControlStateSelected];
        [selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        self.selectBtn = selectBtn;
        [self addSubview:selectBtn];
        [selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.height.offset(24);
            make.left.equalTo(self).offset(8);
        }];
        
        UIImageView *iconView = [UIImageView new];
        self.iconImage = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.height.offset(36);
            make.left.equalTo(selectBtn.mas_right).offset(10);
        }];
        
        UILabel *nameLabel = [UILabel new];
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(iconView.mas_right).offset(10);
            make.right.equalTo(self).offset(20);
        }];
        
        iconView.backgroundColor = [UIColor lightGrayColor];
        nameLabel.text = @"咖喱辣椒";
        
    }
    return self;
}

-(void)setModel:(LSContactModel *)model{

    _model = model;
    
    [self.iconImage setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:[UIImage imageNamed:@""]];
    self.nameLabel.text = model.user_name;
    
    self.selectBtn.selected = model.is_select;
}


-(void)selectBtnClick:(UIButton *)sender{

    sender.selected = !sender.selected;
    if (sender.selected) {
        self.model.is_select = YES;
    }else{
        self.model.is_select = NO;
    }
}
-(void)selectClick:(LSContactModel *)model{
    
    self.selectBtn.selected = model.is_select;
}


-(void)setCellSelected:(BOOL)cellSelected{
    _cellSelected = cellSelected;
    self.model.is_select = cellSelected;
    self.selectBtn.selected = cellSelected;
}

@end

@implementation LSSelectContactNormalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = @"选择一个群";
        titleLabel.font = SYSTEMFONT(14);
        
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(15);
        }];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
