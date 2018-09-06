//
//  LSTablePostViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/3/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTablePostViewController.h"
#import "LSAlbumsViewController.h"
#import "LSPostNewsModel.h"
#import "UIView+HUD.h"
#import "LSCaptureViewController.h"
#import "LSPostTimeLineModel.h"
#import "LSPlayerVideoView.h"


static NSString *const reuse_id = @"LSImageCell";

@interface LSTablePostViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewConstHeight;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, assign) CGFloat contentHeight;

@property (weak, nonatomic) IBOutlet UILabel *placeHolder;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;

@property (nonatomic, strong) NSMutableArray *imageList;

@property (nonatomic, assign) LSPostTimeLineType type;
@property (nonatomic, strong) LSCaptureModel *caputreModel;


@end

@implementation LSTablePostViewController

- (NSMutableArray *)imageList {

    if (!_imageList) {
        _imageList = [NSMutableArray array];
    }
    return _imageList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configCollectionView];
    [self installKVO_Noti];
    [self buildNaviBar];
}

- (void)buildNaviBar {
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = SYSTEMFONT(16);
    [cancelButton sizeToFit];
    
    @weakify(self)
    [[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    sendButton.titleLabel.font = SYSTEMFONT(16);
    [sendButton sizeToFit];
    
    [[sendButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        
        [self postNews];
    }];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)setPostType:(LSPostTimeLineType)type WithModel:(id)model{
    self.type = type;
    if (type == LSPostTimeLineTypeVideo) {
        
        self.caputreModel = model;
        
    }else if(type == LSPostTimeLineTypePhoto){
        
        [self.imageList addObject:model];
        
    }
    [self.collectionView reloadData];
}

//发布消息
-(void)postNews{
    
    [self.view endEditing:YES];
    if (self.type == LSPostTimeLineTypeVideo){
        
        if ([self.inputTextView.text isEqualToString:@""] && self.caputreModel == nil ) {
            [self.view showError:@"发送消息不能为空" hideAfterDelay:1];
            return;
        }
        [LSKeyWindow showLoading];
        [LSPostNewsModel postVideoLinkInWithFiles:self.caputreModel content:self.inputTextView.text id_value:self.types id_value_ext:self.sh_id feed_type:2 success:^{
            
            [self.view showSucceed:@"发布成功" hideAfterDelay:1];
            
            //发送通知刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:kLinkSchoolInfoNoti object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            [LSKeyWindow hideHUDAnimated:YES];
            
        } failure:^(NSError *error) {
            [LSKeyWindow hideHUDAnimated:YES];
            [self.view showError:@"发布失败" hideAfterDelay:1];
        }];
        
    }else if(self.type == LSPostTimeLineTypePhoto){
    
        if ([self.inputTextView.text isEqualToString:@""] && self.imageList.count<1 ) {
            [self.view showError:@"发送消息不能为空" hideAfterDelay:1];
            return;
        }
        [LSKeyWindow showLoading];
        [LSPostNewsModel postNewsLinkWithlistToken:ShareAppManager.loginUser.access_token files:self.imageList content:self.inputTextView.text id_value:self.types id_value_ext:self.sh_id feed_type:1 success:^{
            [self.view showSucceed:@"发布成功" hideAfterDelay:1];
            
            //发送通知刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:kLinkSchoolInfoNoti object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            [LSKeyWindow hideHUDAnimated:YES];
            
        } failure:^(NSError *error) {
            [LSKeyWindow hideHUDAnimated:YES];
            [self.view showError:@"发布失败" hideAfterDelay:1];
        }];
    }
}

- (void)configCollectionView {
    
    CGFloat margin = 10;
    CGFloat count = 5;
    CGFloat itemW = ((kScreenWidth-30)- (count-1) * margin) / 5;
    
    self.layout.itemSize = CGSizeMake(itemW, itemW);
    self.layout.minimumLineSpacing = margin;
    self.layout.minimumInteritemSpacing = margin;
    self.layout.sectionInset = UIEdgeInsetsZero;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[LSImageCell class] forCellWithReuseIdentifier:reuse_id];
    [self.view layoutIfNeeded];
}

- (void)installKVO_Noti {
    @weakify(self)
    [RACObserve(self.layout, collectionViewContentSize) subscribeNext:^(NSValue *value) {
        @strongify(self)
        [self updateEditViewHeight];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextViewTextDidChangeNotification object:nil] subscribeNext:^(NSNotification *noti) {
        @strongify(self)
        NSInteger length = self.inputTextView.text.length;
        self.placeHolder.hidden = (length != 0);
    }];
}

- (void)updateEditViewHeight {
    CGSize contentSize = self.layout.collectionViewContentSize;
    self.contentHeight = 105+contentSize.height;
    self.collectionViewConstHeight.constant = contentSize.height;
    
    [self.tableView reloadData];
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageList.count<9 ? self.imageList.count+1 : 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_id forIndexPath:indexPath];
    
    cell.deleteButton.hidden = NO;
    
    if (self.imageList.count<9 && self.type == LSPostTimeLineTypePhoto) {
        
        if (indexPath.row == self.imageList.count) {
            cell.imageView.image = [UIImage imageNamed:@"timeline_add_photos"];
            cell.deleteButton.hidden = YES;
        }
        else {
            UIImage *image = self.imageList[indexPath.row];
            cell.imageView.image = image;
            cell.deleteButton.tag = indexPath.row;
        }
    }else if(self.type == LSPostTimeLineTypeVideo){
        cell.imageView.image = [self.caputreModel localThumImage];
        cell.deleteButton.hidden = YES;
    }
    else {
        UIImage *image = self.imageList[indexPath.row];
        cell.imageView.image = image;
        cell.deleteButton.tag = indexPath.row;
    }
    
    [cell.deleteButton addTarget:self action:@selector(cellDeleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)cellDeleteButtonAction:(UIButton *)button {
    [self.imageList removeObjectAtIndex:button.tag];
    [self.collectionView reloadData];
    [self updateEditViewHeight];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.imageList.count<9&&indexPath.row == self.imageList.count&& self.type == LSPostTimeLineTypePhoto) {
        @weakify(self)
        [LSAlbumsViewController presentImageSelected:self maxImageCount:(9-self.imageList.count) didSelectAction:^(LSAlbumsViewController *vc, NSArray *images) {
            @strongify(self)
            [vc dismissViewControllerAnimated:YES completion:^{
                [self.imageList addObjectsFromArray:images];
                [self.collectionView reloadData];
                [self updateEditViewHeight];
            }];
        }];
    }else if(self.type == LSPostTimeLineTypeVideo){
        
        LSImageCell * cell = (LSImageCell *)[collectionView cellForItemAtIndexPath: indexPath];
        NSURL * url = [self.caputreModel localVideoFileURL];
        UIImage * thumImage= [self.caputreModel localThumImage];
        [LSPlayerVideoView showFromView:cell withCoverImage:thumImage playURL:url];
    }
}

#pragma mark - TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return self.contentHeight;
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) return 0.1;
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

@end

@implementation LSImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        self.imageView = imageView;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setImage:[UIImage imageNamed:@"timeline_deleteimage"] forState:UIControlStateNormal];
        self.deleteButton = deleteButton;
        deleteButton.backgroundColor = [UIColor blackColor];
        [self addSubview:deleteButton];
        [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.equalTo(self);
            make.width.height.offset(15);
        }];
    }
    return self;
}

@end
