//
//  CoreData.m
//  iDo
//
//  Created by Praveen Kansara on 7/13/10.
//  Copyright 2010 Pani Puri Soft. All rights reserved.
//

//---------------------------------------------------------------------------------
#pragma mark - ProjectImports
//---------------------------------------------------------------------------------

#import <CoreData/CoreData.h>

#import "CoreDataStack.h"

//---------------------------------------------------------------------------------
#pragma mark - HashDefines
//---------------------------------------------------------------------------------

#define		CD_DATABASE_NAME							@"PopCliqs.sqlite"
#define		POPCLIQS_MOMD_PACKAGE_NAME					@"PopCliqs"
#define		POPCLIQS_MOMD_PACKAGE_TYPE                  @"momd"

//---------------------------------------------------------------------------------
#pragma mark - Private 
//---------------------------------------------------------------------------------

@interface CoreDataStack()

@property (nonatomic, strong) NSManagedObjectContext*       coreDataQueueMOC;
@property (nonatomic, strong) NSManagedObjectContext*       mainQueueMOC;
@property (atomic,    strong) NSManagedObjectModel*         managedObjectModel;
@property (atomic,    strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;

//---------------------------------------------------------------------------------
@end
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
#pragma mark - Implementation
//---------------------------------------------------------------------------------

@implementation CoreDataStack

//---------------------------------------------------------------------------------
#pragma mark - Core Data Stack Methods
//---------------------------------------------------------------------------------

- (NSManagedObjectModel *)createManagedObjectModel
{
    NSManagedObjectModel* lobjManagedObjectModel = nil;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:POPCLIQS_MOMD_PACKAGE_NAME
                                              withExtension:POPCLIQS_MOMD_PACKAGE_TYPE];
    
    if (modelURL)
    {
        lobjManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    else
    {
        SLog(@"ERROR : ModelUrl is nil");
    }

    return lobjManagedObjectModel;
}

- (NSPersistentStoreCoordinator *)createPersistentStoreCoordinator
{
    NSPersistentStoreCoordinator* lobjPersistentStoreCoordinator = nil;
    
    if (self.managedObjectModel == nil)
    {
        self.managedObjectModel = [self createManagedObjectModel];
    }

    if (self.managedObjectModel)
    {
        NSURL *lobjURLStore = nil;
        {
            NSURL *lobjURLDocumentDirectory =
            [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                    inDomains:NSUserDomainMask] lastObject];
            
            lobjURLStore = [lobjURLDocumentDirectory URLByAppendingPathComponent:CD_DATABASE_NAME];
        }
        
        NSError *lobjError = nil;
        
        lobjPersistentStoreCoordinator =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSPersistentStore *lobjNewStore =
        [lobjPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:lobjURLStore
                                                        options:nil
                                                          error:&lobjError];
        
        if (lobjError || lobjNewStore == nil)
        {
            SLog(@"ERROR : Store created is nil %@, %@", lobjError, [lobjError userInfo]);
        }
        else
        {
            // Do nothing
        }
    }

    return lobjPersistentStoreCoordinator;
}

- (void)managedObjectContextDidSave:(NSNotification*)lobjManagedObjectContextDidSaveNotification
{
    NSManagedObjectContext* lobjSavedContext = [lobjManagedObjectContextDidSaveNotification object];
    
    if (lobjSavedContext == self.mainQueueMOC)
    {
        if (self.coreDataQueueMOC)
        {
            [self.coreDataQueueMOC mergeChangesFromContextDidSaveNotification:lobjManagedObjectContextDidSaveNotification];
        }
    }
    else if(lobjSavedContext == self.coreDataQueueMOC)
    {
        if (self.mainQueueMOC)
        {
            [self.mainQueueMOC mergeChangesFromContextDidSaveNotification:lobjManagedObjectContextDidSaveNotification];
        }
    }
}

- (NSManagedObjectContext *)createManagedObjectContext
{
    NSManagedObjectContext* lobjManagedObjectContext = nil;
    
    if (self.persistentStoreCoordinator == nil)
    {
        self.persistentStoreCoordinator = [self createPersistentStoreCoordinator];
    }
    
    if (self.persistentStoreCoordinator)
    {
        lobjManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [lobjManagedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        //        [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                 selector:@selector(managedObjectContextDidSave:)
        //                                                     name:NSManagedObjectContextDidSaveNotification
        //                                                   object:lobjManagedObjectContext];
    }
    
    return lobjManagedObjectContext;
}

+ (void)cleanDatabase
{
    NSManagedObjectContext* lobjMOC = [[CoreDataStack sharedInstance] createManagedObjectContext];
    NSFetchRequest* lobjFetchRequest = [[NSFetchRequest alloc] initWithEntityName:CD_EVENT_NAME];
    
    NSError* lobjError = nil;
    NSArray* larrayEvents = [lobjMOC executeFetchRequest:lobjFetchRequest error:&lobjError];
    
    if (lobjError)
    {
        SLog(@"ERROR: logoutCleanup : Fetch Failed : %@", [lobjError description]);
    }
    else
    {
        for (CDEvent* lobjEvent in larrayEvents)
        {
            [lobjMOC deleteObject:lobjEvent];
        }
        
        [lobjMOC save:&lobjError];
        
        if (lobjError)
        {
            SLog(@"ERROR: logoutCleanup : Save Failed : %@", [lobjError description]);
        }
        else
        {
            // Nothing
        }
    }
}

//---------------------------------------------------------------------------------
#pragma mark - Singleton methods
//---------------------------------------------------------------------------------

+ (CoreDataStack*)sharedInstance
{
    static CoreDataStack *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[CoreDataStack alloc] init];
                      
                  });
    return sharedInstance;
}

//---------------------------------------------------------------------------------
@end
//---------------------------------------------------------------------------------
