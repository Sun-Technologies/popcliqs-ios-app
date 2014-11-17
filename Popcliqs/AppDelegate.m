//
//  AppDelegate.m
//  Popcliqs
//
//  Created by Praveen Kansara on 17/08/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataStack.h"
#import "PopcliqsAPI.h"
#import "HomeViewController.h"
#import "CheckInViewController.h"
#import <Pushbots/Pushbots.h>

@interface  AppDelegate ()

@property (nonatomic, strong) NSURLConnection* objConnection;
@property (nonatomic, strong) NSMutableData* objReceivedData;

@end

@implementation AppDelegate

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    SLog(@"Did Receive Local notification");
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    CheckInViewController* CheckinView = [mainstoryboard instantiateViewControllerWithIdentifier:@"CheckInViewController"];
    [self.window.rootViewController presentViewController:CheckinView animated:YES completion:NULL];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Nav-Bar-Background"] forBarMetrics:UIBarMetricsDefault];
//    [[UIView appearance] setBackgroundColor:[UIColor colorWithRed:0.92f green:0.94f blue:0.98f alpha:1.0f]];
    
    NSDictionary * userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo) {
        // Notification Message
        NSString* notificationMsg = [userInfo valueForKey:@"message"];
        // Custom Field
        NSString* title = [userInfo valueForKey:@"title"];
        NSLog(@"Notification Msg is %@ and Custom field title = %@", notificationMsg , title);
        if(notificationMsg)
        {
            UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            HomeViewController* homeView = [mainstoryboard instantiateViewControllerWithIdentifier:@"HomeView"];
            [self.window.rootViewController presentViewController:homeView animated:YES completion:NULL];
        }
    }
    
    [Pushbots getInstance];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self promptForLocationServicesIfDisabled];
    
    [self startLocationServices];
    
    if ([PopcliqsAPI authKey])
    {
        [self fetchDataFromInternet];
    }
    
    [[[UIApplication sharedApplication] delegate].window setTintColor:[UIColor clearColor]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)startLocationServices
{
    if ([CLLocationManager locationServicesEnabled])
    {
        SLog(@"locationServicesEnabled:YES");
        
        if (self.objLocationManager == nil)
        {
            self.objLocationManager = [[CLLocationManager alloc] init];
            self.objLocationManager.delegate = self;
            self.objLocationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
            self.objLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        }
        
//        Start updating location changes.
//        if ([CLLocationManager significantLocationChangeMonitoringAvailable])
//        {
//            SLog(@"significantLocationChangeMonitoringAvailable:YES");
//            
//            [self.objLocationManager startMonitoringSignificantLocationChanges];
//        }
//        else
//        {
//            SLog(@"significantLocationChangeMonitoringAvailable:NO");
//            
//            [self.objLocationManager startUpdatingLocation];
//        }
        

    }
    else
    {
        SLog(@"locationServicesEnabled:NO");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    SLog(@"locationManager:didFailWithError:%@", [error description]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    SLog(@"locationManager:didUpdateLocations");
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
//    UIAlertView* lobjAlertView = [[UIAlertView alloc] initWithTitle:@"Did Enter Region"
//                                                            message:@"Did Enter region"
//                                                           delegate:nil cancelButtonTitle:@"Cancel"
//                                                  otherButtonTitles:@"Ok", nil];
//    [lobjAlertView show];
    
    NSPredicate* lobjPredicate = [NSPredicate predicateWithFormat:@"strIdentifier == %@", region.identifier];
    
    NSFetchRequest* lobjFR = [[NSFetchRequest alloc] initWithEntityName:CD_EVENT_NAME];
    [lobjFR setPredicate:lobjPredicate];
    
    NSManagedObjectContext* lobjMOC = [[CoreDataStack sharedInstance] createManagedObjectContext];
    
    NSError* lobjError = nil;
    NSArray* larrayEvents = [lobjMOC executeFetchRequest:lobjFR error:&lobjError];
    
    if (lobjError == nil)
    {
        if ([larrayEvents count] > 0)
        {
            CDEvent* lobjEvent = (CDEvent*)[larrayEvents objectAtIndex:0];
            
            if (lobjEvent)
            {
                [lobjEvent enteredGeoRegion];
                
                if ([lobjEvent.objCheckInStartTime compare:[NSDate date]] != NSOrderedDescending)
                {
                    // Present an alert to checkin
                    UILocalNotification* lobjLocalNotification = [[UILocalNotification alloc] init];
                    lobjLocalNotification.fireDate = [NSDate date];
                    lobjLocalNotification.alertBody = [NSString stringWithFormat:@"You are close to the event %@", lobjEvent.strTitle];
                    [[UIApplication sharedApplication] presentLocalNotificationNow:lobjLocalNotification];
                    
                    // Schedule a reminder 15 minutes prior to event
                    [lobjEvent scheduleReminderBeforeSeconds:EVENT_TIME_INTERVAL_FIFTEEN_MINUTES];
                }
                else
                {
                    // Schedule a reminder 15 minutes prior to event
                    [lobjEvent scheduleReminderBeforeSeconds:EVENT_TIME_INTERVAL_FIFTEEN_MINUTES];
                }
            }
            else
            {
                // Do nothing
            }
        }
        else
        {
            SLog(@"No event found for monitored region");
        }
    }
    else
    {
        SLog(@"ERROR : %@", [lobjError description]);
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
//    UIAlertView* lobjAlertView = [[UIAlertView alloc] initWithTitle:@"Did Exit Region"
//                                                            message:@"Did Exit region"
//                                                           delegate:nil cancelButtonTitle:@"Cancel"
//                                                  otherButtonTitles:@"Ok", nil];
//    [lobjAlertView show];
    
    NSPredicate* lobjPredicate = [NSPredicate predicateWithFormat:@"strIdentifier == %@", region.identifier];
    
    NSFetchRequest* lobjFR = [[NSFetchRequest alloc] initWithEntityName:CD_EVENT_NAME];
    [lobjFR setPredicate:lobjPredicate];
    
    NSManagedObjectContext* lobjMOC = [[CoreDataStack sharedInstance] createManagedObjectContext];
    
    NSError* lobjError = nil;
    NSArray* larrayEvents = [lobjMOC executeFetchRequest:lobjFR error:&lobjError];
    
    if (lobjError == nil)
    {
        if ([larrayEvents count] > 0)
        {
            CDEvent* lobjEvent = (CDEvent*)[larrayEvents objectAtIndex:0];
            
            if (lobjEvent)
            {
                [lobjEvent exitedGeoRegion];
                
                if ([lobjEvent.objCheckInStartTime compare:[NSDate date]] == NSOrderedAscending)
                {
                    // Unschedule any reminder
                    [lobjEvent removeReminderIfAny];
                }
                else
                {
                    // Unschedule any reminder
                    [lobjEvent removeReminderIfAny];
                }
            }
            else
            {
                // Do nothing
            }
        }
        else
        {
            SLog(@"No event found for monitored region");
        }
    }
    else
    {
        SLog(@"ERROR : %@", [lobjError description]);
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    SLog(@"Did Start Monitoring for region");
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    SLog(@"didChangeAuthorizationStatus");
    
    [self promptForLocationServicesIfDisabled];
    
    [self startLocationServices];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    SLog(@"monitoringDidFailForRegion:%@ error:%@", region.identifier, [error description]);
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    SLog(@"locationManagerDidPauseLocationUpdates");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    SLog(@"locationManagerDidResumeLocationUpdates");
}
    
- (void)promptForLocationServicesIfDisabled
{
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        UIAlertView* lobjAlertView = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                message:@"The app needs location services to function properly. Please enable the same in settings."
                                                               delegate:nil
                                                      cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [lobjAlertView show];
    }
}

#pragma mark - Fetch CheckInEvents

- (void)fetchDataFromInternet
{
    self.objReceivedData = [NSMutableData data];
    NSURL* lobjURL = [NSURL URLWithString:[PopcliqsAPI checkInEventsURL]];
    NSURLRequest* lobjRequest = [NSURLRequest requestWithURL:lobjURL];
    self.objConnection = [NSURLConnection connectionWithRequest:lobjRequest delegate:self];
}

#pragma mark - Event Related Methods

- (BOOL)geoFenceLocation:(CLLocationCoordinate2D)lclLocationCoordinate
              withRadius:(CLLocationDistance)lclLocationDistance
              identifier:(NSString*)lstrIdentifier
{
    BOOL lbGeoFenced = NO;
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]])
    {
        CLCircularRegion* lobjRegion = [[CLCircularRegion alloc] initWithCenter:lclLocationCoordinate
                                                                         radius:lclLocationDistance
                                                                     identifier:lstrIdentifier];
        
        [self.objLocationManager startMonitoringForRegion:lobjRegion];
        
        lbGeoFenced = YES;
    }
    else
    {
        SLog(@"regionMonitoringAvailable:NO");
    }
    
    return lbGeoFenced;
}

