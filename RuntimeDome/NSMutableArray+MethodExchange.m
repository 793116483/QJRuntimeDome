//
//  NSMutableArray+MethodExchange.m
//  RuntimeDome
//
//  Created by 瞿杰 on 2017/6/27.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import "NSMutableArray+MethodExchange.h"

#import <objc/runtime.h>

@implementation NSMutableArray (MethodExchange)

+(void)load
{
    [super load];
    
    // Class 的相关是用 objc 开头
    // 方法代码块 交换：只是一个方法功能，所以用 method 开头
    // Method 类或对象方法 是通过类的isa指针找，所以用 class_开头
    Method method1 = class_getInstanceMethod(self, @selector(qj_addObject:));
    Method method2 = class_getInstanceMethod(self, @selector(addObject:));
    // 只能交换一次，不然又会变成方法本身 ，所以放在 +load 方法实现交换(+load方法在app起动时只调一次)
    method_exchangeImplementations(method1, method2);
    
}

-(void)qj_addObject:(id)object
{
    if (object) {// 这样可以防止添加空数据
        // 通过上面的方法交换后，在使用 [self qj_addObject:] 等于调用了 [self addObjec:]
        // 反之如果调用 [self addObjec:] 就等于调用了 [self qj_addObject:]
        // 所以在这里不能调用 [self addObject:]，否则会造成死循环
        [self qj_addObject:object];
    }
}

#pragma mark - ids 属性 关联
static char NSMutableArrayIds = '\0' ;
-(void)setIds:(NSString *)ids
{
    [self willChangeValueForKey:@"ids"];
    objc_setAssociatedObject(self, &NSMutableArrayIds, ids, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"ids"];
}

-(NSString *)ids
{
    return objc_getAssociatedObject(self, &NSMutableArrayIds);
}

@end
