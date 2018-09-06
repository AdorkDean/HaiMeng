//
//  LSTimeLineHomeDetailViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTimeLineHomeDetailViewController.h"
#import "LSTimeLineViewController.h"
#import "LSOptionsView.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "LSTimeLineTableListModel.h"
#import "LSTimeLineHomeViewController.h"
#import "LSAppManager.h"
#import "UIView+HUD.h"
#import "LSPostCommentView.h"
#import "IQKeyboardManager.h"
#import "LSGoodAndCommentView.h"

static NSString *const reuse_id = @"LSTimeLineTableViewCell";
@interface LSTimeLineHomeDetailViewController ()<UITableViewDelegate,UITableViewDataSource,LSGoodAndCommentViewDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataSource;


@property (nonatomic,strong) LSPostCommentView *addCommentView;
@property (nonatomic,strong) LSTimeLineTableListModel *detailModel;
@property (nonatomic,assign) TimeLineContentType contentType;

@end

@implementation LSTimeLineHomeDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详情";
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataSource = [NSMutableArray array];
    [self setConstrains];
    [self loadData];
    [self setNotifications];

    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
}


-(void)setNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openAddCommentViewWithNoti:) name:addCommentViewNoti object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadData) name:TimeLineReloadCellNoti object:nil];
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification *notification) {
        @strongify(self)
        
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{                [self.addCommentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).offset(-keyBoardFrame.size.height);
        }];
            [self.view layoutIfNeeded];
        }];
        
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(NSNotification *notification) {
        @strongify(self)
        
        CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            [self.addCommentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view.mas_bottom);
            }];
            [self.view layoutIfNeeded];
        }];
    }];
}

-(void)loadData{
    
    [LSTimeLineTableListModel loadTimeLineDetailWithfeed_id:self.feed_Id success:^(LSTimeLineTableListModel *model) {
        self.detailModel = model;
        self.addCommentView.model = model;
        [self.tableView reloadData];
        [self.view endEditing:YES];
        self.addCommentView.hidden = YES;
    } failure:^(NSError *error) {
        
    }];
}


-(void)setUser_id:(NSString *)user_id{
    _user_id = user_id;
        if (![user_id isEqualToString: [LSAppManager sharedAppManager].loginUser.user_id]){
            self.contentType = TimeLineContentTypeSelf;
            self.navigationItem.rightBarButtonItem = nil;
        }else{
            self.contentType = TimeLineContentTypeOther;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"shake_setup"] style:UIBarButtonItemStyleDone target:self action:@selector(openOptionsView)];
        }
}

-(void)setConstrains{
    
    [self.view addSubview:self.tableView];
    
    self.addCommentView = [LSPostCommentView new];
    self.addCommentView.hidden = YES;
    [self.view addSubview:self.addCommentView];

    [self.addCommentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.height.equalTo(self.view);
        
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
}


-(void)openOptionsView{
    
    if ([[LSAppManager sharedAppManager].loginUser.user_id isEqualToString:self.detailModel.user_id]) {
        return;
    }
    LSOptionsView * optionsView = [[LSOptionsView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.frame WithData:@[@"删除"]];
    __weak typeof(LSTimeLineHomeDetailViewController) *weakself = self;
    
    [optionsView setSelectCellBlock:^(NSString * title){
        if ([title  isEqualToString: @"删除"]) {
            [self.view showLoading];
            [LSTimeLineTableListModel deleteTimeLineWithFeed_id:self.detailModel.feed_id success:^{
                
                [[NSNotificationCenter defaultCenter]postNotificationName:kreloadTimeLineNoti object:nil];
                [self.view showSucceed:@"删除成功" hideAfterDelay:1];
                for (UIViewController *Vc in self.navigationController.viewControllers) {
                    if ([Vc isKindOfClass:[LSTimeLineHomeViewController class]]) {
                        [weakself.navigationController popToViewController:Vc animated:YES];
                    }
                }
                
            } failure:^(NSError *error) {
                [self.view showError:@"删除失败" hideAfterDelay:1];
            }];
        }
    }];

    
    [[UIApplication sharedApplication].keyWindow addSubview:optionsView];
}


#pragma mark tableView
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView = tableView;
        
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [tableView registerClass:[LSTimeLineTableViewCell class] forCellReuseIdentifier:reuse_id];

        self.tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LSTimeLineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    
    cell.model = self.detailModel;
    [cell configCellWithModel:self.detailModel];
    cell.goodAndCommentView.delegate = self;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hiddenKeyboardAndPostCommentView];
}


-(void)CommentViewLongPressWithCommentModel:(LSTimeLineCommentModel *)model cellIndex:(int)cellIndex{
    self.addCommentView.hidden = NO;
    self.addCommentView.index = cellIndex;
    self.addCommentView.type = postCommentTypeAnswer;
    self.addCommentView.commentModel = model;
    [self.addCommentView.commentTextField becomeFirstResponder];
}

-(void)openAddCommentViewWithNoti:(NSNotification *)noti{
    NSDictionary *dic = noti.userInfo;
    
    LSTimeLineTableListModel *model = dic[@"commentModel"];
    NSNumber *index = dic[@"index"];
    self.addCommentView.hidden = NO;
    self.addCommentView.type = postCommentTypeNew;
    self.addCommentView.model = model;
    self.addCommentView.index = index.intValue;
    [self.addCommentView.commentTextField becomeFirstResponder];
    
}

-(void)hiddenKeyboardAndPostCommentView{
    self.addCommentView.hidden = YES;
    [self.view endEditing:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = [LSTimeLineTableViewCell hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
        LSTimeLineTableViewCell *cell = (LSTimeLineTableViewCell *)sourceCell;
        [cell configCellWithModel:self.detailModel];
    }];
    return  height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
