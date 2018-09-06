//
//  LSChatViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSChatViewController.h"
#import "LSConversationModel.h"
#import "LSChatInputView.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "LSCollectionViewController.h"
#import "LSMessageManager.h"
#import "LSOBaseModel.h"
#import "LSBaseMessageCell.h"
#import "LSCaptureViewController.h"
#import "LSEmotionModel.h"
#import "LSMyEmotionViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "UIView+HUD.h"
#import "ImagePickerManager.h"
#import "LSChatRefreshHeader.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "IDFileManager.h"

static NSString *const system_cell_reuse_id = @"LSMessageSystemCell";
static NSString *const text_cell_reuse_id = @"LSMessageTextCell";
static NSString *const image_cell_reuse_id = @"LSMessagePictureCell";
static NSString *const voice_cell_reuse_id = @"LSMessageVoiceCell";
static NSString *const video_cell_reuse_id = @"LSMessageVideoCell";
static NSString *const emotion_cell_reuse_id = @"LSMessageEmotionCell";

@interface LSChatViewController () <LSChatInputViewDelegate,UITableViewDelegate,UITableViewDataSource,LSMessageManagerDelegate,BackButtonHandlerProtocol>

@property (nonatomic,strong) LSChatInputView *chatInputView;

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray<LSMessageModel *> *dataSource;
//聊天背景图
@property (nonatomic,strong) UIImageView *chatBgView;
//正在获取数据
@property (nonatomic,assign) BOOL loading;

@end

@implementation LSChatViewController

- (instancetype)initWithConversation:(LSConversationModel *)model {
    if ([super init]) {
        self.conversation = [LSMessageManager conversation:model];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.conversation.title;
    self.view.backgroundColor = [UIColor whiteColor];
    self.fd_interactivePopDisabled = YES;
    
    [self buildSubviews];
    
    [self registNotis];
    
    self.dataSource = [ShareMessageManager messagesInConversation:self.conversation.conversationId earlierMessageId:nil];
    [self.tableView reloadData];
    
    [self scrollToBottom];
    
    //重置未读消息数
    [self resetUnReadCount];
    
    //设置接收消息的代理
    [self receiveNewMessageAction];
    
    [self setNavigationBar];
}

- (void)setNavigationBar {

//    UIImage * image = [UIImage imageNamed:@"navi_chat_details"];
    UIImage * image = self.conversation.type == LSConversationTypeGroup? [UIImage imageNamed:@"home_menu_group_chat"]:[UIImage imageNamed:@"navi_chat_details"];
    UIButton * personalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [personalBtn setImage:image forState:UIControlStateNormal];
    [personalBtn sizeToFit];

    UIBarButtonItem * personalItem = [[UIBarButtonItem alloc] initWithCustomView:personalBtn];
    self.navigationItem.rightBarButtonItem = personalItem;
    
    @weakify(self)
    [[personalBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        
        if (self.conversation.type == LSConversationTypeGroup) {
            UIViewController *groutVC = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupChatDetails"];
            [groutVC setValue:self.conversation.conversationId forKey:@"groupid"];
            [groutVC setValue:self.conversation forKey:@"conversation"];
            [self.navigationController pushViewController:groutVC animated:YES];
        }
        else if(self.conversation.type == LSConversationTypeChat) {
            
            UIViewController *singleVC = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatMessages"];
            [singleVC setValue:self.conversation.conversationId forKey:@"user_id"];
            [singleVC setValue:self.conversation forKey:@"conversation"];
            [self.navigationController pushViewController:singleVC animated:YES];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //设置通知的代理对象
    ShareMessageManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //发送停止音频播放通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kStopAudioPlayNoti object:nil];
}

- (void)buildSubviews {
    
    [self.view addSubview:self.chatInputView];
    [self.chatInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom).offset(-self.chatInputView.toolBarHeight);
        make.height.offset(kToolBarItemH+kPannelViewH);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.chatInputView.mas_top);
    }];
}

//拦截返回按钮的点击事件
- (BOOL)navigationShouldPopOnBackButton {
    self.conversation.unReadCount = 0;
    //移除空回话
    if (!self.conversation.lastMessage) {
        [LSMessageManager sharedManager].conversationDict[self.conversation.conversationId] = nil;
        [LSMessageManager syncConversations];
    }
    return YES;
}

#pragma mark - Action
- (void)receiveNewMessageAction {
    
    ShareMessageManager.delegate = self;
    
    @weakify(self)
    [[self rac_signalForSelector:@selector(didReceiveNewMessage:) fromProtocol:@protocol(LSMessageManagerDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        LSMessageModel *model = tuple.first;
        if (![model.conversation_id isEqualToString:self.conversation.conversationId]) return;
        
        [self addNewMessage:model];
        [self scrollToBottom];
        //重置未读消息数
        [self resetUnReadCount];
    }];
}

- (void)resetUnReadCount {
    kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
        self.conversation.unReadCount = 0;
        [LSMessageManager syncConversations];
    })
}

