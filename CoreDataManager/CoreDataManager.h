//
//  CoreDataManager.h
//  CoreDataManager
//
//  Created by neolix on 14-8-6.
//  Copyright (c) 2014年 Neolix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObject+Convenient.h"

@interface CoreDataManager : NSObject
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;

+ (CoreDataManager *)mainInstance;

@end
