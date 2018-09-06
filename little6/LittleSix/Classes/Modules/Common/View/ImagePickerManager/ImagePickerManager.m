//
//  ImagePickerManager.m
//  SixtySixBoss
//
//  Created by AdminZhiHua on 16/7/9.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ImagePickerManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+HUD.h"

@implementation ImagePickerManager
singleton_implementation(ImagePickerManager)

- (void)takePhotoWithPresentedVC:(UIViewController *)vc allocEditing:(BOOL)allocEditing finishPicker:(void (^)(NSDictionary *info))finishBlock {

    if (![self isCameraAuthor]) {
        [LSKeyWindow showAlertWithTitle:@"提示" message:@"您已关闭相机使用权限，请至手机“设置->隐私->相机”中打开" cancelAction:nil doneAction:^{
            NSURL *appUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:appUrl]) {
                [[UIApplication sharedApplication] openURL:appUrl];
            }
        }];
        return;
    }

    self.finishPickerBlock = finishBlock;

    UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
    [imagePickerVC setSourceType:UIImagePickerControllerSourceTypeCamera];

    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = allocEditing;

    [vc presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)pickPhotoWithPresentedVC:(UIViewController *)vc allocEditing:(BOOL)allocEditing finishPicker:(void (^)(NSDictionary *))finishBlock {

    if (![self isPhotoLibraryAuthor]) {
        [LSKeyWindow showAlertWithTitle:@"提示" message:@"您已关闭相册使用权限，请至手机“设置->隐私->相册”中打开" cancelAction:nil doneAction:^{
            NSURL *appUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:appUrl]) {
                [[UIApplication sharedApplication] openURL:appUrl];
            }
        }];
        return;
    }

    self.finishPickerBlock = finishBlock;

    UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
    [imagePickerVC setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePickerVC.delegate = self;

    imagePickerVC.allowsEditing = allocEditing;

    [vc presentViewController:imagePickerVC animated:YES completion:nil];
}

//判断摄像头是否授权
- (BOOL)isCameraAuthor {

    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];

    if (authorizationStatus == AVAuthorizationStatusRestricted || authorizationStatus == AVAuthorizationStatusDenied) {
        return NO;
    }

    return YES;
}

//判断相册是否授权
- (BOOL)isPhotoLibraryAuthor {

    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];

    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
        return NO;
    }

    return YES;
}

#pragma mark - Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:info];

    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageOrientation imageOrientation=image.imageOrientation;
        if(imageOrientation!=UIImageOrientationUp)
        {
            // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
            // 以下为调整图片角度的部分
            UIGraphicsBeginImageContext(image.size);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // 调整图片角度完毕
            dict[UIImagePickerControllerOriginalImage] = image;
        }
    }
    
    if (self.finishPickerBlock) {
        self.finishPickerBlock(dict);
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