- (void)scrollToBottom {
    
    if (self.dataSource.count == 0) return;
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSMessageModel *message = self.dataSource[indexPath.row];
    
    NSString *cell_reuse_id;

    if (message.messageType == LSMessageTypeTime) {
        cell_reuse_id = system_cell_reuse_id;
    }
    else if (message.messageType == LSMessageTypeText) {
        cell_reuse_id = text_cell_reuse_id;
    }
    else if (message.messageType == LSMessageTypePicture) {
        cell_reuse_id = image_cell_reuse_id;
    }
    else if (message.messageType == LSMessageTypeAudio) {
        cell_reuse_id = voice_cell_reuse_id;
    }
    else if (message.messageType == LSMessageTypeVideo) {
        cell_reuse_id = video_cell_reuse_id;
    }
    else if (message.messageType == LSMessageTypeEmotion) {
        cell_reuse_id = emotion_cell_reuse_id;
    }
    
    LSBaseMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_reuse_id];
    cell.model = message;

    @weakify(self)
    [cell setPlayClick:^(NSURL *playURL, UIImage *image) {
        @strongify(self)
        UIViewController * vc = [NSClassFromString(@"LSVideoPlayerViewController") new];
        [vc setValue:playURL forKey:@"playURL"];
        [vc setValue:image forKey:@"coverImage"];
        [self presentViewController:vc animated:YES completion:nil];
    }];
    
    [cell setAvaterClick:^(LSMessageModel * model) {
        @strongify(self)
        //点击头像回调
        UIViewController *lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
        [lsvc setValue:model.senderId forKey:@"user_id"];
        [self.navigationController pushViewController:lsvc animated:YES];
    }];
    
    [cell setDeleteMessageBlock:^(LSMessageModel * model) {
        @strongify(self)
        [ShareMessageManager deleteMessageByMessageId:model.message_id andConversationId:model.conversation_id];
        NSInteger idx = [self.dataSource indexOfObject:model];
        [self.dataSource removeObject:model];
        [self.tableView beginUpdates];
        [self.tableView deleteRow:idx inSection:0 withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }];
    
    [cell setForwardBlock:^(LSMessageModel *model){
        @strongify(self)
        UIViewController *vc = [NSClassFromString(@"LSSelectContactViewController") new];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
        [vc setValue:model forKey:@"message"];
        [self presentViewController:naviVC animated:YES completion:nil];
    }];
    
    //收藏
    [cell setFavorBlock:^(LSMessageModel *model){
        @strongify(self)
        
        LSTextMessageModel *textMessage = (LSTextMessageModel *)model;
        LSPictureMessageModel *picModel = (LSPictureMessageModel *)model;
        LSVideoMessageModel *videoModel = (LSVideoMessageModel *)model;
        NSString * type ;
        NSString * text ;
        NSString * picUrl;
        NSString * videoUrl;
        if (model.messageType == LSMessageTypeText) {
            type = @"0";
            text = [textMessage.text stringByTrim];
        }else if (model.messageType == LSMessageTypePicture) {
            type = @"1";
            picUrl = picModel.picUrl;
        }else {
            type = @"2";
            picUrl = videoModel.remoteThumURL;
            videoUrl = videoModel.remoteVideoURL;
        }
        NSString * gname = model.conversation_type == LSConversationTypeGroup ? [self.conversation.title stringByTrim]:@"";
        
        [LSCollectModel userAddCollectListWithFromid:[model.senderId intValue] gname:gname thum:picUrl url:videoUrl type:type text:text success:^(LSCollectModel *model) {
            [LSKeyWindow showSucceed:@"收藏成功" hideAfterDelay:1];
        } failure:^(NSError *error) {
            [LSKeyWindow showError:@"收藏失败" hideAfterDelay:1];
        }];
    }];
    
    if (message.messageType == LSMessageTypePicture) {
        //获取phototItems
        [cell setPhotoItemsBlock:^NSArray<YYPhotoGroupItem *> *(LSMessageModel *message){
            @strongify(self)
            return [self photoGroupItems:message];
        }];
    }
    
    return cell;
}

