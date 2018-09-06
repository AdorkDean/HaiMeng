//
//  LSSelectGroupViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/4/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSelectGroupViewController.h"
#import "LSSelectContactViewController.h"
#import "UIView+HUD.h"
#import "LSChineseSort.h"
#import "LSGroupModel.h"

static NSString *const reuseId = @"LSSelectGroupCell";
static NSString *const normal_reuseId = @"LSSelectContactNormalCell";

@interface LSSelectGroupViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

//排序后的出现过的拼音首字母数组
@property(nonatomic, strong) NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic, strong) NSMutableArray *letterResultArr;


@end

@implementation LSSelectGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"移出群成员";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configNaviBar];
    [self _installSubViews];
    [self _initDataSource];
}

-(void)_initDataSource {
    
    //根据LSContactModel对象的 user_name 属性 按中文 对 LSContactModel数组 排序
    self.indexArray = [LSChineseSort IndexWithArray:self.listArr Key:@"nickname"];
    self.letterResultArr = [LSChineseSort sortObjectArray:self.listArr Key:@"nickname"];
    [self.tableView reloadData];
    
}

- (void)configNaviBar {
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.titleLabel.font = SYSTEMFONT(16);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    @weakify(self)
    [[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.titleLabel.font = SYSTEMFONT(16);
    [sureButton setTitle:@"删除" forState:UIControlStateNormal];
    [sureButton sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:sureButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [[sureButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        
        NSMutableArray * members = [NSMutableArray array];
        
        for (NSArray * arr in self.letterResultArr) {
            for (LSMembersModel * model in arr) {
                if (model.is_select) {
                    [members addObject:model.userid];
                
                }
            }
        }
        
        [self removeMembers:members];
        
    }];
}

- (void)removeMembers:(NSArray *)members {
    
    NSString * memStr = @"";
    
    for (int i = 0; i < members.count; i ++) {
        
        if (i == 0) {
            memStr = [NSString stringWithFormat:@"%@",members[i]];
        }else{
            
            memStr = [NSString stringWithFormat:@"%@,%@",memStr,members[i]];
        }
    }
    
    [LSGroupModel removeMembersWithGroupid:self.groupid members:memStr success:^(NSString *message) {
        
        [self.view showSucceed:message hideAfterDelay:1.5];
        [self dismissViewControllerAnimated:YES completion:nil];
        //发送通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupReduceMembersNoti object:nil];
        
    } failure:^(NSError *error) {
        [self.view showError:@"移除失败" hideAfterDelay:1.5];
    }];
}


- (void)_installSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *searchView = [UIView new];
    [self.view addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.offset(55);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    
    UIImageView *searchImageView = [UIImageView new];
    [self.view addSubview:searchImageView];
    searchImageView.image = [UIImage imageNamed:@"addcontact_group_search"];
    [searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView).offset(10);
        make.centerY.equalTo(searchView);
    }];
    
    UITextField *searchTextField = [UITextField new];
    searchTextField.placeholder = @"搜索";
    searchTextField.returnKeyType = UIReturnKeySearch;
    searchTextField.delegate = self;
    [searchView addSubview:searchTextField];
    [searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(searchView);
        make.left.equalTo(searchImageView.mas_right).offset(4);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = HEXRGB(0xe9e9ec);
    [searchView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(searchView);
        make.height.offset(0.8);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if (![textField.text isEqualToString:@""]) {
        NSString * key = [textField.text stringByTrim];
        NSMutableArray * arr = [NSMutableArray array];
        for (NSArray * array in self.letterResultArr) {
            for (LSMembersModel * model  in array) {
                if ([model.nickname rangeOfString:key].location != NSNotFound) {
                    [arr addObject:model];
                }
            }
        }
        self.indexArray = [LSChineseSort IndexWithArray:arr Key:@"nickname"];
        self.letterResultArr = [LSChineseSort sortObjectArray:arr Key:@"nickname"];
        [self.tableView reloadData];
    }else {
    
        [self _initDataSource];
    }

    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.letterResultArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.letterResultArr objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSSelectGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    LSMembersModel * model = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.membersModel = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSMembersModel * model = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    model.is_select = !model.is_select;
    LSSelectGroupCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.cellSelected = !cell.isCellSelected;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView new];
    headerView.backgroundColor = HEXRGB(0xefeff4);
    
    UILabel *indexLabel = [UILabel new];
    indexLabel.font = SYSTEMFONT(14);
    indexLabel.textColor = HEXRGB(0x8e8e93);
    indexLabel.text = self.indexArray[section];
    
    [headerView addSubview:indexLabel];
    [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView);
        make.left.equalTo(headerView).offset(10);
    }];
    
    return headerView;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0.0;
            
        default:
            return 22;
    }
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
        tableView.sectionIndexColor = HEXRGB(0x555555);
        tableView.backgroundColor = HEXRGB(0xefeff4);
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        
        [tableView registerClass:[LSSelectGroupCell class] forCellReuseIdentifier:reuseId];
    }
    return _tableView;
}


@end

@implementation LSSelectGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *selectBtn = [UIButton new];
        [selectBtn setImage:[UIImage imageNamed:@"addcontact_checkbox"] forState:UIControlStateNormal];
        [selectBtn setImage:[UIImage imageNamed:@"addcontact_checkbox_on"] forState:UIControlStateSelected];
        [selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        self.selectBtn = selectBtn;
        [self addSubview:selectBtn];
        [selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.height.offset(24);
            make.left.equalTo(self).offset(8);
        }];
        
        UIImageView *iconView = [UIImageView new];
        self.iconImage = iconView;
        [self addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.height.offset(36);
            make.left.equalTo(selectBtn.mas_right).offset(10);
        }];
        
        UILabel *nameLabel = [UILabel new];
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(iconView.mas_right).offset(10);
            make.right.equalTo(self).offset(20);
        }];
        
        iconView.backgroundColor = [UIColor lightGrayColor];
        nameLabel.text = @"咖喱辣椒";
        
    }
    return self;
}

- (void)setMembersModel:(LSMembersModel *)membersModel {
    
    _membersModel = membersModel;
    
    [self.iconImage setImageWithURL:[NSURL URLWithString:membersModel.snap] placeholder:[UIImage imageNamed:@""]];
    self.nameLabel.text = membersModel.nickname;
    
    self.selectBtn.selected = membersModel.is_select;
}


-(void)selectBtnClick:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.membersModel.is_select = YES;
    }else{
        self.membersModel.is_select = NO;
    }
}



-(void)setCellSelected:(BOOL)cellSelected{
    _cellSelected = cellSelected;
    self.membersModel.is_select = cellSelected;
    self.selectBtn.selected = cellSelected;
}

@end
