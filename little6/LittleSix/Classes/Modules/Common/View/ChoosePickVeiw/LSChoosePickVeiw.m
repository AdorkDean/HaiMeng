//
//  LSChoosePickVeiw.m
//  LittleSix
//
//  Created by GMAR on 2017/3/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSChoosePickVeiw.h"
#import "LSLocationModel.h"
#import "LSHobbieModel.h"
#import "AppDelegate.h"

static CGFloat bgViewHeith =300;
static CGFloat cityPickViewHeigh = 180;
static CGFloat toolsViewHeith = 40;
static CGFloat animationTime = 0.25;
@interface LSChoosePickVeiw()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *cityPickerView;/** 城市选择器 */
@property (nonatomic, strong) UIButton *sureButton;        /** 确认按钮 */
@property (nonatomic, strong) UIButton *canselButton;      /** 取消按钮 */
@property (nonatomic, strong) UIView *toolsView;           /** 自定义标签栏 */
@property (nonatomic, strong) UIView *bgView;              /** 背景view */

//省  市 县 变量
@property (nonatomic, strong) NSArray *provinceArr;        /** 省 数组 */
@property (nonatomic, strong) NSArray *cityArr;            /** 市 数组 */
@property (nonatomic, strong) NSArray *townArr;            /** 县城 数组 */

@property (copy,nonatomic)NSArray * locData;

@property (copy,nonatomic)NSString * sex; //性别
@property (copy,nonatomic)NSString * sexId;

@property (copy,nonatomic)NSString * work; // 行业
@property (copy,nonatomic)NSString * workId;

@end

@implementation LSChoosePickVeiw

// init 会调用 initWithFrame
- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self initSubViews];
    }
    return self;
}

-(void)ininSoureData:(NSInteger)index{

    self.index = index;
    
    [self locData];
    
}

- (void)initSubViews{
    
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.toolsView];
    [self.toolsView addSubview:self.canselButton];
    [self.toolsView addSubview:self.sureButton];
    
    [self.bgView addSubview:self.cityPickerView];
    
    [self showPickView];
    
}
- (NSArray *)locData {
    
    if (!_locData) {
        
        if (self.index == 1) {
            
            NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Area" ofType:@"json"]];
            
            NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
            
            NSMutableArray *newArray = [NSMutableArray array];
            
            for (NSDictionary *dict in dataArray) {
                
                LSLocationModel * model = [LSLocationModel createLSLocationModel:dict];
                
                [newArray addObject:model];
                
            }
            
            self.provinceArr   = newArray;
            LSLocationModel * model = newArray[0];
            self.cityArr       = model.list;
            LSCityModel * cmodel = model.list[0];
            self.townArr       = cmodel.list;
            
            
            //================初始化ID=====================//
            self.province   = model.region_name;
            self.provinceId = model.region_id;
            
            self.city       = cmodel.region_name;
            self.cityId     = cmodel.region_id;
            
            LSLCitnModel * tmodel = cmodel.list[0];
            self.town       = tmodel.region_name;
            self.townId     = tmodel.region_id;
            
            _locData = newArray;
            
        }else if(self.index == 0){
            NSMutableArray *newArray = [NSMutableArray array];
            NSDictionary * mdic = @{@"key":@"1",@"sex":@"男"};
            NSDictionary * wdic = @{@"key":@"2",@"sex":@"女"};
            
            [newArray addObject:mdic];
            [newArray addObject:wdic];
            
            self.sex = mdic[@"sex"];
            self.sexId = mdic[@"key"];
            
            _locData = newArray;
            
        }else if(self.index == 2){
        
            [LSWorkModel workWithlistToken:ShareAppManager.loginUser.access_token success:^(NSArray *array) {
                
                NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];

                _locData = newArray;
                self.cityPickerView.delegate = self;
                self.cityPickerView.dataSource = self;
                
                LSWorkModel * model = array[0];
                self.work = model.w_name;
                self.workId = model.w_id;
                
            } failure:^(NSError *errer) {
                
            }];
            
        }
        
        
    }
    
    return _locData;
    
}