- (NSArray<YYPhotoGroupItem *> *)photoGroupItems:(LSMessageModel *)message {
    
    NSMutableArray *items = [NSMutableArray array];
    
    for (LSMessageModel *message in self.dataSource) {
        
        if (message.messageType != LSMessageTypePicture) continue;
        
        LSPictureMessageModel *picMessage = (LSPictureMessageModel *)message;
        YYPhotoGroupItem *item = [YYPhotoGroupItem new];
        item.largeImageURL = [NSURL URLWithString:picMessage.picUrl];
        item.largeImageSize = CGSizeMake(picMessage.originWidth, picMessage.originHeight);
        
        NSInteger idx = [self.dataSource indexOfObject:message];
        LSBaseMessageCell *messageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        
        item.thumbView = messageCell.bubbleView;
        [items addObject:item];
    }
    return items;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSMessageModel *message = self.dataSource[indexPath.row];
    
    if (message.cellHeight > 0) {
        return message.cellHeight;
    }
    
    return [LSBaseMessageCell cellHeightForMessage:message];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.chatInputView endIntput];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.chatInputView.inputStatus == LSChatInputStatusEmotion || self.chatInputView.inputStatus == LSChatInputStatusMore) {
        [self.chatInputView endIntput];
    }
}

#pragma mark - LSChatInputViewDelegate
- (void)registNotis {
    //添加键盘处理事件
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification *notification) {
        @strongify(self)
        
        if (![self.navigationController.topViewController isEqual:self]) return;
        
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{                [self.chatInputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_bottom).offset(-self.chatInputView.toolBarHeight-keyBoardFrame.size.height);
            }];
            [self.view layoutIfNeeded];
        }];
        self.chatInputView.keyboardHeight = keyBoardFrame.size.height;
        [self scrollToBottom];
    }];
    //隐藏键盘
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.chatInputView endIntput];
    }];
    
    //发送表情图片
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kSelectEmotionNoti object:nil] subscribeNext:^(NSNotification * _Nullable noti) {
        @strongify(self)
        
        [self.chatInputView endIntput];
        
        LSEmotionModel *model = noti.object;
        
        LSEmotionMessageModel *message = [LSEmotionMessageModel new];
        [self configBaseMessageInfo:message];
        message.code = model.emo_code;
        message.originWidth = model.width;
        message.originHeight = model.height;
        
        //创建时间消息
        [ShareMessageManager initMessageTimeModel:self.conversation timeStamp:message.timeStamp];
        //发送消息
        [self addNewMessage:message];
        //发送表情
        [LSMessageManager sendEmotionMessage:message conversation:self.conversation];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kRemoveMessagesInConversation object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        self.dataSource = [ShareMessageManager messagesInConversation:self.conversation.conversationId earlierMessageId:nil];
        [self.tableView reloadData];
    }];
    
    [RACObserve(self.conversation, title) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        self.title = self.conversation.title;
    }];
    
}

