//
//  LSPermissionViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPermissionViewController.h"
#import "LSTLSelectContactViewController.h"
#import "LSFriendModel.h"
#import "LSFriendLabelManager.h"
#import "LSPermissionModel.h"

static NSString *const reuse_id = @"LSPermissionCell";

@interface LSPermissionViewController () <UITableViewDelegate,UITableViewDataSource,LSPermissionViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,weak) LSPermissionView *selectedHeader;
@property (nonatomic,weak) LSPermissionView *fristHeader;

@property (nonatomic,strong) NSArray *canSeeOtherArr;
@property (nonatomic,strong) NSArray *noSeeOtherArr;

@property (nonatomic,strong) NSMutableArray *selectLabelArr;

@end

@implementation LSPermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"谁可以看";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.tableView reloadData];
    [self _buildNaviBar];
    [self setNotification];
    
    self.selectLabelArr = [NSMutableArray array];
    
}

- (void)_buildNaviBar {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = SYSTEMFONT(16);
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
}

-(void)sureBtnClick{
    if ([self.delegate respondsToSelector:@selector(ViewController:selectDoneWithType:LabelArr:otherArr:)]) {
        
        SelectContactViewType type;
        
        NSArray * sendLabelArr;
        NSArray * sendOhterArr;
        
        switch (self.selectedHeader.index) {
            case 0:
                type = SelectContactViewTypeAll;
                sendLabelArr = nil;
                sendOhterArr = nil;
                break;
                
            case 1:
                type = SelectContactViewTypeOnlyMe;
                sendLabelArr = nil;
                sendOhterArr = nil;
                break;
                
            case 2:
                type = SelectContactViewTypeCanSee;
                sendLabelArr = self.selectLabelArr;
                sendOhterArr = self.canSeeOtherArr;
                break;
                
            case 3:
                type = SelectContactViewTypeNoSee;
                sendLabelArr = self.selectLabelArr;
                sendOhterArr = self.noSeeOtherArr;
                
                break;
                
            default:
                break;
        }
        
        [self.delegate ViewController:self selectDoneWithType:type LabelArr:sendLabelArr otherArr:sendOhterArr];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
//    
//    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
//    [dic setObject:self.selectLabelArr forKey:@"selectLabelArr"];
//    if (self.selectedHeader.index == 2) {
//        if (self.canSeeOtherArr.count>0) [dic setObject:self.canSeeOtherArr forKey:@"otherArr"];
//       
//        [dic setObject:[NSNumber numberWithInt:SelectContactViewTypeCanSee] forKey:@"type"];
//      
//    }else{
//
//        if (self.noSeeOtherArr.count>0) [dic setObject:self.noSeeOtherArr forKey:@"otherArr"];
//        
//        [dic setObject:[NSNumber numberWithInt:SelectContactViewTypeNoSee] forKey:@"type"];
//    }
//    [[NSNotificationCenter defaultCenter]postNotificationName:TimeLinePermissionNoti object:nil userInfo:dic];
}

-(void)setNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addLabelWithNoti:) name:FriendListLabelNoti object:nil];
}

-(void)addLabelWithNoti:(NSNotification *)noti{
    NSDictionary *dic = noti.userInfo;
    LSFriendListLabelModel * friendListLabelModel =dic[@"LSFriendListLabelModel"];
    NSNumber * typeNum = dic[@"type"];
    
    SelectContactViewType type = typeNum.intValue;
    
    NSMutableArray * friendNameArr = [NSMutableArray array];
    LSPermissionSubModel * subModel = [LSPermissionSubModel new];
    subModel.title = friendListLabelModel.label;

    for (LSFriendModel * friendModel in friendListLabelModel.friendList) {
            [friendNameArr addObject:friendModel.user_name];
    }
    NSString * nameStr = [friendNameArr componentsJoinedByString:@","];
    subModel.subTitle = nameStr;
    subModel.friendList = (NSMutableArray *)friendListLabelModel.friendList;
    
    LSPermissionSubModel *remind = [LSPermissionSubModel new];
    remind.addCell =YES;
    if (type == SelectContactViewTypeCanSee) {
        [self closeCellWithView:self.selectedHeader];
        LSPermissionModel * model = self.dataSource[2];
        [model.sub insertObject:subModel atIndex:0];
        [self openCellWithView:self.selectedHeader];
        
    }else{
        [self closeCellWithView:self.selectedHeader];
        LSPermissionModel * model = self.dataSource[3];
        [model.sub insertObject:subModel atIndex:0];
        [self openCellWithView:self.selectedHeader];
    }

}

