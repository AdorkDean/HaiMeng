//
//  LSShakeSettingViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSShakeSettingViewController.h"

static NSString *reuseId = @"LSShakeSettingCell";

@interface LSShakeSettingViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tabelView;

@end

@implementation LSShakeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"摇一摇设置";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.tabelView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section==0 ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSShakeSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    cell.indexPath = indexPath;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15 : 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Getter & Setter
- (UITableView *)tabelView {
    if (!_tabelView) {
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tabelView = tableView;
        tableView.backgroundColor = HEXRGB(0xefeff4);
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[LSShakeSettingCell class] forCellReuseIdentifier:reuseId];
        tableView.rowHeight = 44;
        
        tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
        tableView.layoutMargins = UIEdgeInsetsMake(0, 15, 0, 0);
        
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuide);
            make.left.right.bottom.equalTo(self.view);
        }];
    }
    return _tabelView;
}


@end

@implementation LSShakeSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = SYSTEMFONT(14);
        titleLabel.textColor = [UIColor blackColor];
        self.titleLabel = titleLabel;
        
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(15);
        }];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    return self;
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        self.titleLabel.text = @"打招呼的人";
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        self.titleLabel.text = @"摇到的历史";
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        self.titleLabel.text = @"摇一摇消息";
    }
}

@end
