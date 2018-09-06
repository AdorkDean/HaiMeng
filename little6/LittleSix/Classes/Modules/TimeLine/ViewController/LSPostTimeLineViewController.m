//
//  LSPostTimeLineViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPostTimeLineViewController.h"
#import "LSAlbumsViewController.h"
#import "LSPostTimeLineModel.h"
#import "LSTLSelectContactViewController.h"
#import "LSPermissionViewController.h"
#import "LSPermissionModel.h"
#import "LSFriendModel.h"
#import "LSCaptureViewController.h"
#import "LSPlayerVideoView.h"
#import "UIView+HUD.h"
#import "TZImageManager.h"
#import "TZImagePickerController.h"
#import "LFUITips.h"
#import "IQKeyboardManager.h"

static NSString *const reuse_id = @"LSShowImageCell";

@interface LSPostTimeLineViewController () <UICollectionViewDelegate,UICollectionViewDataSource,LSPermissionVCDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewConstHeight;

@property (nonatomic,strong) NSArray *dataSource;

@property (nonatomic,assign) CGFloat contentHeight;

@property (weak, nonatomic) IBOutlet UILabel *placeHolder;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UILabel *TextNumLabel;

@property (nonatomic,strong) NSMutableArray *imageList;

@property (weak, nonatomic) IBOutlet UILabel *whoCanSeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remindLabel;

@property (nonatomic,strong) NSMutableArray *permissionArr;
@property (nonatomic,strong) NSArray * remindArr;
@property (nonatomic,assign) SelectContactViewType permissionType;
@property (nonatomic,assign) LSPostTimeLineType type;
@property (nonatomic,strong) LSCaptureModel *caputreModel;
@property (nonatomic,copy) NSString * nowProgressStr;

@end

@implementation LSPostTimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configCollectionView];
    [self installKVO_Noti];
    [self buildNaviBar];
    self.inputTextView.delegate =self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)buildNaviBar {
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = SYSTEMFONT(16);
    [cancelButton sizeToFit];
    
    @weakify(self)
    [[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    sendButton.titleLabel.font = SYSTEMFONT(16);
    [sendButton sizeToFit];
    [[sendButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self sendBtnClick];
    }];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)setPostType:(LSPostTimeLineType)type WithModel:(id)model{
    self.type = type;
    if (type == LSPostTimeLineTypeVideo) {
        
        self.caputreModel = model;
        
    }else{
        [self.imageList addObject:model];
        [self.collectionView reloadData];
        
        
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
    self.collectionView.scrollEnabled = NO;
    
    [self.collectionView registerClass:[LSShowImageCell class] forCellWithReuseIdentifier:reuse_id];
    
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


#pragma mark -action

-(void)sendBtnClick{
    
    NSString * permissionStr  = [NSString string];
    NSMutableArray * permissionStrArr = [NSMutableArray array];
    switch (self.permissionType) {
        case SelectContactViewTypeAll:
            permissionStr = @"all";
            
            break;
            
        case SelectContactViewTypeOnlyMe:
            permissionStr = @"myself";

            break;
        case SelectContactViewTypeCanSee:case SelectContactViewTypeNoSee:
            for (LSPermissionSubModel * subModel in self.permissionArr) {
                
                for (LSFriendModel * freindModel in subModel.friendList) {
                    if (![permissionStrArr containsObject:freindModel.friend_id]) {
                        [permissionStrArr addObject:freindModel.friend_id];
                    }
                }
            }
            permissionStr = [permissionStrArr componentsJoinedByString:@","];
            
            break;
        default:
            break;
    }
    NSString * remindIdStr = [NSString string];
    NSMutableArray * remindStrArr = [NSMutableArray array];
    for (LSFriendModel * friendModel in self.remindArr) {
        [remindStrArr addObject:friendModel.friend_id];
    }
    remindIdStr = [remindStrArr componentsJoinedByString:@","];
    
    
    if (self.inputTextView.text.length<1 && (self.imageList.count<1 || self.caputreModel == nil)) {
        [self.view showError:@"发送消息不能为空" hideAfterDelay:1];
        return;
    }else if(self.inputTextView.text.length>2000){
        [self.view showError:@"朋友圈文字不能超过2000字" hideAfterDelay:1];
        return;

    }
    [self.view endEditing:YES];
    [LSKeyWindow showLoading];
    if (self.type == LSPostTimeLineTypePhoto) {

        [LSPostTimeLineModel postTimeLineWithContent:self.inputTextView.text files:self.imageList whoSeeType:self.permissionType whoSeeExt:permissionStr position:nil remindUser:remindIdStr success:^(LSPostTimeLineModel *model) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kreloadTimeLineNoti object:nil];
            [LSKeyWindow showSucceed:@"发布成功" hideAfterDelay:1];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [LSKeyWindow showError:@"发布失败" hideAfterDelay:1];

        }];
    }else if (self.type == LSPostTimeLineTypeVideo){
        self.nowProgressStr =[NSString stringWithFormat:@"%.2f%%",0.00];
        [LSKeyWindow hideHUDAnimated:YES];
        LFUITips *tips = [LFUITips showLoading:@"正在上传...." inView:LSKeyWindow];
        [LSKeyWindow addSubview:tips];

        [LSPostTimeLineModel postVideoTimeLineWithContent:self.inputTextView.text videoModel:self.caputreModel whoSeeType:self.permissionType whoSeeExt:permissionStr position:nil remindUser:remindIdStr Progress:^(NSProgress *Progress) {
            
            
            self.nowProgressStr = [NSString stringWithFormat:@"%.2f%%",(CGFloat)Progress.completedUnitCount/Progress.totalUnitCount*100.00];
            NSLog(@"%@",self.nowProgressStr);
            kDISPATCH_MAIN_THREAD(^{
                tips.detailsLabel.text = self.nowProgressStr;
            });
            
        } success:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:kreloadTimeLineNoti object:nil];
            [tips showSucceed:@"发布成功" hideAfterDelay:1];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError *error) {
            [tips showError:@"发布失败" hideAfterDelay:1];

        }];

         
    }

    
}

