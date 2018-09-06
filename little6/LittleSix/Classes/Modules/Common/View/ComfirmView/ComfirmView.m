//
//  ComfirmView.m
//  ComfirmView
//
//  Created by AdminZhiHua on 16/4/18.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ComfirmView.h"

static NSString *const reuseId = @"ComfirmCell";

@interface ComfirmView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstHeight;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) ModelComfirm *cancelModel;

@property (nonatomic, copy) void (^actionBlock)(ComfirmView *view, NSInteger index);

@end

@implementation ComfirmView

+ (instancetype)showInView:(UIView *)superView
            cancelItemWith:(ModelComfirm *)cancelModel
                dataSource:(NSArray *)dataSource
               actionBlock:(void (^)(ComfirmView *, NSInteger))actionBlock {
    ComfirmView *comfirmView = [[[NSBundle mainBundle] loadNibNamed:@"ComfirmView" owner:nil options:nil] lastObject];

    comfirmView.cancelModel = cancelModel;
    comfirmView.actionBlock = actionBlock;
    comfirmView.dataSource = dataSource;

    comfirmView.frame = superView.bounds;

    [comfirmView layoutIfNeeded];

    [superView addSubview:comfirmView];

    //刷新数据，获取contentSize
    [comfirmView.tableView reloadData];

    //重新设置tableView的高度
    comfirmView.tableViewConstHeight.constant = comfirmView.tableView.contentSize.height;

    [comfirmView showAction];

    return comfirmView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //注册cell
    [self.tableView registerClass:[ComfirmCell class] forCellReuseIdentifier:reuseId];

    self.tableView.backgroundColor = HEXRGB(0xf6f6f6);

    [self viewDidLayoutSubviews];

    //添加点击手势
    UITapGestureRecognizer *tapGest = [UITapGestureRecognizer new];
    [tapGest addTarget:self action:@selector(bgViewDidTap:)];
    [self.bgView addGestureRecognizer:tapGest];
}

//设置tableView的分割线到左边
- (void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Action
- (void)showAction {
    //
    [self layoutIfNeeded];

    self.bgView.alpha = 0.3;

    self.tableView.transform = CGAffineTransformMakeTranslation(0, self.tableViewConstHeight.constant);

    [UIView animateWithDuration:0.25
                     animations:^{

                         self.bgView.alpha = 0.3;

                         self.tableView.transform = CGAffineTransformIdentity;

                     }];
}

- (void)dissmissAcion {
    [UIView animateWithDuration:0.25
        animations:^{

            self.bgView.alpha = 0;
            self.tableView.transform = CGAffineTransformMakeTranslation(0, self.tableViewConstHeight.constant);

        }
        completion:^(BOOL finished) {

            [self removeFromSuperview];

        }];
}

- (void)bgViewDidTap:(UIGestureRecognizer *)gestureRecognizer {
    [self dissmissAcion];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 1 ? 5 : 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 1 ? 1 : self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ComfirmCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];

    ModelComfirm *model;
    if (indexPath.section == 0) {
        model = self.dataSource[indexPath.row];
    } else {
        model = self.cancelModel;
    }

    cell.model = model;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1) {
        if (self.actionBlock) {
            self.actionBlock(self, indexPath.row);
        }
    }

    [self dissmissAcion];
}

- (void)tableView:(UITableView *)tableView
      willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPat {
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

#pragma mark - Getter&Setter
- (ModelComfirm *)cancelModel {
    if (!_cancelModel) {
        ModelComfirm *model = [ModelComfirm comfirmModelWith:@"取消" titleColor:HEXRGB(0x333333) fontSize:16];
        _cancelModel = model;
    }
    return _cancelModel;
}

@end

@interface ComfirmCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ComfirmCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    //重写初始化方法自定义子控件
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)addConstsToTitleLabel {
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *label = self.titleLabel;

    NSString *hVFL = @"H:|-(15)-[label]-(15)-|";
    NSString *vVFL = @"V:|-(0)-[label]-(0)-|";

    NSArray *hConsts = [NSLayoutConstraint constraintsWithVisualFormat:hVFL
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(label)];
    NSArray *vConsts = [NSLayoutConstraint constraintsWithVisualFormat:vVFL
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(label)];

    [self.titleLabel.superview addConstraints:hConsts];
    [self.titleLabel.superview addConstraints:vConsts];
}

#pragma mark - Getter&Setter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        //
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        [self addConstsToTitleLabel];
        [self addConstsToTitleLabel];
    }

    return _titleLabel;
}

- (void)setModel:(ModelComfirm *)model {
    _model = model;

    self.titleLabel.text = model.title;
    self.titleLabel.textColor = model.titleColor;
    self.titleLabel.font = [UIFont systemFontOfSize:model.fontSize];
}

@end

@implementation ModelComfirm

+ (instancetype)comfirmModelWith:(NSString *)title titleColor:(UIColor *)color fontSize:(CGFloat)size {
    ModelComfirm *model = [ModelComfirm new];
    model.title = title;
    model.titleColor = color;
    model.fontSize = size;

    return model;
}

@end
