//
//  LSTLSelectContactViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/9.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTLSelectContactViewController.h"
#import "LSSearchListView.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "LSFriendModel.h"
#import "LSFriendLabelManager.h"
#import "UIView+HUD.h"


static NSString *const reuseId = @"LSLTSelectContactCell";
static NSString *const normal_reuseId = @"LSTLSelectContactNormalCell";

@interface LSTLSelectContactViewController () <UITableViewDelegate,UITableViewDataSource,LSSearchListViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *sortArr;

@property (nonatomic,strong) NSArray *dataSource;

@property (nonatomic,strong) NSMutableArray * selectedArr;

@property (nonatomic,strong) UIButton * sureButton;
@property (nonatomic,strong) LSSearchListView *searchListView;

@property (nonatomic,strong) NSArray *noOrderListArr;

@end

@implementation LSTLSelectContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择联系人";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configNaviBar];
    [self _installSubViews];
    self.selectedArr = [NSMutableArray array];
    
    [self.view showLoading];
    [LSFriendModel getFriendListSuccess:^(NSArray *modelArr) {
        self.dataSource = modelArr;
        [self.tableView reloadData];
        [self.view showSucceed:@"加载完成" hideAfterDelay:1];
    } failure:^(NSError *error) {
        
        [self.view showError:@"加载失败" hideAfterDelay:1];

    }];
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
    self.sureButton = sureButton;
    sureButton.titleLabel.font = SYSTEMFONT(16);
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureButton sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:sureButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.sureButton.enabled = self.selectedArr.count;
    
    [[sureButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        if (self.type == SelectContactViewTypeRemind ) {
            self.remindListBlock(self.selectedArr);
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
            }];

        
        }else{
            [self AlertToLabel];
        }

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
    [searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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
    
    LSSearchListView *listView = [LSSearchListView new];
    self.searchListView = listView;
    self.searchListView.delegate =self;
    self.searchListView.backgroundColor = [UIColor clearColor];
    listView.hidden = YES;
    [self.view addSubview:listView];
    [self.view bringSubviewToFront:listView];
    [listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.tableView);
    }];
    
}

#pragma mark - Action
-(void)AlertToLabel{
#warning 预留标签功能位置
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加标签" message:@"是否把联系人保存为标签？" preferredStyle:UIAlertControllerStyleAlert];
//    
    __weak typeof(LSTLSelectContactViewController) *weakself = self;
//
//    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        
//        LSPerMissionLabelViewController *vc = [LSPerMissionLabelViewController new];
//        vc.type = weakself.type;
//        vc.listArr = weakself.selectedArr;
//        [weakself.navigationController pushViewController:vc animated:YES];
//        
//    }]];
//    [alert addAction:[UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
        weakself.AddressListBlock(weakself.selectedArr,weakself.type);
        [weakself.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
//
//    }]];
//    
//    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//    }]];
//    
//    
//    [self presentViewController:alert animated:YES completion:nil];
}
         
#pragma mark -searchViewDelegate
-(void)searchView:(LSSearchListView *)view didSelectedWithModel:(LSFriendModel *)model{
    for (int section = 1; section<self.dataSource.count; section++) {
        LSFriendListModel * listModel = self.dataSource[section];
        for (int row = 0; row<listModel.friendList.count; row++) {
            LSFriendModel *friendModel = listModel.friendList[row];
            if ([model.friend_id isEqualToString:friendModel.friend_id]) {
                [self.tableView scrollToRow:row inSection:section atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }

        }
        
    }
    
}
#pragma mark - TextFieldAction

-(void)textFieldDidChange:(UITextField *)textField{
    if (textField.text.length>0) {
        [self.searchListView searchFriendWithStr:textField.text];
        self.searchListView.hidden = NO;
    }else{
        self.searchListView.hidden = YES;

    }
    
}


#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0;
    }else{
        LSFriendListModel * listModel = self.dataSource[section-1];
        return listModel.friendList.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
    LSTLSelectContactNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:normal_reuseId];
        
        return cell;
    }
    
    LSTLSelectContactCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    LSFriendListModel * listModel = self.dataSource[indexPath.section-1];
    LSFriendModel *friendModel = listModel.friendList[indexPath.row];
    cell.model =friendModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        UIViewController *vc = [NSClassFromString(@"LSPickGroupViewController") new];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        LSTLSelectContactCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        LSFriendListModel * listModel = self.dataSource[indexPath.section-1];
        LSFriendModel *friendModel = listModel.friendList[indexPath.row];
        friendModel.selected = !friendModel.selected;
        cell.cellSelected = friendModel.selected;
        
        if (cell.cellSelected)
            [self.selectedArr addObject:cell.model];
        else
            [self.selectedArr removeObject:cell.model];
        
    }
    
    self.sureButton.enabled = self.selectedArr.count;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView new];
    headerView.backgroundColor = HEXRGB(0xefeff4);
    
    UILabel *indexLabel = [UILabel new];
    indexLabel.font = SYSTEMFONT(14);
    indexLabel.textColor = HEXRGB(0x8e8e93);
    LSFriendListModel *listModel = self.dataSource[section-1];
    indexLabel.text = listModel.first_letter;
    
    [headerView addSubview:indexLabel];
    [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView);
        make.left.equalTo(headerView).offset(10);
    }];
    
    return headerView;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray * sortArr = [NSMutableArray array];
    [sortArr addObject:@"{search}"];
    
    for (LSFriendListModel *listModel in self.dataSource) {
        [sortArr addObject:listModel.first_letter];
    }
    self.sortArr = sortArr;
    return sortArr;
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
        
        [tableView registerClass:[LSTLSelectContactCell class] forCellReuseIdentifier:reuseId];
        [tableView registerClass:[LSTLSelectContactNormalCell class] forCellReuseIdentifier:normal_reuseId];
    }
    return _tableView;
}

@end

@interface LSTLSelectContactCell ()

@property(nonatomic,strong) UIImageView * iconView;
@property(nonatomic,strong) UILabel *nameLabel;

@end

@implementation LSTLSelectContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *selectBtn = [UIButton new];
        self.selectBtn = selectBtn;
        [selectBtn setImage:[UIImage imageNamed:@"addcontact_checkbox"] forState:UIControlStateNormal];
        [selectBtn setImage:[UIImage imageNamed:@"addcontact_checkbox_on"] forState:UIControlStateSelected];
        [self addSubview:selectBtn];
        
        UIImageView *iconView = [UIImageView new];
        self.iconView = iconView;
        [self addSubview:iconView];
        
        UILabel *nameLabel = [UILabel new];
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        
        [selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.height.offset(24);
            make.left.equalTo(self).offset(8);
        }];
        
        
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.height.offset(36);
            make.left.equalTo(selectBtn.mas_right).offset(10);
        }];
        
        
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(iconView.mas_right).offset(10);
            make.right.equalTo(self).offset(20);
        }];
        
        
    }
    return self;
}

-(void)setModel:(LSFriendModel *)model{
    _model = model;
    
    self.nameLabel.text = model.user_name;
    [self.iconView setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:timeLineSmallPlaceholderName];
    self.cellSelected = model.selected;
    
}

-(void)setCellSelected:(BOOL)cellSelected{
    _cellSelected = cellSelected;
    self.selectBtn.selected = cellSelected;
}

@end

@implementation LSTLSelectContactNormalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = @"选择一个群";
        titleLabel.font = SYSTEMFONT(14);
        
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(15);
        }];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


@end
