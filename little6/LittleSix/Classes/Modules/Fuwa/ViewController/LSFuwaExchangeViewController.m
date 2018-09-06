//
//  LSFuwaExchangeViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaExchangeViewController.h"
#import "LSFuwaExchangeModel.h"
#import "LSFuwaPickView.h"
#import "LSPayView.h"
#import "LSFuwaFilterButton.h"
#import "UIView+HUD.h"
#import <AlipaySDK/AlipaySDK.h>

static NSString * const reuseId = @"LSFuwaExchangeBuyCell";

@interface LSFuwaExchangeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,assign) FuwaSaleType saleType;
@property (nonatomic,assign) FuwaSortType sortType;
@property (nonatomic,assign) int filterIndex;

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *allSaleArray;
@property (nonatomic,strong) NSMutableArray *mySaleArray;

@property (nonatomic,strong) LSFuwaExchangeModel *selectedModel;

@property (nonatomic,strong) LSFuwaFilterButton *filterButton;
@property (nonatomic,strong) LSFuwaFilterButton *priceBtn;

@property (nonatomic,strong) UIButton *mySaleButton;
@property (nonatomic,strong) UIButton *allSaleButton;
@property (nonatomic,strong) UIButton *selectedButton;

@property (nonatomic,strong) UIView *scrollBar;

@property (nonatomic,strong) UIButton * buyBtn;
@property (nonatomic,strong) UIButton *editBtn;
@property (nonatomic,assign) BOOL listIsEditing;

@end

@implementation LSFuwaExchangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"交易";
    
    [self installSubviews];
    
    [self loadData];
    
    [self intallNotis];
}

-(void)installSubviews {
    
    //导航条透明
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_obg"].CGImage);
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    UIView *menuView = [UIView new];
    [self.view addSubview:menuView];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitle:@"取消" forState:UIControlStateSelected];
    self.editBtn = editBtn;
    [editBtn setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateNormal];
    editBtn.hidden = YES;
    editBtn.titleLabel.font = SYSTEMFONT(16);
    [editBtn sizeToFit];
    @weakify(self)
    [[editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        editBtn.selected = !editBtn.selected;
        self.listIsEditing = editBtn.selected;
    }];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    UIButton *allSaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    allSaleButton.tag = FuwaSaleTypeAll;
    self.allSaleButton = allSaleButton;
    self.selectedButton = allSaleButton;
    allSaleButton.selected = YES;
    [allSaleButton setTitle:@"寄售摊位" forState:UIControlStateNormal];
    [allSaleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [allSaleButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateSelected];
    [allSaleButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    allSaleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [menuView addSubview:allSaleButton];
    
    UIButton *mySaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mySaleButton.tag = FuwaSaleTypeMy;
    self.mySaleButton = mySaleButton;
    [mySaleButton setTitle:@"我的出售" forState:UIControlStateNormal];
    [mySaleButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [mySaleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [mySaleButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateSelected];
    mySaleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [menuView addSubview:mySaleButton];
    
    UIView *scrollBar = [UIView new];
    self.scrollBar = scrollBar;
    scrollBar.backgroundColor = HEXRGB(0xe7d09a);
    [menuView addSubview:scrollBar];
    
    UIButton *buyButton = [UIButton new];
    self.buyBtn = buyButton;
    ViewBorderRadius(buyButton, 5, 1, HEXRGB(0xff0012));
    [buyButton setTitle:@"购买" forState:UIControlStateNormal];
    [buyButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateNormal];
    [buyButton addTarget:self action:@selector(buyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    buyButton.titleLabel.font = [UIFont systemFontOfSize:18];
    buyButton.backgroundColor = HEXRGB(0xd3000f);
    [self.view addSubview:buyButton];
    
    UIView *bottomPannel = [UIView new];
    bottomPannel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:bottomPannel];
    
    LSFuwaFilterButton *filterButton = [LSFuwaFilterButton new];
    self.filterButton = filterButton;
    filterButton.nameLabel.text = @"筛选";
    filterButton.normalImage = [UIImage imageNamed:@"screen"];
    filterButton.selectImage = [UIImage imageNamed:@"screen_click"];
    filterButton.selected = NO;
    [filterButton addTarget:self action:@selector(filterListClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomPannel addSubview:filterButton];
    
    UIView * marginView = [UIView new];
    [bottomPannel addSubview:marginView];
    
    LSFuwaFilterButton *priceBtn = [LSFuwaFilterButton new];
    priceBtn.nameLabel.text = @"价格";
    priceBtn.normalImage = [UIImage imageNamed:@"price"];
    priceBtn.selectImage = [UIImage imageNamed:@"price_click"];
    priceBtn.selected = NO;
    [priceBtn addTarget:self action:@selector(orderListClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomPannel addSubview:priceBtn];
    
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    [allSaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(menuView);
        make.centerX.equalTo(menuView).offset(-kScreenWidth * 0.12);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(25);
    }];
    
    [mySaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.width.height.equalTo(allSaleButton);
        make.centerX.equalTo(menuView).offset(kScreenWidth * 0.12);
    }];
    
    [scrollBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(menuView.mas_bottom);
        make.width.equalTo(allSaleButton.mas_width);
        make.centerX.equalTo(allSaleButton.mas_centerX);
        make.height.mas_equalTo(3);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(menuView.mas_bottom).offset(5);
        make.right.left.equalTo(self.view);
        CGFloat margin = kScreenHeight > 568 ? 400 : 200;
        make.height.offset(margin);
    }];
    
    [bottomPannel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(49);
        make.left.bottom.right.equalTo(self.view);
    }];
    
    [filterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(bottomPannel).multipliedBy(0.5);
        make.left.top.bottom.equalTo(bottomPannel);
    }];
    
    [marginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.equalTo(bottomPannel).multipliedBy(0.5);
        make.left.equalTo(filterButton.mas_right);
        make.centerY.equalTo(bottomPannel);
    }];
    
    [priceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(marginView.mas_right);
        make.right.top.bottom.equalTo(bottomPannel);
    }];
    
    [buyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom).offset(30);
        make.width.mas_equalTo(287);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(45);
    }];
}

