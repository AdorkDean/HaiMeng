//
//  LSEmotionsShopViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSEmotionPackage,LSPackageSearchModel;
@interface LSEmotionsShopViewController : UIViewController

@end

@interface LSEmotionShopCell : UITableViewCell

@property (nonatomic,strong) LSEmotionPackage *package;

@property (nonatomic,strong) LSPackageSearchModel *searchModel;
@property (nonatomic,copy) NSString *keyword;

@property (nonatomic,strong) NSURLSessionDownloadTask *task;

@end

@interface LSEmotionShopSearchResultViewContorller : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,copy) NSString *keyword;

@property (nonatomic,copy) NSArray *dataSource;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,copy) void(^itemClickBlock)(LSEmotionShopSearchResultViewContorller *serchVC,NSString *group_id);

@end
