//
//  LSFuwaCatchListView.m
//  LittleSix
//
//  Created by Jim huang on 17/4/12.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaCatchListView.h"
#import "LSFuwaModel.h"
#import "MJRefresh.h"
static NSString *const reuse_id = @"LSFuwaCatchListCell";

@interface LSFuwaCatchListView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *listView;
@property (nonatomic,strong) UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listViewHeight;

@property (nonatomic,assign) int page;

@end
@implementation LSFuwaCatchListView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self layoutIfNeeded];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshTableFoot)];

}

+ (instancetype)LSFuwaCatchListView {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaCatchListView" owner:nil options:nil] lastObject];
}

-(void)setDataSource:(NSMutableArray *)dataSource{
    _dataSource = dataSource;
    int listHeight ;
    if (dataSource.count<4){
        listHeight = (int)dataSource.count * 60;

    }else{
        listHeight = 4*60;

    }

    [self.listView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(listHeight);
    }];
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.listView);
    }];

    [self.tableView reloadData];
    
    [self layoutIfNeeded];

}

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark tableView
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView = tableView;
        
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.listView addSubview:_tableView];

        [tableView registerClass:[LSFuwaCatchListCell class] forCellReuseIdentifier:reuse_id];
        

        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self.listView);
        }];
        
    }
    return _tableView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LSFuwaCatchListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    LSFuwaModel * model = self.dataSource[indexPath.row];
    cell.model = model;
    @weakify(self)
    [cell setDetailBlock:^{
        @strongify(self)
        self.detailBlock(model);
    }];
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LSFuwaModel * model = self.dataSource[indexPath.row];
    self.catchActionBlock(model);
}

- (IBAction)expandAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    !self.expandBlock ? : self.expandBlock(!sender.selected);
}

-(void)refreshTableFoot{
    if (self.dataSource.count<1) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    LSFuwaModel * model = self.dataSource[self.dataSource.count-1];

    NSArray *strArray = [model.gid componentsSeparatedByString:@"_"];
    NSString *numStr =strArray[2];
    if(self.refreshTableFootBlock){
        self.refreshTableFootBlock(numStr);
    }
}

-(void)endLoadFoot{
    [self.tableView.mj_footer endRefreshing];
}


@end

@interface LSFuwaCatchListCell ()
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UILabel * locaLabel;
@property (nonatomic,strong) UIButton * detailBtn;
@property (nonatomic,strong) UIImageView * iconView;

@end

@implementation LSFuwaCatchListCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeConstrains];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    // Configure the view for the selected state
}

-(void)makeConstrains{
    
    self.iconView = [UIImageView new];
    ViewRadius(self.iconView, 22);
    [self.contentView addSubview:self.iconView];
    
    self.nameLabel = [UILabel new];
    self.nameLabel.textColor = HEXRGB(0xd3000f);
    self.nameLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:self.nameLabel];
    
    self.locaLabel = [UILabel new];
    self.locaLabel.textColor = HEXRGB(0x999999);
    self.locaLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:self.locaLabel];
    
    self.detailBtn = [UIButton new];
    [self.detailBtn setTitle:@"详情" forState:UIControlStateNormal];
    [self.detailBtn setTitleColor:HEXRGB(0xd3000f) forState:UIControlStateNormal];
    [self.detailBtn addTarget:self action:@selector(detailAction) forControlEvents:UIControlEventTouchUpInside];
    self.detailBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    ViewBorderRadius(self.detailBtn, 5, 1, HEXRGB(0xd3000f));
    [self.contentView addSubview:self.detailBtn];
    
    [self.detailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-20);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(45);
        make.height.mas_equalTo(30);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(45);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.iconView.mas_right).offset(10);
        make.right.equalTo(self.detailBtn.mas_left).offset(-10);
        make.height.mas_equalTo(20);
    }];
    
   [self.locaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.right.height.equalTo(self.nameLabel);
       make.top.equalTo(self.nameLabel.mas_bottom).offset(2);
   }];
}
-(void)detailAction{
    self.detailBlock();
}

-(void)setModel:(LSFuwaModel *)model{
    _model = model;
    self.nameLabel.text = model.name;
    self.locaLabel.text = [NSString stringWithFormat:@"%@%@",model.location,model.pos];
    [self.iconView setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:timeLineBigPlaceholderName];
    
}




@end
