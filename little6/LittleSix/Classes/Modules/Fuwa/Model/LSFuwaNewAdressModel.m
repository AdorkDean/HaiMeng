//
//  LSNewAdressModel.m
//  LittleSix
//
//  Created by Jim huang on 17/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaNewAdressModel.h"

@implementation LSFuwaNewAdressModel

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.city forKey:@"city"];
    [coder encodeObject:self.district forKey:@"district"];
    [coder encodeObject:self.adress forKey:@"adress"];
    [coder encodeObject:self.totalAdress forKey:@"totalAdress"];


}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        
        self.name = [coder decodeObjectForKey:@"name"];
        self.city = [coder decodeObjectForKey:@"city"];
        self.district = [coder decodeObjectForKey:@"district"];
        self.adress = [coder decodeObjectForKey:@"adress"];
        self.totalAdress = [coder decodeObjectForKey:@"totalAdress"];
    


    }
    return self;
}


@end
