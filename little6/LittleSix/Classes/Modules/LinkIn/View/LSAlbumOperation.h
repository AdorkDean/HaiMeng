//
//  LSAlbumOperation.h
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AlbumOperationType) {
    XHAlbumOperationTypeReply = 1,
    XHAlbumOperationTypeLike = 0,
};

typedef void(^DidSelectedOperationBlock)(AlbumOperationType operationType,UIButton * sender);


@interface LSAlbumOperation : UIView

@property (nonatomic, assign) BOOL shouldShowed;

@property (nonatomic, copy) DidSelectedOperationBlock didSelectedOperationCompletion;

+ (instancetype)initailzerAlbumOperationView;

- (void)showAtView:(UIView *)containerView rect:(CGRect)targetRect andIs_praise:(int)is_praise;

- (void)dismiss;

@end
