//
//  LSFuwaBackpackViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaBackpackViewController.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "UIView+HUD.h"
#import "LSBaseFuwaModelCell.h"
#import "LSClanCofcViewController.h"
#import "LSIndexLinkInModel.h"
#import "LSFuwaModel.h"
#import "QRCodeImage.h"
#import "LSQRCodeViewController.h"
#import "UIImage+QRCode.h"
#import "MLLinkLabel.h"

static NSString * const reuseId = @"LSFuwaBackPackCollectionCell";

@interface LSFuwaBackpackViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic ,strong) UICollectionView * collectionView;
@property (nonatomic,strong) NSArray * dataSource;
@property (nonatomic,strong) UIButton * catchListBtn;
@property (nonatomic,strong) UIButton * applyListBtn;
@property (nonatomic,strong) UIButton * selectedBtn;
@property (nonatomic,strong) UIView * colorView;

@property (nonatomic,assign) FuwaBackPickertype listType;
@property (nonatomic,weak) LSFuwaDetailView * detailView;


@end

@implementation LSFuwaBackpackViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //导航条透明
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    [self setNaviBarTintColor:HEXRGB(0xe7d09a)];
}
- (void)setNaviBarTintColor:(UIColor *)color {
    //
    NSDictionary *attribute = @{NSForegroundColorAttributeName : color};
    [self.navigationController.navigationBar setTitleTextAttributes:attribute];
    [self.navigationController.navigationBar setBarTintColor:color];
    [self.navigationController.navigationBar setTintColor:color];
    //设置UIBarbuttonItem的大小样式
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    NSMutableDictionary *itemAttr = [NSMutableDictionary dictionary];
    itemAttr[NSForegroundColorAttributeName] = color;
    itemAttr[NSFontAttributeName] = SYSTEMFONT(16);
    [item setTitleTextAttributes:itemAttr forState:UIControlStateNormal];
    [item setTitleTextAttributes:itemAttr forState:UIControlStateHighlighted];
    [item setTitleTextAttributes:itemAttr forState:UIControlStateSelected];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"背包";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setContraints];
    
    
    [self registNotis];
    
    self.catchListBtn.selected = YES;
    self.selectedBtn = self.catchListBtn;
    self.listType = FuwaBackPickertypeCatch;
    
}

- (void)registNotis {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:reloadBackPackoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self loadData];
    }];
}

- (void)loadData {
    
    [self.view showLoading:@"正在请求"];
    
    [LSFuwaBackPackModel searchBackPackWithListType:self.listType AutoComplete:YES Success:^(NSArray *modelList) {
        [self.view hideHUDAnimated:YES];
        self.dataSource = modelList;
        [self.collectionView reloadData];
        
    } failure:^(NSError *error) {
        [self.view showError:@"请求失败" hideAfterDelay:1];
    }];

}

