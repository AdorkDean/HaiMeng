//
//  LSFuwaSearchLocationViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaSearchLocationViewController.h"
#import "LSFuwaCreateLocationViewController.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "LSFuwaNewAdressModel.h"

static NSString *const reuse_id = @"tableViewCell";

@interface LSFuwaSearchLocationViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray * dataSource;

@property (nonatomic,strong) UIView * customNaviBar;

@property (nonatomic,strong) UITextField *searchTextField;

@property (nonatomic,strong) NSMutableArray *locaArr;


@end

@implementation LSFuwaSearchLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configNaviBar];
    [self.view addSubview:self.tableView];
    

}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.customNaviBar.hidden = NO;
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingPathComponent:@"listArr.data"];
    NSMutableArray *listArr = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    self.locaArr = listArr;
    [self.tableView reloadData];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.customNaviBar.hidden = YES;
}

- (void)configNaviBar {
    
    UIView * customNaviBar = [UIView new];
    self.customNaviBar = customNaviBar;
    customNaviBar.backgroundColor = [UIColor clearColor];
    [self.navigationController.view addSubview: customNaviBar];
    
    [customNaviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.navigationController.navigationBar);
    }];

    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.titleLabel.font = SYSTEMFONT(16);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    [customNaviBar addSubview:cancelButton];

    @weakify(self)
    [[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(customNaviBar.mas_right).offset(-5);
        make.width.mas_equalTo(50);
        make.height.equalTo(customNaviBar);
        make.centerY.equalTo(customNaviBar);

    }];

    UIView * searchView = [UIView new];
    searchView.backgroundColor = [UIColor whiteColor];
    ViewBorderRadius(searchView, 5, 0, [UIColor clearColor]);
    [customNaviBar addSubview:searchView];
    
    UITextField * searchTextField = [UITextField new];
    searchTextField.backgroundColor =[UIColor whiteColor];
    searchTextField.delegate = self;
    searchTextField.placeholder = @"搜索位置";
    searchTextField.font = [UIFont systemFontOfSize:15];
    [searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [searchView addSubview:searchTextField];

    UIImageView * searchImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search_fuwa"]];
    searchImage.contentMode = UIViewContentModeScaleToFill;
    [searchView addSubview:searchImage];

    
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cancelButton);
        make.left.equalTo(customNaviBar).offset(15);
        make.bottom.equalTo(customNaviBar).offset(-6);
        make.right.equalTo(cancelButton.mas_left).offset(-5);
        make.height.mas_equalTo(30);
    }];
    
    [searchImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(searchView);
        make.left.equalTo(searchView).offset(10);
        make.height.width.mas_equalTo(15);
        
    }];
    
    [searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cancelButton);
        make.left.equalTo(searchImage.mas_right).offset(5);
        make.bottom.equalTo(searchView).offset(-5);
        make.right.equalTo(searchView).offset(-10);
        make.height.mas_equalTo(20);
        
    }];
    
}


- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView = tableView;
        [self.view addSubview:tableView];
        
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];
        
        
        
        self.tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse_id];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.textColor = HEXRGB(0x999999);
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    
    if (indexPath.row == 0) {
        cell.textLabel.textColor = HEXRGB(0x999999);
        cell.textLabel.text = @"没有找到你的位置";
        cell.detailTextLabel.text = @"创建新的位置";

    }else{
        
        LSFuwaNewAdressModel * model = self.dataSource[indexPath.row-1];
        cell.textLabel.text = model.name;
        cell.textLabel.textColor = HEXRGB(0x000000);
        cell.detailTextLabel.text = model.totalAdress;
    }
    return cell;
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        LSFuwaCreateLocationViewController * createVC =[[UIStoryboard storyboardWithName:@"Fuwa" bundle:nil]instantiateViewControllerWithIdentifier:@"LSFuwaCreateLocationViewController"];
        
        if (self.dataSource.count>0 || self.pois.count>0) {
            AMapPOI * poi = self.pois[0];
            createVC.city = poi.city;
            createVC.district = poi.district;
        }
        [self.navigationController pushViewController:createVC animated:YES];
    }else{
        

        LSFuwaNewAdressModel * model = self.dataSource[indexPath.row-1];
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:model forKey:@"LSFuwaNewAdressModel"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kFuwaNewAdressNoti object:nil userInfo:dic];

        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark - TextFieldDelegate

-(void)textFieldDidChange:(UITextField *)textField{
    if (textField.text.length>0) {
        [self searchLocationWithStr:textField.text];
        [self.tableView reloadData];
    }else{
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:self.locaArr];
        [self.tableView reloadData];
    }
    
}

-(void)searchLocationWithStr:(NSString *)Str{
    [self.dataSource removeAllObjects];
    for (AMapPOI * poi in self.locaArr) {
        if ([poi.name containsString:Str]||[poi.address containsString:Str]) {
            [self.dataSource addObject:poi];
        }
    }
    
}

-(void)setLocaArr:(NSMutableArray *)locaArr{
    _locaArr = locaArr;
    self.dataSource = [NSMutableArray array];
    [self.dataSource addObjectsFromArray:locaArr];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
