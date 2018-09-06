//
//  ConstKeys.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/12.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "ConstKeys.h"

#pragma mark - WebSocket
//NSString *const kWSUrl = @"ws://live.66boss.com:6060/entry";
NSString *const kWSUrl = @"ws://wsim.hmg66.com:8080/entry";
NSString *const kWSUploadUrl = @"http://wsim.hmg66.com";

#pragma mark - Url
NSString *const kBaseUrl = @"https://api.66boss.com";
NSString *const kCenterUri = @"ucenter";
NSString *const kLoginPath = @"login/index";
NSString *const kQQAuthPath = @"login/qqoath";
NSString *const kWechatAuthPath = @"login/wxoath";
NSString *const kSMSPath = @"sms/index";
NSString *const kRegPath = @"reg/index";
NSString *const kSmsValidatePath = @"sms/validatecode";
NSString *const kPwdFindPath = @"psw/find";
NSString *const kSearchUserPath = @"ucenter/userinfo/index";
NSString *const kChangeUserIconPath = @"ucenter/userinfo/changeavatar";
NSString *const kChangeUserNamePath = @"ucenter/userinfo/updateuname";
NSString *const kChangeSignaturePath = @"ucenter/userinfo/updatesignature";
NSString *const kBindmobilePath = @"ucenter/userinfo/bindmobile";
NSString *const kChangePWDPath = @"ucenter/psw/index";
NSString *const kSearhFriendWithPhoneListPath = @"ucenter/matchphone";

NSString *const kWechatPayPath = @"api/pay/weixin";
NSString *const kAliPayPath = @"api/pay/alipay";

NSString *const kOBaseUrl = @"http://wsim.hmg66.com";
NSString *const kUploadImagePath = @"upload/writev2";
NSString *const kUploadAudioPath = @"upload/writev1";
NSString *const kUploadVideoPath = @"upload/writev3";

NSString *const kEmoBaseURL = @"https://imgcdn.66boss.com/emo/assets";
NSString *const kEmoStorePath = @"api/v1/store";
NSString *const kViewPackagePath = @"api/v1/store/viewpack";
NSString *const kPackageSearchPath = @"api/v1/search/store";

#pragma mark - Fuwa
//NSString *const kBaseFuwaURL = @"http://wsimali.66boss.com:9090";

//NSString *const kBaseFuwa2URL = @"http://fuwa2.66boss.com:9090";
NSString *const kBaseFuwa2URL = @"http://fuwa.hmg66.com";



NSString *const kNearbyFuwaPath = @"api/queryv2";
NSString *const kNearbyPartnerFuwaPath = @"api/querystrangerv2";
NSString *const kNearMerchantbyFuwaPath = @"api/queryv3";
NSString *const kNearOnePartnerbyFuwaPath = @"api/querystrangerv3";


NSString *const kCaptureFuwaPath2 = @"/api/capturev2";
NSString *const kCaptureFuwaPath = @"api/capture";
NSString *const kQueryFuwaPath = @"api/querymy";
NSString *const kHiddenFuwaPath = @"api/hidev2";
NSString *const kFuwaBackPackCatchPath = @"api/querymy";
NSString *const kFuwaBackPackApplyPath = @"api/querymyapply";
NSString *const kFuwaActivityPath = @"api/huodong";


NSString *const kFuwaDetailPath = @"api/querydetail";
NSString *const kFuwaExchangePath = @"msg/querysell";
NSString *const kFuwaExMyListPath = @"msg/querymysell";
NSString *const kFuwaMyMessagePath = @"msg/myinfo";
NSString *const kFuwaApplyPath = @"msg/apply";
NSString *const kFuwaAwardPath = @"api/award";
NSString *const kFuwacancelSellPath = @"msg/cancelsell";

NSString *const kFuwaQueryVideo = @"api/queryvideo";
NSString *const kFuwaQuerystrVideo = @"api/querystrvideo";
NSString *const kFuwaQureyClass = @"api/queryclass";
NSString *const kFuwaHit = @"/api/hit";


NSString *const kInReviewPath = @"http://live.66boss.com/weibo/pass";

#pragma mark - Noti
NSString *const kStopAudioPlayNoti = @"kStopAudioPlayNoti";
NSString *const kSelectEmotionNoti = @"kSelectEmotionNoti";
NSString *const kMessageUnReadCountDidChange = @"kMessageUnReadCountDidChange";
NSString *const kCompleteLinkInInfoNoti = @"kCompleteLinkInInfoNoti";
NSString *const kCelebrityLinkInInfoNoti = @"kCelebrityLinkInInfoNoti";
NSString *const kIntroduceLinkInInfoNoti = @"kIntroduceLinkInInfoNoti";
NSString *const kEmotionPackageUpdateNoti = @"kEmotionPackageUpdateNoti";
NSString *const kRemoveMessagesInConversation = @"kRemoveMessagesInConversation";
NSString *const kGroupReduceMembersNoti = @"kGroupReduceMembersNoti";
NSString *const kPaySuccessNoti = @"kPaySuccessNoti";
NSString *const kInReviewNoti = @"kInReviewNoti";
NSString *const kUserInfoChangeNoti = @"kUserInfoChangeNoti";