- (void)intallNotis {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kPaySuccessNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self loadData];
    }];
}

- (void)loadData {
    
//    RACSignal *sinal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//        [LSFuwaExchangeModel getFuwaExMyListSuccess:^(NSArray *listArr) {
//            [subscriber sendNext:listArr];
//            [subscriber sendCompleted];
//        } failure:^(NSError *error) {
//            [subscriber sendError:error];
//        }];
//        return nil;
//    }];
//    RACSignal *sinal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//        
//        [LSFuwaExchangeModel getFuwaExchangeListSuccess:^(NSArray *listArr) {
//            [subscriber sendNext:listArr];
//            [subscriber sendCompleted];
//        } failure:^(NSError *error) {
//            [subscriber sendError:error];
//        }];
//
//        return nil;
//    }];
    

    [LSFuwaExchangeModel getFuwaExchangeListSuccess:^(NSArray *listArr) {
        self.allSaleArray = [NSMutableArray arrayWithArray:listArr];
        [self handleDataSource];
        
        [LSFuwaExchangeModel getFuwaExMyListSuccess:^(NSArray *listArr) {
            self.mySaleArray = [NSMutableArray arrayWithArray:listArr];
            [self handleDataSource];
            
        } failure:^(NSError *error) {
            [self.view showError:@"请求失败" hideAfterDelay:1.5];
        }];
        
    } failure:^(NSError *error) {
        [self.view showError:@"请求失败" hideAfterDelay:1.5];
    }];


    
//    [[RACSignal combineLatest:@[sinal1,sinal2]] subscribeNext:^(RACTuple *tuple) {
//        
//        self.mySaleArray = [NSMutableArray arrayWithArray:tuple.first];
//        self.allSaleArray = [NSMutableArray arrayWithArray:tuple.last];
//        [self handleDataSource];
//        
//    } error:^(NSError * _Nullable error) {
//        [self.view showError:@"请求失败" hideAfterDelay:1.5];
//    }];
}

-(void)buyButtonClick{
    if (self.selectedModel != nil) {
        
        for (LSFuwaExchangeModel * buyModel in self.dataSource) {
            
            if (buyModel.fuwagid == self.selectedModel.fuwagid) {
                [LSFuwaBuyComfirmView showInView:LSKeyWindow withDataModel:self.selectedModel comfirmBlock:^{
                    //显示支付view
                    [LSPayView showInView:LSKeyWindow price:self.selectedModel.amount withPayBlock:^(LSPayType type) {
                        switch (type) {
                            case LSPayTypeWechat:
                                [self wechatPay];
                                break;
                            default:
                                [self aliPay];
                                break;
                        }
                    }];
                }];
                return;
            }
        }
        
        [self.view showError:@"请选择要购买的福娃" hideAfterDelay:1];

        
    }
    else {
        [self.view showError:@"请选择要购买的福娃" hideAfterDelay:1];
    }
}

- (void)wechatPay {
    
//    self.selectedModel
    
}