- (BOOL)removeGeoFenceWithIdentifier:(NSString*)lstrIdentifier
{
    BOOL lbRemovedGeoFence = NO;
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]])
    {
        NSSet* lsetMonitoredRegions = [self.objLocationManager monitoredRegions];
        
        for (CLRegion* lobjRegion in lsetMonitoredRegions)
        {
            if ([lobjRegion.identifier isEqualToString:lstrIdentifier])
            {
                [self.objLocationManager stopMonitoringForRegion:lobjRegion];
                
                lbRemovedGeoFence = YES;
                
                SLog(@"Removed Geofence : %@", lstrIdentifier);                
                
                break;
            }
        }
    }
    else
    {
        SLog(@"regionMonitoringAvailable : NO");
    }
    
    return lbRemovedGeoFence;
}

#pragma mark - Push Notification Delegation

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    NSString* lstrDeviceToken = [NSString stringWithFormat:@"%@", devToken];
    
    [PopcliqsAPI savePushNotificationDeviceToken:lstrDeviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    SLog(@"Error in registration. Error: %@", err);
}

//---------------------------------------------------------------------------------
#pragma mark - ConnectionDelegates
//---------------------------------------------------------------------------------

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
        }
        else
        {
            if ([lobjData isKindOfClass:[NSDictionary class]])
            {
                NSString* lstrExitCode = [lobjData valueForKey:PCAPI_EXIT_CODE_KEY_STR];
                
                if ([PopcliqsAPI isExitCodeSuccess:lstrExitCode])
                {
                    NSDictionary* ldictEvents = [lobjData valueForKey:PCAPI_CHECK_IN_EVENTS_KEY_STR];
                    
                    if ([self eventDataHasOnlyStrings:ldictEvents])
                    {
                        [CoreDataStack cleanDatabase];
                        
                        NSManagedObjectContext* lobjMOC = [[CoreDataStack sharedInstance] createManagedObjectContext];
                        
                        NSArray* larrayEvents = [ldictEvents allKeys];
                        
                        for (NSString* lstrEventKey in larrayEvents)
                        {
                            NSDictionary* ldictEventDetails = [ldictEvents valueForKey:lstrEventKey];
                            
                            CDEvent* lobjEvent = [NSEntityDescription insertNewObjectForEntityForName:CD_EVENT_NAME
                                                                               inManagedObjectContext:lobjMOC];
                            
                            lobjEvent.strIdentifier = [ldictEventDetails valueForKey:PCAPI_EVENT_ID_KEY_STR];
                            lobjEvent.strDescription = [ldictEventDetails valueForKey:PCAPI_EVENT_DESCRIPTION_KEY_STR];
                            lobjEvent.strTypeIdentifier = [ldictEventDetails valueForKey:PCAPI_EVENT_TYPE_ID_KEY_STR];
                            lobjEvent.strType = [ldictEventDetails valueForKey:PCAPI_EVENT_TYPE_KEY_STR];
                            lobjEvent.strTitle = [ldictEventDetails valueForKey:PCAPI_EVENT_TITLE_KEY_STR];
                            lobjEvent.strLocation = [ldictEventDetails valueForKey:PCAPI_EVENT_LOCATION_KEY_STR];
                            lobjEvent.strAddress = [ldictEventDetails valueForKey:PCAPI_EVENT_ADDRESS_KEY_STR];
                            lobjEvent.strCity = [ldictEventDetails valueForKey:PCAPI_EVENT_CITY_KEY_STR];
                            lobjEvent.strPostalCode = [ldictEventDetails valueForKey:PCAPI_EVENT_POSTAL_CODE_KEY_STR];
                            lobjEvent.doubleLatitude = [[ldictEventDetails valueForKey:PCAPI_EVENT_LATITUDE_KEY_STR] doubleValue];
                            lobjEvent.doubleLongitude = [[ldictEventDetails valueForKey:PCAPI_EVENT_LONGITUDE_KEY_STR] doubleValue];
                            
                            NSString* lstrStartDate = [ldictEventDetails valueForKey:PCAPI_EVENT_START_DATE_KEY_STR];
                            NSString* lstrStartTime = [ldictEventDetails valueForKey:PCAPI_EVENT_START_TIME_KEY_STR];
                            lobjEvent.objStartDate = [lobjEvent dateFromString:[NSString stringWithFormat:@"%@ %@", lstrStartDate, lstrStartTime]];
                            
                            NSString* lstrEndDate = [ldictEventDetails valueForKey:PCAPI_EVENT_END_DATE_KEY_STR];
                            NSString* lstrEndTime = [ldictEventDetails valueForKey:PCAPI_EVENT_END_TIME_KEY_STR];
                            lobjEvent.objEndDate = [lobjEvent dateFromString:[NSString stringWithFormat:@"%@ %@", lstrEndDate, lstrEndTime]];
                            
                            lobjEvent.bUserCreated = [PopcliqsAPI boolForString:[ldictEventDetails valueForKey:PCAPI_EVENT_IS_USER_CREATED_KEY_STR]];
                            NSString* lstrLeftForCheckInTime = [ldictEventDetails valueForKey:PCAPI_EVENT_CHECK_IN_START_TIME_KEY_STR];
                            NSString* lstrLeftForCheckInDate = [ldictEventDetails valueForKey:PCAPI_EVENT_CHECK_IN_START_DATE_KEY_STR];
                            lobjEvent.objCheckInStartTime = [lobjEvent dateFromString:[NSString stringWithFormat:@"%@ %@", lstrLeftForCheckInDate, lstrLeftForCheckInTime]];
                            
                            SLog(@"Check-In Time : %@", lobjEvent.objCheckInStartTime);
                            
                            [lobjEvent updateState];
                            [lobjEvent scheduleReminderBeforeSeconds:EVENT_TIME_INTERVAL_TWO_HOURS];
                        }
                        
                        NSError* lobjError = nil;
                        
                        if ([lobjMOC save:&lobjError])
                        {
                            // DO nothing
                        }
                        else
                        {
                            SLog(@"ERROR : %@", [lobjError description]);
                        }
                    }
                    
                }
                else
                {
                    SLog(@"ERROR: No data found : %@", lobjData);
                }
            }
            else
            {
                
            }
        }
    }
    else
    {
        SLog(@"ERROR : objReceivedData is nil");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    SLog(@"connection:didFailWithError:%@", [error description]);
}

