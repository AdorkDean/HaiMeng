//
//  LSAddConactResultsViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/10.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSAddConactResultsViewController.h"
#import "LSContactViewController.h"
#import "LSContactModel.h"
#import "LSContactDetailViewController.h"
#import "LSSchoolViewController.h"

static NSString *const reuseId = @"LSContactCell";

@interface LSAddConactResultsViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation LSAddConactResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.edges.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(60);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.searchResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    LSContactCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    LSContactModel * model = self.searchResults[indexPath.row];
    cell.contactModel = model;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    LSContactModel * model = self.searchResults[indexPath.row];
    
    if (self.indexClick) {
        self.indexClick(model);
    }
}

#pragma mark - Getter & Setter
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView = tableView;
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.rowHeight = 55;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        tableView.tableFooterView = [UIView new];
        [self.tableView registerClass:[LSContactCell class] forCellReuseIdentifier:reuseId];
    }
    return _tableView;
}

@end