-(void)setContraints {
    
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_obg"].CGImage);
    
    self.catchListBtn = [UIButton new];
    self.catchListBtn.tag = FuwaBackPickertypeCatch;
    [self.catchListBtn setTitle:@"我捕抓的" forState:UIControlStateNormal];
    self.catchListBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.catchListBtn setTitleColor:HEXRGB(0x8d1800) forState:UIControlStateNormal];
    [self.catchListBtn setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateSelected];
    [self.catchListBtn addTarget:self action:@selector(listBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.catchListBtn];
    
    [self.catchListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(5);
        make.right.equalTo(self.view.mas_centerX).offset(-15);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(40);
    }];
    
    self.applyListBtn = [UIButton new];
    self.applyListBtn.tag = FuwaBackPickertypeApply;
    [self.applyListBtn setTitle:@"我申请的" forState:UIControlStateNormal];
    self.applyListBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.applyListBtn setTitleColor:HEXRGB(0x8d1800) forState:UIControlStateNormal];
    [self.applyListBtn setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateSelected];
    [self.applyListBtn addTarget:self action:@selector(listBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.applyListBtn];
    
    [self.applyListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(5);
        make.left.equalTo(self.view.mas_centerX).offset(15);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(40);
    }];
    
    self.colorView = [UIView new];
    self.colorView.backgroundColor = HEXRGB(0xe7d09a);
    [self.view addSubview:self.colorView];
    
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo (self.catchListBtn.mas_bottom);
        make.width.equalTo(self.catchListBtn);
        make.right.equalTo(self.view.mas_centerX).offset(-15);
        make.height.mas_equalTo(3);
    }];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LSBaseFuwaModelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    LSFuwaBackPackListModel * listModel = self.dataSource[indexPath.row];
    LSFuwaModel * Model = [LSFuwaModel new];
    Model.id =[NSString stringWithFormat:@"%i",(int)indexPath.row+1];
    Model.count = listModel.fuwaListArr.count;
    cell.model = Model;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LSBaseFuwaModelCell * cell = (LSBaseFuwaModelCell *)[collectionView cellForItemAtIndexPath:indexPath];
    LSFuwaModel *model =cell.model;

    if (model.count == 0) return;
    
    LSFuwaDetailView * detailView = [LSFuwaDetailView FuwaDetailView];
    self.detailView = detailView;
    @weakify(self)
    @weakify(detailView)
    [detailView setPushQCodeBlock:^{
        @strongify(self)
        LSQRCodeViewController * vc = [LSQRCodeViewController new];
        vc.codeType = LSQRcodeTypeFuwaUser;
        
        [vc setFuwaUserBlock:^(NSString *userB64) {
            @strongify(detailView)
            detailView.userB64 = userB64;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [detailView setPushTribalBlock:^(NSString * createId){
        @strongify(self)
        [LSIndexLinkInModel indexLinkWithTribalCreateId:createId success:^(NSArray *list) {
            if (list.count > 0) {
                [self.detailView removeFromSuperview];
                LSIndexLinkInModel * model = list[0];
                UIViewController *vc = [NSClassFromString(@"LSClanCofcViewController") new];
                [vc setValue:@(model.stribe_id) forKey:@"sh_id"];
                [vc setValue:@(5) forKey:@"type"];
                [vc setValue:model.name forKey:@"titleStr"];
                [vc  setValue:@"isFuwa" forKey:@"isFuwa"];
                [self.navigationController pushViewController:vc animated:YES];
            }else {
                [self.view showAlertWithTitle:@"提示" message:@"该用户没有部落"];
            }
        } failure:^(NSError *error) {
            [LSKeyWindow showError:@"该用户没有部落" hideAfterDelay:1.5];
        }];
    }];
    
    LSFuwaBackPackListModel * listModel = self.dataSource[indexPath.row];
    detailView.dataSource = listModel.fuwaListArr;
    detailView.listType = self.listType;
    detailView.frame = self.view.bounds;
    [self.view addSubview:detailView];
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * layout = [UICollectionViewFlowLayout new];
        
        CGFloat itemW = 100;
        NSInteger count = kScreenWidth / itemW;
        CGFloat margin = (kScreenWidth - itemW*count)/(count+1);
        
        layout.itemSize = CGSizeMake(100, 145);
        layout.minimumLineSpacing = margin;
        layout.minimumInteritemSpacing = margin;
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, 0, margin);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:NSClassFromString(@"LSBaseFuwaModelCell") forCellWithReuseIdentifier:reuseId];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:self.collectionView];
        
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.colorView.mas_bottom).offset(5);
            make.left.bottom.right.equalTo(self.view);
        }];
    }
    
    return _collectionView;
}



#pragma mark getter&setter
-(void)listBtnAction:(UIButton *)btn{
    
    @weakify(self)
    [UIView animateWithDuration:0.15f animations:^{
        @strongify(self)
        self.colorView.right = btn.right;
    }completion:^(BOOL finished) {
        @strongify(self)
        [self.colorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(btn);
            make.top.equalTo (self.catchListBtn.mas_bottom);
            make.width.mas_equalTo(65);
            make.height.mas_equalTo(3);
        }];
    }];


    self.selectedBtn = btn;
    self.listType = (int)btn.tag;

}



-(void)setSelectedBtn:(UIButton *)selectedBtn{
    _selectedBtn.selected = NO;
    selectedBtn.selected = YES;
    _selectedBtn = selectedBtn;
}