#pragma event menthods
- (void)canselButtonClick{
    [self hidePickView];
}

- (void)sureButtonClick{
    [self hidePickView];
    
    if (self.index == 1) {
        NSString * address = [NSString stringWithFormat:@"%@/%@/%@",self.province,self.city,self.town];
        if (self.config) {
            self.config(address,self.provinceId, self.cityId, self.townId);
        }
    }else if(self.index == 0){
        if (self.config) {
            self.config(self.sex,self.sexId,@"",@"");
        }
    }else if (self.index == 2){
        if (self.config) {
            self.config(self.work,self.workId,@"",@"");
        }
    }
    
}

#pragma mark private methods
- (void)showPickView{
    [UIView animateWithDuration:animationTime animations:^{
        self.bgView.frame = CGRectMake(0, self.frame.size.height - bgViewHeith, self.frame.size.width, bgViewHeith);
    } completion:^(BOOL finished) {
        
    }];
}


- (void)hidePickView{
    
    [UIView animateWithDuration:animationTime animations:^{
        
        self.bgView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, bgViewHeith);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}


#pragma mark - pickerViewDatasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    if(self.index == 0||self.index == 2) return 1;
    
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.index == 1) {
        if (component == 0) {
            return self.provinceArr.count;
        }
        else if(component == 1){
            return  self.cityArr.count;
        }
        else if(component == 2){
            return self.townArr.count;
        }
    }else if(self.index == 0){
        return self.locData.count;
    }else{
    
        return self.locData.count;
    }
    
    return 0;
}

#pragma mark - pickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/3.0, 30)];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    if (self.index == 1) {
        
        if (component == 0) {
            LSLocationModel *model =self.provinceArr[row];
            label.text =  model.region_name;
        }else if (component == 1){
            LSCityModel * cmodel = self.cityArr[row];
            label.text =  cmodel.region_name;
        }else if (component == 2){
            LSLCitnModel * tmodel = self.townArr[row];
            label.text =  tmodel.region_name;
        }
    }else if(self.index == 0){
    
        NSDictionary * dict = self.locData[row];
        label.text = dict[@"sex"];
    }else if(self.index == 2){
    
        LSWorkModel * model = self.locData[row];
        label.text = model.w_name;
    }
    
    return label;
}

- (NSArray *)getNameforProvince:(NSInteger)row{
    
    LSLocationModel * model = self.locData[row];
    
    return model.list;
    
}
-(NSArray *)getNameforCity:(NSInteger)row{
    
    LSCityModel * model = self.cityArr[0];
    
    return model.list;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (self.index == 1) {
        if (component == 0) {//选择省
            self.cityArr = [self getNameforProvince:row];
            self.townArr = self.townArr = [self getNameforCity:0];
            
            [self.cityPickerView reloadComponent:1];
            [self.cityPickerView selectRow:0 inComponent:1 animated:YES];
            [self.cityPickerView reloadComponent:2];
            [self.cityPickerView selectRow:0 inComponent:2 animated:YES];
            
            LSLocationModel * model = self.provinceArr[row];
            self.province   = model.region_name;
            self.provinceId = model.region_id;
            
            LSCityModel * cmodel = self.cityArr[0];
            self.city       = cmodel.region_name;
            self.cityId     = cmodel.region_id;
            
            LSLCitnModel * tmodel = self.townArr[0];
            self.town       = tmodel.region_name;
            self.townId     = tmodel.region_id;
            
        }else if (component == 1){//选择城市
            LSCityModel * model = self.cityArr[row];
            
            self.townArr = model.list;
            
            [self.cityPickerView reloadComponent:2];
            [self.cityPickerView selectRow:0 inComponent:2 animated:YES];
            
            LSCityModel * cmodel = self.cityArr[row];
            self.city = cmodel.region_name;
            self.cityId = cmodel.region_id;
            
            LSLCitnModel * tmodel =  self.townArr[0];
            self.town = tmodel.region_name;
            self.townId = tmodel.region_id;
            
        }else if (component == 2){
            
            LSLCitnModel * tmodel = self.townArr[row];
            self.town = tmodel.region_name;
            self.townId = tmodel.region_id;
            
        }
    }else if(self.index == 0){
        NSDictionary * dict = self.locData[row];
        self.sex = dict[@"sex"];
        self.sexId = dict[@"key"];
        
    }else{
    
        LSWorkModel * model = self.locData[row];
        self.workId = model.w_id;
        self.work = model.w_name;
        
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if ([touches.anyObject.view isKindOfClass:[self class]]) {
        [self hidePickView];
    }
}

#pragma mark - lazy

- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, bgViewHeith)];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (UIPickerView *)cityPickerView{
    if (!_cityPickerView) {
        _cityPickerView = ({
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolsViewHeith, self.frame.size.width, cityPickViewHeigh)];
            pickerView.backgroundColor = [UIColor whiteColor];
//            [pickerView setShowsSelectionIndicator:YES];
            pickerView.delegate = self;
            pickerView.dataSource = self;
            pickerView;
        });
    }
    return _cityPickerView;
}

