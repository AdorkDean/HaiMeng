//
//  LSBaseMessageCell.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMessageModel.h"
#import "YYPhotoGroupView.h"

#define kTextFont SYSTEMFONT(16) //消息字体大小
#define kAvatarMarginTop 4 //头像的 margin top
#define kAvatarMarginLeft 10
#define kAvatarWidth 45

#define kNickNameMarginTop kAvatarMarginTop + 1
#define kNickNameHeight 15
#define kNickNameLeftOffSet 10

#define kBubbleMarginNickName 3
#define kBubbleMarginTop kNickNameMarginTop + kBubbleMarginNickName
#define kBubblePadding UIEdgeInsetsMake(10, 15, 15, 15)
#define kBubbleMarginLeft 4

#define kBubbleMinHeight 54
#define kBubbleMinWidth 50

#define kTextMaxWidth kScreenWidth - 72 - 82 //消息在右边， 70：文本离屏幕左的距离，  82：文本离屏幕右的距离

#define kImageMinHeight 50
#define kImageMaxWidth kScreenWidth*0.5
#define kImageMaxHeight kImageMaxWidth
#define kImageMinWidth 50

#define kVoiceImageMarginR 28
#define kVoiceImageMarginL 18

#define kEmotionOffsetL 10


@class LSMessageProgressView;
@interface LSBaseMessageCell : UITableViewCell

//公用的视图view
@property (nonatomic,strong) UIImageView *avatarView;
@property (nonatomic,strong) UILabel *nicknameLabel;
@property (nonatomic,strong) UIImageView *bubbleView;

//点击头像回调
@property (copy,nonatomic) void (^avaterClick)(LSMessageModel * model);
@property (copy,nonatomic) void (^deleteMessageBlock)(LSMessageModel * model);
@property (copy,nonatomic) void (^forwardBlock)(LSMessageModel *model);
@property (copy,nonatomic) void (^favorBlock)(LSMessageModel *model);

@property (nonatomic,copy) void (^playClick)(NSURL * playURL,UIImage * image);

@property (nonatomic,strong) UIImage *senderBubbleImage;
@property (nonatomic,strong) UIImage *receiverBubbleImage;

@property (nonatomic,strong) LSMessageProgressView *progressView;
@property (nonatomic,strong) NSProgress *progress;
- (void)uploadComplete;

@property (nonatomic,strong) LSMessageModel *model;

//获取当前的图片数组
@property (nonatomic,copy) NSArray<YYPhotoGroupItem *> *(^photoItemsBlock)(LSMessageModel *message);

+ (CGFloat)cellHeightForMessage:(LSMessageModel *)message;

//添加遮罩图层
- (void)makeMaskView:(UIView *)view withImage:(UIImage *)image;

- (BOOL)hasProgressView;

//手势事件
- (void)bubbleViewDidTapAction;
- (void)bubbleViewDidLongTapAction;

@end

@interface LSMessageProgressView : UIView

@property (nonatomic,assign) CGFloat ratio;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end
