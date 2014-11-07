//
//  CheckInViewController.m
//  Popcliqs
//
//  Created by Praveen Kansara on 09/09/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import "CheckInViewController.h"

#import "PopcliqsAPI.h"
#import "CoreDataStack.h"

#import "EventCell.h"

@interface CheckInViewController () <NSFetchedResultsControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSFetchedResultsController* objFRC;
@property (nonatomic, strong) NSManagedObjectContext* objMOC;
@property (nonatomic, strong) NSURLConnection* objConnection;
@property (nonatomic, strong) NSMutableData* objReceivedData;
@property (nonatomic, strong) CLLocationManager* objLocationManager;
@property (nonatomic, strong) CLLocation*        objCurrentLocation;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorObject;


@property (nonatomic, strong) UILabel* objNoEventsLabel;


@end

@implementation CheckInViewController

- (void)didBecomeActive:(NSNotification*)lobjNotification
{
    
    [self fetchDataFromInternet];
}

- (void)willResignActive:(NSNotification*)lobjNotification
{

}

- (void)contextDidChange:(NSNotification*)lobjMOCDidChangeNotification
{
    NSManagedObjectContext* lobjMOC = [lobjMOCDidChangeNotification object];
    
    if (lobjMOC == self.objMOC)
    {
        SLog(@"Detected change in context");
        
        [self loadDataInFRC];
    }
}

- (void)fetchDataFromInternet
{
    self.activityIndicatorObject = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorObject.center = self.view.center;

    [self.view addSubview:self.activityIndicatorObject];
    [self.activityIndicatorObject startAnimating];
    
    self.objReceivedData = [NSMutableData data];
    NSURL* lobjURL = [NSURL URLWithString:[PopcliqsAPI checkInEventsURL]];
    NSURLRequest* lobjRequest = [NSURLRequest requestWithURL:lobjURL];
    self.objConnection = [NSURLConnection connectionWithRequest:lobjRequest delegate:self];
}

- (void)loadDataInFRC
{
    NSError* lobjError = nil;
    
    NSFetchRequest* lobjFetchRequest = [[NSFetchRequest alloc] initWithEntityName:CD_EVENT_NAME];
    NSSortDescriptor* lobjSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"objStartDate" ascending:YES];
    [lobjFetchRequest setSortDescriptors:@[lobjSortDescriptor]];
    
    self.objFRC = [[NSFetchedResultsController alloc]
                   initWithFetchRequest:lobjFetchRequest
                   managedObjectContext:self.objMOC
                   sectionNameKeyPath:nil
                   cacheName:nil];
    
    self.objFRC.delegate = self;
    
    if ([self.objFRC performFetch:&lobjError] == NO || lobjError)
    {
        SLog(@"ERROR : %@", [lobjError description]);
    }
    else
    {
        [self.tableView reloadData];
    }
}