- (BOOL)eventDataHasOnlyStrings:(NSDictionary*)ldictEvents
{
    BOOL lbEventDataHasOnlyStrings = YES;
    
    NSArray* larrayEvents = [ldictEvents allKeys];
    
    for (NSString* lstrEventKey in larrayEvents)
    {
        NSDictionary* ldictEventDetails = [ldictEvents valueForKey:lstrEventKey];
        
        NSArray* larrayKeys = [ldictEventDetails allKeys];
        
        BOOL lbFoundNonString = NO;
        
        for (NSString* lstrKey in larrayKeys)
        {
            if ([lstrKey isKindOfClass:[NSString class]] == NO)
            {
                lbFoundNonString = YES;
                break;
            }
        }
        
        if (lbFoundNonString == NO)
        {
            NSArray* larrayValues = [ldictEventDetails allValues];
            
            for (NSString* lstrValue in larrayValues)
            {
                if ([lstrValue isKindOfClass:[NSString class]] == NO)
                {
                    lbFoundNonString = YES;
                    break;
                }
            }
        }
        
        if (lbFoundNonString)
        {
            lbEventDataHasOnlyStrings = NO;
            break;
        }
    }
    
    return lbEventDataHasOnlyStrings;
}

-(void)onReceivePushNotification:(NSDictionary *) pushDict andPayload:(NSDictionary *)payload {
    [payload valueForKey:@"title"];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"New Alert !" message:[pushDict valueForKey:@"alert"] delegate:self cancelButtonTitle:@"Thanks !" otherButtonTitles: @"Open",nil];
    [message show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Open"]) {
        [[Pushbots getInstance] OpenedNotification];
        // set Badge to 0
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        // reset badge on the server
        [[Pushbots getInstance] resetBadgeCount];
        
        // Fetch data from events
        if([PopcliqsAPI authKey]){
            [self fetchDataFromInternet];
        }
    }
}

@end
