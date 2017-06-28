//
//  QJCoderEntity.h
//  RuntimeDome
//
//  Created by 瞿杰 on 2017/6/27.
//  Copyright © 2017年 yiniu. All rights reserved.
//  runtime 用于归档功能

#import <Foundation/Foundation.h>

@interface QJCoderEntity : NSObject<NSCoding>

@property (nonatomic , assign)NSInteger age ;
@property (nonatomic , copy) NSString * name ;
@property (nonatomic , copy) NSString * clid;
@property (nonatomic , assign) BOOL pro1;
@property (nonatomic , assign) double pro2;
@property (nonatomic , assign) int pro3;
@property (nonatomic , assign) float pro4;
@property (nonatomic , strong) NSData * pro5;
@property (nonatomic , assign) int32_t pro6;
@property (nonatomic , assign) int64_t pro7;

-(void)save;
+(instancetype)coderEntity;

@end
