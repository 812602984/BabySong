//  PlayModel.m
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "PlayModel.h"

@implementation PlayModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"mediumLogo"]) {
        self.cover = self.coverSmall = self.coverLarge = value;
    }
    if ([key isEqualToString:@"nickname"]) {
        self.title = value;
    }
    if ([key isEqualToString:@"uid"]) {
        self.id = [value integerValue];
    }
}

@end
