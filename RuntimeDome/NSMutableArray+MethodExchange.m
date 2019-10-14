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

#pragma makr - 动态交换方法
+(void)load
{
    [super load];
    
    // Class 的相关是用 objc 开头
    // 方法代码块 交换：只是一个方法功能，所以用 method 开头
    // Method 类或对象方法 是通过类的isa指针找，所以用 class_开头
    // NSMutableArray 实际上是 __NSArrayM 类型
    Method method1 = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(qj_addObject:));
    Method method2 = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(addObject:));
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

#pragma mark - 动态添加方法
// 什么时候调用：当调用 当前类未实现的方法 时调用下面方法
// 下面方法作用：当系统查看到没有 sel类方法时，使用 runtime 动态添加与实现该方法
+(BOOL)resolveInstanceMethod:(SEL)sel
{
    // 创建 +test:
    if (sel == NSSelectorFromString(@"test:")) {
        // cls 参数: 类形[Class]
        // name参数: 方法名[sel(SEL)]
        // imp 参数: 函数实现入口 [(IMP)test],test 是函数 void test(id self,SEL _cmd)
        // types参数: 是字符串 每个字符及位置对应的描述了函数需要传的参数类型，test函数的第二个和第三个参数类型必须用 “@:”
        //          比如 "v@:" 表示：v(表示void类型，字符所在位置0就是返回值类型) ,
                                // @(表示id类型，函数第1个传参位置的类型是 id类型)；
                                // :(表示SEL类型，函数第二个参数位置的类型是 SEL方法类型 ),
                    // 可以对照每一个传的字符代表的参数类型
        // 下面的方法是用于 sel 与 test函数 邦定
        class_addMethod(self, sel, (IMP)test, "v@:@");
        
        return YES ;
    }
    return [super resolveClassMethod:sel];
}

// 函数实现(定义参数内必须包含下面两个参数，是系统自动传的)
// self 参数: 系统自动传,代码当前类
// _cmd 参数: 当前方法编号,系统自动传的
// number参数：自己定义的，从外面传的
void test(id self , SEL _cmd , NSNumber * number)
{
    NSLog(@"动态调用了test方法,number = %@",number);
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
