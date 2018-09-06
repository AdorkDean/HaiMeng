//
//  WeiboReportViewController.m
//  SixtySixBoss
//
//  Created by ZhiHua on 2016/10/5.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "WeiboReportViewController.h"
#import "UIView+HUD.h"

static NSString *reuse_id = @"WeiboReasonCell";

@interface WeiboReportViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) NSArray *reasons;

@property (nonatomic,strong) UICollectionView *collectionView;

@end

@implementation WeiboReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"举报";
    [self _instalSubViews];
}

- (void)_instalSubViews {
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_close"] style:UIBarButtonItemStylePlain target:self action:@selector(leftItemAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIScrollView *scrollView = [UIScrollView new];
    [self.view addSubview:scrollView];
    scrollView.bounces = YES;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    UIView *containerView = [UIView new];
    [scrollView addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(kScreenWidth*0.5, 40);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    UICollectionView *reasonView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    reasonView.delegate = self;
    reasonView.dataSource = self;
    [reasonView registerClass:[WeiboReasonCell class] forCellWithReuseIdentifier:reuse_id];
    reasonView.backgroundColor = [UIColor whiteColor];
    self.collectionView = reasonView;
    [scrollView addSubview:reasonView];
    
    [reasonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(containerView);
        make.top.equalTo(containerView).offset(10);
        make.height.offset(layout.itemSize.height*4);
    }];
    
    YYTextView *textView = [YYTextView new];
    textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    textView.font = [UIFont systemFontOfSize:15];
    textView.placeholderText = @"请详细填写,以确保举报能够被受处理。";
    textView.placeholderTextColor = HEXRGB(0xbbbbbb);
    textView.layer.borderColor = HEXRGB(0xcccccc).CGColor;
    textView.layer.borderWidth = 0.5;
    textView.layer.cornerRadius = 6;
    textView.layer.masksToBounds = YES;
    [scrollView addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(reasonView.mas_bottom).offset(10);
        make.left.equalTo(containerView).offset(15);
        make.right.equalTo(containerView).offset(-15);
        make.height.equalTo(@100);
    }];
    
    UIButton *reportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scrollView addSubview:reportBtn];
    [reportBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    reportBtn.backgroundColor = kMainColor;
    [reportBtn setTitle:@"举报" forState:UIControlStateNormal];
    reportBtn.layer.cornerRadius = 4;
    reportBtn.layer.masksToBounds = YES;
    [reportBtn addTarget:self action:@selector(reportButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [reportBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(textView);
        make.top.equalTo(textView.mas_bottom).offset(25);
        make.height.equalTo(@40);
        make.bottom.equalTo(containerView).offset(-20);
    }];
    
}

- (CGSize)attrSizeWithAttrString:(NSMutableAttributedString *)attrStr constWidth:(CGFloat)width {
    
    CGSize size = CGSizeMake(width, CGFLOAT_MAX);

    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attrStr];
    
    return CGSizeMake(layout.textBoundingSize.width, layout.textBoundingSize.height+3);
}

#pragma mark - Action
- (void)reportButtonAction:(UIButton *)button {
    
    [self.view endEditing:YES];
    [self.view showLoading:@"正在请求"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view showSucceed:@"举报成功" hideAfterDelay:1.5];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)leftItemAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchAction:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.reasons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WeiboReasonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_id forIndexPath:indexPath];
    
    ReportReason *reason = self.reasons[indexPath.row];
    
    [cell.item setTitle:reason.reson forState:UIControlStateNormal];
    
    NSString *image = reason.select?@"chat_circle_click":@"chat_radio_m";
    [cell.item setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    for (ReportReason *reason in self.reasons)
    {
        reason.select = NO;
    }
    
    ReportReason *reason = self.reasons[indexPath.row];
    reason.select = YES;
    
    [collectionView reloadData];
}

#pragma mark - Getter & Setter
- (NSArray *)reasons {
    if (!_reasons)
    {
        ReportReason *reason1 = [ReportReason reasonWith:@"垃圾营销"];
        ReportReason *reason2 = [ReportReason reasonWith:@"不实信息"];
        ReportReason *reason3 = [ReportReason reasonWith:@"有害信息"];
        ReportReason *reason4 = [ReportReason reasonWith:@"淫秽色情"];
        ReportReason *reason5 = [ReportReason reasonWith:@"人身攻击"];
        ReportReason *reason6 = [ReportReason reasonWith:@"违法信息"];
        ReportReason *reason7 = [ReportReason reasonWith:@"抄袭我的"];
        ReportReason *reason8 = [ReportReason reasonWith:@"违规活动"];
        self.reasons = @[reason1,reason2,reason3,reason4,reason5,reason6,reason7,reason8];
    }
    return _reasons;
}

@end

@implementation WeiboReasonCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame])
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"chat_radio_m"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"chat_circle_click"] forState:UIControlStateSelected];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:HEXRGB(0x333333) forState:UIControlStateNormal];
        button.enabled = NO;
        self.item = button;
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.right.top.bottom.equalTo(self);
        }];
    }
    return self;
}

@end

@implementation ReportReason

+ (instancetype)reasonWith:(NSString *)title {
    ReportReason *reason = [ReportReason new];
    reason.reson = title;
    return reason;
}

@end