-(void)setListType:(FuwaBackPickertype)listType{
    
    _listType = listType;
    [self loadData];
    
}

-(void)dealloc{
    [self.view removeAllSubviews];
    
}
@end


@interface LSFuwaPresentView ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *BGBtn;
@property (weak, nonatomic) IBOutlet UITextField *commandTextField;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation LSFuwaPresentView

+ (instancetype)FuwaPresentView{
    return [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaPresentView" owner:nil options:nil]lastObject];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.contentView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_obg"].CGImage);
    self.contentView.layer.contentMode = UIViewContentModeCenter;
        self.contentView.layer.masksToBounds = YES;
    [self.BGBtn addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    self.commandTextField.delegate = self;
    UITapGestureRecognizer * hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.showView addGestureRecognizer:hideTap];
    ViewBorderRadius(self.sureBtn, 5, 1, HEXRGB(0xff0012));
    ViewBorderRadius(self.codeBtn, 5, 1, HEXRGB(0xff0012));
    ViewRadius(self.commandTextField, 5);
}

- (void)hideKeyBoard {

    [self.commandTextField resignFirstResponder];
}

- (IBAction)codeAction:(id)sender {
    self.pushQCodeBlock();
    
}

- (IBAction)sureBtnClick:(UIButton *)sender {
    if (self.commandTextField.text.length ==0) {
        [self showError:@"口令不能为空" hideAfterDelay:1];
        return;
    }
    
    NSString * token = [self.commandTextField.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];;
    [LSKeyWindow showLoading];
    
    [LSFuwaModel presentFuwaWithtoken:token Gid:self.model.gid Success:^{
        [LSKeyWindow showSucceed:@"赠送成功" hideAfterDelay:1];
        [[NSNotificationCenter defaultCenter]postNotificationName:reloadBackPackoti object:nil];
        [self removeFromSuperview];
    } failure:^(NSError *error) {
        [LSKeyWindow showSucceed:@"赠送失败" hideAfterDelay:1];
    }];
}

-(void)setUserB64:(NSString *)userB64{
    _userB64 = userB64;
    self.commandTextField.text = userB64;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    
    return YES;
}


-(void)removeFromSuperview{
    [self.detailView removeFromSuperview];
    [super removeFromSuperview];    
}

@end

@interface LSFuwaSaleView()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *BGBtn;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (nonatomic,assign) BOOL dot;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end
@implementation LSFuwaSaleView

