//
//  LSOptionsView.m
//  LittleSix
//
//  Created by Jim huang on 17/2/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSOptionsView.h"
#define margin 10
#define cancelHeight 50
static NSString *const reuse_id = @"Cell";

@interface LSOptionsView ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UIControl *bgView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@end

@implementation LSOptionsView



-(instancetype)initWithFrame:(CGRect)frame WithData:(NSArray *)data{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.bgView = [UIControl new];
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.alpha = 0.7;
        [self.bgView addTarget:self action:@selector(removeFromThisViews) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.bgView];
        
        self.dataSource = [NSMutableArray array];
        [self.dataSource addObjectsFromArray:data];
        self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self addSubview:self.tableView];
        self.tableView.scrollEnabled = NO;
        CGFloat tableViewHeight = 50*(self.dataSource.count)+margin+cancelHeight;
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.mas_equalTo(tableViewHeight);
        }];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.bottom.equalTo(self.tableView.mas_top);
            
        }];
        self.tableView.delegate =self;
        self.tableView.dataSource = self;
        self.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {

        }];
        
    }
    return self;
}


- (void)removeFromThisViews {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark tableviewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return section==0?self.dataSource.count:1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?0:10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse_id];
    }
    NSString * title;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if (indexPath.section==0) {
        title = self.dataSource[indexPath.row];
        cell.textLabel.text = title;
    }else
    {
        title = @"取消";
        cell.textLabel.text = title;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSString *title = self.dataSource[indexPath.row];
        self.selectCellBlock(title);
    }
    
    [self removeFromThisViews];
    
}

@end