#pragma mark - TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LSPermissionModel * model = self.dataSource[section];
    if (model.sub.count>0 && self.selectedHeader.isOpen == NO && self.selectedHeader.index == section) {
        return model.sub.count;
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    LSPermissionView * view = [[LSPermissionView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 65)index:section];
    view.delegate = self;
    if (section == 0){
        self.fristHeader = view;
        self.selectedHeader = view;
        view.checkView.hidden = NO;
    }else{
        view.checkView.hidden = YES;
    }
    
    LSPermissionModel *model = self.dataSource[section];
    view.delegate = self;
    view.titleL.text = model.title;
    view.subTitleLabel.text = model.subTitle;
    
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSPermissionCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
        LSPermissionModel * model = self.dataSource[indexPath.section];
        if (model.sub.count !=0 ) {
            LSPermissionSubModel *subModel = model.sub[indexPath.row];
            if (subModel.isAddCell) {
                cell.titleL.text = @"从通讯录选择";
                cell.titleL.textColor = [UIColor blueColor];
                
                NSString * subStr =@"";
                if (indexPath.section == 2){
                    cell.subTitleLabel.textColor = [UIColor greenColor];
//                    self.noSeeOtherArr = nil;
                    for (LSFriendModel * model in self.canSeeOtherArr) {
                        subStr = [subStr stringByAppendingString:[NSString stringWithFormat:@"%@,",model.user_name]];
                    }
                    
                }else{
                    cell.subTitleLabel.textColor = [UIColor redColor];
//                    self.canSeeOtherArr = nil;
                    for (LSFriendModel * model in self.noSeeOtherArr) {
                        subStr = [subStr stringByAppendingString:[NSString stringWithFormat:@"%@,",model.user_name]];
                    }
                }
                cell.subTitleLabel.text = subModel.subTitle;
                cell.editBtn.hidden = YES;
                cell.selectbutton.hidden = YES;
            }else{
                cell.titleL.text = subModel.title;
                cell.subTitleLabel.text = subModel.subTitle;
                cell.titleL.textColor = [UIColor blackColor];
                cell.subTitleLabel.textColor = HEXRGB(0x888888);
                cell.editBtn.hidden = NO;
                cell.selectbutton.hidden = NO;
                cell.model = subModel;
                cell.CellSelected = subModel.modelSelected;
            }

    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LSPermissionModel * model = self.dataSource[indexPath.section];
    LSPermissionSubModel *subModel = model.sub[indexPath.row];


    if (subModel.isAddCell) {
        LSTLSelectContactViewController *vc = [NSClassFromString(@"LSTLSelectContactViewController") new];
        
        if (indexPath.section == 2)
            vc.type = SelectContactViewTypeCanSee;
        else
            vc.type = SelectContactViewTypeNoSee;
        __weak typeof(LSPermissionViewController) *weakself = self;

        [vc setAddressListBlock:^(NSArray*listArr,SelectContactViewType type){
            NSString * subStr =@"";
            if (type == SelectContactViewTypeCanSee) {
                weakself.canSeeOtherArr = listArr;
                for (LSFriendModel * model in weakself.canSeeOtherArr) {
                    subStr = [subStr stringByAppendingString:[NSString stringWithFormat:@"%@,",model.user_name]];
                }
            }else{
                
                weakself.noSeeOtherArr = listArr;
                for (LSFriendModel * model in weakself.noSeeOtherArr) {
                    subStr = [subStr stringByAppendingString:[NSString stringWithFormat:@"%@,",model.user_name]];
                }
                
            }
            LSPermissionCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.subTitleLabel.text = subStr;
         }];

        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:naviVC animated:YES completion:nil];
    }else{
     
        LSPermissionCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.CellSelected = !cell.isCellSelected;
        subModel.modelSelected = cell.isCellSelected;
        
        if (subModel.modelSelected) 
            [self.selectLabelArr addObject:subModel];
        else
            [self.selectLabelArr removeObject:subModel];
        
    }
}
#pragma mark delegate



