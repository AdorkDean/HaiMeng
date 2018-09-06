
//
//  ZHRecordButton.m
//  RecordTest
//
//  Created by AdminZhiHua on 16/4/11.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ZHRecordButton.h"
#import "ZHRecordUtil.h"
#import "ZHRecordView.h"

@interface ZHRecordButton () <ZHRecordUtilDelegate>

@property (nonatomic, strong) ZHRecordUtil *recordUtil;
@property (nonatomic, strong) ZHRecordView *recordView;

@end

@implementation ZHRecordButton

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.recordUtil = [[ZHRecordUtil alloc] initWithDelegate:self];
        
        //按下按钮
        [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        //内部松开
        [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        //外部松开
        [self addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        //进入内部
        [self addTarget:self action:@selector(touchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        //进入外部
        [self addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
        //触摸取消
        [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchCancel];
    }
    return self;
}

#pragma mark - Action
- (void)touchDown:(UIButton *)button {
    //开始录音
    ZHRecordView *recordView = [ZHRecordView showInKeyWindow];
    self.recordView = recordView;
//    [recordView updateMetersValue:1];
    [self.recordUtil startRecord];
}

//在按钮内松开
- (void)touchUpInside:(UIButton *)button {
    //判断录音是否是合法
    //正常结束录音
    [self.recordUtil stopRecord];
}

- (void)touchUpOutside:(UIButton *)button {
    //取消录音
    [self.recordUtil cancelRecord];
    [self.recordView dismissHUD];
}

- (void)touchDragEnter:(UIButton *)button {
    [self.recordUtil startUpdateVolumeMeters];
    [self.recordView setStatus:LSRecordStatusSignalVol];
}

- (void)touchDragExit:(UIButton *)button {
    [self.recordUtil stopUpdateVolumeMeters];
    [self.recordView setStatus:LSRecordStatusRecocation];
}

- (void)touchCancel:(UIButton *)button {
    //取消录音
    [self.recordUtil cancelRecord];
    [self.recordView dismissHUD];
}

#pragma mark - ZHRecordUtilDelegate
//结束录音
- (void)completeRecordWithFileName:(NSString *)fileName {
    [self.recordView dismissHUD];
    !self.recordComplete?:self.recordComplete(fileName);
}

//监听音量的变化
- (void)updateVolumeMeters:(CGFloat)value {
    NSInteger newValue = (NSInteger)(value*10);
    [self.recordView updateMetersValue:newValue];
}

//录音时间太短
- (void)recordDurationTooShort {
    [self.recordView setStatus:LSRecordStatusShortTime];
    kDISPATCH_AFTER_BLOCK(1.5, ^{
        [self.recordView dismissHUD];
    })
}

@end