- (UIView *)toolsView{
    
    if (!_toolsView) {
        _toolsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, toolsViewHeith)];
        _toolsView.layer.borderWidth = 0.5;
        _toolsView.layer.borderColor = [UIColor grayColor].CGColor;
    }
    return _toolsView;
}

- (UIButton *)canselButton{
    if (!_canselButton) {
        _canselButton = ({
            UIButton *canselButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 50, toolsViewHeith)];
            [canselButton setTitle:@"取消" forState:UIControlStateNormal];
            [canselButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [canselButton addTarget:self action:@selector(canselButtonClick) forControlEvents:UIControlEventTouchUpInside];
            canselButton;
        });
    }
    return _canselButton;
}

- (UIButton *)sureButton{
    if (!_sureButton) {
        _sureButton = ({
            UIButton *sureButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 20 - 50, 0, 50, toolsViewHeith)];
            [sureButton setTitle:@"确定" forState:UIControlStateNormal];
            [sureButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [sureButton addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
            sureButton;
        });
    }
    return _sureButton;
}

@end


//  时间选择器

@interface HMDatePickView()
{
    NSString *_dateStr;
}
@property(strong, nonatomic) UIDatePicker *hmDatePicker;
@property (nonatomic, strong) UIButton *sureButton;        /** 确认按钮 */
@property (nonatomic, strong) UIButton *canselButton;      /** 取消按钮 */
@property (nonatomic, strong) UIView *toolsView;           /** 自定义标签栏 */
@property (nonatomic, strong) UIView *bgView;              /** 背景view */


@end
@implementation HMDatePickView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.227 alpha:0.5];
        [self initSubViews];
    }
    return self;
}
- (void)initSubViews{
    
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.toolsView];
    [self.toolsView addSubview:self.canselButton];
    [self.toolsView addSubview:self.sureButton];
    
    [self.bgView addSubview:self.hmDatePicker];
    
    [self showPickView];
    
}

#pragma mark - lazy

- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, bgViewHeith)];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}
- (UIView *)toolsView{
    
    if (!_toolsView) {
        _toolsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, toolsViewHeith)];
        _toolsView.layer.borderWidth = 0.5;
        _toolsView.layer.borderColor = [UIColor grayColor].CGColor;
    }
    return _toolsView;
}

- (UIButton *)canselButton{
    if (!_canselButton) {
        _canselButton = ({
            UIButton *canselButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 50, toolsViewHeith)];
            [canselButton setTitle:@"取消" forState:UIControlStateNormal];
            [canselButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [canselButton addTarget:self action:@selector(canselButtonClick) forControlEvents:UIControlEventTouchUpInside];
            canselButton;
        });
    }
    return _canselButton;
}

