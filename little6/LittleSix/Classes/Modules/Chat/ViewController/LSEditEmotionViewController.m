//
//  LSEditEmotionViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/10.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEditEmotionViewController.h"
#import "LSEmotionModel.h"
#import "IQKeyboardManager.h"

#define kEditFont BOLDSYSTEMFONT(22)

@interface LSEditEmotionViewController ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIView *inputView;
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) YYLabel *textLabel;
@property (nonatomic,strong) UIView *editView;

@end

@implementation LSEditEmotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"编辑表情";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initSubviews];
    
    self.imageView.image = [UIImage imageWithContentsOfFile:[self.model filePath]];
    
    [self registNotis];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [IQKeyboardManager sharedManager].enable = YES;
}

//添加子view
- (void)initSubviews {
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIView *editView = [UIView new];
    editView.clipsToBounds = YES;
    self.editView = editView;
    editView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:editView];
    
    [editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(contentView).offset(15);
        make.width.height.offset(kScreenWidth-30);
    }];
    
    UIImageView *imageView = [UIImageView new];
    self.imageView = imageView;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [editView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(editView);
    }];
    
    UILabel *tipsLabel = [UILabel new];
    tipsLabel.text = @"长按文本框编辑 按住拖动";
    tipsLabel.font = SYSTEMFONT(12);
    [contentView addSubview:tipsLabel];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(editView.mas_bottom).offset(30);
    }];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ViewBorderRadius(sendButton, 5, 1, HEXRGB(0xd42136));
    sendButton.backgroundColor = kMainColor;
    [sendButton addTarget:self action:@selector(sendButtonActon:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [contentView addSubview:sendButton];
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(editView);
        make.top.equalTo(tipsLabel.mas_bottom).offset(20);
        make.height.offset(47);
    }];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ViewBorderRadius(addButton, 5, 1, HEXRGB(0x8f8f8f));
    addButton.backgroundColor = [UIColor whiteColor];
    [addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTitle:@"添加到表情" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [contentView addSubview:addButton];
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.left.right.equalTo(sendButton);
        make.top.equalTo(sendButton.mas_bottom).offset(20);
    }];
    
    [contentView layoutIfNeeded];
    contentView.frame = CGRectMake(0, 0, kScreenWidth, CGRectGetMaxY(addButton.frame)+50);
    tableView.tableHeaderView = contentView;
    
    YYLabel *textLabel = [YYLabel new];
    self.textLabel = textLabel;
    textLabel.numberOfLines = 0;
    textLabel.textAlignment = NSTextAlignmentCenter;
    [editView addSubview:textLabel];
    textLabel.text = @"长按编辑";
    textLabel.font = kEditFont;
    
    CGSize size = [textLabel.text sizeForFont:textLabel.font size:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping];
    
    CGFloat labelW = size.width + 20;
    CGFloat labelH = size.height + 20;
    CGFloat labelX = ((kScreenWidth - 30) - labelW) * 0.5;
    CGFloat labelY = editView.height - 20 - labelH;
    
    textLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
    ViewBorderRadius(textLabel, 0, 1.5, kMainColor);
    
    UILongPressGestureRecognizer *longGest = [UILongPressGestureRecognizer new];
    longGest.minimumPressDuration = 1.0;
    [textLabel addGestureRecognizer:longGest];
    @weakify(self)
    [[longGest rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self)
        [self.textField becomeFirstResponder];
    }];
    
    UIPanGestureRecognizer *panGest = [UIPanGestureRecognizer new];
    [textLabel addGestureRecognizer:panGest];
    [[panGest rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable gest) {
        CGPoint point = [gest translationInView:editView];
        gest.view.center = CGPointMake(gest.view.center.x + point.x, gest.view.center.y + point.y);
        [gest setTranslation:CGPointMake(0, 0) inView:editView];
    }];
    
    UIView *inputView = [UIView new];
    self.inputView = inputView;
    inputView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:inputView];
    [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom);
        make.height.offset(44);
    }];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.titleLabel.font = SYSTEMFONT(15);
    doneButton.backgroundColor = kMainColor;
    [doneButton setTitle:@"确定" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:doneButton];
    [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(inputView);
        make.right.equalTo(inputView).offset(-8);
        make.top.equalTo(inputView).offset(5);
        make.bottom.equalTo(inputView).offset(-5);
        make.width.offset(50);
    }];
    
    ViewRadius(doneButton, 5);
    
    UITextField *textField = [UITextField new];
    self.textField = textField;
    textField.font = SYSTEMFONT(15);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = @"请输入编辑内容";
    [inputView addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(inputView).offset(8);
        make.right.equalTo(doneButton.mas_left).offset(-8);
        make.centerY.height.equalTo(doneButton);
    }];
}

- (void)registNotis {
    
    //添加键盘处理事件
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification *notification) {
        @strongify(self)
        
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        [UIView animateWithDuration:duration animations:^{
            [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_bottom).offset(-keyBoardFrame.size.height-44);
            }];
            [self.view layoutIfNeeded];
        }];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(NSNotification *notification) {
        @strongify(self)
        
        CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        [UIView animateWithDuration:duration animations:^{
            [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_bottom);
            }];
            [self.view layoutIfNeeded];
        }];
    }];
}

#pragma mark - Action 
- (void)doneButtonAction:(UIButton *)button {
    [self.textField endEditing:YES];
    
    NSString *text = self.textField.text;
    self.textField.text = nil;
    
    self.textLabel.text = text;

    CGSize size = [text sizeForFont:self.textLabel.font size:CGSizeMake((kScreenWidth-30-20), CGFLOAT_MAX) mode:NSLineBreakByWordWrapping];
    
    CGFloat labelW = size.width + 20;
    CGFloat labelH = size.height + 20;
    
    self.textLabel.width = labelW;
    self.textLabel.height = labelH;
}

- (void)sendButtonActon:(UIButton *)button {
    
    ViewBorderRadius(self.textLabel, 0, 1.5, [UIColor clearColor]);
    
    UIImage *image = [self resizeEditImage];
    
    !self.completeBlock?:self.completeBlock(LSEmotionOperationSend,image);
}

- (void)addButtonAction:(UIButton *)button {
    
    ViewBorderRadius(self.textLabel, 0, 1.5, [UIColor clearColor]);
    
    UIImage *image = [self resizeEditImage];

    !self.completeBlock?:self.completeBlock(LSEmotionOperationAdd,image);
}

- (UIImage *)resizeEditImage {
    
    UIImage *image = [self.editView snapshotImageAfterScreenUpdates:YES];
    CGSize size = self.imageView.image.size;
    CGFloat width = MIN(size.width, size.height);
    
    UIImage *newImage = [image imageByResizeToSize:CGSizeMake(width, width) contentMode:UIViewContentModeScaleAspectFill];
    
    return newImage;
}

@end
