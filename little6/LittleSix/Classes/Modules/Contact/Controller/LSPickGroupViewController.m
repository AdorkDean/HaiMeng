//
//  LSPickGroupViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPickGroupViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "LSConversationModel.h"
#import "LSChatViewController.h"
#import "UIView+HUD.h"
#import "LSGroupModel.h"
#import "LSForwardView.h"
#import "LSMessageManager.h"

static NSString *const reuseId = @"LSPickGroupCell";

@interface LSPickGroupViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation LSPickGroupViewController

-(NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择一个群";
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self _naviLeftItemConfig];
    
    [self _initDataSource];
}
-(void)_initDataSource {
    
    [self.view showLoading];
    [LSGroupModel groupWithlistUser_Id:ShareAppManager.loginUser.user_id success:^(NSArray *array) {
        
        [self.dataSource addObjectsFromArray:array];
        
        [self.tableView reloadData];
        [self.view hideHUDAnimated:YES];
    } failure:^(NSError *error) {
        [self.view hideHUDAnimated:YES];
        [self.view showErrorWithError:error];
    }];
}

- (void)_naviLeftItemConfig {
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.titleLabel.font = SYSTEMFONT(16);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    @weakify(self)
    [[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSPickGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    LSGroupModel * model = self.dataSource[indexPath.row];
    
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSGroupModel *gmodel = self.dataSource[indexPath.row];
    
    LSConversationModel *model = [LSConversationModel new];
    model.type = LSConversationTypeGroup;
    model.conversationId = gmodel.groupid;
    model.title = gmodel.name;
    model.avartar = gmodel.snap;
    
    if (self.message) {
        
        [LSForwardView showInView:LSKeyWindow senders:@[gmodel] withMessage:self.message comfirmActon:^(NSString *leaveMessage) {
            
            LSConversationModel *newConver = [LSMessageManager conversation:model];
            
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
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        return;
    }
    
    //是好友到聊天界面
    LSChatViewController *chatVC = [[LSChatViewController alloc] initWithConversation:model];
    [self.navigationController pushViewController:chatVC animated:YES];
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

        [tableView registerClass:[LSPickGroupCell class] forCellReuseIdentifier:reuseId];
        
    }
    return _tableView;
}

@end

@interface LSPickGroupCell ()

@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation LSPickGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [UIImageView new];
        self.iconView = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.centerY.equalTo(self);
            make.width.height.offset(37);
        }];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = SYSTEMFONT(16);
        self.titleLabel = titleLabel;
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(iconView);
            make.left.equalTo(iconView.mas_right).offset(10);
        }];
        
        iconView.backgroundColor = [UIColor grayColor];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"鱼香茄子(7)"];
        
        [attr addAttribute:NSForegroundColorAttributeName value:HEXRGB(0x888888) range:NSMakeRange(4, 3)];
        
        titleLabel.attributedText = attr;
        
    }
    return self;
}

-(void)setModel:(LSGroupModel *)model{

    _model = model;
    
    [self.iconView setImageWithURL:[NSURL URLWithString:model.snap] placeholder:[UIImage imageNamed:@""]];
    NSString * muber = [NSString stringWithFormat:@"(%ld)",model.members.count];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",model.name,muber]];
    [attr addAttribute:NSForegroundColorAttributeName value:HEXRGB(0x888888) range:NSMakeRange(model.name.length,muber.length)];
    self.titleLabel.attributedText = attr;
}

@end
