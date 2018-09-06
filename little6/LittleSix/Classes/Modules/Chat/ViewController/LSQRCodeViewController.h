//
//  LSQRCodeViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef enum{
    LSQRcodeTypeFriend,
    LSQRcodeTypeFuwaUser,
    LSQRcodeTypeFuwa,
}LSQRcodeType;

@interface LSQRCodeViewController : UIViewController

//判断相机是否授权
+ (BOOL)isCameraAuthorize;

+ (void)photoLibraryAuthor:(void(^)(PHAuthorizationStatus status))authorAtatus;

@property (nonatomic,assign) LSQRcodeType codeType;

@property (nonatomic,copy) void(^fuwaUserBlock)(NSString * FuwaUserb64);


@end
