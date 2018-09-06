//
//  ConstKeys.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/12.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - WebSocket
extern NSString *const kWSUrl;
extern NSString *const kWSUploadUrl;


#define kConversationCache [NSString stringWithFormat:@"ConversationCache_%@",ShareAppManager.loginUser.user_id]

#pragma mark - Url
extern NSString *const kBaseUrl;
extern NSString *const kCenterUri;
#define CenterUri [kBaseUrl stringByAppendingPathComponent:kCenterUri]
extern NSString *const kLoginPath;
extern NSString *const kQQAuthPath;
extern NSString *const kWechatAuthPath;
extern NSString *const kSMSPath;
extern NSString *const kRegPath;
extern NSString *const kSmsValidatePath;
extern NSString *const kPwdFindPath;
extern NSString *const kSearchUserPath;
extern NSString *const kChangeUserIconPath;
extern NSString *const kChangeUserNamePath;
extern NSString *const kChangeSignaturePath;
extern NSString *const kBindmobilePath;
extern NSString *const kChangePWDPath;
extern NSString *const kSearhFriendWithPhoneListPath;


extern NSString *const kWechatPayPath;
extern NSString *const kAliPayPath;

extern NSString *const kShakePath;

extern NSString *const kOBaseUrl;
extern NSString *const kUploadImagePath;
extern NSString *const kUploadAudioPath;
extern NSString *const kUploadVideoPath;

extern NSString *const kEmoBaseURL;
extern NSString *const kEmoStorePath;
extern NSString *const kViewPackagePath;
extern NSString *const kPackageSearchPath;

#pragma mark - Fuwa

//extern NSString *const kBaseFuwaURL;

extern NSString *const kBaseFuwa2URL;

extern NSString *const kNearbyFuwaPath;
extern NSString *const kNearbyPartnerFuwaPath;
extern NSString *const kNearMerchantbyFuwaPath;
extern NSString *const kNearOnePartnerbyFuwaPath;





extern NSString *const kCaptureFuwaPath;
extern NSString *const kCaptureFuwaPath2;
#define kFuwaTopURL [NSString stringWithFormat:@"http://wsim.66boss.com/toplist/top.html?user=%@",ShareAppManager.loginUser.user_id]

#define kFuwaRuleURL @"http://stat.boss89.com/static/help/index.html"
#define kFuwaAnswerURL @"http://stat.boss89.com/static/help/interlocution.html"

extern NSString *const kQueryFuwaPath;
extern NSString *const kHiddenFuwaPath;
extern NSString *const kFuwaBackPackCatchPath;
extern NSString *const kFuwaBackPackApplyPath;
extern NSString *const kFuwaActivityPath;




extern NSString *const kFuwaDetailPath;
extern NSString *const kFuwaExchangePath;
extern NSString *const kFuwaExMyListPath;
extern NSString *const kFuwaMyMessagePath;
extern NSString *const kFuwaApplyPath;
extern NSString *const kFuwaAwardPath;
extern NSString *const kFuwacancelSellPath;

extern NSString *const kFuwaHit;
extern NSString *const kFuwaQueryVideo;
extern NSString *const kFuwaQuerystrVideo;
extern NSString *const kFuwaQureyClass;

extern NSString *const kInReviewPath;

#pragma mark - Noti
//停止录音播放通知
extern NSString *const kStopAudioPlayNoti;
//选取表情图片的通知
extern NSString *const kSelectEmotionNoti;
extern NSString *const kMessageUnReadCountDidChange;
//修改人脉资料通知
extern NSString *const kCompleteLinkInInfoNoti;
extern NSString *const kCelebrityLinkInInfoNoti;
//修改人脉简介通知
extern NSString *const kIntroduceLinkInInfoNoti;
//表情包更新-下载或者移除
extern NSString *const kEmotionPackageUpdateNoti;
//移除聊天消息
extern NSString *const kRemoveMessagesInConversation;
//支付成功的通知
extern NSString *const kPaySuccessNoti;
//审核状态通知
extern NSString *const kInReviewNoti;
//用户信息发生改变
extern NSString *const kUserInfoChangeNoti;

