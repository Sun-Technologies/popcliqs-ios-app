//
//  HomeViewController.m
//  Popcliqs
//
//  Created by Praveen Kansara on 19/08/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import "HomeViewController.h"
#import "HowItWorksPageControlViewController.h"
#import "LogInViewController.h"

#import "PopcliqsAPI.h"
#import "CoreDataStack.h"

@interface HomeViewController ()

@property (nonatomic, strong) NSMutableArray* arrayConnections;
@property (nonatomic, strong) NSMutableData* objDataRecieved;

@end

@implementation HomeViewController

#pragma mark - Event Related Methods

- (void)presentLogInControllerIfNeeded
{
    if ([PopcliqsAPI authKey])
    {
        // Continue
    }
    else
    {
        if (self.storyboard)
        {
            UINavigationController* lobjLoginNC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            
            [self presentViewController:lobjLoginNC
                               animated:YES
                             completion:^{}];
        }
        else
        {
            SLog(@"ERROR : storyboard is nil");
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self presentLogInControllerIfNeeded];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"HomeToHowItWorks"])
    {
//        HowItWorksPageControlViewController* lobjHIWPCVC =
//        (HowItWorksPageControlViewController*)segue.destinationViewController;
    }
}

- (IBAction)eventsButtonPressed:(UIButton*)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[PopcliqsAPI eventsURL]]];
}

- (IBAction)howitworksButtonPressed:(UIButton *)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [PopcliqsAPI howitWorksURL]]];

}

- (IBAction)logoutButtonPressed:(UIButton*)sender
{
    [PopcliqsAPI deleteAuthKey];
    [CoreDataStack cleanDatabase];
    
    [self presentLogInControllerIfNeeded];
}

- (IBAction)dumpData:(UIButton*)sender
{
//    NSDate* lobjDate = [[NSDate date] dateByAddingTimeInterval:30];
//    NSCalendar* lobjCalendar = [NSCalendar currentCalendar];
//    NSDateComponents* lobjDateCOmponents = [lobjCalendar components:NSHourCalendarUnit fromDate:lobjDate];
//    NSString* lstrStartHour = [NSString stringWithFormat:@"%d", [lobjDateCOmponents hour]];
    
    self.arrayConnections = [NSMutableArray arrayWithCapacity:8];
    
    for (int index = 1; index < 9; index++)
    {
        float lfloatStarHour = 2.5f;
        
        if (index > 3)
        {
            lfloatStarHour = 3.5f;
        }
        
        NSString* lstrZipCode = @"";
        
        if (index % 2)
        {
            lstrZipCode = @"342005";
        }
        else
        {
            lstrZipCode = @"342011";
        }
        
        NSString* lstrStartHour = [NSString stringWithFormat:@"%.1f", lfloatStarHour];
        NSString* lstrCreateEvent = [PopcliqsAPI createEventForCategory:[NSString stringWithFormat:@"%d", index]
                                                              startHour:lstrStartHour
                                                                zipCode:lstrZipCode];
        NSURL* lobjURL = [NSURL URLWithString:lstrCreateEvent];
        NSURLRequest* lobjURLRequest = [NSURLRequest requestWithURL:lobjURL];
        NSURLConnection* lobjConnection = [NSURLConnection connectionWithRequest:lobjURLRequest delegate:self];
        [self.arrayConnections addObject:lobjConnection];
    }
}


//---------------------------------------------------------------------------------
#pragma mark - ConnectionDelegates
//---------------------------------------------------------------------------------

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    SLog(@"connection:%@ didReceiveData", [[[connection originalRequest] URL] absoluteString]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    SLog(@"connectionDidFinishLoading:%@", [[[connection originalRequest] URL] absoluteString]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    SLog(@"connection:%@ didFailWithError:%@", [[[connection originalRequest] URL] absoluteString], [error description]);
}

@end
