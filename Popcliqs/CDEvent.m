//
//  CDEvent.m
//  Popcliqs
//
//  Created by Praveen Kansara on 23/09/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "CDEvent.h"
#import "AppDelegate.h"
#import "LocationConstants.h"
#import "PopcliqsAPI.h"

@interface CDEvent()

@property (nonatomic, strong) NSURLConnection*  objConnection;
@property (nonatomic, strong) NSMutableData*    objReceivedData;
@property (nonatomic, assign) EventState        enumEventState;

@end

@implementation CDEvent

@dynamic bUserCreated;
@dynamic doubleLatitude;
@dynamic doubleLongitude;
@dynamic objCheckInStartTime;
@dynamic objEndDate;
@dynamic objStartDate;
@dynamic strAddress;
@dynamic strCity;
@dynamic strDescription;
@dynamic strIdentifier;
@dynamic strLocation;
@dynamic strOwnerIdentifier;
@dynamic strPostalCode;
@dynamic strTitle;
@dynamic strType;
@dynamic strTypeIdentifier;
@dynamic strVenue;

@synthesize objConnection;
@synthesize objReceivedData;
@synthesize enumEventState;
@synthesize observer;

- (NSDate*)dateFromString:(NSString*)lstrDateString
{
    NSLog(@"Time Str = %@",lstrDateString);
    NSLog(@"system time zone = %@",[NSTimeZone systemTimeZone]);
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

    [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    NSDate *lobjDate = [dateFormat dateFromString:lstrDateString];
    
    NSLog(@"date from string = %@",lobjDate);
    NSLog(@"string from date = %@",[dateFormat stringFromDate:lobjDate]);

    return lobjDate;
}

- (void)setEnumEventState:(EventState)lenumEventState
{
    enumEventState = lenumEventState;
    
    if (self.observer)
    {
        if ([self.observer respondsToSelector:@selector(eventDidChangeState:)])
        {
            [self.observer eventDidChangeState:self];
        }
    }
}

- (BOOL)isSnoozed
{
    BOOL lbIsSnoozed = NO;
    
    NSArray* larrayLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification* lobjLocalNotification in larrayLocalNotifications)
    {
        NSDictionary* ldictUserInfo = lobjLocalNotification.userInfo;
        NSString* lstrIdentifier = [ldictUserInfo objectForKey:EVENT_IDENTIFIER_KEY_STR];
        
        if ([lstrIdentifier isEqualToString:self.strIdentifier])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:lobjLocalNotification];
        
            lbIsSnoozed = YES;
            
            break;
        }
    }
    
    return lbIsSnoozed;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    [self updateState];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    [self updateState];
}

- (void)updateState
{
    if ([self canBeCheckedIn])
    {
        self.enumEventState = WaitingForUserActionEventState;
    }
    else
    {
        self.enumEventState = TimeUntilCheckInEventState;
    }
}

- (void)informServerOfAction:(NSString*)lstrActionId
{
    self.objReceivedData = [NSMutableData data];
    NSString* lstrCheckInURL = [PopcliqsAPI userActionURLForEventId:self.strIdentifier actionId:lstrActionId];
    NSURL* lobjURL = [NSURL URLWithString:lstrCheckInURL];
    NSURLRequest* lobjURLRequest = [NSURLRequest requestWithURL:lobjURL];
    self.objConnection = [NSURLConnection connectionWithRequest:lobjURLRequest delegate:self];
}

- (BOOL)canBeCheckedIn
{
    if (self.objCheckInStartTime)
    {
//        SLog(@"Checkin Time : %@ Start Time %@", self.objCheckInStartTime, self.objStartDate);
        
        if ([[NSDate date] compare:self.objCheckInStartTime] == NSOrderedAscending ||
            [[NSDate date] compare:self.objCheckInStartTime] == NSOrderedSame)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

- (void)checkIn
{
    [self informServerOfAction:[PopcliqsAPI checkInAction]];
    
    self.enumEventState = CheckingInEventState;
}

- (void)cancel
{
    [self informServerOfAction:[PopcliqsAPI cancelAction]];
    
    self.enumEventState = CancellingEventState;
}

- (BOOL)removeReminderIfAny
{
    NSArray* larrayLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    BOOL lbRemovedReminder = NO;
    
    for (UILocalNotification* lobjLocalNotification in larrayLocalNotifications)
    {
        NSDictionary* ldictUserInfo = lobjLocalNotification.userInfo;
        NSString* lstrIdentifier = [ldictUserInfo objectForKey:EVENT_IDENTIFIER_KEY_STR];
        
        if ([lstrIdentifier isEqualToString:self.strIdentifier])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:lobjLocalNotification];
            
            lbRemovedReminder = YES;
        }
    }
    
    return lbRemovedReminder;
}

