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
        NSLog(@"协方 name = %@",protocolName);
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
}


-(void)useInCoding
{
    QJCoderEntity * entity = [[QJCoderEntity alloc] init];
    entity.name = @"dsfdd";
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
