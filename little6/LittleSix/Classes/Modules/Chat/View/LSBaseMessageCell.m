//
//  LSBaseMessageCell.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSBaseMessageCell.h"
#import "LSMessageManager.h"

@implementation LSBaseMessageCell

+ (CGFloat)cellHeightForMessage:(LSMessageModel *)message {
    
    if (message.messageType == LSMessageTypeTime) {
        message.cellHeight = 26.5;
    }else if (message.messageType == LSMessageTypeSystem) {

        CGFloat textHeight = [message.systemMessage heightForFont:SYSTEMFONT(12) width:kScreenWidth-70];

        CGFloat cellHeight = (textHeight+4) + 8;
        return cellHeight;
    }
    else if (message.messageType == LSMessageTypeText) {
        [self heightForTextMessage:message];
    }
    else if (message.messageType == LSMessageTypePicture) {
        [self heightForImageMessage:message];
    }//音频
    else if (message.messageType == LSMessageTypeAudio) {
        [self heightForVoiceMessage:message];
    }
    else if (message.messageType == LSMessageTypeVideo) {
        [self heightForVideoMessage:message];
    }
    else if (message.messageType == LSMessageTypeEmotion) {
        [self heightForEmotionMessage:message];
    }
    
    //异步将模型保存到数据库
    [ShareMessageManager updateMessage:message];
    
    return message.cellHeight;
}

+ (void)heightForTextMessage:(LSMessageModel *)message {
    
    LSTextMessageModel *textMessage = (LSTextMessageModel *)message;
    
    NSMutableAttributedString *attributedString = [LSTextParaser parseText:textMessage.text withFont:kTextFont];
    
    textMessage.richTextAttributedString = attributedString;
    
    CGSize constSize = CGSizeMake(kTextMaxWidth, CGFLOAT_MAX);
    
    //计算文本的高度
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:constSize text:attributedString];
    CGSize size = CGSizeMake(layout.textBoundingSize.width, layout.textBoundingSize.height);
    
    textMessage.textWidth = size.width;
    textMessage.textHeight = size.height;
    
    CGFloat height = kBubblePadding.top + kBubblePadding.bottom + size.height;
    
    if (message.fromMe||message.conversation_type == LSConversationTypeChat) {
        height = MAX(height, kBubbleMinHeight) + kBubbleMarginTop;
    }
    else {
        height = MAX(height, kBubbleMinHeight) + kBubbleMarginTop + kNickNameHeight;
    }
    
    message.cellHeight = height;
}

+ (void)heightForImageMessage:(LSMessageModel *)message {
    
    LSPictureMessageModel *pictureModel = (LSPictureMessageModel *)message;
    
    CGFloat imageW;
    CGFloat imageH;
    
    if (message.fromMe) {
        imageW = pictureModel.image.size.width;
        imageH = pictureModel.image.size.height;
    }
    else {
        imageW = pictureModel.originWidth;
        imageH = pictureModel.originHeight;
    }
    
    CGFloat scale = imageW/imageH;
    
    if (imageH >= imageW) {
        if (imageH >= kImageMaxHeight) {
            pictureModel.scaleHeight = kImageMaxHeight;
            pictureModel.scaleWidth = kImageMaxHeight*scale;
        }
        else if (imageW >= kImageMaxWidth) {
            pictureModel.scaleWidth = kImageMaxWidth;
            pictureModel.scaleHeight = kImageMaxWidth / scale;
        }
        else {
            pictureModel.scaleHeight = imageH;
            pictureModel.scaleWidth = imageW;
        }
    }
    else {
        if (imageW >= kImageMaxWidth) {
            pictureModel.scaleWidth = kImageMaxWidth;
            pictureModel.scaleHeight = kImageMaxWidth / scale;
        }
        else if(imageH >= kImageMaxHeight) {
            pictureModel.scaleHeight = kImageMaxHeight;
            pictureModel.scaleWidth = kImageMaxHeight * scale;
        }
        else {
            pictureModel.scaleWidth = imageW;
            pictureModel.scaleHeight = imageH;
        }
    }
    
    CGFloat height;
    
    if (message.fromMe) {
        height = pictureModel.scaleHeight + kBubbleMarginTop;
    }
    else {
        if (message.conversation_type == LSConversationTypeChat) {
            height = pictureModel.scaleHeight + kBubbleMarginTop;
        }
        else {
            height = pictureModel.scaleHeight + kBubbleMarginTop + kNickNameHeight;
        }
    }
    
    message.cellHeight = height;
}

