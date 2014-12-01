//
//  CDEvent.h
//  Popcliqs
//
//  Created by Praveen Kansara on 23/09/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

#define EVENT_IDENTIFIER_KEY_STR                    @"Identifier"
#define EVENT_TIME_INTERVAL_TWO_HOURS               7200
#define EVENT_TIME_INTERVAL_FIFTEEN_MINUTES         900

typedef enum
{
    TimeUntilCheckInEventState,
    WaitingForUserActionEventState,
    SnoozedEventState,
    CheckingInEventState,
    CheckingInFailedEventState,
    CheckedInEventState,
    CancellingEventState,
    CancellingFailedEventState,
    CancelledEventState
} EventState;

@class CDEvent;

@protocol CDEventObserver <NSObject>

- (void)eventDidChangeState:(CDEvent*)lobjEvent;

@end

@interface CDEvent : NSManagedObject <NSURLConnectionDelegate>

@property (nonatomic, assign) BOOL bUserCreated;
@property (nonatomic, assign) double doubleLatitude;
@property (nonatomic, assign) double doubleLongitude;
@property (nonatomic, retain) NSDate * objCheckInStartTime;
@property (nonatomic, retain) NSDate * objEndDate;
@property (nonatomic, retain) NSDate * objStartDate;
@property (nonatomic, retain) NSString * strAddress;
@property (nonatomic, retain) NSString * strCity;
@property (nonatomic, retain) NSString * strDescription;
@property (nonatomic, retain) NSString * strIdentifier;
@property (nonatomic, retain) NSString * strLocation;
@property (nonatomic, retain) NSString * strOwnerIdentifier;
@property (nonatomic, retain) NSString * strPostalCode;
@property (nonatomic, retain) NSString * strTitle;
@property (nonatomic, retain) NSString * strType;
@property (nonatomic, retain) NSString * strTypeIdentifier;
@property (nonatomic, retain) NSString * strVenue;

@property (nonatomic, readonly, assign) EventState enumEventState;
@property (nonatomic, weak) id<CDEventObserver> observer;

- (BOOL)canBeCheckedIn;
- (void)checkIn;
- (void)updateState;

- (void)cancel;

- (void)scheduleReminderBeforeSeconds:(float)lfloatSecondsPriorToEvent;

- (BOOL)snooze;
- (BOOL)removeReminderIfAny;

- (void)geoFence;
- (void)enteredGeoRegion;
- (void)exitedGeoRegion;

- (NSDate*)dateFromString:(NSString*)lstrDateString;

@end
