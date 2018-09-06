//
//  LSPullDownListView.m
//  LittleSix
//
//  Created by Jim huang on 17/4/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPullDownListView.h"
#import "LSQueryClass.h"
static NSString *const reuse_id = @"listCell";

@interface LSPullDownListView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet UILabel *selectLabel;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (nonatomic,assign,getter=isSelected) BOOL selected;

@end

@implementation LSPullDownListView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.selected = NO;
    UIControl * control = [[UIControl alloc]init];
    [control addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];

    [self.selectView addSubview:control];
    
    [control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.selectView);
    }];

    self.selelctIndex = @"0";
}


+ (instancetype)PullDownListView{
    return [[[NSBundle mainBundle] loadNibNamed:@"LSPullDownListView" owner:nil options:nil]lastObject];
}

-(void)setDataSource:(NSArray *)dataSource{
    _dataSource = dataSource;
    [self.tableView reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuse_id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse_id];
        
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    LSQueryClass *class = self.dataSource[indexPath.row];
    cell.textLabel.text = class.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LSQueryClass *class = self.dataSource[indexPath.row];
    self.selectLabel.text = class.name;
    self.selelctIndex = class.classid;
    self.selected = NO;
}


-(void)setSelected:(BOOL)selected{
    _selected = selected;
    

    if (selected) {
        [self.arrowImageView setImage:[UIImage imageNamed:@"choicebox_show"]];
        
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(205);
            }];
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(160);
            }];

    }else{
        [self.arrowImageView setImage:[UIImage imageNamed:@"choicebox_no"]];

        
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(40);
            }];
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
    }
}

-(void)clickAction{
    self.selected = !self.isSelected;
}
@end