+ (instancetype)FuwaSaleView{
    return [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaSaleView" owner:nil options:nil]lastObject];
}

-(void)awakeFromNib{
    self.contentView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_obg"].CGImage);
    self.contentView.layer.contentMode = UIViewContentModeCenter;
        self.contentView.layer.masksToBounds = YES;
    [self.BGBtn addTarget:self action:@selector(selfRemove) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(selfRemove) forControlEvents:UIControlEventTouchUpInside];
    [super awakeFromNib];
    ViewBorderRadius(self.sureBtn, 5, 1, HEXRGB(0xff0012));
    self.priceTextField.delegate = self;
    self.priceTextField.keyboardType = UIKeyboardTypeDecimalPad;
}
- (IBAction)sureBtnClick:(UIButton *)sender {
    
    if (self.priceTextField.text.length<1) {
        [self showError:@"价格不能为空" hideAfterDelay:1];
        return;
    }else if([self.priceTextField.text isEqualToString:@"0"]){
        [self showError:@"价格不能为0" hideAfterDelay:1];
        return;
    }else if(![self isPureFloat:self.priceTextField.text]){
        [self showError:@"价格只能是纯数字" hideAfterDelay:1];
        return;

    }
    
    NSString * amount = self.priceTextField.text;
    [LSKeyWindow showLoading];
    [LSFuwaModel saleFuwaWithID:self.model.id Gid:self.model.gid amount:amount Success:^{
        [LSKeyWindow showSucceed:@"挂出售成功" hideAfterDelay:1];
        [[NSNotificationCenter defaultCenter]postNotificationName:reloadBackPackoti object:nil];
        [self removeFromSuperview];
    } failure:^(NSError *error) {
        [LSKeyWindow showError:@"出售失败" hideAfterDelay:1];
    }];
}

-(void)selfRemove{
    [self endEditing:YES];
    [self removeFromSuperview];
}


- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 判断是否输入内容，或者用户点击的是键盘的删除按钮
    
    if (![string isEqualToString:@""]) {
        
        if (textField == self.priceTextField) {
            
            // 小数点在字符串中的位置 第一个数字从0位置开始
            
            NSInteger dotLocation = [textField.text rangeOfString:@"."].location;
            
            // 判断字符串中是否有小数点，并且小数点不在第一位
            
            // NSNotFound 表示请求操作的某个内容或者item没有发现，或者不存在
            
            // range.location 表示的是当前输入的内容在整个字符串中的位置，位置编号从0开始
            
            if (dotLocation == NSNotFound && range.location != 0) {
                
                // 取只包含“myDotNumbers”中包含的内容，其余内容都被去掉
                
                if (range.location >= 7) {
                    [self showError:@"单笔金额不能超过百万" hideAfterDelay:1];

                    
                    
                    if ([string isEqualToString:@"."] && range.location == 9)
                        
                    {
                        
                        return YES;
                        
                    }
                    
                    return NO;
                    
                }else{
                    
                    if (_dot ==YES)
                        
                    {
                        
                        if ([string isEqualToString:@"."])
                            
                        {
                            
                            return YES;
                            
                        }
                        
                        return NO;
                        
                    }else{
                        
                        NSString *first = [textField.text substringFromIndex:0];
                        
                        if ([first isEqualToString:@"0"])
                            
                        {
                            
                            if ([string isEqualToString:@"."])
                                
                            {
                                
                                return YES;
                                
                            }
                            
                            return NO;
                            
                        }else{
                            
                            return YES;
                            
                        }
                        
                    }
                    
                }
                
            }else {
                
                if ([string isEqualToString:@"."]){
                    
                    NSString *first = [textField.text substringFromIndex:0];
                    
                    if ([first isEqualToString:@"0"]) {
                        
                        self.priceTextField.text = @"0";
                        
                    }else if ([first isEqualToString:@""]){
                        
                        self.priceTextField.text = @"0";
                        
                    }else{
                        
                        if ([string isEqualToString:@"."]){
                            
                            return NO;
                            
                        }
                        
                        return YES;
                        
                    }
                    
                }
                
                if ([string isEqualToString:@"0"]){
                    
                    _dot =YES;
                    
                }else{
                    
                    _dot =NO;
                    
                }
                
            }
            
            if (dotLocation != NSNotFound && range.location > dotLocation + 2) {
                
                return NO;
                
            }
            
            if (textField.text.length > 11) {
                
                return NO;
                
            }
            
            
        }
        
    }
    
    return YES;
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];
}

-(void)removeFromSuperview{
    [self.detailView removeFromSuperview];
    [super removeFromSuperview];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    // NSLog(@"清除输入内容了");
    _dot = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    return YES;
}

@end

static NSString *const reuseDetailCatchId = @"LSFuwaDetailCatchCollectionCell";
static NSString *const reuseDetailApplyId = @"LSFuwaDetailApplyCollectionCell";

@interface LSFuwaDetailView ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *BGBtn;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *saleBtn;
@property (weak, nonatomic) IBOutlet UIButton *presentBtn;

@property (weak, nonatomic) IBOutlet UIView *fuwaView;
@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,assign) int nowPage;
@property (weak, nonatomic) IBOutlet UIButton *leftArrowBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightArrowBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *activityBtn;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong,nonatomic) LSFuwaPresentView * presentView;
@property (weak,nonatomic) LSFuwaDetailCatchCollectionCell * lastCatchCell;
@end


@implementation LSFuwaDetailView


