//
//  LSFuwaSimilarity.h
//  LittleSix
//
//  Created by GMAR on 2017/6/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef double Similarity;

@interface LSFuwaSimilarity : NSObject

+ (Similarity)getSimilarityValueWithObtainPic:(UIImage*)imga interceptionPic:(UIImage*)imgb;

@end
