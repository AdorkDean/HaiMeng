//
//  LSForwardView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/4/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSForwardView.h"
#import "LSGroupModel.h"

@interface LSForwardView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewConstHeight;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *titleHeaderView;
@property (weak, nonatomic) IBOutlet UIView *messageContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContentConstHeight;

@property (nonatomic,strong) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *inputView;

@end

@implementation LSForwardView

+ (instancetype)forwardView {
    return [[[NSBundle mainBundle] loadNibNamed:@"LSForwardView" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    ViewRadius(self.contentView, 6);
    
    [self registNotis];
}

+ (void)showInView:(UIView *)view senders:(NSArray<LSContactModel *> *)senders withMessage:(LSMessageModel *)message comfirmActon:(void (^)(NSString *leaveMessage))action {
    
    LSForwardView *forwardView = [LSForwardView forwardView];
    
    forwardView.message = message;
    forwardView.comfirmBlock = action;
    forwardView.senders = senders;
    
    [view addSubview:forwardView];
    forwardView.frame = view.bounds;
    
    [forwardView configSubviews];
    [forwardView layoutView];
}

- (void)configSubviews {
    
    if (self.senders.count == 1) {
        
        UIImageView *iconView = [UIImageView new];
        ViewRadius(iconView, 3);
        [self.titleHeaderView addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleHeaderView).offset(6);
            make.bottom.equalTo(self.titleHeaderView).offset(-6);
            make.left.equalTo(self.titleHeaderView);
            make.width.equalTo(iconView.mas_height);
        }];

        UILabel *titleLabel = [UILabel new];
        titleLabel.font = SYSTEMFONT(15);
        titleLabel.textColor = HEXRGB(0x333333);
        [self.titleHeaderView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self.titleHeaderView);
            make.left.equalTo(iconView.mas_right).offset(5);
        }];
        
        if ([self.senders.firstObject isKindOfClass:[LSContactModel class]]) {
            LSContactModel *model = self.senders.firstObject;
            [iconView setImageURL:[NSURL URLWithString:model.avatar]];
            titleLabel.text = model.user_name;
        }
        else if ([self.senders.firstObject isKindOfClass:[LSGroupModel class]]) {
            
            LSGroupModel *gmodel = (LSGroupModel *)self.senders.firstObject;
            [iconView setImageURL:[NSURL URLWithString:gmodel.snap]];
            titleLabel.text = gmodel.name;
        }
        
    }
    else {
        NSString *title = nil;
        for (LSContactModel *model in self.senders) {
            !title ? (title = model.user_name) : (title = [title stringByAppendingString:[NSString stringWithFormat:@"、%@",model.user_name]]);
        }
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = title;
        titleLabel.font = SYSTEMFONT(15);
        titleLabel.textColor = HEXRGB(0x333333);
        
        [self.titleHeaderView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self.titleHeaderView);
            make.left.equalTo(self.titleHeaderView).offset(5);
        }];
        
    }
    
    [self layoutIfNeeded];
    
    CGFloat constWidth = self.messageContentView.width;
    
    switch (self.message.messageType) {
        case LSMessageTypeText:
        {
            LSTextMessageModel *model = (LSTextMessageModel *)self.message;
            
            CGFloat textHeight = [model.text heightForFont:SYSTEMFONT(14) width:constWidth];
            
            UILabel *messageLabel = [UILabel new];
            messageLabel.font = SYSTEMFONT(14);
            messageLabel.textColor = HEXRGB(0x999999);
            messageLabel.text = model.text;
            messageLabel.numberOfLines = 0;
            
            [self.messageContentView addSubview:messageLabel];
            [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.messageContentView);
            }];
            
            self.messageContentConstHeight.constant = textHeight + 30;
            
        }
            break;
            
        case LSMessageTypePicture:
        {
            LSPictureMessageModel *model = (LSPictureMessageModel *)self.message;

            UIImageView *imageView = [UIImageView new];
            self.imageView = imageView;
            
            [imageView setImageWithURL:[NSURL URLWithString:model.picUrl] placeholder:nil options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                
                if (!image) return;
                
                CGFloat radio = image.size.width / image.size.height;
                
                [self.messageContentView addSubview:self.imageView];
                [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(self.messageContentView);
                    make.top.equalTo(self.messageContentView).offset(15);
                    make.bottom.equalTo(self.messageContentView).offset(-15);
                    make.width.equalTo(self.imageView.mas_height).multipliedBy(radio);
                }];
                
                [self layoutIfNeeded];
            }];
            
            self.messageContentConstHeight.constant = 100 + 30;
        }
            break;
            
        case LSMessageTypeEmotion:
        {
            LSEmotionMessageModel *model = (LSEmotionMessageModel *)self.message;
            
            UIImageView *imageView = [YYAnimatedImageView new];
            self.imageView = imageView;
            
            [imageView setImageWithURL:[NSURL URLWithString:model.emo_url] placeholder:nil options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                
                if (!image) return;
                
                CGFloat radio = image.size.width / image.size.height;
                
                [self.messageContentView addSubview:self.imageView];
                [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(self.messageContentView);
                    make.top.equalTo(self.messageContentView).offset(15);
                    make.bottom.equalTo(self.messageContentView).offset(-15);
                    make.width.equalTo(self.imageView.mas_height).multipliedBy(radio);
                }];
                
                [self layoutIfNeeded];
            }];
            
            self.messageContentConstHeight.constant = 100 + 30;
        }
            break;
            
        case LSMessageTypeVideo:
        {
            LSVideoMessageModel *model = (LSVideoMessageModel *)self.message;
            
            UIImageView *imageView = [YYAnimatedImageView new];
            self.imageView = imageView;
            
            [imageView setImageWithURL:[NSURL URLWithString:model.remoteThumURL] placeholder:nil options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                
                if (!image) return;
                
                CGFloat radio = image.size.width / image.size.height;
                
                [self.messageContentView addSubview:self.imageView];
                [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(self.messageContentView);
                    make.top.equalTo(self.messageContentView).offset(15);
                    make.bottom.equalTo(self.messageContentView).offset(-15);
                    make.width.equalTo(self.imageView.mas_height).multipliedBy(radio);
                }];
                
                UIImageView *videView = [UIImageView new];
                videView.image = [UIImage imageNamed:@"chat_video_recorder"];
                [self.messageContentView addSubview:videView];
                [videView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.imageView).offset(4);
                    make.bottom.equalTo(self.imageView).offset(-4);
                }];
                
                [self layoutIfNeeded];
            }];
            
            self.messageContentConstHeight.constant = 100 + 30;
        }
            break;

        default:
            break;
    }
    
}

- (void)layoutView {
    [self layoutIfNeeded];
    CGFloat height = CGRectGetMaxY(self.sendButton.frame);
    self.contentViewConstHeight.constant = height;
    [self layoutIfNeeded];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (IBAction)cancelAction:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)sendAction:(id)sender {
    !self.comfirmBlock ? : self.comfirmBlock(self.inputView.text);
    [self removeFromSuperview];
}

- (void)registNotis {
    
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSDictionary *userInfo = [x userInfo];

        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [aValue CGRectValue];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.contentView.bottom = keyboardRect.origin.y - 10;
        }];
        
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        [UIView animateWithDuration:0.25 animations:^{
            self.contentView.center = self.center;
        }];
    }];

}

@end