- (void)chatInputViewDelegateActions {
    //添加键盘处理事件
    @weakify(self)
    [[self rac_signalForSelector:@selector(chatInputViewWillShowPannel:) fromProtocol:@protocol(LSChatInputViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self.chatInputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_bottom).offset(-self.chatInputView.toolBarHeight-kPannelViewH);
            }];
            [self.view layoutIfNeeded];
        }];
        [self scrollToBottom];
    }];
    
    [[self rac_signalForSelector:@selector(chatInputViewWillDismissPannel:) fromProtocol:@protocol(LSChatInputViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self.chatInputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_bottom).offset(-self.chatInputView.toolBarHeight);
            }];
            [self.view layoutIfNeeded];
        }];
        [self scrollToBottom];
    }];
    
    [[self rac_signalForSelector:@selector(chatInputViewTextDidChange:) fromProtocol:@protocol(LSChatInputViewDelegate)] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        //更新约束
        [self.chatInputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_bottom).offset(-self.chatInputView.toolBarHeight-self.chatInputView.keyboardHeight);
            make.height.offset(self.chatInputView.toolBarHeight+kPannelViewH);
        }];
        [self.view layoutIfNeeded];
    }];
    
    [[self rac_signalForSelector:@selector(chatInputViewWillRecord:) fromProtocol:@protocol(LSChatInputViewDelegate)] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self.chatInputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_bottom).offset(-kToolBarItemH);
                make.height.offset(kToolBarItemH+kPannelViewH);
            }];
            [self.view layoutIfNeeded];
        }];
        [self scrollToBottom];
    }];
    
    [[self rac_signalForSelector:@selector(chatInputView:didSendText:) fromProtocol:@protocol(LSChatInputViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)

        NSString *text = tuple.last;
        
        LSTextMessageModel *messageModel = [LSTextMessageModel new];
        [self configBaseMessageInfo:messageModel];
        messageModel.text = text;
        
        //创建时间消息
        [ShareMessageManager initMessageTimeModel:self.conversation timeStamp:messageModel.timeStamp];
        
        //发送消息
        [LSMessageManager sendTextMessage:messageModel conversation:self.conversation];
        
        [self addNewMessage:messageModel];
    }];
    
    [[self rac_signalForSelector:@selector(chatInputViewDidClickAddButton:) fromProtocol:@protocol(LSChatInputViewDelegate)] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        UIViewController *vc = [NSClassFromString(@"LSEmotionsShopViewController") new];
        [self.navigationController pushViewController:vc animated:YES];
        [self.chatInputView endIntput];
    }];
    
    [[self rac_signalForSelector:@selector(chatInputViewDidClickEditButton:) fromProtocol:@protocol(LSChatInputViewDelegate)] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        //我的表情
        LSMyEmotionViewController *vc = [NSClassFromString(@"LSMyEmotionViewController") new];
        
        [vc setEditComplteBlock:^(LSEmotionOperation operation, UIImage *image) {
            if (operation == LSEmotionOperationSend) {
                [self sendImage:image];
            }
        }];
        
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:naviVC animated:YES completion:nil];
    }];

    [[self rac_signalForSelector:@selector(chatInputViewDidClickCustomButton:) fromProtocol:@protocol(LSChatInputViewDelegate)] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        UIViewController *vc = [NSClassFromString(@"LSEmotionManagerViewController") new];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[self rac_signalForSelector:@selector(chatInputView:didClickFeatureItem:) fromProtocol:@protocol(LSChatInputViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        
        LSFeatureModel *model = tuple.last;
        
        if ([model.title isEqualToString:@"照片"]) {
            
            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
            imagePickerVc.isSelectOriginalPhoto = YES;
            imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
            imagePickerVc.allowPickingVideo = YES;
            imagePickerVc.allowPickingImage = YES;
            imagePickerVc.allowPickingOriginalPhoto = YES;
            imagePickerVc.allowPickingGif = YES;
            @weakify(self)
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                @strongify(self)
                
                for (PHAsset *asset in assets) {
                    //获取原图
                    [[TZImageManager manager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                        [self sendImage:photo];
                    }];
                }
                
            }];
            [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage,id asset){
                [[TZImageManager manager] getVideoWithAsset:asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
                    
                    AVAsset *currentPlayerAsset = playerItem.asset;
                    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) return ;
                    NSURL *url = [(AVURLAsset *)currentPlayerAsset URL];
                    NSString *filePath = [self copyAssetToCaptureFolder:url];
                    LSCaptureModel *model = [LSCaptureModel captureModelWithName:[filePath lastPathComponent]];
                    kDISPATCH_MAIN_THREAD(^{
                        [self sendVideo:model];
                    })
                }];
            }];

            [self presentViewController:imagePickerVc animated:YES completion:nil];
        }
        else if ([model.title isEqualToString:@"拍摄"]) {
            
            @weakify(self)
            [[ImagePickerManager new] takePhotoWithPresentedVC:self allocEditing:NO finishPicker:^(NSDictionary *info) {
                @strongify(self)
                UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
                [self sendImage:image];
            }];
        }
        else if ([model.title isEqualToString:@"小视频"]) {
            LSCaptureViewController *captureVC = [NSClassFromString(@"LSCaptureViewController") new];
            [captureVC setCapCompleteBlock:^(LSCaptureModel *model) {
                [self sendVideo:model];
            }];
            [self presentViewController:captureVC animated:YES completion:nil];
        }
        else {
            [self.view showAlertWithTitle:@"提示" message:@"功能尚未开放,敬请期待！" cancelAction:nil doneAction:nil];
        }
        
        [self.chatInputView endIntput];
    }];
    
    //录音
    [[self rac_signalForSelector:@selector(chatInputViewRecordComplete:recordPath:) fromProtocol:@protocol(LSChatInputViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        
        NSString *fileName = tuple.last;
        
        LSAudioMessageModel *messageModel = [LSAudioMessageModel new];
        [self configBaseMessageInfo:messageModel];
        messageModel.fileName = fileName;
        
        //创建时间消息
        [ShareMessageManager initMessageTimeModel:self.conversation timeStamp:messageModel.timeStamp];
        
        [self addNewMessage:messageModel];
        @weakify(self)
        [LSMessageManager sendAudioMessage:messageModel conversation:self.conversation uploadProgress:nil success:^{
            @strongify(self)
            
            NSInteger index = [self.dataSource indexOfObject:messageModel];
            NSIndexPath *idxPath = [NSIndexPath indexPathForRow:index inSection:0];
            LSBaseMessageCell *cell = [self.tableView cellForRowAtIndexPath:idxPath];
            [cell uploadComplete];
            
        } failure:nil];
        
    }];
    
}

