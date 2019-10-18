//
//  QJCoderEntity.m
//  RuntimeDome
//
//  Created by 瞿杰 on 2017/6/27.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import "QJCoderEntity.h"

#import <objc/message.h>

@implementation QJCoderEntity

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    unsigned int count = 0 ;
    objc_property_t * propertys = class_copyPropertyList([QJCoderEntity class], &count);
    for (unsigned int index = 0; index < count; index++) {
        objc_property_t property_t = propertys[index];
        NSString * key = [NSString stringWithUTF8String:property_getName(property_t)];
//        NSString * attributesName = [NSString stringWithUTF8String:property_getAttributes(property_t)];
        
        NSLog(@"decoder property : key = %@ ",key);
        [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
    }
    
    free(propertys);
    
    return self ;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int count = 0 ;
    objc_property_t * propertys =class_copyPropertyList([QJCoderEntity class], &count);
    for (int index = 0; index < count; index++) {
        objc_property_t property_t = propertys[index];
        NSString * key = [NSString stringWithUTF8String:property_getName(property_t)];
        
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
        NSLog(@"encode property : key = %@ , value = %@ ",key,[self valueForKey:key]);
    }
    free(propertys);
}


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