- (void)aliPay {
    
    [self.view showLoading];
    
    [LSFuwaExchangeModel requestAlipay:self.selectedModel.orderid amount:self.selectedModel.amount gid:self.selectedModel.fuwagid success:^(NSString *orderString) {
        
        [LSKeyWindow hideHUDAnimated:YES];
        [self doAlipay:orderString];
        [self loadData];
        [self handleDataSource];
        self.selectedModel = nil;
        [self.view showSucceed:@"支付成功" hideAfterDelay:2];

    } failure:^(NSError *error) {
        [self.view showError:@"支付失败" hideAfterDelay:1.5];
    }];
}

- (void)doAlipay:(NSString *)orderString {
    
    if (!orderString) return;
    
    NSString *appScheme = @"HimengApp";
    
    // NOTE: 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"支付回调 = %@",resultDic);
    }];
}

-(void)filterListClick:(UIButton *)btn {
    LSFuwaPickView * pick = [LSFuwaPickView new];
    @weakify(self)
    [pick setSureButtonBlock:^(int fuwaIndex) {
        @strongify(self)
        self.filterIndex = fuwaIndex;
        self.filterButton.selected = fuwaIndex;

        if (fuwaIndex>0)
            self.filterButton.nameLabel.text = [NSString stringWithFormat:@"%d号福娃" ,fuwaIndex];
        else
            self.filterButton.nameLabel.text = @"全部";
        
        [self handleDataSource];
    }];
    [self.view addSubview:pick];
}

- (void)orderListClick:(LSFuwaFilterButton *)btn {
    btn.selected = YES;
    
    if (self.sortType == FuwaSortTypeAsc) {
        self.sortType = FuwaSortTypeDesc;
        btn.nameLabel.text = @"价格从高到低";
    }
    else {
        self.sortType = FuwaSortTypeAsc;
        btn.nameLabel.text =@"价格从低到高";
    }
    
    [self handleDataSource];
}

- (void)handleDataSource {
    
    NSMutableArray *sourceArray = self.saleType == FuwaSaleTypeAll ? self.allSaleArray : self.mySaleArray;
    
    //筛选福娃
    NSMutableArray *filterArr = [self filterData:sourceArray byIndex:self.filterIndex];
    
    //数组排序
    [filterArr sortUsingComparator:^NSComparisonResult(LSFuwaExchangeModel *_Nonnull obj1, LSFuwaExchangeModel *_Nonnull obj2) {
        
        if (self.sortType == FuwaSortTypeAsc) {
            
            if (obj2.amount.floatValue >obj1.amount.floatValue)
                return NSOrderedAscending;
            else
                return NSOrderedDescending;

//            return [obj1.amount compare:obj2.amount options:NSCaseInsensitiveSearch];
        }
        else if (self.sortType == FuwaSortTypeDesc) {
            
            if (obj1.amount.floatValue >obj2.amount.floatValue)
                return NSOrderedAscending;
            else
                return NSOrderedDescending;

            
//            return [obj2.amount compare:obj1.amount options:NSCaseInsensitiveSearch];
        }//不排序
        else {
            return [obj1.amount compare:obj1.amount options:NSCaseInsensitiveSearch];
        }
    }];
    
    for (LSFuwaExchangeModel * model in filterArr) {
        NSLog(@"%.2f",model.amount.floatValue);

    }
    self.dataSource = [NSMutableArray arrayWithArray:filterArr];
    [self.collectionView reloadData];
}

- (NSMutableArray *)filterData:(NSMutableArray *)data byIndex:(int)index {
    
    if (index == 0) return data;
    
    NSMutableArray * handleArr  = [NSMutableArray array];
    
    for (LSFuwaExchangeModel *obj in data) {
        if (obj.fuwaid.intValue != index) continue;
        [handleArr addObject:obj];
    }
    
    return handleArr;
}

- (void)menuButtonAction:(UIButton *)button {
    
    self.selectedButton = button;
    
    self.saleType = button.tag;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollBar.centerX = button.centerX;
    }];
    
    [self handleDataSource];
}


