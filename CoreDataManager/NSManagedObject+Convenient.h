//
//  NSManagedObject+Convenient.h
//  CoreDataManager
//
//  Created by neolix on 14-8-6.
//  Copyright (c) 2014年 Neolix. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Convenient)
//是否在异步队列中操作数据库
+ (void)asnycQueue:(BOOL)asnyc actions:(void (^)(void))actions;
/**异步创建NSManagedObject插入一条记录*/
+ (id)insertItem_asyncWithBlock:(void(^)(id item))settingBlcok;
/**异步查询*/
+ (void)items_asyncSortDescriptions:(NSArray *)sortDesccriptions withFormat:(NSString *)fmt complete:(void (^)(NSMutableArray * items))completeBlcok;

/**同步查询*/

+ (void)items_syncSortDescriptions:(NSArray *)sortDesccriptions withFormat:(NSString *)fmt complete:(void (^)(NSMutableArray * items))completeBlcok;


/**删除一条记录*/
+ (void)save:(void (^) (BOOL success))block;
- (void)remove;



@end
