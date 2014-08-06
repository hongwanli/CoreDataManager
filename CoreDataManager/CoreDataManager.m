//
//  CoreDataManager.m
//  CoreDataManager
//
//  Created by neolix on 14-8-6.
//  Copyright (c) 2014年 Neolix. All rights reserved.
//

#import "CoreDataManager.h"
NSManagedObjectContext * globalManagedObjectContext;
NSManagedObjectModel * globalManagedObjectModel;

static CoreDataManager * DB = nil;
@implementation CoreDataManager

+ (CoreDataManager *)mainInstance{
    dispatch_once_t pred = 0;
    __strong static CoreDataManager * coreDataManager = nil;
    dispatch_once(&pred, ^{
        coreDataManager = [[self alloc] init];
    });
    return coreDataManager;
}

- (id)init{
    self = [super init];
    if (self) {
        [NSManagedObject asnycQueue:NO actions:^{
            globalManagedObjectContext = [self managedObjectContext];
            globalManagedObjectModel = [self managedObjectModel];
            [globalManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        }];
    }
    return self;
}

#pragma mark -- CoreData 方法

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}
//返回managedObjectModel,设置momd名字
- (NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL * modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
    
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL * storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreData.sqlite"];
    NSError * error = nil;
    NSDictionary * optitons = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,[NSNumber numberWithBool:YES],NSInferMappingModelAutomaticallyOption, nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optitons error:&error]) {
        NSLog(@"未解决的错误%@,%@",error,[error userInfo]);
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AllAuthData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        _persistentStoreCoordinator = nil;
        return [self persistentStoreCoordinator];
    }
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