+ (void)heightForVideoMessage:(LSMessageModel *)message {
    
    LSVideoMessageModel *videoModel = (LSVideoMessageModel *)message;
    
    CGFloat imageW = videoModel.originWidth;
    CGFloat imageH = videoModel.originHeight;
    
    CGFloat scale = imageW/imageH;
    
    if (imageH >= imageW) {
        if (imageH >= kImageMaxHeight) {
            videoModel.scaleHeight = kImageMaxHeight;
            videoModel.scaleWidth = kImageMaxHeight*scale;
        }
        else if (imageW >= kImageMaxWidth) {
            videoModel.scaleWidth = kImageMaxWidth;
            videoModel.scaleHeight = kImageMaxWidth / scale;
        }
        else {
            videoModel.scaleHeight = imageH;
            videoModel.scaleWidth = imageW;
        }
    }
    else {
        if (imageW >= kImageMaxWidth) {
            videoModel.scaleWidth = kImageMaxWidth;
            videoModel.scaleHeight = kImageMaxWidth / scale;
        }
        else if(imageH >= kImageMaxHeight) {
            videoModel.scaleHeight = kImageMaxHeight;
            videoModel.scaleWidth = kImageMaxHeight * scale;
        }
        else {
            videoModel.scaleWidth = imageW;
            videoModel.scaleHeight = imageH;
        }
    }
    
    CGFloat height;
    
    if (message.fromMe) {
        height = videoModel.scaleHeight + kBubbleMarginTop;
    }
    else {
        if (message.conversation_type == LSConversationTypeChat) {
            height = videoModel.scaleHeight + kBubbleMarginTop;
        }
        else {
            height = videoModel.scaleHeight + kBubbleMarginTop + kNickNameHeight;
        }
    }
    
    message.cellHeight = height;
}

+ (void)heightForVoiceMessage:(LSMessageModel *)message {
    
    CGFloat height;
    
    if (message.fromMe) {
        height = kBubbleMinHeight + kBubbleMarginTop;
    }
    else {
        if (message.conversation_type == LSConversationTypeChat) {
            height = kBubbleMinHeight + kBubbleMarginTop;
        }
        else {
            height = kBubbleMinHeight + kBubbleMarginTop + kNickNameHeight;
        }
    }

    message.cellHeight = height;
}

+ (void)heightForEmotionMessage:(LSMessageModel *)message {
    
    LSEmotionMessageModel *emotionModel = (LSEmotionMessageModel *)message;
    
    CGFloat imageW = emotionModel.originWidth;
    CGFloat imageH = emotionModel.originHeight;
    
    CGFloat scale = imageW/imageH;
    
    if (imageH >= imageW) {
        if (imageH >= kImageMaxHeight) {
            emotionModel.scaleHeight = kImageMaxHeight;
            emotionModel.scaleWidth = kImageMaxHeight*scale;
        }
        else if (imageW >= kImageMaxWidth) {
            emotionModel.scaleWidth = kImageMaxWidth;
            emotionModel.scaleHeight = kImageMaxWidth / scale;
        }
        else {
            emotionModel.scaleHeight = imageH;
            emotionModel.scaleWidth = imageW;
        }
    }
    else {
        if (imageW >= kImageMaxWidth) {
            emotionModel.scaleWidth = kImageMaxWidth;
            emotionModel.scaleHeight = kImageMaxWidth / scale;
        }
        else if(imageH >= kImageMaxHeight) {
            emotionModel.scaleHeight = kImageMaxHeight;
            emotionModel.scaleWidth = kImageMaxHeight * scale;
        }
        else {
            emotionModel.scaleWidth = imageW;
            emotionModel.scaleHeight = imageH;
        }
    }
    
    CGFloat height;
    
    if (message.fromMe) {
        height = emotionModel.scaleHeight + kBubbleMarginTop;
    }
    else {
        if (message.conversation_type == LSConversationTypeChat) {
            height = emotionModel.scaleHeight + kBubbleMarginTop;
        }
        else {
            height = emotionModel.scaleHeight + kBubbleMarginTop + kNickNameHeight;
        }
    }
    
    message.cellHeight = height + 8;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.model) return;
    if (self.model.messageType == LSMessageTypeTime || self.model.messageType == LSMessageTypeSystem) return;
    
    if (self.model.fromMe) {
        CGFloat avatarX = kScreenWidth-kAvatarMarginLeft-kAvatarWidth;
        self.avatarView.frame = CGRectMake(avatarX, kAvatarMarginTop, kAvatarWidth, kAvatarWidth);
    }
    else {
        self.avatarView.frame = CGRectMake(kAvatarMarginLeft, kAvatarMarginTop, kAvatarWidth, kAvatarWidth);
        //显示昵称
        if (self.model.conversation_type == LSConversationTypeGroup) {
            CGFloat nicknameX = CGRectGetMaxX(self.avatarView.frame) + kBubbleMarginLeft;
            self.nicknameLabel.frame = CGRectMake(nicknameX + kNickNameLeftOffSet, kNickNameMarginTop, kScreenWidth, kNickNameHeight);
        }
    }
}

