//
//  NSObject+QJCoding.m
//  RuntimeDome
//
//  Created by 瞿杰 on 2020/1/10.
//  Copyright © 2020 yiniu. All rights reserved.
//

#import "NSObject+QJCoding.h"
#import <objc/message.h>

@implementation NSObject (QJCoding)

/// 解档
-(instancetype)initWithCoder:(NSCoder *)coder {
    
    [self initIvarWithCoder:coder currentClass:[self class]];
    
    return self ;
}

-(void)initIvarWithCoder:(NSCoder *)aDecoder currentClass:(Class)currentClass{
    if ([currentClass isEqual:[NSObject class]]) return ;
    
    unsigned int count = 0 ;
    Ivar * ivarList = class_copyIvarList(currentClass, &count);
    
    for (unsigned int i = 0 ; i < count; i++) {
        Ivar ivar = ivarList[i];
        
        NSString * name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        [self setValue:[aDecoder decodeObjectForKey:name] forKeyPath:name];
        NSLog(@"decoder ivar : key = %@ , value = %@ ",name,[self valueForKey:name]);
    }
    
    free(ivarList);
    
    [self initIvarWithCoder:aDecoder currentClass:class_getSuperclass(currentClass)];
}


// 归档
-(void)encodeWithCoder:(NSCoder *)coder {
    [self encodeWithCoder:coder currentClass:[self class]];
}

-(void)encodeWithCoder:(NSCoder *)coder currentClass:(Class)currentClass {
    if ([currentClass isEqual:[NSObject class]]) return ;

    unsigned int count = 0 ;
    Ivar * ivarList = class_copyIvarList(currentClass, &count);
    
    for (unsigned int i = 0 ; i < count; i++) {
        Ivar ivar = ivarList[i];
        
        NSString * name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        [coder encodeObject:[self valueForKey:name] forKey:name];
        NSLog(@"encode ivar : key = %@ , value = %@ ",name,[self valueForKey:name]);
    }
    
    free(ivarList);
    
    [self encodeWithCoder:coder currentClass:class_getSuperclass(currentClass)];
}

@end
