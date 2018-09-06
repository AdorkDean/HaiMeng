//
//  ZHRecordButton.m
//  RecordTest
//
//  Created by AdminZhiHua on 16/4/11.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^CompletionBlock)(BOOL);

@interface AVAudioPlayerWithCompletionBlock : AVAudioPlayer

@property (nonatomic, copy) CompletionBlock completionBlock;

@end

@interface ZHAudioPlayer : NSObject <AVAudioPlayerDelegate> {
	NSMutableSet *players;
}


+ (ZHAudioPlayer *)shared;

+ (AVAudioPlayer *)playAudio:(NSURL *)url;

+ (AVAudioPlayer *)playAudio:(NSURL *)url volume:(CGFloat)vol loops:(NSInteger)loops;

+ (AVAudioPlayer *) playAudio:(NSURL *)url withCompletionBlock:(CompletionBlock)completion;

+ (AVAudioPlayer *) playAudio:(NSURL *)url volume:(CGFloat)vol loops:(NSInteger)loops withCompletionBlock:(CompletionBlock)completion;

+ (AVAudioPlayer *) playLoopedAudio:(NSURL *)url;

+ (void)stopPlayer:(AVAudioPlayer *)player;
+ (void)stopAllPlayers;

+ (void) playFiles:(NSArray *)filesList withCompletionBlock:(CompletionBlock)completion;

@end