- (BOOL)hasProgressView {
    return _progressView;
}

//添加遮罩图层
- (void)makeMaskView:(UIView *)view withImage:(UIImage *)image {
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = view.bounds;
    view.layer.mask = imageViewMask.layer;
}

#pragma mark - Action
- (void)bubbleViewDidTapAction {

}

- (void)bubbleViewDidLongTapAction {
    
    UIMenuController *menu = [UIMenuController sharedMenuController];

    if (menu.isMenuVisible) return;
    
    [self becomeFirstResponder];
    
    UIMenuItem *forwardItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(forwardAction)];
    UIMenuItem *copyItem =[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyAction)];
    UIMenuItem *deleteItem = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(deleteAction)];
    UIMenuItem *favorItem = [[UIMenuItem alloc]initWithTitle:@"收藏" action:@selector(favorAction)];
    
    if (self.model.messageType == LSMessageTypeText) {
        menu.menuItems = @[forwardItem,copyItem,favorItem,deleteItem];
    }
    else if (self.model.messageType == LSMessageTypePicture) {
        menu.menuItems = @[forwardItem,favorItem,deleteItem];
    }
    else if (self.model.messageType == LSMessageTypeVideo) {
        menu.menuItems = @[forwardItem,favorItem,deleteItem];
    }
    else if (self.model.messageType == LSMessageTypeEmotion) {
        menu.menuItems = @[forwardItem,deleteItem];
    }//LSMessageTypeAudio
    else if (self.model.messageType == LSMessageTypeAudio){
        menu.menuItems = @[deleteItem];
    }

    CGRect targetRect = [self.bubbleView convertRect:self.bubbleView.bounds toViewOrWindow:self.superview];
    
    [menu setTargetRect:targetRect inView:self.superview];
    menu.arrowDirection = UIMenuControllerArrowDefault;
    [menu update];
    [menu setMenuVisible:YES animated:YES];
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(action == @selector(forwardAction) || action == @selector(copyAction) || action == @selector(deleteAction)||action == @selector(favorAction)) {
        return YES;
    }
    return NO;
}

- (void)forwardAction {
    !self.forwardBlock ? : self.forwardBlock(self.model);
}

- (void)copyAction {
    if ([self.model isKindOfClass:[LSTextMessageModel class]]) {
        LSTextMessageModel *textModel = (LSTextMessageModel *)self.model;
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = textModel.text;
    }
}

- (void)deleteAction {
    !self.deleteMessageBlock ? : self.deleteMessageBlock(self.model);
}

- (void)favorAction {
    !self.favorBlock ? : self.favorBlock(self.model);
}

#pragma mark - Getter & Setter
- (void)setModel:(LSMessageModel *)model {
    _model = model;
    
    if (model.messageType==LSMessageTypeTime) return;
    if (model.messageType==LSMessageTypeSystem) return;
    
    //自己发的消息或者群聊不显示昵称
    if (model.fromMe||model.conversation_type == LSConversationTypeChat) {
        [self.nicknameLabel removeFromSuperview];
    }
    else {
        [self.contentView addSubview:self.nicknameLabel];
        self.nicknameLabel.text = model.sender;
    }
    
    //头像的显示
    [self.avatarView setImageWithURL:[NSURL URLWithString:model.senderAvartar] placeholder:nil];

    if (model.messageType == LSMessageTypePicture||model.messageType == LSMessageTypeVideo) return;
    
    //设置聊天框的背景图片
    if (model.messageType != LSMessageTypeEmotion) {
        self.bubbleView.image = model.fromMe ? self.senderBubbleImage : self.receiverBubbleImage;
    }
    else {
        self.bubbleView.image = nil;
    }
    
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        UIImageView *avatarView = [UIImageView new];
        avatarView.userInteractionEnabled = YES;
        UITapGestureRecognizer * avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapClick:)];
        [avatarView addGestureRecognizer:avatarTap];
        _avatarView = avatarView;
    }
    return _avatarView;
}

