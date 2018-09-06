//
//  ZHRecordTool.m
//  RecordTest
//
//  Created by AdminZhiHua on 16/4/8.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ZHAudioPlayer.h"

@implementation AVAudioPlayerWithCompletionBlock

@end

@implementation ZHAudioPlayer

static ZHAudioPlayer *sharedInstance = nil;

+ (void)initialize
{
    if (sharedInstance == nil)
        sharedInstance = [[self alloc] init];
}

+ (ZHAudioPlayer *)shared
{
    //Already set by +initialize.
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone*)zone
{
    //Usually already set by +initialize.
    @synchronized(self) {
        if (sharedInstance) {
            //The caller expects to receive a new object, so implicitly retain it
            //to balance out the eventual release message.
            return sharedInstance;
        } else {
            //When not already set, +initialize is our caller.
            //It's creating the shared instance, let this go through.
            return [super allocWithZone:zone];
        }
    }
}

- (id)init
{
    //If sharedInstance is nil, +initialize is our caller, so initialize the instance.
    //If it is not nil, simply return the instance without re-initializing it.
    if (sharedInstance == nil) {
		self = [super init];
		if (self) {
            //Initialize the instance here.
			players = [NSMutableSet setWithCapacity:1];
        }
    }
    return self;
}


- (AVAudioPlayer *) playAudioWithUrl:(NSURL *)url volume:(CGFloat)vol loops:(NSInteger)loops withCompletionBlock:(CompletionBlock)completion
{

    if (!url) return nil;
	
	NSError *error = nil;
	AVAudioPlayerWithCompletionBlock *player = [[AVAudioPlayerWithCompletionBlock alloc] initWithContentsOfURL:url error:&error];
	player.volume = vol;
	player.numberOfLoops = loops;
	// Retain and play
	if(player) {
		[players addObject:player];
		player.delegate = self;
        player.completionBlock = completion;
		[player play];
		return player;
	}
    else {
        NSLog(@"播放出错：%@",error);
    }
    
	return nil;
    
}
- (void) playFiles:(NSArray<NSURL *> *) urlsList withCompletionBlock:(CompletionBlock) completion
{
    __block int idx = 0;
    void(^playBlock)();
    playBlock = ^() {
        if (idx >= urlsList.count) {
            if (completion) {
                completion ( YES );
            }
            return ;
        }
        [self playAudio:urlsList[idx] withCompletionBlock:^(BOOL complete) {
            playBlock ();
        }];
        idx ++;
    };
    
    playBlock ();
}

- (AVAudioPlayer *)playAudio:(NSURL *)url {
    
    return [self playAudioWithUrl:url volume:1.0f loops:0 withCompletionBlock:nil];
}

- (AVAudioPlayer *) playLoopedAudio:(NSURL *)url {
    return [self playAudio:url volume:1.0f loops:1];
}

- (AVAudioPlayer *) playAudio:(NSURL *)url withCompletionBlock:(CompletionBlock)completion
{
    return [self playAudioWithUrl:url volume:1.0 loops:0 withCompletionBlock:completion];
}

- (AVAudioPlayer *)playAudio:(NSURL *)url volume:(CGFloat)vol loops:(NSInteger)loops {
    
    return [self playAudioWithUrl:url volume:vol loops:loops withCompletionBlock:nil];
}


- (void)stopPlayer:(AVAudioPlayer *)player {
	if([players containsObject:player]) {
		player.delegate = nil;
		[players removeObject:player];
		[player stop];
	}
}

- (void)stopAllPlayers {
    NSSet *pls = [NSSet setWithSet:players];
    for (AVAudioPlayer *p in pls) {
        [self stopPlayer:p];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayerWithCompletionBlock *)player successfully:(BOOL)completed {
    
	if (player.completionBlock) {
        player.completionBlock ( completed );
    }
	player.delegate = nil;
	[players removeObject:player];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
	//TRC_DBG(@"audioPlayerDecodeErrorDidOccur %@", error);
	player.delegate = nil;
	[players removeObject:player];
}

+ (AVAudioPlayer *)playAudio:(NSURL *)url {
    return [[ZHAudioPlayer shared] playAudio:url];
}

+ (AVAudioPlayer *)playAudio:(NSURL *)url volume:(CGFloat)vol loops:(NSInteger)loops {
    return [[ZHAudioPlayer shared] playAudio:url volume:vol loops:loops];
}
+ (AVAudioPlayer *) playAudio:(NSURL *)url withCompletionBlock:(CompletionBlock)completion
{
    return [[ZHAudioPlayer shared] playAudio:url withCompletionBlock:completion];
}
+ (AVAudioPlayer *) playAudio:(NSURL *)url volume:(CGFloat)vol loops:(NSInteger)loops withCompletionBlock:(CompletionBlock)completion
{
    return [[ZHAudioPlayer shared] playAudioWithUrl:url volume:vol loops:loops withCompletionBlock:completion];
}
+ (AVAudioPlayer *) playLoopedAudio:(NSURL *)url
{
    return [[ZHAudioPlayer shared] playLoopedAudio:url];
}
+ (void)stopPlayer:(AVAudioPlayer *)player {
	return [[ZHAudioPlayer shared] stopPlayer:player];
}
+ (void)stopAllPlayers {
    return [[ZHAudioPlayer shared] stopAllPlayers];
}
+ (void) playFiles:(NSArray *)filesList withCompletionBlock:(CompletionBlock)completion
{
    [[ZHAudioPlayer shared] playFiles:filesList withCompletionBlock:completion];
}
@end
