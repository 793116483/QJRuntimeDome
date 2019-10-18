//
//  NSObject+QJExtension.h
//  RuntimeDome
//
//  Created by 瞿杰 on 2019/10/18.
//  Copyright © 2019 yiniu. All rights reserved.
//  字典转模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (QJExtension)
// 字典转模型
+(instancetype)qj_modeWithDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
