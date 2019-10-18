//
//  QJTestMode.h
//  RuntimeDome
//
//  Created by 瞿杰 on 2019/10/18.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJTestDogMode : NSObject

@property (nonatomic , copy) NSString * name ;
@property (nonatomic , assign) NSInteger age ;

@end


@interface QJTestUserMode : NSObject

@property (nonatomic , copy) NSString * name ;
@property (nonatomic , assign) NSInteger age ;

@property (nonatomic , strong) QJTestDogMode * dog ;

@end

@interface QJTestMode : NSObject

@property (nonatomic , assign)BOOL isVip ;
@property (nonatomic , assign) NSInteger count ;

@property (nonatomic , copy) NSString * name ;
@property (nonatomic , strong) NSValue * value ;

@property (nonatomic , strong) NSDictionary * error ;
@property (nonatomic , strong) NSMutableArray * message ;
@property (nonatomic , strong) QJTestUserMode * user ;

@end

NS_ASSUME_NONNULL_END
