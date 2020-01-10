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
    if (dic == nil || [self isSubclassOfDicOrArrayClass]) {
        return dic ;
    }
    
    NSObject * mode = [[self alloc] init];
    [mode setIvarWithDic:dic currentClass:self];
    return mode;
}
-(void)setIvarWithDic:(NSDictionary *)dic currentClass:(Class)currentClass {
    if([currentClass isEqual:[NSObject class]]) return ;
    
    // 用于成员变量 字典数组 转成对应的 模型数组
    NSDictionary<NSString * , Class> * dicForIvarModel = nil ;
    if ([currentClass respondsToSelector:@selector(dicForIvarModelArray)]) {
        dicForIvarModel = [currentClass dicForIvarModelArray];
    }
    
    // 获取当前类的所有 成员变量 , 以 class开头
    unsigned int outCont ;
    Ivar * ivarList = class_copyIvarList([self class], &outCont);
    for (int i = 0; i < outCont; i++) {
        // 获取某个 成员变量名 和 类型
        Ivar ivar = ivarList[i];
        
        // 获取成员变量名
        NSString * name = [NSString stringWithUTF8String:ivar_getName(ivar)];
       
        // name 对应的 value
        id value = [dic objectForKey:name];
        if ([name hasPrefix:@"_"] && value == nil) {
            // 去掉下划线
            NSString * name_t = [name substringFromIndex:1];
            value = [dic objectForKey:name_t];
        }
        
        // 获取 属性的 类型
        NSString * className = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        className = [className stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        className = [className stringByReplacingOccurrencesOfString:@"@" withString:@""];
        Class class = NSClassFromString(className);
        
        // 属性是模型属性
        if ([value isKindOfClass:[NSDictionary class]]) {
            value = [class qj_modeWithDic:value];
            NSLog(@"%@",className);
        }
        
        // 字典数组 转 模型数组
        if (dicForIvarModel[name] && [value isKindOfClass:[NSArray class]]) {
            value = [dicForIvarModel[name] modelArrayWithDicArray:value];
        }
        
        // 赋值
        [self setValue:value forKey:name];
    }
    free(ivarList);
    
    // 设置继成父类的属性
    [self setIvarWithDic:dic currentClass:class_getSuperclass(currentClass)];
}

/// 字典数组转成 模型数组
+(NSArray *)modelArrayWithDicArray:(NSArray *)array  {
    
    if (array == nil || [self isSubclassOfDicOrArrayClass]) {
        return array ;
    }
    
     NSMutableArray * modeArr = [NSMutableArray array];
       
       for (NSDictionary * modeDic in array) {
           if ([modeDic isKindOfClass:[NSDictionary class]]) {
               [modeArr addObject:[self qj_modeWithDic:modeDic]];
           } else if ([modeDic isKindOfClass:[NSArray class]]) { // 是数组，则进一层再看
               [modeArr addObjectsFromArray:[self modelArrayWithDicArray:(NSArray *)modeDic]];
           } else { // 即不是字典，也不是数组
               [modeArr addObject:modeDic];
           }
       }
       
       return [modeArr copy];
}

+(BOOL)isSubclassOfDicOrArrayClass {
    if ([self isSubclassOfClass:[NSArray class]]) return YES ;
    if ([self isSubclassOfClass:[NSDictionary class]]) return YES ;

    return NO;
}

@end