+ (instancetype)FuwaDetailView{
       return [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaDetailView" owner:nil options:nil]firstObject];
}
-(void)setUserB64:(NSString *)userB64{
    _userB64 = userB64;
    self.presentView.userB64 = userB64;
    
}
-(void)setListType:(FuwaBackPickertype)listType{
    _listType = listType;
    if (listType == FuwaBackPickertypeCatch) {
        self.saleBtn.hidden = NO;
        self.presentBtn.hidden = NO;
        self.activityBtn.hidden = NO;
    }else{
        self.saleBtn.hidden = YES;
        self.presentBtn.hidden = YES;
        self.activityBtn.hidden = YES;

    }
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.contentView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_obg"].CGImage);
    self.contentView.layer.contentMode = UIViewContentModeCenter;
        self.contentView.layer.masksToBounds = YES;
    [self.fuwaView addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.fuwaView);
    }];
    
    [self.BGBtn addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    
    [self.saleBtn addTarget:self action:@selector(toSaleView) forControlEvents:UIControlEventTouchUpInside];
    [self.presentBtn addTarget:self action:@selector(toPreSentView) forControlEvents:UIControlEventTouchUpInside];
    ViewBorderRadius(self.saleBtn, 5, 1, HEXRGB(0xff0012));
    ViewBorderRadius(self.presentBtn, 5, 1, HEXRGB(0xff0012));

}

-(void)removeFromSuperview{
    if (self.lastCatchCell) [self.lastCatchCell timerInvalidate];
    [super removeFromSuperview];
}

-(void)setDataSource:(NSArray *)dataSource{
    _dataSource = dataSource;
    if (self.dataSource.count>1){
        self.leftArrowBtn.hidden = YES;
        self.rightArrowBtn.hidden = NO;
    }else{
        self.leftArrowBtn.hidden = YES;
        self.rightArrowBtn.hidden = YES;
    }
    
    NSString * AllText = [NSString stringWithFormat:@"1 / %d",(int)self.dataSource.count];
    NSMutableAttributedString * AttText = [[NSMutableAttributedString alloc]initWithString:AllText];
    
    NSRange numRange = [AllText rangeOfString:@"1" options:NSLiteralSearch];
    [AttText setFont:[UIFont boldSystemFontOfSize:15] range:numRange];
    [AttText setColor:HEXRGB(0xe7d09a) range:numRange];
    
    NSRange countRange = [AllText rangeOfString:[NSString stringWithFormat:@"/ %d",(int)self.dataSource.count] options:NSLiteralSearch];
    [AttText setFont:[UIFont systemFontOfSize:12] range:countRange];
    [AttText setColor:HEXRGB(0xff7f5b) range:countRange];
    
    self.countLabel.attributedText = AttText;
    
    [self.collectionView reloadData];
}


-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(self.fuwaView.frame.size.width, self.fuwaView.frame.size.height);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing =0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.collectionView registerNib:[UINib nibWithNibName:@"LSFuwaDetailCatchCollectionCell"
                                                        bundle:nil]
              forCellWithReuseIdentifier:reuseDetailCatchId];
        
        [self.collectionView registerNib:[UINib nibWithNibName:@"LSFuwaDetailApplyCollectionCell"
                                                        bundle:nil]
              forCellWithReuseIdentifier:reuseDetailApplyId];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}



#pragma mark --)<UICollectionViewDataSource,UICollectionViewDelegate>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataSource.count;
    
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0,0,0,0);//分别为上、左、下、右
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.listType == FuwaBackPickertypeCatch) {
        if (self.lastCatchCell)   [self.lastCatchCell timerInvalidate];
        
        
        LSFuwaDetailCatchCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseDetailCatchId forIndexPath:indexPath];
        LSFuwaBackPackModel * bpModel = self.dataSource[indexPath.row];
        cell.model = bpModel;
        cell.userInteractionEnabled = YES;
        [cell setPushTribalBlock:^(NSString * createid){
            !self.pushTribalBlock ? : self.pushTribalBlock(createid);
        }];
        self.lastCatchCell = cell;
        return cell;

    }else{
        
        LSFuwaDetailApplyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseDetailApplyId forIndexPath:indexPath];
        LSFuwaBackPackModel * bpModel = self.dataSource[indexPath.row];
        
        cell.model = bpModel;
        return cell;
    }
}