#pragma mark - timelineUrl
extern NSString *const kTimeLineListPath;
extern NSString *const kTimeLineChangeBGImagePath;
extern NSString *const kPostTimeLinePath;
extern NSString *const kPostVideoTimeLinePath;
extern NSString *const kdeleteTimeLinePath;
extern NSString *const kdeleteTimeLineCommentPath;
extern NSString *const kPriseTimeLinePath;
extern NSString *const kloadTimeLineDetailPath;
extern NSString *const kaddComnentPath;
extern NSString *const kgalleryListPath;
extern NSString *const kTimeLineMsgListPath;
extern NSString *const kTimeLineGetNewMsgPath;
extern NSString *const kTimeLineDeleteAllMsgPath;
extern NSString *const kTimeLineDeleteOneMsgPath;
extern NSString *const kreloadTimeLineNoti;


#pragma mark -friendList
extern NSString *const kFriendListPath;


#define NSNotificationName
extern NSString *const TimeLineMessageNoti;
extern NSString *const TimeLineGoodAndCommentBtnNoti;
extern NSString *const TimeLineMyIconNoti;
extern NSString *const TimeLineBGImageNoti;

extern NSString *const TimeLineDoneBGImageNoti;
extern NSString *const showOptionsViewNoti;
extern NSString *const TimeLineReloadCellNoti;
extern NSString *const addCommentViewNoti;
extern NSString *const FriendListLabelNoti;
extern NSString *const TimeLinePermissionNoti;
extern NSString *const kreloadTimeLineNoti;

extern NSString *const reloadInfoNoti;
extern NSString *const reloadBackPackoti;

extern NSString *const kFuwaNewAdressNoti;

extern NSString *const kGroupReduceMembersNoti;
extern NSString *const kSendMessageNoti;
extern NSString *const kSendGroupMessageNoti;
#pragma mark 人脉接口
extern NSString *const kLinkInListPath;//学校列表
extern NSString *const kLinkIndeletePath;//删除学校
extern NSString *const kHobbiesPath;//兴趣爱好
extern NSString *const kWorkPath;//工作
extern NSString *const kAddSchoolPath;//添加学校
extern NSString *const kUpdateSchoolPath;//更新学校信息
extern NSString *const kIndexLinkPath;//人脉首页
extern NSString *const kUpdateInfoPath;//完善用户信息
extern NSString *const kqueryMoneyPath;//查询余额
extern NSString *const kGetMoneyPath;//查询余额
extern NSString *const kStoretribePath ;


extern NSString *const kCelebrityPath;//学校名人
extern NSString *const khCelebrityPath;//家乡名人
extern NSString *const kclanCelebrityPath;//宗亲名人
extern NSString *const kcofcCelebrityPath;//商会名人
extern NSString *const ksCommunityPath;//学校协会
extern NSString *const khCommunityPath;//家乡商会
extern NSString *const kContactsmsgPath;//消息列表
extern NSString *const kContactflushallPath;//清空消息列表
extern NSString *const kContactdeletePath;//删除某一条消息
extern NSString *const kContactsfeedPath;//获取帖子列表
extern NSString *const kContDateilsfeedPath;//获取帖子详情
extern NSString *const kCreatefeedPath;//发布帖子
extern NSString *const kCommentfeedPath;//评论帖子
extern NSString *const kPraisefeedPath;//点赞帖子
extern NSString *const kDeletefeedPath;//删除帖子
extern NSString *const kContactscPath;//人脉中心列表
extern NSString *const kCommentPath;//删除评论
extern NSString *const kUserinfoPath;//获取好友资料列表