#pragma marl _collectionView
-(UICollectionView *)collectionView {
    
    if (_collectionView == nil) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection =UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 20;
        layout.minimumInteritemSpacing = 20;
        layout.itemSize = CGSizeMake(100, 165);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerNib:[UINib nibWithNibName:@"LSFuwaExchangeBuyCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:reuseId];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:self.collectionView];
    }
    
    return _collectionView;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSFuwaExchangeBuyCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    LSFuwaExchangeModel * model = self.dataSource[indexPath.row];
    model.index = indexPath;
    cell.model = model;
    cell.cellEdit = self.listIsEditing;
    return cell;
    
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 15, 15, 15);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.saleType == FuwaSaleTypeAll){
    
    LSFuwaExchangeBuyCell * cell = (LSFuwaExchangeBuyCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
        if (cell.model == self.selectedModel) {
            cell.cellSelect = NO;
            self.selectedModel = nil;
        }else{
            LSFuwaExchangeBuyCell * selectCell = (LSFuwaExchangeBuyCell *)[collectionView cellForItemAtIndexPath:self.selectedModel.index];
            selectCell.cellSelect = NO;
            cell.cellSelect = YES;
            self.selectedModel = cell.model;
        }
    }else if (self.saleType == FuwaSaleTypeMy && self.listIsEditing == YES){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否撤销该福娃？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        UIAlertAction * login = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            LSFuwaExchangeModel * model = self.dataSource[indexPath.row];
            [self.view showLoading];
            [LSFuwaExchangeModel revokeFuwaWithOrderID:model.orderid Gid:model.fuwagid Success:^{
                [self.view showSucceed:@"撤销成功"hideAfterDelay:1];
                [self loadData];
                [self handleDataSource];
                
            } failure:^(NSError *error) {
                [self.view showSucceed:@"撤销失败"hideAfterDelay:0.5];

            }];
        }];
        [alert addAction:cancel];
        [alert addAction:login];
        
        [self presentViewController:alert animated:YES completion:nil];
                                 
        
    }
    
}



-(void)setSaleType:(FuwaSaleType)saleType{
    _saleType = saleType;
    if (saleType == FuwaSaleTypeAll){
        self.editBtn.hidden = YES;
        self.buyBtn.hidden = NO;
        self.editBtn.selected = NO;
        self.listIsEditing = NO;
    }else{
        self.editBtn.hidden = NO;
        self.buyBtn.hidden = YES;
        
    }
}


- (void)setSelectedButton:(UIButton *)selectedButton {
    _selectedButton.selected = NO;
    selectedButton.selected = YES;
    _selectedButton = selectedButton;
}

-(void)setListIsEditing:(BOOL)listIsEditing{
    _listIsEditing = listIsEditing;
    [self.collectionView reloadData];
}

@end

@interface LSFuwaExchangeBuyCell ()

@property (weak, nonatomic) IBOutlet UIButton *numBtn;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation LSFuwaExchangeBuyCell

- (void)setModel:(LSFuwaExchangeModel *)model {
    _model = model;
    [self.numBtn setTitle:model.fuwaid forState:UIControlStateNormal];
    self.priceLabel.text = [NSString stringWithFormat:@"¥%@",model.amount];
    self.cellSelect = model.cellSelect;
    if (model.cellSelect) {
        self.selectView.hidden = NO;
    }else{
        self.selectView.hidden = YES;
    }
}
-(void)setCellSelect:(BOOL)cellSelect{
    _cellSelect = cellSelect;
    self.model.cellSelect = cellSelect;
    if (cellSelect) {
        self.selectView.hidden = NO;
    }else{
        self.selectView.hidden = YES;
    }
}
- (IBAction)deleteAction:(id)sender {
    
    NSLog(@"删除啦~删除啦~");
}

-(void)setCellEdit:(BOOL)cellEdit{
    _cellEdit = cellEdit;
    self.deleteBtn.hidden = !cellEdit;
}

@end

@interface LSFuwaBuyComfirmView ()

@property (weak, nonatomic) IBOutlet UIButton *BGbtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *numBtn;

@end

@implementation LSFuwaBuyComfirmView

+ (instancetype)showInView:(UIView *)view withDataModel:(LSFuwaExchangeModel *)model comfirmBlock:(void (^)())block {
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"LSFuwaComfirmView" owner:nil options:nil];
    LSFuwaBuyComfirmView *comfirmView = views[1];
    
    comfirmView.model = model;
    comfirmView.buyButtonBlock = block;
    
    comfirmView.frame = view.bounds;
    [view addSubview:comfirmView];
    
    return comfirmView;
}

- (void)setModel:(LSFuwaExchangeModel *)model {
    _model = model;
    self.nameLabel.text =[NSString stringWithFormat:@"%d号福娃", model.fuwaid.intValue];
    
    self.priceLabel.text = [NSString stringWithFormat:@"购买金额为:%.2f元",  model.amount.floatValue];
    [self.numBtn setTitle:model.fuwaid forState:UIControlStateNormal];
}


- (void)awakeFromNib {
    [self.BGbtn addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [super awakeFromNib];
    ViewBorderRadius(self.sureBtn, 5, 1, HEXRGB(0xff0012));

}
- (IBAction)sureBtnClick:(UIButton *)sender {
    
    !self.buyButtonBlock?:self.buyButtonBlock();
    
    [self removeFromSuperview];
}

@end
