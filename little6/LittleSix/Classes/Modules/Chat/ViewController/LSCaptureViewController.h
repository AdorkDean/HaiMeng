//
//  LSCaptureViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

//刷新时间
#define kRefreshDuration 0.1
//视频录制保存的文件夹
#define kCaptureFolder [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Captures"]

@class LSCaptureModel;
@interface LSCaptureViewController : UIViewController

//最大录制时间 默认15
@property (nonatomic,assign) CGFloat maxCaptureDuration;

@property (nonatomic,copy) NSURL *localFileURL;

//录制完成的回调
@property (nonatomic,copy) void(^capCompleteBlock)(LSCaptureModel *model);

@end

//聚焦视图
@interface LSFocusView : UIView

- (void)showFocusAnimation;

@end

@interface LSCaptureModel : NSObject

//视频文件名
@property (nonatomic,copy) NSString *videoName;
//缩略图文件名
@property (nonatomic,copy) NSString *thumName;

- (NSURL *)localVideoFileURL;
- (UIImage *)localThumImage;

+ (instancetype)captureModelWithName:(NSString *)videoName;

@end