- (void)avatarTapClick:(UITapGestureRecognizer *)click {

    if (self.avaterClick) {
        self.avaterClick (self.model);
    }
}

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        UILabel *nicknameLabel = [UILabel new];
        nicknameLabel.font = SYSTEMFONT(11);
        nicknameLabel.textColor = [UIColor grayColor];
        _nicknameLabel = nicknameLabel;
    }
    return _nicknameLabel;
}

- (UIImageView *)bubbleView {
    if (!_bubbleView) {
        
        UIImageView *bubbleImageView = [UIImageView new];
        _bubbleView = bubbleImageView;
        
        bubbleImageView.userInteractionEnabled = YES;
        
        //添加点击手势
        UITapGestureRecognizer *tapGest = [UITapGestureRecognizer new];
        [tapGest addTarget:self action:@selector(bubbleViewDidTapAction)];
        [bubbleImageView addGestureRecognizer:tapGest];
        
        //添加长按手势
        UILongPressGestureRecognizer *longGest = [UILongPressGestureRecognizer new];
        [bubbleImageView addGestureRecognizer:longGest];
        longGest.minimumPressDuration = 0.8;
        [longGest addTarget:self action:@selector(bubbleViewDidLongTapAction)];
        
        //
    }
    return _bubbleView;
}

- (UIImage *)receiverBubbleImage {
    if (!_receiverBubbleImage) {
        _receiverBubbleImage = [[UIImage imageNamed:@"receiverbubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 28, 85, 28) resizingMode:UIImageResizingModeStretch];
    }
    return _receiverBubbleImage;
}

- (UIImage *)senderBubbleImage {
    if (!_senderBubbleImage) {
        _senderBubbleImage = [[UIImage imageNamed:@"senderbubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 28, 85, 28) resizingMode:UIImageResizingModeStretch];
    }
    return _senderBubbleImage;
}

- (LSMessageProgressView *)progressView {
    if (!_progressView) {
        LSMessageProgressView *progerssView = [LSMessageProgressView new];
        progerssView.backgroundColor = [UIColor whiteColor];
        progerssView.alpha = 0.5;
        _progressView = progerssView;
        [self.contentView addSubview:progerssView];
    }
    return _progressView;
}

- (void)setProgress:(NSProgress *)progress {
    _progress = progress;
    
    @weakify(self)
    [RACObserve(self, progress) subscribeNext:^(NSProgress *uploadProgress) {
        @strongify(self)
        CGFloat ratio = (float)uploadProgress.completedUnitCount/uploadProgress.totalUnitCount;
        self.progressView.ratio = ratio;
        
        if (ratio != 1.0) return;
        [self uploadComplete];
    }];
}

- (void)uploadComplete {
    
    if (![self hasProgressView]) return;
    [self.progressView removeFromSuperview];
    self.progressView = nil;
}

@end

@implementation LSMessageProgressView


//添加遮罩图层
- (void)makeMaskView:(UIView *)view withImage:(UIImage *)image {
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = view.bounds;
    view.layer.mask = imageViewMask.layer;
}

- (void)setRatio:(CGFloat)ratio {
    _ratio = ratio;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.progressLayer.strokeEnd = ratio;
    [CATransaction commit];
    
    self.progressLayer.center = CGPointMake(self.width*0.5, self.height*0.5);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressLayer.center = CGPointMake(self.width*0.5, self.height*0.5);
    [self makeMaskView:self withImage:[[UIImage imageNamed:@"senderbubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 28, 85, 28) resizingMode:UIImageResizingModeStretch]];
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.size = CGSizeMake(35, 35);
        _progressLayer.cornerRadius = 17.5;
        _progressLayer.backgroundColor = [UIColor blackColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:(40 / 2 - 7)];
        _progressLayer.path = path.CGPath;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.lineWidth = 4;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 0;
        [self.layer addSublayer:_progressLayer];
    }
    return _progressLayer;
}

@end
