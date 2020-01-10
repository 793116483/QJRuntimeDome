//
//  ViewController.m
//  RuntimeDome
//
//  Created by 瞿杰 on 2017/6/27.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import "ViewController.h"

#import "QJCoderEntity.h"
#import "NSMutableArray+MethodExchange.h"

#import <objc/message.h>
#import "QJTestMode.h"
#import "NSObject+QJExtension.h"

@interface ViewController ()<UITableViewDelegate>

@property (nonatomic , strong)UIView * contentView ;

@end

@implementation ViewController

+(void)load
{
    [super load];
    
    /** 使用 runtime 获取类对象的 属性、成员、方法 和 遵守的协议 */
    unsigned int count = 0 ;
    
    // 获取属性列表，如 key = contentView
    objc_property_t * propertyArr =  class_copyPropertyList([self class], &count);
    for (int index = 0; index < count; index++) {
        objc_property_t pt = propertyArr[index];
        NSString * key = [NSString stringWithUTF8String:property_getName(pt)];
        NSLog(@"属性 key = %@",key);
    }
    free(propertyArr);
    
    // 获取成员变量列表，如 key = _contentView
    Ivar * ivars = class_copyIvarList([self class], &count);
    for (int index = 0; index < count; index++) {
        Ivar ivar = ivars[index];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSLog(@"成员 key = %@",key);
    }
    ivars = class_copyIvarList(class_getSuperclass([self class]), &count);
    for (int index = 0; index < count; index++) {
        Ivar ivar = ivars[index];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSLog(@"父类成员 key = %@",key);
    }
    free(ivars);
    
    // 获取对象方法列表
    Method * methods = class_copyMethodList([self class], &count);
    for (int index = 0; index < count; index++) {
        Method method = methods[index];
        NSString * methodName = NSStringFromSelector(method_getName(method));
        NSLog(@"方法 name = %@",methodName);
    }
    free(methods);
    
    IMP imp = method_getImplementation(class_getInstanceMethod([self class], @selector(viewWillAppear:)));
    
    // 获取协议列表，如 protocolName = UITableViewDelegate
    __unsafe_unretained Protocol ** protocols = class_copyProtocolList([self class], &count);
    for (int index = 0; index < count; index++) {
        Protocol * protocol = protocols[index];
        NSString * protocolName = [NSString stringWithUTF8String:protocol_getName(protocol)];
        NSLog(@"协义 name = %@",protocolName);
    }
    free(protocols);
    
    NSLog(@"\n");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // [[UIView alloc] initWithFrame:CGRectZero];
    // runtime 方法调用本质：就是用 objc_msgSend(id ,SEL); 发送消息
    // 发送一个消息，id(传self)指定谁发送消息 ，SEL: 被发送的消息
    // objc_getClass("UIView") 可以用 [UIView class] 代替
    UIView * objc = objc_msgSend(objc_getClass("UIView"), sel_registerName("alloc"));
    objc = objc_msgSend(objc, @selector(initWithFrame:),CGRectZero);
    
    [self useInCoding];
    
    [self useInMethodExchangeAndConnected];
    
//    CFRunLoopTimerRef timer = CFRunLoopTimerCreateWithHandler(CFAllocatorGetDefault(), CFAbsoluteTimeGetCurrent(), 1.0, 10, 5, ^(CFRunLoopTimerRef timer) {
//        NSLog(@"时间 = %@",timer);
//    }) ;
//    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes);
    // 调用 NSMutableArray 对象 未实现的方法 test: ,动态创建一个函数与之关联
    objc_msgSend([[NSMutableArray alloc] init], @selector(test:),@10);
    
    
    // 字典转模型测试
    NSDictionary * dic = @{
        @"isVip":@1,
        @"count":@20,
        @"name" : @"我的商品",
        @"value": [NSValue valueWithCGSize:CGSizeMake(100, 100)],
        @"error": @{@"msg":@"成功"},
        @"message":@[@"纟有要求d",@"32领导撒酒疯"],
        @"user" : @{
                @"name":@"qj",
                @"age":@"20",
                @"dog":@{
                        @"name":@"小黄",
                        @"age":@10
                }
        }
    };
    QJTestMode * mode = [QJTestMode qj_modeWithDic:dic];
    
    NSArray * array = @[[dic copy],[dic copy],[dic copy]];
    NSArray * modeArray = [QJTestMode modelArrayWithDicArray:array];
    
    [self isa_metaClass_And_super_class];
    
}

