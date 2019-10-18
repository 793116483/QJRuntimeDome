//
//  NSObject+QJExtension.m
//  RuntimeDome
//
//  Created by 瞿杰 on 2019/10/18.
//  Copyright © 2019 yiniu. All rights reserved.
//  字典转模型

#import "NSObject+QJExtension.h"

#import <objc/message.h>


@implementation NSObject (QJExtension)
+(instancetype)qj_modeWithDic:(NSDictionary *)dic
{
    NSObject * objc = [[self alloc] init];
    
    // 获取当前类的所有 成员变量 , 以 class开头
    int outCont ;
    Ivar * ivarList = class_copyIvarList(self, &outCont);
    for (int i = 0; i < outCont; i++) {
        // 获取某个 成员变量名 和 类型
        Ivar ivar = ivarList[i];
        
        // 获取成员变量名
        NSString * name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        // 去掉下划线
        if ([name hasPrefix:@"_"]) {
           name = [name substringFromIndex:1];
        }
        
        // name 对应的 value
        id value = [dic objectForKey:name];
        
        // 获取 属性的 类型
        NSString * className = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        className = [className stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        className = [className stringByReplacingOccurrencesOfString:@"@" withString:@""];
        Class class = NSClassFromString(className);
        
        // 属性是模型属性
        if (![class isKindOfClass:[NSDictionary class]] && [value isKindOfClass:[NSDictionary class]]) {
            value = [class qj_modeWithDic:value];
            NSLog(@"%@",className);
        }
        
        // 赋值
        [objc setValue:value forKey:name];
    }
    
    return objc;
}
@end