- (UIButton *)sureButton{
    if (!_sureButton) {
        _sureButton = ({
            UIButton *sureButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 20 - 50, 0, 50, toolsViewHeith)];
            [sureButton setTitle:@"确定" forState:UIControlStateNormal];
            [sureButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [sureButton addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
            sureButton;
        });
    }
    return _sureButton;
}
#pragma event menthods
- (void)canselButtonClick{
    [self hidePickView];
}

- (void)sureButtonClick{
    [self hidePickView];
    
    //确定
    if (self.completeBlock) {
        self.completeBlock(_dateStr);
    }
}
#pragma mark private methods
- (void)showPickView{
    [UIView animateWithDuration:animationTime animations:^{
        self.bgView.frame = CGRectMake(0, self.frame.size.height - bgViewHeith, self.frame.size.width, bgViewHeith);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)hidePickView{
    
    [UIView animateWithDuration:animationTime animations:^{
        
        self.bgView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, bgViewHeith);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
#pragma mark -- 选择器



#pragma mark -- 时间选择器日期改变
-(void)selectDate:(id)sender {
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM"];
    _dateStr =[outputFormatter stringFromDate:self.hmDatePicker.date];
    
}
- (UIDatePicker *)hmDatePicker{
    if (!_hmDatePicker) {
        UIDatePicker *datePicker=[[UIDatePicker alloc]initWithFrame:CGRectMake(0, toolsViewHeith, self.frame.size.width, cityPickViewHeigh)];
        datePicker.datePickerMode = UIDatePickerModeDate;
        NSDate *currentDate = [NSDate date];
        
        
        //设置默认日期
        if (!self.date) {
            self.date = currentDate;
        }
        datePicker.date = self.date;
        
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM"];
        
        _dateStr = [formater stringFromDate:self.date];
        
        NSString *tempStr = [formater stringFromDate:self.date];
        NSArray *dateArray = [tempStr componentsSeparatedByString:@"-"];
        
        //设置日期选择器最大可选日期
        if (self.maxYear) {
            NSInteger maxYear = [dateArray[0] integerValue] - self.maxYear;
            NSString *maxStr = [NSString stringWithFormat:@"%ld-%@",maxYear,dateArray[1]];
            NSDate *maxDate = [formater dateFromString:maxStr];
            datePicker.maximumDate = maxDate;
        }
        
        //设置日期选择器最小可选日期
        if (self.minYear) {
            
            NSInteger minYear = [dateArray[0] integerValue] - self.minYear;
            NSString *minStr = [NSString stringWithFormat:@"%ld-%@",minYear,dateArray[1]];
            NSDate* minDate = [formater dateFromString:minStr];
            datePicker.minimumDate = minDate;
        }
        
        
        self.hmDatePicker = datePicker;
        
        [self.hmDatePicker addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventValueChanged];
    }
    return _hmDatePicker;
}

@end

@interface LSDatePickerView () <UIPickerViewDataSource,UIPickerViewDelegate>{
    UIView *contentView;
    void(^backBlock)(NSString *);
    
    NSMutableArray *yearArray;
    NSMutableArray *monthArray;
    NSInteger currentYear;
    NSInteger currentMonth;
    NSString *restr;
    
    NSString *selectedYear;
    NSString *selectecMonth;
    
    int indexRow;
}


@end

@implementation LSDatePickerView

#pragma mark - initDatePickerView
- (instancetype)initDatePackerRow:(int)row WithResponse:(void(^)(NSString*))block{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    indexRow = row;
    [self setViewInterface];
    if (block) {
        backBlock = block;
    }
    return self;
}

#pragma mark - ConfigurationUI
- (void)setViewInterface {
    //获取当前时间 （时间格式支持自定义）
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM"];//自定义时间格式
    NSString *currentDateStr = [formatter stringFromDate:[NSDate date]];
    //拆分年月成数组
    NSArray *dateArray = [currentDateStr componentsSeparatedByString:@"-"];
    if (dateArray.count == 2) {//年 月
        currentYear = [[dateArray firstObject]integerValue];
        currentMonth =  [dateArray[1] integerValue];
    }
    selectedYear = [NSString stringWithFormat:@"%ld",(long)currentYear];
    selectecMonth = [NSString stringWithFormat:@"%ld",(long)currentMonth];
    
    //初始化年数据源数组
    yearArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1970; i <= currentYear ; i++) {
        NSString *yearStr = [NSString stringWithFormat:@"%ld年",i];
        [yearArray addObject:yearStr];
    }
    //[yearArray addObject:@"至今"];
    
    //初始化月数据源数组
    monthArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1 ; i <= 12; i++) {
        NSString *monthStr = [NSString stringWithFormat:@"%ld月",i];
        [monthArray addObject:monthStr];
    }
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 300)];
    [self addSubview:contentView];
    //设置背景颜色为黑色，并有0.4的透明度
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    //添加白色view
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:whiteView];
    //添加确定和取消按钮
    for (int i = 0; i < 2; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 60) * i, 0, 60, 40)];
        [button setTitle:i == 0 ? @"取消" : @"确定" forState:UIControlStateNormal];
        if (i == 0) {
            [button setTitleColor:[UIColor colorWithRed:97.0 / 255.0 green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        [whiteView addSubview:button];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 10 + i;
    }
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.bounds), 260)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = [UIColor colorWithRed:240.0/255 green:243.0/255 blue:250.0/255 alpha:1];
    
    //设置pickerView默认选中当前时间
    [pickerView selectRow:[selectedYear integerValue] - 1970 inComponent:0 animated:YES];
    if (indexRow == 1) {
        [pickerView selectRow:[selectecMonth integerValue] - 1 inComponent:1 animated:YES];
    }
    
    [contentView addSubview:pickerView];
}

