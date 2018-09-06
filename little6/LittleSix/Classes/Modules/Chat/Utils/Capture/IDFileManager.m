//
//  IDFileManager.m
//  VideoCaptureDemo
//
//  Created by Adriaan Stellingwerff on 9/04/2015.
//  Copyright (c) 2015 Infoding. All rights reserved.
//

#import "IDFileManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation IDFileManager


- (NSURL *)tempFileURL
{
    //沙盒中没有目录则新创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:kCaptureFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:kCaptureFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //已当前时间命名视频文件
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    formate.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
    NSString *dateString = [formate stringFromDate:currentDate];
    
    //生成文件名
    NSString *fileName = [NSString stringWithFormat:@"capture_%@.mov",dateString];
    
    NSString *path = [kCaptureFolder stringByAppendingPathComponent:fileName];

    return [NSURL fileURLWithPath:path];
}

- (void) removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
        if(error){
            NSLog(@"error removing file: %@", [error localizedDescription]);
        }
        else {
            NSLog(@"文件删除成功");
        }
    }
}

- (NSString *) copyFileToDocuments:(NSURL *)fileURL
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *destinationPath = [kCaptureFolder stringByAppendingFormat:@"/output_%@.mov", [dateFormatter stringFromDate:[NSDate date]]];
    NSError	*error;
    [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:destinationPath] error:&error];
    if(error){
        NSLog(@"error copying file: %@", [error localizedDescription]);
    }
    return destinationPath;
}

- (void)copyFileToCameraRoll:(NSURL *)fileURL
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if(![library videoAtPathIsCompatibleWithSavedPhotosAlbum:fileURL]){
        NSLog(@"video incompatible with camera roll");
    }
    [library writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if(error){
            NSLog(@"Error: Domain = %@, Code = %@", [error domain], [error localizedDescription]);
        } else if(assetURL == nil){
            
            //It's possible for writing to camera roll to fail, without receiving an error message, but assetURL will be nil
            //Happens when disk is (almost) full
            NSLog(@"Error saving to camera roll: no error message, but no url returned");
            
        } else {
            //remove temp file
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
            if(error){
                NSLog(@"error: %@", [error localizedDescription]);
            }
            
        }
    }];

}


@end
