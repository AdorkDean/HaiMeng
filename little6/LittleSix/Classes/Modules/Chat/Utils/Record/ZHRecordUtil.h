//
//  ZHRecordUtil.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZHRecordUtilDelegate <NSObject>

//结束录音
- (void)completeRecordWithFileName:(NSString *)fileName;
//监听音量的变化
- (void)updateVolumeMeters:(CGFloat)value;
//录音时间太短
- (void)recordDurationTooShort;

@end

@interface ZHRecordUtil : NSObject

//最大的录音时间
@property (nonatomic,assign) NSTimeInterval maxRecordDuration;
//当前的录音时间
@property (nonatomic,assign) NSTimeInterval currentRecordDuration;

- (id)initWithDelegate:(id<ZHRecordUtilDelegate>)delegate;
- (void)startRecord;
- (void)stopRecord;
- (void)cancelRecord;
- (void)startUpdateVolumeMeters;
- (void)stopUpdateVolumeMeters;

@end
