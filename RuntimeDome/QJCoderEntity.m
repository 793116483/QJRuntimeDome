//
//  QJCoderEntity.m
//  RuntimeDome
//
//  Created by 瞿杰 on 2017/6/27.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import "QJCoderEntity.h"

@implementation QJCoderEntity

+(NSString *)filePath
{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"coderEntity.QJ"] ;
}

-(void)save
{
    [NSKeyedArchiver archiveRootObject:self toFile:[QJCoderEntity filePath]];
}
+(instancetype)coderEntity
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]];
}

@end