#pragma mark - Actions
- (void)buttonTapped:(UIButton *)sender {
    if (sender.tag == 10) {
        [self dismiss];
    } else {
        if (indexRow == 1) {
            
            if ([selectecMonth isEqualToString:@""]) {//至今的情况下 不需要中间-
                restr = [NSString stringWithFormat:@"%@%@",selectedYear,selectecMonth];
            } else {
                restr = [NSString stringWithFormat:@"%@-%@",selectedYear,selectecMonth];
            }
        }else {
        
            if ([selectecMonth isEqualToString:@""]) {//至今的情况下 不需要中间-
                restr = [NSString stringWithFormat:@"%@",selectedYear];
            } else {
                restr = [NSString stringWithFormat:@"%@",selectedYear];
            }
        }
        
        restr = [restr stringByReplacingOccurrencesOfString:@"年" withString:@""];
        restr = [restr stringByReplacingOccurrencesOfString:@"月" withString:@""];
        backBlock(restr);
        [self dismiss];
    }
}

#pragma mark - pickerView出现
- (void)show {
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [app.window addSubview:self];
    [UIView animateWithDuration:0.4 animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y - contentView.frame.size.height);
    }];
}
#pragma mark - pickerView消失
- (void)dismiss{
    
    [UIView animateWithDuration:0.4 animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y + contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self dismiss];
}

#pragma mark - UIPickerViewDataSource UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return indexRow == 1 ? 2 : 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return yearArray.count;
    }
    else {
        return monthArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return yearArray[row];
    } else {
        return monthArray[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        selectedYear = yearArray[row];
        if (row == yearArray.count - 1) {//至今的情况下,月份清空
            [monthArray removeAllObjects];
            selectecMonth = @"";
        } else {//非至今的情况下,显示月份
            monthArray = [[NSMutableArray alloc]init];
            for (NSInteger i = 1 ; i <= 12; i++) {
                NSString *monthStr = [NSString stringWithFormat:@"%ld月",i];
                [monthArray addObject:monthStr];
            }
            selectecMonth = [NSString stringWithFormat:@"%ld",(long)currentMonth];
        }
        if(indexRow == 1) [pickerView reloadComponent:1];
        
    } else {
        selectecMonth = monthArray[row];
    }
}

@end