-(void)didsSelectPermissionView:(LSPermissionView *)View{

    self.noSeeOtherArr = nil;
    self.canSeeOtherArr = nil;
    
    if (self.selectedHeader == View) {
        if (View.index == 0) {
            return;
        }else{
            View.checkView.hidden = YES;
            self.fristHeader.checkView.hidden = NO;
            [self closeCellWithView:self.selectedHeader];
            self.selectedHeader = self.fristHeader;
        }
    }else{

        if(self.selectedHeader.isOpen == NO){
            self.selectedHeader.checkView.hidden = YES;
            View.checkView.hidden = NO;
            self.selectedHeader = View;
            [self openCellWithView:self.selectedHeader];
        }else{
            [self closeCellWithView:self.selectedHeader];
            self.selectedHeader.checkView.hidden = YES;
            View.checkView.hidden = NO;
            self.selectedHeader = View;
            [self openCellWithView:self.selectedHeader];
        }
    }
}

-(void)closeCellWithView:(LSPermissionView *)view{
    [self.tableView deleteRowsAtIndexPaths:[self indexPathsCellWithView:view] withRowAnimation:UITableViewRowAnimationLeft];
    self.selectedHeader.open = NO;
}


-(void)openCellWithView:(LSPermissionView *)view{
        [self.tableView insertRowsAtIndexPaths:[self indexPathsCellWithView:view] withRowAnimation:UITableViewRowAnimationLeft];
    self.selectedHeader.open =YES;
}

-(NSArray *)indexPathsCellWithView:(LSPermissionView *)view{
            LSPermissionModel *model = self.dataSource[view.index];
            NSMutableArray * indexPathArr = [NSMutableArray array];
            for (int index = 0; index<model.sub.count; index++) {
                NSIndexPath * indexpath = [NSIndexPath indexPathForRow:index inSection:view.index];
                [indexPathArr addObject:indexpath];
            }
    return indexPathArr;
}


#pragma mark - Getter & Setter
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 65;
        tableView.sectionFooterHeight = 0;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [tableView registerClass:[LSPermissionCell class] forCellReuseIdentifier:reuse_id];
        
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];
    }
    return _tableView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        
        LSPermissionModel *model1 = [LSPermissionModel new];
        model1.title = @"公开";
        model1.subTitle = @"所有朋友可见";
        
        LSPermissionModel *model2 = [LSPermissionModel new];
        model2.title = @"私密";
        model2.subTitle = @"仅自己可见";
        
        LSPermissionModel *model3 = [LSPermissionModel new];
        model3.title = @"部分可见";
        model3.subTitle = @"选中的朋友可见";
        
        LSPermissionModel *model4 = [LSPermissionModel new];
        model4.title = @"不给谁看";
        model4.subTitle = @"选中的朋友不可见";
        
        NSArray *  listArr=[LSFriendLabelManager DBGetAllListLabel];
        
        NSMutableArray * friendNameArr = [NSMutableArray array];
        NSMutableArray * labelArr = [NSMutableArray array];
        for (LSFriendListLabelModel *friendListLabelModel in listArr) {
            
            LSPermissionSubModel * subModel = [LSPermissionSubModel new];
            subModel.title = friendListLabelModel.label;
            
            for (LSFriendModel * friendModel in friendListLabelModel.friendList) {
                [friendNameArr addObject:friendModel.user_name];
            }
            NSString * nameStr = [friendNameArr componentsJoinedByString:@","];
            subModel.subTitle = nameStr;
            subModel.friendList = (NSMutableArray *)friendListLabelModel.friendList;
            [labelArr addObject:subModel];
        }
        LSPermissionSubModel *remind = [LSPermissionSubModel new];
        remind.addCell =YES;
        
        [labelArr addObject:remind];
        
        model3.sub = labelArr;
        model4.sub = labelArr;

        _dataSource =[NSMutableArray arrayWithArray:@[model1,model2,model3,model4]] ;
    }
    return _dataSource;
}




