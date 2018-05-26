//
//  MyModel.h
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyModel : NSObject

@property (nonatomic,assign) NSInteger id;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *coverSmall;
@property (nonatomic,copy)NSString *coverLarge;
@property (nonatomic,copy)NSString *size;

-(void)setValue:(id)value forUndefinedKey:(NSString *)key;

@end
