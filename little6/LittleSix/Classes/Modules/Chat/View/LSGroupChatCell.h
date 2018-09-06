//
//  LSGroupChatCell.h
//  LittleSix
//
//  Created by GMAR on 2017/3/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSMembersModel,LSPersonsModel;
@interface LSGroupChatCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (retain,nonatomic) LSMembersModel * model;

@property (copy,nonatomic) void (^delectClick)(NSString * members);

@property (retain,nonatomic) LSPersonsModel * personModel;

@end