- (NSString *)copyAssetToCaptureFolder:(NSURL *)sourceUrl {
    
    //沙盒中没有目录则新创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:kCaptureFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:kCaptureFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSString *destinationPath = [kCaptureFolder stringByAppendingPathComponent:[sourceUrl.absoluteString lastPathComponent]];
    
    destinationPath = [destinationPath stringByReplacingOccurrencesOfString:@"MOV" withString:@"mov"];
    
    NSError	*error;
    [[NSFileManager defaultManager] copyItemAtURL:sourceUrl toURL:[NSURL fileURLWithPath:destinationPath] error:&error];
    
    return destinationPath;
}

- (void)sendVideo:(LSCaptureModel *)model {
    
    LSVideoMessageModel *videoModel = [LSVideoMessageModel new];
    videoModel.localFileName = model.videoName;
    videoModel.localThumName = model.thumName;
    
    UIImage *thumImage = [model localThumImage];
    if (thumImage) {
        videoModel.originWidth = thumImage.size.width;
        videoModel.originHeight = thumImage.size.height;
    }
    
    [self configBaseMessageInfo:videoModel];
        
    //创建时间消息
    [ShareMessageManager initMessageTimeModel:self.conversation timeStamp:videoModel.timeStamp];
    
    [self addNewMessage:videoModel];
    
    [LSMessageManager sendVideoMessage:videoModel conversation:self.conversation uploadProgress:^(NSProgress *progress) {
        
        kDISPATCH_MAIN_THREAD(^{
            //获取上传进度
            NSInteger index = [self.dataSource indexOfObject:videoModel];
            NSIndexPath *idxPath = [NSIndexPath indexPathForRow:index inSection:0];
            
            LSBaseMessageCell *cell = [self.tableView cellForRowAtIndexPath:idxPath];
            cell.progress = progress;
        })
        
    } success:^{
        kDISPATCH_MAIN_THREAD(^{
            //隐藏loadingView
            NSInteger index = [self.dataSource indexOfObject:videoModel];
            NSIndexPath *idxPath = [NSIndexPath indexPathForRow:index inSection:0];
            LSBaseMessageCell *cell = [self.tableView cellForRowAtIndexPath:idxPath];
            [cell uploadComplete];
        })

    } failure:nil];
}

- (void)sendImages:(NSArray<UIImage *> *)images {
    
    for (UIImage *image in images) {
        [self sendImage:image];
    }
}

