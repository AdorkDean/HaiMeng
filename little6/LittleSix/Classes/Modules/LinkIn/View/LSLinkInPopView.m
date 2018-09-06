//
//  LSLinkInPopView.m
//  LittleSix
//
//  Created by GMAR on 2017/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkInPopView.h"
#import <YYKit/YYKit.h>

static NSString * reuse_id = @"LSLinkInPopCell";
@interface LSLinkInPopView () <UITableViewDelegate,UITableViewDataSource>

@property (retain,nonatomic) UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (retain,nonatomic) NSMutableArray * dataSource;
@property (assign,nonatomic) CGFloat height;

@end

@implementation LSLinkInPopView

- (NSMutableArray *)dataSource {

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

+ (instancetype)linkInMainView {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"LSLinkInPopView" owner:nil options:nil] lastObject];
}

- (void)showInView:(UIViewController *)view andArray:(NSArray *)list withBlock:(void(^)(NSString *title))sureBlock {

    self.frame = CGRectMake(0, 0,kScreenWidth , kScreenHeight);
    [view.navigationController.view addSubview:self];
    self.height = 0;
    self.backgroundView.alpha = 0;
    self.sureBlock = sureBlock;
    [self.dataSource addObjectsFromArray:list];
    for (NSArray * arr in self.dataSource) {
        self.height = self.height + arr.count * 50;
    }
    [self setTableView];
}

- (void)setTableView {

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kScreenHeight,kScreenWidth , (10*(self.dataSource.count-1))+self.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.alpha = 0.9;
    [self addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.tableView registerClass:[LSLinkInPopCell class] forCellReuseIdentifier:reuse_id];
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.top = kScreenHeight - ((10*(self.dataSource.count-1))+self.height);
        self.backgroundView.alpha = 0.6;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self removeFromThisViews];
}

- (void)removeFromThisViews {

    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.top = kScreenHeight;
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        return 0.01;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSArray * array = self.dataSource[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LSLinkInPopCell * cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    NSArray * array = self.dataSource[indexPath.section];
    cell.titleLabel.text = array [indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray * array = self.dataSource[indexPath.section];
    
    if (![array[indexPath.row] isEqualToString:@"取消"]) {
        if (self.sureBlock) {
            self.sureBlock(array[indexPath.row]);
        }
    }
    [self removeFromThisViews];
    
}

@end

@implementation LSLinkInPopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        UILabel * textLabel = [UILabel new];
        self.titleLabel = textLabel;
        textLabel.font = SYSTEMFONT(17);
        textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:textLabel];
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = HEXRGB(0xbcbcbc);
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.offset(0.5);
        }];
    }
    return self;
}

@end
