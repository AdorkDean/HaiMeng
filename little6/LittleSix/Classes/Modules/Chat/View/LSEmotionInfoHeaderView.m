//
//  LSEmotionInfoHeaderView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEmotionInfoHeaderView.h"
#import "LSEmotionModel.h"
#import "HttpManager.h"
#import "UIView+HUD.h"
#import "LSEmotionManager.h"

@interface LSEmotionInfoHeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (nonatomic,strong) NSURLSessionDownloadTask *task;

@end

@implementation LSEmotionInfoHeaderView

+ (instancetype)emotionInfoHeaderView {
    return [[[NSBundle mainBundle] loadNibNamed:@"LSEmotionInfoHeaderView" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    ViewRadius(self.downloadButton, 5);
    [self.downloadButton setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [self.downloadButton setBackgroundImage:[UIImage imageWithColor:HEXRGB(0x8c8c8c)] forState:UIControlStateDisabled];
}

- (CGFloat)viewHeight:(LSEmotionPackage *)package {
    self.package = package;
    [self layoutIfNeeded];
    return CGRectGetMaxY(self.tipsLabel.frame);
}

- (void)setPackage:(LSEmotionPackage *)package {
    _package = package;
    
    [self.coverView setImageWithURL:[NSURL URLWithString:package.group_cover] placeholder:nil];
    self.titleLabel.text = package.group_name;
    self.descLabel.text = package.group_desc;
    
    BOOL exist = [LSEmotionManager exitEmotionPackageById:package.group_id];
    self.downloadButton.enabled = !exist;
}

- (IBAction)downloadAction:(UIButton *)sender {

    if (self.task) return;
    
    self.task = [HttpManager download:self.package.url downloadProgress:^(NSProgress *progress) {
        kDISPATCH_MAIN_THREAD((^{
            CGFloat ratio = (float)progress.completedUnitCount/progress.totalUnitCount;
            NSString *title = [NSString stringWithFormat:@"%d%%",(int)(ratio*100)];
            [self.downloadButton setTitle:title forState:UIControlStateNormal];
        }));
    } completeHandler:^(NSURLResponse *response, NSURL *fileUrl, NSError *error) {
        if (error) {
            self.task = nil;
            self.downloadButton.enabled = YES;
            [self.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
            [LSKeyWindow showError:@"下载失败" hideAfterDelay:1.5];
        }
        else {
            self.downloadButton.enabled = NO;
            NSString *filePath = [fileUrl.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            NSDictionary *dict = [LSEmotionManager unPackEmotionPackage:filePath removeSourceFile:YES];
            if (dict) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kEmotionPackageUpdateNoti object:nil];
            }
        }
    }];
}

@end
