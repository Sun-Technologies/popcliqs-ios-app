//
//  PopcliqsAPI.h
//  Popcliqs
//
//  Created by Praveen Kansara on 14/10/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TEST_USER_NAME_STR                          @"tahir@popcliqs.com"
#define TEST_PASSWORD_STR                           @"Bubble@2012"

#define PCAPI_EXIT_CODE_KEY_STR                         @"exit_cd"
#define PCAPI_AUTH_KEY_STR                              @"key"
#define PCAPI_CHECK_IN_EVENTS_KEY_STR                   @"checkin_event"
#define PCAPI_EVENT_ID_KEY_STR                          @"id"
#define PCAPI_EVENT_DESCRIPTION_KEY_STR                 @"desc"
#define PCAPI_EVENT_TYPE_ID_KEY_STR                     @"typeid"
#define PCAPI_EVENT_TYPE_KEY_STR                        @"type"
#define PCAPI_EVENT_START_TIME_KEY_STR                  @"st_time"
#define PCAPI_EVENT_END_TIME_KEY_STR                    @"ed_time"
#define PCAPI_EVENT_START_DATE_KEY_STR                  @"st_dt"
#define PCAPI_EVENT_END_DATE_KEY_STR                    @"ed_dt"
#define PCAPI_EVENT_TITLE_KEY_STR                       @"title"
#define PCAPI_EVENT_LOCATION_KEY_STR                    @"location"
#define PCAPI_EVENT_ADDRESS_KEY_STR                     @"address"
#define PCAPI_EVENT_CITY_KEY_STR                        @"city"
#define PCAPI_EVENT_POSTAL_CODE_KEY_STR                 @"postal_code"
#define PCAPI_EVENT_LATITUDE_KEY_STR                    @"lat"
#define PCAPI_EVENT_LONGITUDE_KEY_STR                   @"lon"
#define PCAPI_EVENT_TIME_ZONE_KEY_STR                   @"tz"
#define PCAPI_EVENT_IS_USER_CREATED_KEY_STR             @"is_creator"
#define PCAPI_EVENT_CHECK_IN_START_TIME_KEY_STR         @"left_for_checkin_time"
#define PCAPI_EVENT_CHECK_IN_START_DATE_KEY_STR         @"left_for_checkin_dt"

@interface PopcliqsAPI : NSObject

@property (nonatomic, retain, readonly) NSDateFormatter* dateFormatter;
@property (nonatomic, retain, readonly) NSDateFormatter* timeFormatter;

+ (instancetype)sharedManager;

+ (NSString*)forgotPasswordURL;
+ (NSString*)signUpURL;
+ (NSString*)eventsURL;
+ (NSString*)logInURLForUsername:(NSString*)lstrUserName password:(NSString*)lstrPassword;
+ (NSString*)userActionURLForEventId:(NSString*)lstrEventId actionId:(NSString*)lstrActionId;
+ (NSString*)checkInEventsURL;
+ (NSString*)checkInEventsURLForKey:(NSString*)lstrAuthKey timeZoneInMinutes:(NSString*)lstrTimeZone demo:(NSString*)lstrDemo;
+ (NSString*)createEventForCategory:(NSString*)lstrCategory startHour:(NSString*)lstrStartHour zipCode:(NSString*)lstrZipCode;
+ (BOOL)isExitCodeSuccess:(NSString*)lstrExitCode;

+ (BOOL)boolForString:(NSString*)lstrTrueOrFalse;
+ (NSString*)checkInAction;
+ (NSString*)cancelAction;

+ (void)deleteAuthKey;
+ (void)saveAuthKey:(NSString*)lstrAuthKey;
+ (NSString*)authKey;

+ (void)savePushNotificationDeviceToken:(NSString*)lstrPushNotificationDeviceToken;
+ (NSString*)pushNotificationDeviceToken;

@end

