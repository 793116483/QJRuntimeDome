//
//  NSObject+QJExtension.h
//  RuntimeDome
//
//  Created by 瞿杰 on 2019/10/18.
//  Copyright © 2019 yiniu. All rights reserved.
//  字典转模型 or 字典数组转模型数组

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ModelArray <NSObject>

@optional
/// 当前类对象的 成员变量的类型 是 字典数组类型， 想要把字典数组 转成 模型数组时 重定该方法
+(NSDictionary<NSString * , Class> *)dicForIvarModelArray ;

@end

@interface NSObject (QJExtension)<ModelArray>
/// 字典转模型
+(instancetype)qj_modeWithDic:(NSDictionary *)dic;

/// 字典数组转成 模型数组
+(NSArray *)modelArrayWithDicArray:(NSArray *)array ;

@end

NS_ASSUME_NONNULL_END