- (void)dealloc
{
    NSNotificationCenter* lobjNC = [NSNotificationCenter defaultCenter];
    [lobjNC removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Register for Notification
    NSNotificationCenter* lobjNC = [NSNotificationCenter defaultCenter];
    [lobjNC addObserver:self
               selector:@selector(didBecomeActive:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    
    [lobjNC addObserver:self
               selector:@selector(willResignActive:)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
    
    [lobjNC addObserver:self
               selector:@selector(contextDidChange:)
                   name:NSManagedObjectContextObjectsDidChangeNotification
                 object:nil];
    
    self.objMOC = [[CoreDataStack sharedInstance] createManagedObjectContext];
    
    [self startLocationServices];
    

    [self fetchDataFromInternet];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.objMOC hasChanges])
    {
        NSError* lobjError = nil;
        
        if ([self.objMOC save:&lobjError])
        {
            // Do nothing
        }
        else
        {
            SLog(@"ERROR : %@", [lobjError description]);
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger lintSections = [[self.objFRC sections] count];
    
    return lintSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.objFRC sections] count] > section)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.objFRC sections] objectAtIndex:section];

        NSInteger lintRows = [sectionInfo numberOfObjects];
        
        if (lintRows == 0)
        {
            if (self.objNoEventsLabel == nil)
            {
                self.objNoEventsLabel = [[UILabel alloc]
                                         initWithFrame:CGRectMake(0, 0,
                                                                  self.view.bounds.size.width,
                                                                  self.view.bounds.size.height)];
                
                self.objNoEventsLabel.text = @"No events available";
                self.objNoEventsLabel.textAlignment = NSTextAlignmentCenter;
                self.objNoEventsLabel.backgroundColor = [UIColor whiteColor];
            }
            
            [self.view addSubview:self.objNoEventsLabel];
        }
        else
        {
            [self.objNoEventsLabel removeFromSuperview];
        }
        
        return lintRows;
    }
    else
    {
        return 0;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strEventCell = @"EventCell";
    
    CDEvent* lobjEvent = (CDEvent*)[self.objFRC objectAtIndexPath:indexPath];
    EventCell* lobjEventCell = [tableView dequeueReusableCellWithIdentifier:strEventCell];
    lobjEventCell.objAddressLabelHeightConstraint.constant = 60.0f;
    lobjEventCell.objDescriptionLabelHeightConstraint.constant = 60.0f;
    
    if (lobjEvent)
    {
        CGSize maximumLabelSize = CGSizeMake(tableView.bounds.size.width, MAXFLOAT);
        
        NSStringDrawingOptions options;
        options = NSStringDrawingTruncatesLastVisibleLine |
        NSStringDrawingUsesLineFragmentOrigin;
        
        NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
        
        // Reduction due to description
        {
            NSString* lstrDescription = lobjEvent.strDescription;
            
            CGRect expectedLabelRect = [lstrDescription boundingRectWithSize:maximumLabelSize
                                                                     options:options
                                                                  attributes:attr
                                                                     context:nil];
            
            if (expectedLabelRect.size.height < 60.0f)
            {
                CGFloat lfloatReductionInHeight = (60.0f - expectedLabelRect.size.height);
                lobjEventCell.objDescriptionLabelHeightConstraint.constant -= lfloatReductionInHeight;
            }
        }
        
        // Reduction Due to Address
        {
            NSString* lstrDescription = lobjEvent.strAddress;
            
            CGRect expectedLabelRect = [lstrDescription boundingRectWithSize:maximumLabelSize
                                                                     options:options
                                                                  attributes:attr
                                                                     context:nil];
            
            if (expectedLabelRect.size.height < 60.0f)
            {
                CGFloat lfloatReductionInHeight = (60.0f - expectedLabelRect.size.height);
                lobjEventCell.objAddressLabelHeightConstraint.constant -= lfloatReductionInHeight;
            }
        }
    }
    
    [lobjEventCell setEvent:lobjEvent currentLocation:self.objCurrentLocation];
    
    return lobjEventCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CDEvent* lobjEvent = (CDEvent*)[self.objFRC objectAtIndexPath:indexPath];
    
    CGFloat lfloatReductionInHeight = 0.0f;
    
    if (lobjEvent)
    {
        CGSize maximumLabelSize = CGSizeMake(tableView.bounds.size.width, MAXFLOAT);
        
        NSStringDrawingOptions options;
        options = NSStringDrawingTruncatesLastVisibleLine |
        NSStringDrawingUsesLineFragmentOrigin;
        
        NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
        
        // Reduction due to description
        {
            NSString* lstrDescription = lobjEvent.strDescription;
            
            CGRect expectedLabelRect = [lstrDescription boundingRectWithSize:maximumLabelSize
                                                                     options:options
                                                                  attributes:attr
                                                                     context:nil];
            
            if (expectedLabelRect.size.height < 60.0f)
            {
                lfloatReductionInHeight += (60.0f - expectedLabelRect.size.height);
            }
        }
        
        // Reduction Due to Address
        {
            NSString* lstrDescription = lobjEvent.strAddress;
            
            CGRect expectedLabelRect = [lstrDescription boundingRectWithSize:maximumLabelSize
                                                                     options:options
                                                                  attributes:attr
                                                                     context:nil];
            
            if (expectedLabelRect.size.height < 60.0f)
            {
                lfloatReductionInHeight += (60.0f - expectedLabelRect.size.height);
            }
        }

        
    }
    
    return (343.0f - lfloatReductionInHeight);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

-(void)controller:(NSFetchedResultsController *)controller
  didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath
    forChangeType:(NSFetchedResultsChangeType)type
     newIndexPath:(NSIndexPath *)newIndexPath
{
//    SLog(@"Data Change conveyed");
    
    switch (type)
    {
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;

        case NSFetchedResultsChangeInsert:
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.objFRC)
    {
        [self.tableView reloadData];
    }
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
    
    
    [self.activityIndicatorObject stopAnimating];
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
                        
                        //NSManagedObjectContext* lobjMOC = [[CoreDataStack sharedInstance] createManagedObjectContext];
                        
                        NSArray* larrayEvents = [ldictEvents allKeys];
                        
                        for (NSString* lstrEventKey in larrayEvents)
                        {
                            NSDictionary* ldictEventDetails = [ldictEvents valueForKey:lstrEventKey];
                            
                            CDEvent* lobjEvent = [NSEntityDescription insertNewObjectForEntityForName:CD_EVENT_NAME
                                                                               inManagedObjectContext:self.objMOC];
                            
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
                        
                        if ([self.objMOC save:&lobjError])
                        {
                           [self loadDataInFRC];
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
    
    [self.activityIndicatorObject stopAnimating];
    
    self.objNoEventsLabel = [[UILabel alloc]
                             initWithFrame:CGRectMake(0, 0,
                                                      self.view.bounds.size.width,
                                                      self.view.bounds.size.height)];
    
    self.objNoEventsLabel.text = @"Error connecting to Popcliqs Server";
    self.objNoEventsLabel.textAlignment = NSTextAlignmentCenter;
    self.objNoEventsLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.objNoEventsLabel];
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

//---------------------------------------------------------------------------------
#pragma mark - Location related methods
//---------------------------------------------------------------------------------

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
        
        if ([self.objLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [self.objLocationManager requestWhenInUseAuthorization];
        }
        
        [self.objLocationManager startUpdatingLocation];
        
        self.objCurrentLocation = nil;
    }
    else
    {
        SLog(@"locationServicesEnabled:NO");
        
        [self promptForLocationServicesIfDisabled];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    SLog(@"didChangeAuthorizationStatus");
    
    [self promptForLocationServicesIfDisabled];
    
    [self startLocationServices];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    SLog(@"locationManager:didFailWithError:%@", [error description]);
    
    self.objCurrentLocation = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    SLog(@"locationManager:didUpdateLocations");
    
    CLLocation* lobjLastLocation = [locations lastObject];
    
    float lfloatTimeDifference = fabs([lobjLastLocation.timestamp timeIntervalSinceNow]);
    
    if (lfloatTimeDifference < 300)
    {
        self.objCurrentLocation = [locations lastObject];
        
        [manager stopUpdatingLocation];
        
        [self.tableView reloadData];
    }
    else
    {
        // Wait for more updates
    }
}

//---------------------------------------------------------------------------------
#pragma mark - Check-in Button
//---------------------------------------------------------------------------------

- (IBAction)checkInButtonPressed:(id)sender
{
    SLog(@"Checin");
}

@end
