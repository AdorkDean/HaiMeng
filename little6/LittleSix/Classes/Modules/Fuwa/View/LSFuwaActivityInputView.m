//
//  LSFuwaActivityInputView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/4/5.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaActivityInputView.h"
#import "LSPullDownListView.h"
#import "LSOptionsView.h"
#import "LSCaptureViewController.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "LFUITips.h"
#import "UIView+HUD.h"
#import "LSQueryClass.h"
@interface LSFuwaActivityInputView () <YYTextViewDelegate>

@property (weak, nonatomic) IBOutlet YYTextView *yyIntputView;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *fuwaDayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;

@property(nonatomic,strong)LSPullDownListView * listView;

@property (weak, nonatomic) IBOutlet UILabel *fuwaTypeLabel;

@property(nonatomic,strong)LSPullDownListView * typeView;

@property (nonatomic,strong) NSMutableArray<LSQueryClass *> *classes;

@end

@implementation LSFuwaActivityInputView


+ (instancetype)showInView:(UIView *)view hiddenType:(fuwaHiddenCountType)hiddenType doneAction:(void(^)(NSString *detailString,LSCaptureModel * model,NSString * day,NSString * fuwaType))doneblock skipAction:(void(^)(NSString *day))skipblock selectVideo:(void(^)(void))selectVideo recordVideo:(void(^)(void))recordVideo{
    LSFuwaActivityInputView *inputView = [[NSBundle mainBundle] loadNibNamed:@"LSFuwaComfirmView" owner:nil options:nil][4];
    inputView.hiddenType = hiddenType;
    [view addSubview:inputView];
    inputView.frame = view.bounds;
    
    inputView.doneBlock = doneblock;
    inputView.skipBlock = skipblock;
    inputView.selectVideoBlock = selectVideo;
    inputView.recordVideoBlock = recordVideo;
    
    return inputView;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    


    
    
    self.contentView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_obg"].CGImage);
    self.contentView.layer.contentMode = UIViewContentModeCenter;
    ViewRadius(self.contentView, 3);
    ViewBorderRadius(self.enterButton, 5, 1, HEXRGB(0xff0012));
    
    [self bringSubviewToFront:self.contentView];
    
    self.yyIntputView.font = SYSTEMFONT(15);
    self.yyIntputView.textColor = [UIColor whiteColor];
    self.yyIntputView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.yyIntputView.placeholderText = @"福娃活动详情介绍";
    self.yyIntputView.placeholderTextColor = HEXRGB(0xcccccc);
    
    self.yyIntputView.textContainerInset = UIEdgeInsetsMake(18, 4, 2, 4);
    
//    
    ViewRadius(self.yyIntputView, 3);
    
    self.yyIntputView.delegate = self;
    
    self.listView = [LSPullDownListView PullDownListView];
    [self addSubview:self.listView ];

    self.listView .dataSource = [self makeTimeClass];
    [self bringSubviewToFront:self.listView ];
    [self.listView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fuwaDayLabel);
        make.left.equalTo(self.fuwaDayLabel.mas_right).offset(5);
        make.right.equalTo(self.enterButton);
    }];
    
    self.typeView = [LSPullDownListView PullDownListView];
    [self addSubview:self.typeView];

    
    
    [self bringSubviewToFront:self.listView];
    [self.typeView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fuwaTypeLabel);
        make.left.equalTo(self.fuwaTypeLabel.mas_right).offset(5);
        make.right.equalTo(self.enterButton);
    }];
    
    [LSQueryClass queryClassWithSuccess:^(NSArray *list) {
        self.classes = [NSMutableArray arrayWithArray:list];
        self.typeView.dataSource = list;
    } failure:^(NSError *error) {
        [LSKeyWindow showError:@"获取分类失败" hideAfterDelay:0.5];
    }];

}

-(NSMutableArray*)makeTimeClass{
    NSMutableArray * classes = [NSMutableArray array];
    LSQueryClass * class1  = [LSQueryClass new];
    class1.name = @"72小时";
    class1.classid = @"1";
    [classes addObject:class1];
    
    LSQueryClass * class2  = [LSQueryClass new];
    class2.name = @"一个月";
    class2.classid = @"2";
    [classes addObject:class2];
    
    LSQueryClass * class3  = [LSQueryClass new];
    class3.name = @"一年";
    class3.classid = @"3";
    [classes addObject:class3];
    
    LSQueryClass * class4  = [LSQueryClass new];
    class4.name = @"三年";
    class4.classid = @"4";
    [classes addObject:class4];
    
    return classes;
    
}


-(void)setHiddenType:(fuwaHiddenCountType)hiddenType{
    _hiddenType = hiddenType;
    if (self.hiddenType == fuwaHiddenCountTypeMerChant) {
        self.typeView.hidden = NO;
        self.fuwaTypeLabel.hidden = NO;
    }else{
        self.typeView.hidden = YES;
        self.fuwaTypeLabel.hidden = YES;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (void)dismissAction {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}




#pragma mark - *** UITextView Delegate ***
- (void)textViewDidChange:(UITextView *)textView{
    
    self.accountLabel.text = [NSString stringWithFormat:@"%ld/200",(unsigned long)textView.text.length];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * searchStr =[NSString string];
    if (!(range.location == 0&& range.length == 1)) {
        if (range.length == 0)
            searchStr = [textView.text stringByAppendingString:text];
        else
            searchStr = [textView.text substringToIndex:[textView.text length]-1];
        
        if (searchStr.length>200)
        {
            [self showError:@"介绍字数超过200字" hideAfterDelay:1];
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

- (IBAction)doneAction:(id)sender {
    [self endEditing:YES];
    if ([self.listView.selelctIndex isEqualToString:@"0"]) {
        [self showError:@"请选择福娃期限" hideAfterDelay:1];
        return;
    }
    if (self.yyIntputView.text.length>200 ) {
        [self showError:@"介绍字数超过200字" hideAfterDelay:1];
        return;
    }
    
    if ([self.typeView.selelctIndex isEqualToString:@"0"]&& self.hiddenType == fuwaHiddenCountTypeMerChant) {
        [self showError:@"请选择福娃类型" hideAfterDelay:1];
        return;
    }
    
    !self.doneBlock ? : self.doneBlock(self.yyIntputView.text,self.model,self.listView.selelctIndex,self.typeView.selelctIndex);
    [self dismissAction];
}

- (IBAction)videoBtnAction:(UIButton *)sender {
    [self endEditing:YES];
    
    LSOptionsView * optionsView = [[LSOptionsView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.frame WithData:@[@"录视频",@"选视频"]];
    @weakify(self)
    
    [optionsView setSelectCellBlock:^(NSString *title){
        @strongify(self)
        if ([title isEqualToString:@"录视频"]){

            self.recordVideoBlock();
        }else if([title isEqualToString:@"选视频"]){
            self.selectVideoBlock();

        }
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:optionsView];
}

- (IBAction)BGBtnAction:(id)sender {
    [self removeFromSuperview];
}

-(void)setModel:(LSCaptureModel *)model{
    _model = model;

    kDISPATCH_MAIN_THREAD(^{
      [self.videoImageView setImage:[model localThumImage]];
        [self.videoBtn setImage:[UIImage imageNamed:@"record_play"] forState:UIControlStateNormal];
    });
}

@end