/// objc_class 中: isa 、元类 和 super_class 关系
-(void)isa_metaClass_And_super_class {
    //objc_class 中: isa 、元类 和 super_class 关系 https://upload-images.jianshu.io/upload_images/4349969-24a6392d9a2a1d2c.png?imageMogr2/auto-orient/strip|imageView2/2/w/807
    /**
         Class object_getClass(id _Nullable obj) {
     
            return objc->isa ;
     
            // 伟代码 ： 经编译的时候 isa 就已经赋值了
            if ( objc 是对象 ) {
                return objc->isa ;
            } else if (objc 不是元类) {
                return objc->isa ; // isa 指向的是自身元类
            } else if (objc 不是 NSObject基元类) {
                return objc->isa ;  // isa 指向的是元类
            } else {
                return objc ;  // isa 指向的是元类
            }
         }
     */
    // 1. isa 指向的是元类 ， 元类的isa 指向 基元类
    Class cls = object_getClass(self);              // ViewController(0x10abea590)  非元类
    Class metaClass1 = object_getClass(cls);        // ViewController(0x10abea568)  元类
    Class metaClass2 = object_getClass(metaClass1); // NSObject(0x7fff89cc4558)     基元类
    Class metaClass3 = object_getClass(metaClass2); // NSObject(0x7fff89cc4558)     基元类
    Class metaClass4 = object_getClass(metaClass3); // NSObject(0x7fff89cc4558)     基元类
    Class metaClass5 = object_getClass(metaClass4); // NSObject(0x7fff89cc4558)     基元类
    NSLog(@"对象及类的isa ：%@(%p) -> %@(%p) -> %@(%p) -> %@(%p) -> %@(%p) -> %@(%p) ->",cls,cls, metaClass1, metaClass1, metaClass2, metaClass2, metaClass3, metaClass3, metaClass4, metaClass4, metaClass5, metaClass5 );

    BOOL isMetaClass = class_isMetaClass(cls);          // NO
    BOOL isMetaClass1 = class_isMetaClass(metaClass1);  // YES
    BOOL isMetaClass2 = class_isMetaClass(metaClass2);  // YES
    BOOL isMetaClass3 = class_isMetaClass(metaClass3);  // YES
    BOOL isMetaClass4 = class_isMetaClass(metaClass4);  // YES
    BOOL isMetaClass5 = class_isMetaClass(metaClass5);  // YES

    
    // 2. super_class 继承链,最终为 Nil
    /**
        class_getSuperclass(Class cls) {
            return cls->super_class ;
        }
     */
    Class cls_ = [ViewController class];                    // ViewController(0x10abea590)
    Class metaClass1_ = class_getSuperclass(cls_);          // UIViewController(0x7fff8976fd38)
    Class metaClass2_ = class_getSuperclass(metaClass1_);   // UIResponder(0x7fff8978c348)
    Class metaClass3_ = class_getSuperclass(metaClass2_);   // NSObject(0x7fff89cc4580)
    Class metaClass4_ = class_getSuperclass(metaClass3_);   // (null)(0x0)
    Class metaClass5_ = class_getSuperclass(metaClass4_);   // (null)(0x0)
    NSLog(@"类的superclass ：%@(%p) -> %@(%p) -> %@(%p) -> %@(%p) -> %@(%p) -> %@(%p) ->",cls_,cls_ , metaClass1_, metaClass1_, metaClass2_, metaClass2_, metaClass3_, metaClass3_, metaClass4_, metaClass4_, metaClass5_, metaClass5_ );

    BOOL isMetaClass_ = class_isMetaClass(cls_);            // NO
    BOOL isMetaClass1_ = class_isMetaClass(metaClass1_);    // NO
    BOOL isMetaClass2_ = class_isMetaClass(metaClass2_);    // NO
    BOOL isMetaClass3_ = class_isMetaClass(metaClass3_);    // NO
    BOOL isMetaClass4_ = class_isMetaClass(metaClass4_);    // NO
    BOOL isMetaClass5_ = class_isMetaClass(metaClass5_);    // NO
}

/// 归档 与 解档
-(void)useInCoding
{
    QJCoderEntity * entity = [[QJCoderEntity alloc] init];
    entity.name = @"dsfdd";
    entity.pro2 = 10.0 ;
    [entity save];
    entity = nil ;
    entity = [QJCoderEntity coderEntity];
    
    
    NSLog(@"\n");
}


-(void)useInMethodExchangeAndConnected
{
    NSMutableArray * mArray = [NSMutableArray array];
    
    [mArray addObject:@"data 1"];
    [mArray addObject:@"data 2"];
    // 这样添加进去不会崩溃,
    // 就是因为在分类 MethodExchange 中对于方法 -addObject: 与自定义方法 -qj_addObject: 进行方法交换，并在 -qj_addObject: 中对空数据做了处理
    [mArray addObject:nil];
    
    mArray.ids = @"8888888";
    
    NSLog(@"可变数组 = %@ , ids = %@",mArray,mArray.ids);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
