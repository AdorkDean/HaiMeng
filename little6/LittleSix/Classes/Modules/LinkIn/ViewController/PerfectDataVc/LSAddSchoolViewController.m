//
//  LSAddSchoolViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSAddSchoolViewController.h"
#import "LSEditorSchoolTableController.h"

static NSString *const reuse_id = @"LSAddSchoolCell";
@interface LSAddSchoolViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (retain,nonatomic)UITableView * tableView;

@property (retain,nonatomic)NSMutableArray * dataArray;

@end

@implementation LSAddSchoolViewController

-(NSMutableArray *)dataArray {

    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    self.title = @"添加学校";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setUI];
    [self initData];
}

-(void)initData {

    NSDictionary * dic1 = @{@"s_id":@"5",@"c_name":@"大学"};
    NSDictionary * dic2 = @{@"s_id":@"4",@"c_name":@"高中"};
    NSDictionary * dic3 = @{@"s_id":@"3",@"c_name":@"中专技校"};
    NSDictionary * dic4 = @{@"s_id":@"2",@"c_name":@"初中"};
    NSDictionary * dic5 = @{@"s_id":@"1",@"c_name":@"小学"};
    
    [self.dataArray addObject:dic1];
    [self.dataArray addObject:dic2];
    [self.dataArray addObject:dic3];
    [self.dataArray addObject:dic4];
    [self.dataArray addObject:dic5];
    
    [self.tableView reloadData];
}

-(void)setUI {

    self.tableView  = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = bgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[LSAddSchoolCell class] forCellReuseIdentifier:reuse_id];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    self.tableView.tableFooterView = [UIView new];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LSAddSchoolCell * cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    
    NSDictionary * dic = self.dataArray[indexPath.row];
    cell.textLabel.text = dic[@"c_name"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary * dic = self.dataArray[indexPath.row];
    LSEditorSchoolTableController * edtv = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSEditorSchool"];
    edtv.level = [dic[@"s_id"] intValue];
    [self.navigationController pushViewController:edtv animated:YES];
}

@end

@interface LSAddSchoolCell ()

@end

@implementation LSAddSchoolCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *nameLabel = [UILabel new];
        self.nameLabel = nameLabel;
        nameLabel.font = SYSTEMFONT(15);
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(20);
            make.width.offset(85);
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


@end
