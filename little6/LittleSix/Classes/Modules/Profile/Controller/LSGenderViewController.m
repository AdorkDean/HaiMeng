//
//  LSGenderViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSGenderViewController.h"
#import "LSUserModel.h"
@interface LSGenderViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *manSelectIcon;
@property (weak, nonatomic) IBOutlet UIImageView *womenSelectIcon;
@property (nonatomic,assign) int selectSexIndex;

@end

@implementation LSGenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"性别";
    
    if ([self.sex isEqualToString:@"男"]) {
        self.manSelectIcon.hidden = NO;
        self.womenSelectIcon.hidden = YES;

    }else if([self.sex isEqualToString:@"女"]){
        self.manSelectIcon.hidden = YES;
        self.womenSelectIcon.hidden = NO;
    }else{
        self.manSelectIcon.hidden = YES;
        self.womenSelectIcon.hidden = YES;
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15 : 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        self.manSelectIcon.hidden = NO;
        self.womenSelectIcon.hidden = YES;
        self.selectSexIndex = 1;
    }else{
        self.manSelectIcon.hidden = YES;
        self.womenSelectIcon.hidden = NO;
        self.selectSexIndex = 2;
    }
    [LSUserModel changeUserInfoSex:self.selectSexIndex Success:^{
        self.changeSex(self.selectSexIndex);
        if (self.selectSexIndex == 1)
            ShareAppManager.loginUser.sex =@"男";
        else
            ShareAppManager.loginUser.sex =@"女";

        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        
    }];
    
}


@end
