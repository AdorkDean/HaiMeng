//
//  LSEmotionManagerViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/29.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEmotionManagerViewController.h"
#import "LSEmotionManager.h"
#import "UIView+HUD.h"

static NSString *reuse_id = @"LSEmotionManagerCell";
static NSString *reuse_normal_id = @"LSEmotionNormalCell";

@interface LSEmotionManagerViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray<LSEmotionPackage *> *dataSource;

@end

@implementation LSEmotionManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"我的表情";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.dataSource = [LSEmotionManager allPackages];
    [self.tableView reloadData];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.dataSource.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        LSEmotionManagerCell *packageCell = (LSEmotionManagerCell *)[tableView dequeueReusableCellWithIdentifier:reuse_id];
        cell = packageCell;
        LSEmotionPackage *package = self.dataSource[indexPath.row];
        [cell setValue:package forKey:@"package"];
        @weakify(self)
        [[packageCell.removeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            
            NSString *message = [NSString stringWithFormat:@"你确定要移除表情包“%@”吗？",package.group_name];
            [self.view showAlertWithTitle:@"提示" message:message cancelAction:nil doneAction:^{
                //删除数据库
                [LSEmotionManager deleteEmotionPackageById:package.group_id];
                //更新表情键盘
                [[NSNotificationCenter defaultCenter] postNotificationName:kEmotionPackageUpdateNoti object:nil];
                //更新TableView
                NSInteger idx = [self.dataSource indexOfObject:package];
                [self.dataSource removeObject:package];
                [tableView beginUpdates];
                [tableView deleteRow:idx inSection:0 withRowAnimation:UITableViewRowAnimationTop];
                [tableView endUpdates];
            }];
            
        }];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:reuse_normal_id];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 50 : 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark - Getter & Setter 
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView = tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        tableView.tableFooterView = [UIView new];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];
        [tableView registerClass:[LSEmotionManagerCell class] forCellReuseIdentifier:reuse_id];
        [tableView registerClass:[LSEmotionNormalCell class] forCellReuseIdentifier:reuse_normal_id];
    }
    return _tableView;
}

@end

@implementation LSEmotionManagerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *iconView = [UIImageView new];
        self.iconView = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.offset(15);
            make.width.height.offset(40);
        }];
        
        UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.removeButton = removeButton;
        removeButton.titleLabel.font = SYSTEMFONT(13);
        removeButton.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [removeButton setBackgroundImage:[UIImage imageNamed:@"emotion_greyborder"] forState:UIControlStateNormal];
        [removeButton setTitle:@"移除" forState:UIControlStateNormal];
        [removeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:removeButton];
        [removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-15);
            make.height.offset(30);
            make.width.offset(60);
        }];
        
        UILabel *nameLabel = [UILabel new];
        self.nameLabel = nameLabel;
        nameLabel.font = SYSTEMFONT(15);
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.mas_right).offset(12);
            make.right.equalTo(removeButton.mas_left).offset(-10);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

- (void)setPackage:(LSEmotionPackage *)package {
    _package = package;

    self.iconView.image = [UIImage imageWithContentsOfFile:[package iconPath]];
    self.nameLabel.text = package.group_name;
}

@end

@implementation LSEmotionNormalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        UILabel *nameLabel = [UILabel new];
        nameLabel.font = SYSTEMFONT(15);
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(self);
        }];
        nameLabel.text = @"添加的表情";
    }
    return self;
}

@end