#pragma mark - Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self checkPageWithScrollView:scrollView];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self checkPageWithScrollView:scrollView];
}
- (IBAction)arrowBtnClick:(UIButton *)sender {
    if (self.nowPage+(int)sender.tag>=self.dataSource.count)
        return;
    self.nowPage +=(int)sender.tag;
    NSIndexPath * indexpath = [NSIndexPath indexPathForRow:self.nowPage inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
}

-(void)checkPageWithScrollView:(UIScrollView *)scrollView{
    self.nowPage = scrollView.contentOffset.x/self.fuwaView.width;
    
    NSString * AllText = [NSString stringWithFormat:@"%d / %d",self.nowPage+1,(int)self.dataSource.count];
    NSMutableAttributedString * AttText = [[NSMutableAttributedString alloc]initWithString:AllText];
    
    NSRange numRange = [AllText rangeOfString:[NSString stringWithFormat:@"%d",self.nowPage+1] options:NSLiteralSearch];
    [AttText setFont:[UIFont boldSystemFontOfSize:15] range:numRange];
    [AttText setColor:HEXRGB(0xe7d09a) range:numRange];
    
    NSRange countRange = [AllText rangeOfString:[NSString stringWithFormat:@"/ %d",(int)self.dataSource.count] options:NSLiteralSearch];
    [AttText setFont:[UIFont systemFontOfSize:12] range:countRange];
    [AttText setColor:HEXRGB(0xff7f5b) range:countRange];
    
    self.countLabel.attributedText = AttText;
    
    if (self.nowPage == 0 && self.dataSource.count>1) {
        self.leftArrowBtn.hidden = YES;
        self.rightArrowBtn.hidden = NO;
    }else if(self.nowPage == self.dataSource.count-1){
        self.leftArrowBtn.hidden = NO;
        self.rightArrowBtn.hidden = YES;
    }else if (self.dataSource.count>1) {
        self.rightArrowBtn.hidden = NO;
        self.leftArrowBtn.hidden = NO;
    }else{
        self.rightArrowBtn.hidden = YES;
        self.leftArrowBtn.hidden = YES;
    }
}
-(void)toSaleView{
    LSFuwaSaleView * saleView = [LSFuwaSaleView FuwaSaleView];
    LSFuwaBackPackModel * bpmodel =self.dataSource[self.nowPage];
    LSFuwaModel * fuwaModel = [LSFuwaModel new];
    saleView.detailView = self;
    fuwaModel.gid =bpmodel.gid;
    fuwaModel.id = bpmodel.id;
    saleView.model = fuwaModel;
    
    saleView.frame = self.superview.bounds;
    [self.superview addSubview:saleView];
}

-(void)toPreSentView{

    LSFuwaPresentView * presentView = [LSFuwaPresentView FuwaPresentView];
    self.presentView = presentView;
    @weakify(self);
    [presentView setPushQCodeBlock:^{
        @strongify(self)
        self.pushQCodeBlock();
    }];
    presentView.detailView = self;
    LSFuwaBackPackModel * bpmodel =self.dataSource[self.nowPage];
    LSFuwaModel * fuwaModel = [LSFuwaModel new];
    fuwaModel.gid =bpmodel.gid;
    fuwaModel.id = bpmodel.id;
    presentView.model = fuwaModel;
    
    presentView.frame = self.superview.bounds;
    [self.superview addSubview:presentView];

}
- (IBAction)activityAction:(id)sender {
    
    
    LSFuwaBackPackActivityView * activityView = [LSFuwaBackPackActivityView BackPackActivityView];

    LSFuwaBackPackModel * bpmodel =self.dataSource[self.nowPage];
    LSFuwaModel * fuwaModel = [LSFuwaModel new];
    fuwaModel.gid =bpmodel.gid;
    fuwaModel.id = bpmodel.id;
    activityView.fuwaModel = fuwaModel;
    
    activityView.frame = self.superview.bounds;
    [self.superview addSubview:activityView];
    
}

@end

@interface LSFuwaBackPackActivityView ()
@property (weak, nonatomic) IBOutlet UILabel *actDetailLabel;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end


@implementation LSFuwaBackPackActivityView

+ (instancetype)BackPackActivityView{
    return [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaDetailView" owner:nil options:nil]lastObject];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    ViewBorderRadius(self.detailView, 5, 1, HEXRGB(0xE7D09A));
    
    self.contentView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_obg"].CGImage);
    self.contentView.layer.contentMode = UIViewContentModeCenter;
    self.contentView.layer.masksToBounds = YES;
}

- (IBAction)BGAction:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)cancelAction:(id)sender {
    [self removeFromSuperview];

}

-(void)setFuwaModel:(LSFuwaModel *)fuwaModel{
    _fuwaModel = fuwaModel;
    [LSFuwaBackPackModel FuwaActivityWithfuwaId:fuwaModel.gid Success:^(NSString *activityStr) {
        if ([activityStr isEqualToString: @""])
            self.actDetailLabel.text = @"该活动没有信息";
        else
            self.actDetailLabel.text = activityStr;

        
    } failure:^(NSError *error) {
        [LSKeyWindow showError:@"获取活动信息失败" hideAfterDelay:0.5];
    }];
    
}

@end



@interface LSFuwaDetailCatchCollectionCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *graspLabel;
@property (weak, nonatomic) IBOutlet UIImageView *awadImageView;
@property (weak, nonatomic) IBOutlet UILabel *useLabel;

@property (nonatomic,weak)NSTimer * timer;

@end



@implementation LSFuwaDetailCatchCollectionCell

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self bringSubviewToFront:self.sourceLabel];
    self.contentView.backgroundColor = [UIColor clearColor];

    UITapGestureRecognizer * sourceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sourceTapClick)];
    
    [self addGestureRecognizer:sourceTap];
}


