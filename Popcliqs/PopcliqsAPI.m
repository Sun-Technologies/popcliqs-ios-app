//
//  PopcliqsAPI.m
//  Popcliqs
//
//  Created by Praveen Kansara on 14/10/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

//---------------------------------------------------------------------------------
#pragma mark - Imports
//---------------------------------------------------------------------------------

#import "PopcliqsAPI.h"
#import "CoreDataStack.h"

//---------------------------------------------------------------------------------
#pragma mark - HashDefines
//---------------------------------------------------------------------------------

#define PCAPI_SAVED_AUTH_KEY_KEY_STR                                @"AuthKeySaved"
#define PCAPI_SAVED_PUSH_NOTIFICATION_DEVUCE_TOKEN_KEY_KEY_STR      @"PushNotificationDeviceToken"
#define PCAPI_TRUE_STR                                              @"true"

#define PCAPI_EXIT_SUCCESS_CODE                                     0
#define PCAPI_CHECK_IN_ACTION_CODE                                  2
#define PCAPI_CANCEL_ACTION_CODE                                    -1

//---------------------------------------------------------------------------------
#pragma mark - Private
//---------------------------------------------------------------------------------

@interface PopcliqsAPI()

@property (nonatomic, retain) NSDateFormatter* dateFormatter;
@property (nonatomic, retain) NSDateFormatter* timeFormatter;

@end

//---------------------------------------------------------------------------------
#pragma mark - Implementation
//---------------------------------------------------------------------------------

@implementation PopcliqsAPI

+ (instancetype)sharedManager
{
    static PopcliqsAPI *sharedAPIManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedAPIManager = [[self alloc] init];
        sharedAPIManager.dateFormatter = [[NSDateFormatter alloc] init];
        [sharedAPIManager.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [sharedAPIManager.dateFormatter setTimeStyle:NSDateFormatterNoStyle];

        sharedAPIManager.timeFormatter = [[NSDateFormatter alloc] init];
        [sharedAPIManager.timeFormatter setDateStyle:NSDateFormatterNoStyle];
        [sharedAPIManager.timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    });
    
    return sharedAPIManager;
}

//---------------------------------------------------------------------------------
#pragma mark - ClassMethods
//---------------------------------------------------------------------------------

+ (NSString*)forgotPasswordURL
{
    return [PopcliqsAPI eventsURL];
}

+ (NSString*)signUpURL
{
    return [PopcliqsAPI eventsURL];
}

+ (NSString*)eventsURL
{
    return @"http://popcliqs.com/beta/";
}

+ (NSString*)howitWorksURL
{
    return @"http://popcliqs.com/beta/about.php";
}


+ (NSString*)logInURLForUsername:(NSString*)lstrUserName password:(NSString*)lstrPassword
{
    NSString* lstrLoginURL = nil;
    
    if (lstrPassword && lstrUserName)
    {
        lstrLoginURL =
        [NSString stringWithFormat:@"http://popcliqs.com/beta/login.service.php?usernm=%@&pwd=%@&deviceToken=%@", lstrUserName, lstrPassword, [PopcliqsAPI pushNotificationDeviceToken]];
    }
    
    return lstrLoginURL;
}

+ (NSString*)logoutURLForKey:(NSString*)lstrAuthKey
{
    NSString* lstrLogoutURL = nil;
    
    if (lstrAuthKey)
    {
        lstrLogoutURL =
        [NSString stringWithFormat:@"http://popcliqs.com/beta/logout.service.php?key=%@&deviceToken=%@", lstrAuthKey, [PopcliqsAPI pushNotificationDeviceToken]];
    }
    
    return lstrLogoutURL;
}

+ (NSString*)userActionURLForEventId:(NSString*)lstrEventId actionId:(NSString*)lstrActionId
{
    NSString* lstrUserActionURL = nil;
    
    if (lstrEventId && lstrActionId)
    {
        lstrUserActionURL =
        [NSString stringWithFormat:@"http://popcliqs.com/beta/updateevent.service.php?key=%@&evtid=%@&rspcd=%@",
         [PopcliqsAPI authKey],
         lstrEventId,
         lstrActionId];
    }
    
    return lstrUserActionURL;
}

