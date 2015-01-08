//
//  ViewController.m
//  Popcliqs
//
//  Created by Praveen Kansara on 17/08/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import "LogInViewController.h"
#import "HowItWorksPageControlViewController.h"

#import "CoreDataStack.h"
#import "PopcliqsAPI.h"

#import "AppDelegate.h"
#import "UIButton+Network.h"


@interface LogInViewController () <NSURLConnectionDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSURLConnection*  objConnection;
@property (nonatomic, strong) NSMutableData*    objReceivedData;

@end

@implementation LogInViewController

- (IBAction)loginButtonPressed:(UIButton*)lobjLogInButton
{
    if (self.objUserNameTextField.text.length == 0)
    {
        self.objUserNameTextField.textColor = [UIColor redColor];
        self.objUserNameTextField.placeholder = @"Please enter an email";
    }
    
    if (self.objPasswordTextField.text.length == 0)
    {
        self.objPasswordTextField.textColor = [UIColor redColor];
        self.objPasswordTextField.placeholder = @"Please enter a password";
    }
    
    if (self.objUserNameTextField.text.length > 0 &&
        self.objPasswordTextField.text.length > 0)
    {
        NSString* lstrLoginURL = [PopcliqsAPI logInURLForUsername:self.objUserNameTextField.text
                                                         password:self.objPasswordTextField.text];
        
        self.objReceivedData = [NSMutableData data];
        
        self.objConnection = [NSURLConnection connectionWithRequest:
                              [NSURLRequest requestWithURL:[NSURL URLWithString:lstrLoginURL]]
                                                           delegate:self];
    }
    
    [lobjLogInButton addActivityIndicator];
}

- (IBAction)forgotPasswordButtonPressed:(UIButton*)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[PopcliqsAPI forgotPasswordURL]]];
}

- (IBAction)signUpButtonPressed:(UIButton*)lobjButton
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[PopcliqsAPI signUpURL]]];
}

- (IBAction)howitworksButtonPressed:(UIButton *)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [PopcliqsAPI howitWorksURL]]];    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LogInToHowItWorks"])
    {
//        HowItWorksPageControlViewController* lobjHIWPCVC =
//        (HowItWorksPageControlViewController*)segue.destinationViewController;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)clearPreviousData
{
    NSManagedObjectContext* lobjFetchMOC = [[CoreDataStack sharedInstance] createManagedObjectContext];
    
    NSFetchRequest* lobjFetchRequest = [[NSFetchRequest alloc] initWithEntityName:CD_EVENT_NAME];
    [lobjFetchRequest setResultType:NSManagedObjectIDResultType];
    
    NSError* lobjError = nil;
    NSArray* larrayEvents = [lobjFetchMOC executeFetchRequest:lobjFetchRequest error:&lobjError];
    
    if (lobjError == nil)
    {
        for (NSManagedObjectID* lobjId in larrayEvents)
        {
            [lobjFetchMOC deleteObject:[lobjFetchMOC objectWithID:lobjId]];
        }
        
        if ([lobjFetchMOC save:&lobjError] == NO)
        {
            SLog(@"ERROR : %@", [lobjError description]);
        }
    }
    else
    {
        SLog(@"ERROR : %@", [lobjError description]);
    }
}

- (IBAction)addNewData
{
    NSManagedObjectContext* lobjInsertMOC = [[CoreDataStack sharedInstance] createManagedObjectContext];
    
    for (int lintEventNumber = 0; lintEventNumber < 20; lintEventNumber++)
    {
        CDEvent* lobjEvent = [NSEntityDescription insertNewObjectForEntityForName:CD_EVENT_NAME
                                                           inManagedObjectContext:lobjInsertMOC];
        
        lobjEvent.strTitle = [NSString stringWithFormat:@"Event %d", lintEventNumber];
        lobjEvent.strDescription = @"Place holder Description";
        lobjEvent.doubleLatitude = 26.248f;
        lobjEvent.doubleLongitude = 73.024696f;
        lobjEvent.strIdentifier = [NSString stringWithFormat:@"%d", lintEventNumber];
        
        [lobjEvent geoFence];
    }
    
    NSError* lobjError = nil;
    
    if ([lobjInsertMOC save:&lobjError] == NO)
    {
        SLog(@"ERROR : %@", [lobjError description]);
    }
}

//---------------------------------------------------------------------------------
#pragma mark - UiTextViewDelegate
//---------------------------------------------------------------------------------

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor = [UIColor blackColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return  YES;
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
        [self.objLoginButton removeActivityIndicator];
        
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
                NSString* lobjExitCode = [lobjData valueForKey:PCAPI_EXIT_CODE_KEY_STR];
                
                if ([PopcliqsAPI isExitCodeSuccess:lobjExitCode])
                {
                    SLog(@"Date is %@", lobjData);
                    
                    
                    NSString* lstrAuthKey = [lobjData valueForKey:PCAPI_AUTH_KEY_STR];
                    
                    [PopcliqsAPI saveAuthKey:lstrAuthKey];
                 
                    [self dismissViewControllerAnimated:YES completion:^{}];
                }
                else
                {
                    self.objPasswordTextField.textColor = [UIColor redColor];
                    self.objUserNameTextField.textColor = [UIColor redColor];
                    
                    UIAlertView* lobjAlertView = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                                            message:@"Please check your email and password and try again."
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Ok"
                                                                  otherButtonTitles:nil];
                    
                    [lobjAlertView show];
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
    
    [self.objLoginButton removeActivityIndicator];
}

@end