#pragma mark - timelineUrl
NSString *const kTimeLineListPath = @"api/v1/cofriends";
NSString *const kTimeLineChangeBGImagePath = @"ucenter/userinfo/uploadcoverpic";
NSString *const kPostTimeLinePath = @"api/v1/cofriends/create";
NSString *const kPostVideoTimeLinePath = @"api/v1/cofriends/createvideo";
NSString *const kdeleteTimeLinePath = @"api/v1/cofriends/delete";
NSString *const kdeleteTimeLineCommentPath = @"api/v1/comment/delete";

NSString *const kPriseTimeLinePath = @"api/v1/praise/create";
NSString *const kloadTimeLineDetailPath = @"api/v1/cofriends/view";
NSString *const kaddComnentPath = @"api/v1/comment/create";
NSString *const kgalleryListPath = @"api/v1/gallery";
NSString *const kTimeLineMsgListPath = @"api/v1/message";
NSString *const kTimeLineDeleteAllMsgPath = @"api/v1/message/flushall";
NSString *const kTimeLineDeleteOneMsgPath = @"api/v1/message/delete";
NSString *const kTimeLineGetNewMsgPath = @"api/v1/message/getnewest";

NSString *const kShakePath = @"ucenter/shakeuser/index";



#pragma mark -friendList
NSString *const kFriendListPath = @"ucenter/friends/index";




#pragma mark notificationName
NSString *const TimeLineMessageNoti = @"TimeLineMessageNoti";
NSString *const TimeLineGoodAndCommentBtnNoti = @"TimeLineGoodAndCommentBtnNoti";
NSString *const TimeLineMyIconNoti = @"TimeLineMyIconNoti";
NSString *const TimeLineBGImageNoti = @"TimeLineBGImageNoti";
NSString *const TimeLineDoneBGImageNoti = @"TimeLineDoneBGImageNoti";
NSString *const showOptionsViewNoti = @"showOptionsViewNoti";
NSString *const TimeLineReloadCellNoti = @"TimeLineReloadCellNoti";
NSString *const addCommentViewNoti = @"addCommentViewNoti";
NSString *const kreloadTimeLineNoti = @"kreloadTimeLineNoti";

NSString *const reloadInfoNoti = @"reloadInfoNoti";
NSString *const reloadBackPackoti = @"reloadBackPackoti";



NSString *const FriendListLabelNoti = @"FriendListLabelNoti";
NSString *const TimeLinePermissionNoti = @"TimeLinePermissionNoti";

NSString *const kFuwaNewAdressNoti = @"kFuwaNewAdressNoti";

NSString *const kSendMessageNoti = @"kSendMessageNoti";
NSString *const kSendGroupMessageNoti = @"kSendGroupMessageNoti";
NSString *const kLinkInListPath = @"/api/v1/userschool";
NSString *const kLinkIndeletePath =@"/api/v1/userschool/delete";

NSString *const kHobbiesPath = @"/api/v1/interest";
NSString *const kWorkPath = @"/api/v1/industry";
NSString *const kAddSchoolPath = @"/api/v1/userschool/create";
NSString *const kUpdateSchoolPath = @"/api/v1/userschool/update";
NSString *const kIndexLinkPath = @"/api/v1/contacts";
NSString *const kUpdateInfoPath = @"/ucenter/userinfo/update";
NSString *const kGetMoneyPath = @"msg/money";
NSString *const kStoretribePath = @"/api/v1/storetribe/createby";

NSString *const kqueryMoneyPath = @"msg/querymoney";


NSString *const kCelebrityPath = @"/api/v1/school/celebrity";
NSString *const khCelebrityPath = @"/api/v1/hometown/celebrity";
NSString *const kclanCelebrityPath = @"/api/v1/clan/getcelebrity";
NSString *const kcofcCelebrityPath = @"/api/v1/cofc/getcelebrity";

NSString *const khMessagePath = @"/api/v1/hometown/message";
NSString *const ksMessagePath = @"/api/v1/school/message";

NSString *const ksCommunityPath = @"/api/v1/school/league";
NSString *const khCommunityPath = @"/api/v1/hometown/cofc";

NSString *const kContactsmsgPath = @"/api/v1/contactsmsg";

NSString *const kContactflushallPath = @"/api/v1/contactsmsg/flushall";
NSString *const kContactdeletePath = @"/api/v1/contactsmsg/delete";

NSString *const kContactsfeedPath = @"/api/v1/contactsfeed";

NSString *const kCreatefeedPath = @"/api/v1/contactsfeed/create";

NSString *const kCommentfeedPath = @"/api/v1/contactscomment/create";

NSString *const kPraisefeedPath = @"/api/v1/contactspraise/create";

NSString *const kDeletefeedPath = @"/api/v1/contactsfeed/delete";

NSString *const kContactscPath = @"/api/v1/contactsc";

NSString *const kCommentPath = @"/api/v1/contactscomment/delete";

NSString *const kUserinfoPath = @"/ucenter/userinfo/index";

NSString *const kFriendsPath = @"/ucenter/friends/index";

