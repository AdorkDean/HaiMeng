//
//  LSSelectLogoViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/4/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSelectLogoViewController.h"
#import "TZImagePickerController.h"
#import "LSLinkInApplyModel.h"
#import "TZImageManager.h"
#import "UIView+HUD.h"

@interface LSSelectLogoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;

@end

@implementation LSSelectLogoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self infoUserData];
}

- (void)infoUserData {
    
    [LSLinkInInformationModel linkInInfoWithC_id:self.s_id type:[self.type intValue] success:^(LSLinkInInformationModel *model) {
        
        [self.logoImage setImageWithURL:[NSURL URLWithString:model.logo] placeholder:timeLineBigPlaceholderName];
    
    } failure:nil];
}

- (IBAction)takePictures:(UIButton *)sender {
    
    if (sender.tag == 1000) {
        
        UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else {
    
        @weakify(self)
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
        imagePickerVc.isSelectOriginalPhoto = YES;
        imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
        imagePickerVc.allowPickingVideo = NO;
        imagePickerVc.allowPickingImage = YES;
        imagePickerVc.allowPickingOriginalPhoto = YES;
        imagePickerVc.allowPickingGif = NO;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            @strongify(self)
            
            for (PHAsset *asset in assets) {
                //获取原图
                [[TZImageManager manager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                    if(photo){
                        [self depositPhoto:photo];
                    }
                }];
            }
        }];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {

    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self depositPhoto:image];
}

- (void)depositPhoto:(UIImage *)photo{

    [self.view showLoading];
    [LSLinkInApplyModel linkInApplyWithC_id:self.s_id logo:photo banner:nil type:[self.type intValue] success:^(NSDictionary *dic){
        [self.view hideHUDAnimated:YES];
        //发送通知刷新人脉首页
        [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteLinkInInfoNoti object:nil];
        [self.logoImage setImageWithURL:[NSURL URLWithString:dic[@"logo"]] placeholder:timeLineBigPlaceholderName];
    } failure:^(NSError * error){
        
        [self.view hideHUDAnimated:YES];
    }];
    
}

@end
