//
//  LSTLPickGroupViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/9.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTLPickGroupViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>

static NSString *const reuseId = @"LSPickGroupCell";

@interface LSTLPickGroupViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation LSTLPickGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择一个群";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.tableView reloadData];
    
    [self _naviLeftItemConfig];
}

- (void)_naviLeftItemConfig {
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.titleLabel.font = SYSTEMFONT(16);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    @weakify(self)
    [[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSTLPickGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Getter & Setter
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
        
        [tableView registerClass:[LSTLPickGroupCell class] forCellReuseIdentifier:reuseId];
        
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuide);
            make.left.right.bottom.equalTo(self.view);
        }];
    }
    return _tableView;
}

@end

@interface LSTLPickGroupCell ()

@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation LSTLPickGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [UIImageView new];
        self.iconView = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.centerY.equalTo(self);
            make.width.height.offset(37);
        }];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = SYSTEMFONT(16);
        self.titleLabel = titleLabel;
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(iconView);
            make.left.equalTo(iconView.mas_right).offset(10);
        }];
        
        iconView.backgroundColor = [UIColor grayColor];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"鱼香茄子(7)"];
        
        [attr addAttribute:NSForegroundColorAttributeName value:HEXRGB(0x888888) range:NSMakeRange(4, 3)];
        
        titleLabel.attributedText = attr;
        
    }
    return self;
}

@end
