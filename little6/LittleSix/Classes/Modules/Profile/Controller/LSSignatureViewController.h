//
//  LSsignatureViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^changeSignatureBlock)(NSString*);

@interface LSSignatureViewController : UITableViewController


@property (nonatomic ,copy) changeSignatureBlock SignatureBlock;

@end
