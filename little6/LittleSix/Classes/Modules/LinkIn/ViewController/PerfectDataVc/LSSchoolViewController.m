//
//  LSSchoolViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSchoolViewController.h"
#import "LSAddSchoolViewController.h"
#import "LSLSLinkInModel.h"
#import "UIView+HUD.h"

static NSString *const reuse_id = @"LSSchoolTableCell";
@interface LSSchoolViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,retain)NSMutableArray * dataSource;

@property (nonatomic,retain)UIImageView * bobyImage;
@property (retain,nonatomic) UILabel * titleLable;

@property (retain,nonatomic)UITableView * tableView;

@end

@implementation LSSchoolViewController

-(NSMutableArray *)dataSource{

    if (!_dataSource) {
        
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    self.title = @"学校";
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self initSuView];
    [self initSourceData];
    [self registerNotification];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
    if (self.dataSource.count > 0) {
        LSLSLinkInModel * linkModel = self.dataSource[0];
        if (self.fristClick) {
            self.fristClick(linkModel.school_name);
        }
    }else {
        if (self.fristClick) {
            self.fristClick(@"");
        }
    }
    
}

- (void)registerNotification {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kCompleteLinkInInfoNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self initSourceData];
    }];
}

-(void)initSourceData{
    
    [LSLSLinkInModel schoolWithlistToken:ShareAppManager.loginUser.access_token success:^(NSArray * list) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:list];
        if (list.count == 0) {
            [self createUI];
        }else{
            [self removeUI];
            [self.view bringSubviewToFront:self.tableView];
            [self.tableView reloadData];
        }
        
    } failure:^(NSError *errer) {
        [self createUI];
        [self.view showError:@"列表为空" hideAfterDelay:1.5];
    }];
}

-(void)initSuView{
    
    UIButton * saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 50, 30);
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [saveBtn setTitle:@"添加" forState:UIControlStateNormal];
    UIBarButtonItem * itme = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    self.navigationItem.rightBarButtonItem = itme;
}


#pragma mark - Getter & Setter
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView = tableView;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [tableView registerClass:[LSSchoolTableCell class] forCellReuseIdentifier:reuse_id];
        
    }
    return _tableView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 90;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 0.1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    LSSchoolTableCell * cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    LSLSLinkInModel * linkModel = self.dataSource[indexPath.row];
    
    cell.linkModel = linkModel;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSLSLinkInModel * linkModel = self.dataSource[indexPath.row];
    UIViewController *ditorSchoolVc =[[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSEditorSchool"];;
    [ditorSchoolVc setValue:linkModel forKey:@"linkModel"];
    [self.navigationController pushViewController:ditorSchoolVc animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        
        LSLSLinkInModel *model = self.dataSource[indexPath.row];
        
        NSUInteger row = [self.dataSource indexOfObject:model];
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        //同步数据
        [self.dataSource removeObject:model];
        [self deleteDataSource:model];
        //刷新表格
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
    }];
    
    delete.backgroundColor = [UIColor redColor];
    
    return @[delete];
}

-(void)deleteDataSource:(LSLSLinkInModel *)linkM{

    [LSLSLinkInModel deleteSchoolWithlistToken:ShareAppManager.loginUser.access_token us_id:[linkM.us_id intValue] success:^{
        
        //发送通知刷新人脉首页
        [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteLinkInInfoNoti object:nil];
        
    } failure:^(NSError *errer) {
        
    }];
    
}

-(void)saveBtnClick:(UIButton *)sender{
    
    LSAddSchoolViewController * lsASVc = [[LSAddSchoolViewController alloc] init];
    [self.navigationController pushViewController:lsASVc animated:YES];
}

- (void)removeUI {

    [self.bobyImage removeFromSuperview];
    [self.titleLable removeFromSuperview];
}

-(void)createUI{

    self.bobyImage = [UIImageView new];
    self.bobyImage.image = [UIImage imageNamed:@"add"];
    [self.view addSubview:self.bobyImage];
    [self.view bringSubviewToFront:self.bobyImage];
    [self.bobyImage mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(80);
        make.width.equalTo(@(150));
        make.height.equalTo(@(120));
    }];
    
    self.titleLable = [UILabel new];
    self.titleLable.font = [UIFont systemFontOfSize:14];
    self.titleLable.textAlignment = NSTextAlignmentCenter;
    self.titleLable.textColor = [UIColor lightGrayColor];
    self.titleLable.text = @"填写学校信息,让更多人找到你";
    [self.view addSubview:self.titleLable];
    [self.view bringSubviewToFront:self.titleLable];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bobyImage.mas_bottom).offset(20);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(@(20));
    }];
    
}

@end

@implementation LSSchoolTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *nameLabel = [UILabel new];
        nameLabel.text = @"大学";
        self.nameLabel = nameLabel;
        nameLabel.font = SYSTEMFONT(17);
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(10);
            make.left.equalTo(self).offset(20);
            make.width.offset(80);
            make.height.offset(20);
        }];
        
        UILabel *schoolLabel = [UILabel new];
        schoolLabel.text = @"好大学";
        self.schoolLabel = schoolLabel;
        schoolLabel.font = SYSTEMFONT(15);
        [self addSubview:schoolLabel];
        [schoolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(10);
            make.left.equalTo(nameLabel.mas_right).offset(5);
            make.right.equalTo(self.mas_right).offset(-30);
            make.height.offset(20);
        }];
        
        UILabel *departmentsLabel = [UILabel new];
        departmentsLabel.text = @"几点工程系";
        self.departmentsLabel = departmentsLabel;
        departmentsLabel.font = SYSTEMFONT(15);
        [self addSubview:departmentsLabel];
        [departmentsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(schoolLabel.mas_bottom).offset(5);
            make.left.equalTo(nameLabel.mas_right).offset(5);
            make.right.equalTo(self.mas_right).offset(-30);
            make.height.offset(20);
        }];
        
        UILabel *timeLabel = [UILabel new];
        timeLabel.text = @"2011年入学";
        self.timeLabel = timeLabel;
        timeLabel.font = SYSTEMFONT(15);
        [self addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(departmentsLabel.mas_bottom).offset(5);
            make.left.equalTo(nameLabel.mas_right).offset(5);
            make.right.equalTo(self.mas_right).offset(-30);
            make.height.offset(20);
        }];
        
        
        UIImageView * iconImage = [UIImageView new];
        iconImage.image = [UIImage imageNamed:@"right_arrows"];
        [self addSubview:iconImage];
        [iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-20);
            make.width.offset(8);
            make.height.offset(13);
        }];
        
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = HEXRGB(0xbcbcbc);
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel);
            make.bottom.right.equalTo(self);
            make.height.offset(0.5);
        }];
        
        
    }
    return self;
}

-(void)setLinkModel:(LSLSLinkInModel *)linkModel{

    _linkModel = linkModel;
    
    self.schoolLabel.text = _linkModel.school_name;
    self.departmentsLabel.text = _linkModel.note;
    self.timeLabel.text = [NSString stringWithFormat:@"%@年入学",_linkModel.edu_year];
    
    switch ([linkModel.level integerValue]) {
        case 5:
            self.nameLabel.text = @"大学";
            break;
        case 4:
            self.nameLabel.text = @"高中";
            break;
        case 3:
            self.nameLabel.text = @"中专";
            break;
        case 2:
            self.nameLabel.text = @"初中";
            break;
        case 1:
            self.nameLabel.text = @"小学";
            break;
        default:
            break;
    }
}

@end