@end

@interface LSPermissionView ()

-(void)didselectHeaderView:(LSPermissionView *)View;

@end

@implementation LSPermissionView

- (instancetype)initWithFrame:(CGRect)frame index:(NSInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        UIControl * control = [UIControl new];
        self.index = index;
        [control addTarget:self action:@selector(didselectHeaderView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control];
        
        
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeline_red_selected"]];
        self.checkView = checkView;
        [self addSubview:checkView];

        
        UILabel *titleL = [UILabel new];
        self.titleL = titleL;
        titleL.font = SYSTEMFONT(17);
        titleL.font = [UIFont boldSystemFontOfSize:17];
        titleL.textColor = [UIColor blackColor];
        [self addSubview:titleL];

        
        UILabel *subTitleLabel = [UILabel new];
        self.subTitleLabel = subTitleLabel;
        subTitleLabel.font = SYSTEMFONT(14);
        subTitleLabel.textColor = HEXRGB(0x888888);
        [self addSubview:subTitleLabel];
        
        UIView * marginView = [UIView new];
        marginView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:marginView];
        
        [control mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self);
        }];
        
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(-13);
            make.left.equalTo(checkView.mas_right).offset(12);
        }];
        
        [checkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.offset(18);
        }];
        [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(13);
            make.left.equalTo(titleL);
        }];
        
        [marginView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
        
    }
    return self;
}

-(void)didselectHeaderView:(LSPermissionView *)View{
    if ([self.delegate respondsToSelector:@selector(didsSelectPermissionView:)]) {
        [self.delegate didsSelectPermissionView:self];
    }

    
}

@end

@implementation LSPermissionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        
        UIButton *selectbutton = [UIButton new];
        [selectbutton setImage:[UIImage imageNamed:@"timeline_red_selected"] forState:UIControlStateSelected];
        [selectbutton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        self.selectbutton = selectbutton;
        [self.contentView addSubview:selectbutton];
        
        UILabel *titleL = [UILabel new];
        self.titleL = titleL;
        titleL.font = SYSTEMFONT(16);
        titleL.textColor = [UIColor blackColor];
        [self.contentView addSubview:titleL];
        
        UIButton * editBtn =[UIButton new];
        self.editBtn = editBtn;
        editBtn.backgroundColor =[UIColor blackColor];
        [self.contentView addSubview:editBtn];
        
        UILabel *subTitleLabel = [UILabel new];
        self.subTitleLabel = subTitleLabel;
        subTitleLabel.font = SYSTEMFONT(13);
        subTitleLabel.textColor = HEXRGB(0x888888);
        [self.contentView addSubview:subTitleLabel];
        

        [selectbutton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.offset(40);
            make.width.height.mas_equalTo(20);
        }];
        
        [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(selectbutton);
            make.right.equalTo(self.contentView).offset(-18);
            make.width.height.mas_equalTo(20);
        }];
        
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView).offset(-13);
            make.left.equalTo(selectbutton.mas_right).offset(12);
            make.right.equalTo(editBtn.mas_left).offset(-12);
        }];
        
        [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView).offset(13);
            make.left.right.equalTo(titleL);
        }];
        
    }
    return self;
}


-(void)setCellSelected:(BOOL)CellSelected{
    _CellSelected = CellSelected;
    self.selectbutton.selected = CellSelected;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}



@end