- (void)scheduleReminderBeforeSeconds:(float)lfloatSecondsPriorToEvent andEventName:(NSString *) eventName
{
    if (self.objStartDate && self.strIdentifier)
    {
        NSLog(@"Event start time = %@",self.objStartDate);
        
        NSDate* lobjFireDate = [self.objStartDate dateByAddingTimeInterval:-1 * lfloatSecondsPriorToEvent];
        
         NSLog(@"Event fire time = %@",lobjFireDate);
        
        if ([lobjFireDate compare:[NSDate date]] == NSOrderedDescending)
        {
            [self removeReminderIfAny];
            
            UILocalNotification* lobjLocalNotification = [[UILocalNotification alloc] init];
            lobjLocalNotification.fireDate = lobjFireDate;
            
            if( lfloatSecondsPriorToEvent == EVENT_TIME_INTERVAL_TWO_HOURS ){
                 lobjLocalNotification.alertBody = [NSString stringWithFormat:@" You are a couple of hours away from your Cliq \nCliq Name: %@ " , eventName ];
            }else if ( lfloatSecondsPriorToEvent == EVENT_TIME_INTERVAL_FIFTEEN_MINUTES  ){
                lobjLocalNotification.alertBody = [NSString stringWithFormat:@" You may check in to the following Cliq in %1.0f  minutes if you will be part of itr Cliq \nCliq Name: %@ " , lfloatSecondsPriorToEvent/60 , eventName ];
            }else{
                lobjLocalNotification.alertBody = [NSString stringWithFormat:@"You have an event to check-in in  %1.0f minutes",(lfloatSecondsPriorToEvent/60)];// @"You have an event to check-in in  %f minutes " , lfloatSecondsPriorToEvent/60 ;
            }
            lobjLocalNotification.userInfo = @{EVENT_IDENTIFIER_KEY_STR:self.strIdentifier};
            
            [[UIApplication sharedApplication] scheduleLocalNotification:lobjLocalNotification];
        }
    }
    else
    {
        SLog(@"ERROR:[scheduleReminder] objStartDate or strIdentifier is nil");
    }
}

- (BOOL)snooze
{
    if (self.strIdentifier)
    {
        [self removeReminderIfAny];
        
        UILocalNotification* lobjLocalNotification = [[UILocalNotification alloc] init];
        lobjLocalNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:60];
        lobjLocalNotification.alertBody = @"You have an event to check-in";
        lobjLocalNotification.userInfo = @{EVENT_IDENTIFIER_KEY_STR:self.strIdentifier};
        
        [[UIApplication sharedApplication] scheduleLocalNotification:lobjLocalNotification];
        
        self.enumEventState = SnoozedEventState;
        
        return YES;
    }
    else
    {
        SLog(@"ERROR:[snooze] strIdentifier is nil");
        
        return NO;
    }
}

- (void)geoFence
{
    [self geoFenceWithRadius:GEO_ALERT_TRIGGER_RADIUS];
}

- (void)enteredGeoRegion
{
    [self removeGeoFence];
 
    // Increase GeoFence radius to avoid flicker on radius
    
    [self geoFenceWithRadius:GEO_ALERT_TRIGGER_INCREASED_RADIUS];
}

- (void)exitedGeoRegion
{
    [self removeGeoFence];
    
    [self geoFenceWithRadius:GEO_ALERT_TRIGGER_RADIUS];
}

- (BOOL)geoFenceWithRadius:(CLLocationDistance)lclLocationDistance
{
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate]
            geoFenceLocation:CLLocationCoordinate2DMake(self.doubleLatitude, self.doubleLongitude)
            withRadius:lclLocationDistance identifier:self.strIdentifier];
}

- (BOOL)removeGeoFence
{
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate]
            removeGeoFenceWithIdentifier:self.strIdentifier];
}

- (void)willSave
{
    [super willSave];
    
    if ([self isDeleted])
    {
        [self removeReminderIfAny];
        [self removeGeoFence];
    }
    else if ([self isInserted])
    {
        [self geoFence];
    }
    else if ([self isUpdated])
    {
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.objReceivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.objReceivedData)
    {
        NSError* lobjError = nil;
        
        NSObject* lobjData = [NSJSONSerialization JSONObjectWithData:self.objReceivedData
                                                             options:NSJSONReadingAllowFragments
                                                               error:&lobjError];
        
        if (lobjError)
        {
            SLog(@"ERROR: parsing JSON Failed");
            
            [self handleFailure];
        }
        else
        {
            if ([lobjData isKindOfClass:[NSDictionary class]])
            {
                NSString* lstrExitCode = [lobjData valueForKey:PCAPI_EXIT_CODE_KEY_STR];
                
                if ([PopcliqsAPI isExitCodeSuccess:lstrExitCode])
                {
                    [self handleSuccess];
                }
                else
                {
                    SLog(@"ERROR: Exit Code not Success : %@ data : %@", lstrExitCode, lobjData);
                    
                    [self handleFailure];
                }
            }
            else
            {
                SLog(@"ERROR: Data received is unrecognizable");
                
                [self handleFailure];
            }
        }
    }
    else
    {
        SLog(@"ERROR : objReceivedData is nil");
        
        [self handleFailure];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    SLog(@"connection:didFailWithError:%@", [error description]);
    
    [self handleFailure];
}

- (void)handleSuccess
{
    if (self.enumEventState == CheckingInEventState)
    {
        self.enumEventState = CheckedInEventState;
    }
    else if(self.enumEventState == CancellingEventState)
    {
        self.enumEventState = CancelledEventState;
    }
    
    [self performSelector:@selector(deleteFromDatabase) withObject:nil afterDelay:0.5f];
}

- (void)deleteFromDatabase
{
    [self.managedObjectContext deleteObject:self];
    
    NSError* lobjError = nil;
    
    if ([self.managedObjectContext save:&lobjError] == NO)
    {
        SLog(@"ERROR : %@", [lobjError description]);
    }
}

- (void)handleFailure
{
    if (self.enumEventState == CheckingInEventState)
    {
        self.enumEventState = CheckingInFailedEventState;
    }
    else if(self.enumEventState == CancellingEventState)
    {
        self.enumEventState = CancellingFailedEventState;
    }
    
    [self performSelector:@selector(changeStateToWaitingForUserAction) withObject:nil afterDelay:0.5f];
}

- (void)changeStateToWaitingForUserAction
{
    self.enumEventState = WaitingForUserActionEventState;
}

@end