- (void)sendImage:(UIImage *)image {
    LSPictureMessageModel *picModel = [LSPictureMessageModel new];
    picModel.image = image;
    [self configBaseMessageInfo:picModel];
    
    //显示本地消息
    [self addNewMessage:picModel];
    
    //图片上传
    [LSMessageManager sendPictureMessage:picModel conversation:self.conversation uploadProgress:^(NSProgress *progress) {
        //获取上传进度
        kDISPATCH_MAIN_THREAD(^{
            NSInteger index = [self.dataSource indexOfObject:picModel];
            NSIndexPath *idxPath = [NSIndexPath indexPathForRow:index inSection:0];
            
            LSBaseMessageCell *cell = [self.tableView cellForRowAtIndexPath:idxPath];
            cell.progress = progress;
        })
        
    } success:^{
        
        kDISPATCH_MAIN_THREAD(^{
            //隐藏loadingView
            NSInteger index = [self.dataSource indexOfObject:picModel];
            NSIndexPath *idxPath = [NSIndexPath indexPathForRow:index inSection:0];
            LSBaseMessageCell *cell = [self.tableView cellForRowAtIndexPath:idxPath];
            [cell uploadComplete];
        })
        
    } failure:nil];
}

- (void)configBaseMessageInfo:(LSMessageModel *)message {
    message.conversation_id = self.conversation.conversationId;
    message.senderId = ShareAppManager.loginUser.user_id;
    message.sender = ShareAppManager.loginUser.user_name;
    message.senderAvartar = ShareAppManager.loginUser.avatar;
    message.timeStamp = [[NSDate date] timeIntervalSince1970];
    message.conversation_type = self.conversation.type;
    message.extension = [self messageExtentionOfConversation];
}

- (NSMutableDictionary *)messageExtentionOfConversation {
    
    NSMutableDictionary *ext = [NSMutableDictionary dictionary];
    ext[@"sender"] = ShareAppManager.loginUser.user_name;
    ext[@"senderAvartar"] = ShareAppManager.loginUser.avatar;
    ext[@"senderID"] = ShareAppManager.loginUser.user_id;
    
    if (self.conversation.type == LSConversationTypeGroup) {
        ext[@"conversation"] = self.conversation.title;
        ext[@"conversationAvartar"] = [self.conversation avartar];
    }
    else {
        ext[@"conversation"] = ShareAppManager.loginUser.user_name;
        ext[@"conversationAvartar"] = ShareAppManager.loginUser.avatar;
    }
    
    return ext;
}

- (void)addNewMessage:(LSMessageModel *)message {
    
    [self.dataSource addObject:message];
    
    [self.tableView beginUpdates];
    [self.tableView insertRow:self.dataSource.count-1 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    [self scrollToBottom];
}

#pragma mark - Getter & Setter
- (LSChatInputView *)chatInputView {
    if (!_chatInputView) {
        
        LSChatInputView *inputView = [LSChatInputView inputView];
        inputView.backgroundColor = [UIColor whiteColor];
        inputView.delegate = self;
        _chatInputView = inputView;

        [self chatInputViewDelegateActions];
    }
    
    return _chatInputView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView = tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        [tableView registerClass:NSClassFromString(@"LSMessageSystemCell") forCellReuseIdentifier:system_cell_reuse_id];
        [tableView registerClass:NSClassFromString(@"LSMessageTextCell") forCellReuseIdentifier:text_cell_reuse_id];
        [tableView registerClass:NSClassFromString(@"LSMessagePictureCell") forCellReuseIdentifier:image_cell_reuse_id];
        [tableView registerClass:NSClassFromString(@"LSMessageVoiceCell") forCellReuseIdentifier:voice_cell_reuse_id];
        [tableView registerClass:NSClassFromString(@"LSMessageVideoCell") forCellReuseIdentifier:video_cell_reuse_id];
        [tableView registerClass:NSClassFromString(@"LSMessageEmotionCell") forCellReuseIdentifier:emotion_cell_reuse_id];
        
        //聊天背景图
        UIImageView *chatBgView = [UIImageView new];
        self.chatBgView = chatBgView;
        chatBgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGest = [UITapGestureRecognizer new];
        @weakify(self)
        [[tapGest rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            [self.chatInputView endIntput];
        }];
        [chatBgView addGestureRecognizer:tapGest];
        tableView.backgroundView = chatBgView;
        
        //上拉刷新
        tableView.mj_header = [LSChatRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self)
            NSString *messageId = self.dataSource.firstObject.message_id;
            NSMutableArray<LSMessageModel *> * messageList = [ShareMessageManager messagesInConversation:self.conversation.conversationId earlierMessageId:messageId];
            [self.tableView.mj_header endRefreshing];
            if (messageList.count == 0) return;
            [self.dataSource insertObjects:messageList atIndex:0];
            [self.tableView reloadData];
            [self.tableView scrollToRow:messageList.count inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }];
        
    }
    
    return _tableView;
}

@end

