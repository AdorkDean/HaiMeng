//
//  LSSearchListView.m
//  LittleSix
//
//  Created by Jim huang on 17/3/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSearchListView.h"
#import "LSTLSelectContactViewController.h"
#import "LSFriendModel.h"
#import "LSFriendLabelManager.h"
static NSString *const reuseId = @"LSTLSelectContactCell";

@interface LSSearchListView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation LSSearchListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setConTraints];
    }
    return self;
}
-(void)setConTraints{
    
    UIView *BGView = [UIView new];
    BGView.backgroundColor = [UIColor whiteColor];
    BGView.alpha = 0.8;
    [self addSubview:BGView];
    
    [self addSubview:self.tableView];
    [self bringSubviewToFront:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.bottom.equalTo(self);
    }];
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.bottom.equalTo(self);
    }];
}

-(void)searchFriendWithStr:(NSString *)str{
    self.dataSource = nil;
    self.dataSource =  [LSFriendLabelManager DBGetFriendsWithStr:str];
    [self.tableView reloadData];
}

#pragma mark tableView
- (UITableView *)tableView {
    
        if (!_tableView) {
            
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
            _tableView = tableView;
            
            tableView.tableFooterView = [UIView new];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.rowHeight = 55;
            tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
            tableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
            tableView.sectionIndexColor = HEXRGB(0x555555);
            tableView.backgroundColor = HEXRGB(0xefeff4);
            tableView.sectionIndexBackgroundColor = [UIColor clearColor];
            tableView.backgroundColor = [UIColor clearColor];

            [tableView registerClass:[LSTLSelectContactCell class] forCellReuseIdentifier:reuseId];
        }
        return _tableView;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
        return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    
    LSTLSelectContactCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    LSFriendModel *friendModel = self.dataSource[indexPath.row];
    cell.selectBtn.hidden = YES;
    cell.model =friendModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(searchView:didSelectedWithModel:)]) {
        LSFriendModel *friendModel = self.dataSource[indexPath.row];
        [self.delegate searchView:self didSelectedWithModel:friendModel];
        self.hidden = YES;
    }
}



@end
