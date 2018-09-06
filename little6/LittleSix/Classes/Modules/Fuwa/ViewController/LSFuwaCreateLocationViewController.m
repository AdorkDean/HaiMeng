//
//  LSFuwaCreateLocationViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaCreateLocationViewController.h"
#import "UIView+HUD.h"
#import "LSFuwaNewAdressModel.h"
@interface LSFuwaCreateLocationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UITextField *adressTextField;

@end

@implementation LSFuwaCreateLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"创建当前位置";
    [self setNavigationBar];
    self.locationLabel.text = [NSString stringWithFormat:@"%@   %@",self.city,self.district];
}

-(void)setNavigationBar{
    @weakify(self)
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setTitle:@"发送" forState:UIControlStateNormal];
    saveButton.titleLabel.font = SYSTEMFONT(16);
    [saveButton sizeToFit];
    [[saveButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self saveButtonClick];
    }];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = rightItem;

    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    leftButton.titleLabel.font = SYSTEMFONT(16);
    [leftButton sizeToFit];
    [[leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
}


-(void)saveButtonClick{
    NSString *name = [self.nameTextField.text stringByTrim];
    NSString *adress = [self.adressTextField.text stringByTrim];
    if (name.length<1) {
        [self.view showError:@"位置名称不能为空" hideAfterDelay:1];
        return;
    }else if(adress.length<1){
        [self.view showError:@"详细地址不能为空" hideAfterDelay:1];
        return;
    }
    

    LSFuwaNewAdressModel * model = [[LSFuwaNewAdressModel alloc]init];
    model.name = name;
    model.adress = adress;
    model.city = self.city;
    model.district = self.district;
    model.totalAdress = [NSString stringWithFormat:@"%@%@%@",self.city,self.district,adress];
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:model forKey:@"LSFuwaNewAdressModel"];
    
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingPathComponent:@"listArr.data"];
    // 解档
    NSMutableArray *listArr = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (listArr == nil)  listArr = [NSMutableArray array];
    [listArr addObject:model];
    [NSKeyedArchiver archiveRootObject:listArr toFile:filePath];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kFuwaNewAdressNoti object:nil userInfo:dic];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
