//
//  LSCelebrityTableViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/4/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSCelebrityTableViewController.h"
#import "TZImagePickerController.h"
#import "LSLinkInApplyModel.h"
#import "LSCelebrityViewController.h"
#import "TZImageManager.h"
#import "UIView+HUD.h"
#import "ComfirmView.h"

@interface LSCelebrityTableViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *desTextView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@end

@implementation LSCelebrityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑名人";
    
    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.delegate = self;
    self.desTextView.delegate = self;
    self.desTextView.returnKeyType = UIReturnKeyDone;
    self.saveBtn.backgroundColor = kMainColor;
    self.saveBtn.titleLabel.font = SYSTEMFONT(18);
    ViewRadius(self.saveBtn, 5);
    [self initface];
}

- (void)initface {

    if (!self.model) {
        self.iconImage.image = timeLineBigPlaceholderName;
    }else {
    
        [self.iconImage setImageWithURL:[NSURL URLWithString:self.model.photo] placeholder:timeLineBigPlaceholderName];
        self.nameTextField.text = self.model.name;
        self.desTextView.text = self.model.desc;
        self.desLabel.text = @"";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    if (indexPath.section == 0) {
        ModelComfirm *item1 = [ModelComfirm comfirmModelWith:@"相机" titleColor:HEXRGB(0x666666) fontSize:16];
        ModelComfirm *item2 = [ModelComfirm comfirmModelWith:@"从相册选择" titleColor:HEXRGB(0x666666) fontSize:16];
        ModelComfirm *cancelItem = [ModelComfirm comfirmModelWith:@"取消" titleColor:HEXRGB(0x666666) fontSize:16];
        //确认提示框
        [ComfirmView showInView:LSKeyWindow cancelItemWith:cancelItem dataSource:@[ item1 ,item2] actionBlock:^(ComfirmView *view, NSInteger index) {
            
            if (index == 0) {
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
                                self.iconImage.image = photo;
                            }
                        }];
                    }
                }];
                [self presentViewController:imagePickerVc animated:YES completion:nil];
            }
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.iconImage.image = image;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if ([textView.text isEqualToString:@""]) {
        self.desLabel.text = @"请输入名人介绍";
    }else {
        self.desLabel.text = @"";
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self.view endEditing:YES];
}

- (IBAction)saveClick:(UIButton *)sender {
    
    if (([self.nameTextField.text isEqualToString:@""]&&self.nameTextField.text.length == 0) || ([self.desTextView.text isEqualToString:@""] && self.desTextView.text.length == 0)) {
        
        [LSKeyWindow showError:@"请填写完整资料" hideAfterDelay:1];
        return;
    }
    
    if (!self.model) {
        [self.view showLoading];
        [LSLinkInApplyModel linkInCelebrityWithC_id:self.s_id logo:self.iconImage.image name:self.nameTextField.text desc:self.desTextView.text type:[self.type intValue] success:^(NSDictionary *dic) {
            
            [self.view hideHUDAnimated:YES];
            //发送通知刷新人脉首页
            [[NSNotificationCenter defaultCenter] postNotificationName:kCelebrityLinkInInfoNoti object:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError *error) {
            [self.view showError:@"请求出错" hideAfterDelay:1];
        
        }];
    }else {
    
        [self.view showLoading];
        [LSLinkInApplyModel linkInUpdateCelebrityWithC_id:self.s_id logo:self.iconImage.image name:self.nameTextField.text desc:self.desTextView.text type:[self.type intValue] success:^(NSDictionary *dic) {
            
            [self.view hideHUDAnimated:YES];
            //发送通知刷新人脉首页
            [[NSNotificationCenter defaultCenter] postNotificationName:kCelebrityLinkInInfoNoti object:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError *error) {
            [self.view showError:@"请求出错" hideAfterDelay:1.5];
            
        }];
        
    }
    
}


@end