NSString *const kNewfriendsPath = @"/ucenter/friendslog/index";

NSString *const kFindmanPath = @"/ucenter/userinfo/findman";

NSString *const kSearchSchooPath = @"/api/v1/search/local-school";

NSString *const kDeleteFriendsPath = @"/ucenter/friends/delete";

NSString *const kSendFriendsPath = @"/ucenter/friendslog/create";

NSString *const kIsFriendsPath = @"/ucenter/friends/isfriend";

NSString *const kDealFriendsPath = @"/ucenter/friendslog/update";

NSString *const kMatchPhonePath = @"/ucenter/matchphone";
NSString *const kGroupPath = @":8080/querymygrps";
NSString *const kCreateGroupPath = @":8080/creategrp";
NSString *const kQueryGroupPath = @":8080/grpinfo";
NSString *const kModifyGroupPath = @":8080/editgrp";
NSString *const kAddMembersPath = @":8080/addmembers";
NSString *const kDelmembersPath = @":8080/delmembers";

NSString *const kSameSchoolPath = @"/api/v1/search/same-school";
NSString *const kSameHomePath = @"/api/v1/search/same-home";
NSString *const kRandPath = @"/api/v1/search/rand";

NSString *const kSearchgPath = @"/api/v1/search/g";
NSString *const kSearchPath = @"/api/v1/search/user";
NSString *const kNearUserPath = @"/ucenter/nearuser/index";
NSString *const kUpdateLocationPath = @"/ucenter/nearuser/update";
NSString *const kContDateilsfeedPath = @"/api/v1/contactsfeed/view";

NSString *const kSchoolPath =@"/api/v1/school";
NSString *const kHometownlPath =@"/api/v1/hometown";
NSString *const kFriendslogCountPath = @"/ucenter/friendslog/count";

NSString *const kGetNeWestPath = @"/api/v1/contactsmsg/getnewest";

NSString *const kCofcCreatePath = @"/api/v1/cofc/create";
NSString *const kClanCreatePath = @"/api/v1/clan/create";
NSString *const kStoretribeCreatePath = @"/api/v1/storetribe/create";

NSString *const kClanUpdatePath = @"/api/v1/clan/update";
NSString *const kCofcUpdatePath = @"/api/v1/cofc/update";
NSString *const kStoretribeUpdatePath = @"/api/v1/storetribe/update";

NSString *const kClanAddPath = @"/api/v1/clan/addcelebrity";
NSString *const kCofcAddPath = @"/api/v1/cofc/addcelebrity";

NSString *const kClanUpdateCelebrityPath = @"/api/v1/clan/updatecelebrity";
NSString *const kCofcUpdateCelebrityPath = @"/api/v1/cofc/updatecelebrity";

NSString *const kClanGetInfoPath = @"/api/v1/clan";
NSString *const kCofcGetInfoPath = @"/api/v1/cofc";
NSString *const kStoretribeGetInfoPath = @"/api/v1/storetribe";

NSString *const kCofcFoucePath = @"/api/v1/cofc/follow";
NSString *const kClanFoucePath = @"/api/v1/clan/follow";
NSString *const kStoretribeFoucePath = @"/api/v1/storetribe/follow";

NSString *const kClanCancelFoucePath = @"/api/v1/clan/unfollow";
NSString *const kCofcCancelFoucePath = @"/api/v1/cofc/unfollow";
NSString *const kStoretribeCancelFoucePath = @"/api/v1/storetribe/unfollow";

NSString *const kCofcIsFoucePath = @"/api/v1/cofc/isfollow";
NSString *const kClanIsFoucePath = @"/api/v1/clan/isfollow";
NSString *const kStoretribeIsFoucePath = @"/api/v1/storetribe/isfollow";

NSString *const kClanCelebrityDeletePath = @"/api/v1/clan/delcelebrity";
NSString *const kCofcCelebrityDeletePath = @"/api/v1/cofc/delcelebrity";

NSString *const kClanHotSearchPath = @"/api/v1/search/hot-clan";
NSString *const kCofcHotSearchPath = @"/api/v1/search/hot-cofc";

NSString *const kClanDeletePath = @"/api/v1/clan/delete";
NSString *const kCofcDeletePath = @"/api/v1/cofc/delete";
NSString *const kStoretribeDeletePath = @"/api/v1/storetribe/delete";

#pragma mark -- ;
NSString *const kAcceptPath = @"accept";//接受好友
NSString *const kAddContactPath = @"addContact";//添加好友
NSString *const kFavoritesPath = @"/api/v1/favorites";
NSString *const kAddFavoritesPath = @"/api/v1/favorites/add";
NSString *const kDeleteFavoritesPath = @"/api/v1/favorites/delete";

NSString *const kContactInfoNoti = @"kContactInfoNoti";
NSString *const kLinkSchoolInfoNoti = @"kLinkSchoolInfoNoti";
NSString *const kAddContactInfoNoti = @"kAddContactInfoNoti";
NSString *const kFuwaCatchInfoNoti = @"kFuwaCatchInfoNoti";

NSString *const TimeLinePlayVideoNoti = @"kTimeLinePlayVideoNoti";
