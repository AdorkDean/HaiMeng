//
//  ImagePickerManager.h
//  SixtySixBoss
//
//  Created by AdminZhiHua on 16/7/9.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ShareImagePickerManager [ImagePickerManager sharedImagePickerManager]

@interface ImagePickerManager : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
    singleton_interface(ImagePickerManager)

@property (nonatomic, copy) void (^finishPickerBlock)(NSDictionary *info);

- (void)takePhotoWithPresentedVC:(UIViewController *)vc allocEditing:(BOOL)allocEditing finishPicker:(void (^)(NSDictionary *info))finishBlock;

- (void)pickPhotoWithPresentedVC:(UIViewController *)vc allocEditing:(BOOL)allocEditing finishPicker:(void (^)(NSDictionary *info))finishBlock;

@end