-(void)setModel:(LSFuwaBackPackModel *)model{
    _model =model;
    
    NSString * codeStr = [NSString stringWithFormat:@"fuwa:fuwa:%@",model.gid];
    self.bgView.userInteractionEnabled = YES;
    self.iconImageView.image = [UIImage qrImageForString:codeStr imageSize:self.iconImageView.size.width logoImageSize:0.0];//[UIImage createQRImageWithString:codeStr size:self.iconImageView.size];
    self.nameLabel.text = [NSString stringWithFormat:@"%@号福娃",model.id];
    self.graspLabel.numberOfLines =2;
    self.sourceLabel.numberOfLines =2;
    
    [self loadDetail];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(loadDetail) userInfo:nil repeats:YES];

    self.useLabel.text = [model.gid containsString:@"_i_"] ? @"用途:社交" : @"用途:寻宝";
    
    
}

- (void)sourceTapClick {
    NSLog(@"sfjdshk")
    !self.pushTribalBlock ? : self.pushTribalBlock(self.model.creatorid);
}

-(void)loadDetail{
    
    [LSFuwaModel fuwaDetailWithGid:self.model.gid Success:^(LSFuwaDetailModel *detailModel) {
        self.graspLabel.text = [NSString stringWithFormat:@"捕获于:%@",detailModel.pos];
        self.sourceLabel.text = [NSString stringWithFormat:@"%@",detailModel.creator];
        NSLog(@"%@",[NSDate date]);
        self.awadImageView.hidden = !detailModel.awarded.boolValue;
        
    } failure:^(NSError *error) {
        
    }];
}


-(void)timerInvalidate{
    [self.timer invalidate];
}

- (IBAction)test:(id)sender {
    
    
    
}

@end


@interface LSFuwaDetailApplyCollectionCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *applyLabel;
@property (weak, nonatomic) IBOutlet UILabel *useLabel;


@end



@implementation LSFuwaDetailApplyCollectionCell

-(void)awakeFromNib{
    [super awakeFromNib];
}


-(void)setModel:(LSFuwaBackPackModel *)model{
    _model =model;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.nameLabel.text = [NSString stringWithFormat:@"%@号福娃",model.id];
    self.useLabel.numberOfLines =2;
    self.applyLabel.numberOfLines =2;
    
    self.applyLabel.text = [NSString stringWithFormat:@"申请人:%@",model.creator];
    self.useLabel.text = [model.gid containsString:@"_i_"] ? @"用途:社交" : @"用途:寻宝";


}



@end