#pragma mark - *** UITextView Delegate ***
- (void)textViewDidChange:(UITextView *)textView{
    
    self.TextNumLabel.text = [NSString stringWithFormat:@"%lu/2000",(unsigned long)textView.text.length];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * searchStr =[NSString string];
    if (!(range.location == 0&& range.length == 1)) {
        if (range.length == 0)
            searchStr = [textView.text stringByAppendingString:text];
        else
            searchStr = [textView.text substringToIndex:[textView.text length]-1];
        
        if (searchStr.length>2000)
        {
            [self.view showError:@"朋友圈文字不能超过2000字" hideAfterDelay:1];
            return NO;
        }
        else
        {
            return YES;
        }
    }else{
        return YES;
    }
    
}


#pragma mark permissonDelegate
-(void)ViewController:(LSPermissionViewController *)VC selectDoneWithType:(SelectContactViewType)type LabelArr:(NSArray *)LabelArr otherArr:(NSArray *)otherArr{
    NSString * totalStr  = [NSString string];
    NSMutableArray * totalNameArr = [NSMutableArray array];
    self.permissionArr = [NSMutableArray array];
    self.permissionType = type;
    switch (type) {
        case SelectContactViewTypeAll:
            self.whoCanSeeLabel.text = @"全部";
            break;
        case SelectContactViewTypeOnlyMe:
            self.whoCanSeeLabel.text = @"私密";
            
            break;
        case SelectContactViewTypeCanSee:
            [self.permissionArr addObjectsFromArray:LabelArr];
            totalStr = @"只对";
            for (LSPermissionSubModel * subModel in LabelArr) {
                [totalNameArr addObject:subModel.title];
            }
            
            if (otherArr.count>0){
                [totalNameArr addObject:@"其他联系人"];
                LSPermissionSubModel * subModel = [LSPermissionSubModel new];
                subModel.friendList =[NSMutableArray arrayWithArray:otherArr];
                [self.permissionArr addObject:subModel];
            }
            
            totalStr = [totalStr stringByAppendingString:[totalNameArr componentsJoinedByString:@","]];
            totalStr = [totalStr stringByAppendingString:@"可见"];
            self.whoCanSeeLabel.text = totalStr;
            
            break;
        case SelectContactViewTypeNoSee:
            [self.permissionArr addObject:LabelArr];
            
            totalStr = @"不给";
            for (LSPermissionSubModel * subModel in LabelArr) {
                [totalNameArr addObject:subModel.title];
            }
            
            if (otherArr.count>0){
                [totalNameArr addObject:@"其他联系人"];
                LSPermissionSubModel * subModel = [LSPermissionSubModel new];
                subModel.friendList =[NSMutableArray arrayWithArray:otherArr];
                [self.permissionArr addObject:subModel];
            }
            
            totalStr = [totalStr stringByAppendingString:[totalNameArr componentsJoinedByString:@","]];
            totalStr = [totalStr stringByAppendingString:@"看"];
            self.whoCanSeeLabel.text = totalStr;
            break;
            
        default:
            break;
    }
    
}

-(NSMutableArray *)imageList{
    if (_imageList == nil) {
        _imageList = [NSMutableArray array];
    }
    return _imageList;
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageList.count<9 ? self.imageList.count+1 : 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSShowImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuse_id forIndexPath:indexPath];
    
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
    }else {
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    if (self.imageList.count<9&&indexPath.row == self.imageList.count && self.type == LSPostTimeLineTypePhoto) {
        @weakify(self)

        
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:(9-self.imageList.count) columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
        imagePickerVc.isSelectOriginalPhoto = YES;
        imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
        imagePickerVc.allowPickingVideo = YES;
        imagePickerVc.allowPickingImage = YES;
        imagePickerVc.allowPickingOriginalPhoto = YES;
        imagePickerVc.allowPickingGif = NO;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            @strongify(self)
            
            for (PHAsset *asset in assets) {
                //获取原图
                [[TZImageManager manager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                    if(photo)  [self.imageList addObject:photo];
                    [self.collectionView reloadData];
                    [self updateEditViewHeight];
                }];
            }

        }];
    

        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }else if(self.type == LSPostTimeLineTypeVideo){
        
        LSShowImageCell * cell = (LSShowImageCell *)[collectionView cellForItemAtIndexPath: indexPath];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //谁可以看
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        LSPermissionViewController * vc = [LSPermissionViewController new];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        
    }//提醒谁看
    else if (indexPath.section == 1 && indexPath.row == 1) {
        
        LSTLSelectContactViewController *vc =[LSTLSelectContactViewController new];
        vc.type = SelectContactViewTypeRemind;
        self.remindArr = [NSArray array];
        __weak typeof(LSPostTimeLineViewController) *weakself = self;

        [vc setRemindListBlock:^(NSArray*remindArr){
            weakself.remindArr = remindArr;
            NSString * remindListStr = [NSString string];
            NSMutableArray * remindListArr = [NSMutableArray array];
            for (LSFriendModel * friendModel in remindArr) {
                [remindListArr addObject:friendModel.user_name];
            }
            
            remindListStr = [remindListArr componentsJoinedByString:@","];
            self.remindLabel.text = remindListStr;
        }];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
        
        [self presentViewController:naviVC animated:YES completion:nil];
    }
}


@end

@implementation LSShowImageCell

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
