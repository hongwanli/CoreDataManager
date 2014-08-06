//
//  NSManagedObject+Convenient.m
//  CoreDataManager
//
//  Created by neolix on 14-8-6.
//  Copyright (c) 2014年 Neolix. All rights reserved.
//

#import "NSManagedObject+Convenient.h"
#import "CoreDataManager.h"
static dispatch_queue_t coreDataQueue;

extern NSManagedObjectContext *globalManagedObjectContext;
extern NSManagedObjectModel *globalManagedObjectModel;

@implementation NSManagedObject (Convenient)

//异步执行
+ (id)insertItem_asyncWithBlock:(void (^)(id))settingBlcok{
    id item = [self bulidManagedObjectByClass:[self class]];
    settingBlcok(item);
    [self asnycQueue:YES actions:^{
        [self save:^(BOOL success) {
            
        }];
    }];
    return item;
}

+ (void)items_asyncSortDescriptions:(NSArray *)sortDesccriptions withFormat:(NSString *)fmt complete:(void (^)(NSMutableArray *))completeBlcok{
    NSPredicate *pred = [NSPredicate predicateWithFormat:fmt];
    [self fetchItemsaSync:YES usingPredicate:pred usingSortDescription:sortDesccriptions complete:completeBlcok];
}

+ (void)fetchItemsaSync:(BOOL)async usingPredicate:(NSPredicate *)predicate usingSortDescription:(NSArray *)sortDescriptions complete:(void (^)(NSMutableArray *))completeBlcok{
    [self asnycQueue:async actions:^{
        NSMutableArray * items = [NSMutableArray arrayWithArray:[self fetchItemsUsingPredicate:predicate usingSortDescription:sortDescriptions]];
        [self setResult:items complete:completeBlcok];
    }];
}

+ (NSArray *)fetchItemsUsingPredicate:(NSPredicate *)predicate usingSortDescription:(NSArray *)sortDescriptions{
    NSArray * items = @[];
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription * description = [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:globalManagedObjectContext];
    [request setEntity:description];
    if (predicate) {
        [request setPredicate:predicate];
    }
    if (sortDescriptions && sortDescriptions.count) {
        [request setSortDescriptors:sortDescriptions];
    }
    @try {
        @synchronized(globalManagedObjectContext){
            items = [globalManagedObjectContext executeFetchRequest:request error:nil];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"查询数据库出错了-->%@",exception);
    }
    return items;
}

+ (void)setResult:(id)result complete:(void (^)(id obj))completeBlock
{
    if (completeBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(result);
        });
    }
}

//同步执行

+ (void)items_syncSortDescriptions:(NSArray *)sortDesccriptions withFormat:(NSString *)fmt complete:(void (^)(NSMutableArray * items))completeBlcok{
    NSPredicate *pred = [NSPredicate predicateWithFormat:fmt];
    [self fetchItemsaSync:NO usingPredicate:pred usingSortDescription:sortDesccriptions complete:completeBlcok];
}

+ (void)deleteObjects:(NSArray *)items{
    @synchronized(globalManagedObjectContext){
        for (NSManagedObject * item in items) {
            [globalManagedObjectContext deleteObject:item];
        }
    }
}

+ (BOOL)deleteObjects_sync:(NSArray *)manyObject
{
    __block BOOL success = true;
    [self asnycQueue:NO actions:^{
        [self save:^(BOOL success) {
            
        }];
    }];
    return success;
}

#pragma mark -- NSManagedObject方法

+ (NSManagedObject *)bulidManagedObjectByClass:(Class)theClass{
    NSManagedObject * _object = nil;
    _object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(theClass) inManagedObjectContext:globalManagedObjectContext];
    return _object;
}

+ (void)save:(void (^) (BOOL success))block{
    NSError * error;
    @synchronized(globalManagedObjectContext){
        if (![globalManagedObjectContext save:&error]) {
            NSLog(@"未解决的错误%@，%@",error, [error userInfo]);
        }
        BOOL success = error==nil? YES:NO;
        block(success);
    }
}

- (void)remove{
    if (self.managedObjectContext) {
        [NSManagedObject deleteObjects_sync:@[self]];
    }
}

//是否在异步队列重操作数据库
+ (void)asnycQueue:(BOOL)asnyc actions:(void (^)(void))actions{
    static int specificKey;
    if (coreDataQueue == NULL) {
        coreDataQueue = dispatch_queue_create("com.neolix.coredata", DISPATCH_QUEUE_SERIAL);//生成一个线程队列
        CFStringRef specificValue = CFSTR("com.neolix.coredata");
        dispatch_queue_set_specific(coreDataQueue, &specificKey, (void *)specificValue, (dispatch_function_t)CFRelease);
    }
    NSString * retrievedValue = (NSString *)CFBridgingRelease(dispatch_get_specific(&specificKey));
    if (retrievedValue && [retrievedValue isEqualToString:@"com.neolix.coredata"]) {
        actions ? actions() : nil;
    }else{
        if (asnyc) {
            dispatch_async(coreDataQueue, ^{
                actions ? actions() : nil;
            });
        }else{
            dispatch_sync(coreDataQueue, ^{
                actions ? actions() : nil;
            });
        }
    }
}

@end