#pragma mark 通讯录接口
extern NSString *const kFriendsPath;//好友列表
extern NSString *const kNewfriendsPath;//新添加好友列表
extern NSString *const kFindmanPath;//查找好友
extern NSString *const kSearchSchooPath;//搜索学校
extern NSString *const kDeleteFriendsPath;//删除好友
extern NSString *const kSendFriendsPath;//发送好友请求
extern NSString *const kIsFriendsPath;//判断是否好友
extern NSString *const kDealFriendsPath;//处理好友请求
extern NSString *const kMatchPhonePath;//匹配好友
extern NSString *const kSameSchoolPath;//学校列表
extern NSString *const kSameHomePath;//家乡列表
extern NSString *const kRandPath;//随便看看
extern NSString *const kSearchPath;//搜索人脉用户
extern NSString *const kSearchgPath;
extern NSString *const kClanAddPath;//添加宗亲名人
extern NSString *const kCofcAddPath;//添加商会名人

#pragma mark 群聊接口
extern NSString *const kGroupPath;//群聊列表
extern NSString *const kCreateGroupPath;//创建群聊
extern NSString *const kQueryGroupPath;//查询群信息
extern NSString *const kModifyGroupPath;//修改群资料
extern NSString *const kAddMembersPath;//增加群成员
extern NSString *const kDelmembersPath;//移除群成员

extern NSString *const kNearUserPath;//附近的人
extern NSString *const kUpdateLocationPath;//更新位置

extern NSString *const kSchoolPath;//学校信息
extern NSString *const kHometownlPath;//家乡信息

extern NSString *const kFriendslogCountPath;//好友数量
extern NSString *const kGetNeWestPath ;//消息数

extern NSString *const kAcceptPath;//接受好友
extern NSString *const kAddContactPath ;//添加好友

extern NSString *const kContactInfoNoti;//刷新联系人
extern NSString *const kLinkSchoolInfoNoti ;//刷新人脉详情
extern NSString *const kAddContactInfoNoti;//好友添加消息
extern NSString *const kFuwaCatchInfoNoti;//明天再来通知

extern NSString *const khMessagePath;//家乡动态列表
extern NSString *const ksMessagePath;//学校动态列表

extern NSString *const kCofcCreatePath;//创建商会
extern NSString *const kClanCreatePath;//创建宗亲
extern NSString *const kStoretribeCreatePath;//创建企业号
extern NSString *const kClanUpdatePath;//修改宗亲
extern NSString *const kCofcUpdatePath;//修改商会
extern NSString *const kStoretribeUpdatePath ;//修改企业号

extern NSString *const kCofcGetInfoPath;//获取商会信息
extern NSString *const kClanGetInfoPath;//获取宗亲信息
extern NSString *const kStoretribeGetInfoPath;//获取企业号信息
extern NSString *const kCofcFoucePath;//关注商会
extern NSString *const kClanFoucePath;//关注宗亲
extern NSString *const kStoretribeFoucePath;//关注企业号

extern NSString *const kClanCancelFoucePath;//取消关注宗亲
extern NSString *const kCofcCancelFoucePath;//取消关注商会
extern NSString *const kStoretribeCancelFoucePath;//取消关注企业号
extern NSString *const kCofcIsFoucePath;//是否关注商会
extern NSString *const kClanIsFoucePath;//是否关注宗亲
extern NSString *const kCofcIsFoucePath;//是否关注商会
extern NSString *const kStoretribeIsFoucePath;//是否关注企业号
extern NSString *const kClanCelebrityDeletePath;//删除宗亲名人
extern NSString *const kCofcCelebrityDeletePath;//删除商会名人
extern NSString *const kClanUpdateCelebrityPath;//编辑宗亲名人
extern NSString *const kCofcUpdateCelebrityPath;//编辑商会名人
extern NSString *const kClanDeletePath;//删除宗亲
extern NSString *const kCofcDeletePath;//删除名人
extern NSString *const kStoretribeDeletePath;//删除企业号
extern NSString *const kClanHotSearchPath;//宗亲列表
extern NSString *const kCofcHotSearchPath;//商会列表
extern NSString *const kFavoritesPath;//收藏列表
extern NSString *const kAddFavoritesPath;//添加收藏
extern NSString *const kDeleteFavoritesPath;//删除收藏

extern NSString *const TimeLinePlayVideoNoti;