+ (NSString*)checkInEventsURL
{
    NSInteger tzSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSInteger tzMinutes = -1 * ((int)(tzSeconds/60) + tzSeconds%60);
    
    return [PopcliqsAPI checkInEventsURLForKey:[PopcliqsAPI authKey]
                             timeZoneInMinutes:[NSString stringWithFormat:@"%ld", (long)tzMinutes]
                                          demo:@"true"];
}

+ (NSString*)checkInEventsURLForKey:(NSString*)lstrAuthKey timeZoneInMinutes:(NSString*)lstrTimeZone demo:(NSString*)lstrDemo
{
    NSString* lstrCheckInEventsURL = nil;
    
    if (lstrAuthKey && lstrTimeZone && lstrDemo)
    {
        lstrCheckInEventsURL =
        [NSString stringWithFormat:@"http://popcliqs.com/beta/checkinevents.service.php?key=%@&tz=%@&deviceToken=%@&demo=%@",
         lstrAuthKey, lstrTimeZone, [PopcliqsAPI pushNotificationDeviceToken], lstrDemo];
    }
    
    return lstrCheckInEventsURL;
}

+ (NSString*)createEventForCategory:(NSString*)lstrCategory startHour:(NSString*)lstrStartHour zipCode:(NSString*)lstrZipCode
{
    NSString* lstrCreateEventURL = nil;
    
    if (lstrCategory && lstrZipCode && lstrStartHour)
    {
        lstrCreateEventURL =
        [NSString stringWithFormat:@"http://popcliqs.com/beta/createevent.service.php?key=%@&tz=%@&cat_cd=%@&zip=%@&st_hr=%@",
         [PopcliqsAPI authKey], @"-330", lstrCategory, lstrZipCode, lstrStartHour];
    }
    
    return lstrCreateEventURL;
}

+ (BOOL)isExitCodeSuccess:(NSString*)lstrExitCode
{
    if ([lstrExitCode isEqualToString:[NSString stringWithFormat:@"%d", PCAPI_EXIT_SUCCESS_CODE]])
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)boolForString:(NSString*)lstrTrueOrFalse
{
    if ([lstrTrueOrFalse isEqualToString:PCAPI_TRUE_STR])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSString*)checkInAction
{
    return [NSString stringWithFormat:@"%d", PCAPI_CHECK_IN_ACTION_CODE];
}

+ (NSString*)cancelAction
{
    return [NSString stringWithFormat:@"%d", PCAPI_CANCEL_ACTION_CODE];
}

+ (void)deleteAuthKey
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PCAPI_SAVED_AUTH_KEY_KEY_STR];
}

+ (void)saveAuthKey:(NSString*)lstrAuthKey
{
    [[NSUserDefaults standardUserDefaults] setObject:lstrAuthKey forKey:PCAPI_SAVED_AUTH_KEY_KEY_STR];
}

+ (NSString*)authKey
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:PCAPI_SAVED_AUTH_KEY_KEY_STR];
}

+ (void)savePushNotificationDeviceToken:(NSString*)lstrPushNotificationDeviceToken
{
    NSString *lstrModifiedPNToken = [lstrPushNotificationDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    lstrModifiedPNToken = [lstrModifiedPNToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    lstrModifiedPNToken = [lstrModifiedPNToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:lstrModifiedPNToken forKey:PCAPI_SAVED_PUSH_NOTIFICATION_DEVUCE_TOKEN_KEY_KEY_STR];
}

+ (NSString*)pushNotificationDeviceToken
{
    NSString* lstrDeviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:PCAPI_SAVED_PUSH_NOTIFICATION_DEVUCE_TOKEN_KEY_KEY_STR];
    
    if (lstrDeviceToken == nil)
    {
        lstrDeviceToken = @"None";
    }
    
    return lstrDeviceToken;
}

@end
