//
//  EventCell.m
//  Popcliqs
//
//  Created by Praveen Kansara on 09/09/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import "EventCell.h"
#import "LocationConstants.h"

@implementation EventCell

- (void)setEvent:(CDEvent *)event
{
    _event = event;
    
    _event.observer = self;
    
    [_event updateState];
    
    [self updateCellUI];
}

- (void)setEvent:(CDEvent *)event currentLocation:(CLLocation*)lobjCurrentLocation
{
    _event = event;
    
    _event.observer = self;
    
    [_event updateState];
    
    self.currentLocation = lobjCurrentLocation;
    
    [self updateCellUI];
}

- (void)updateCellUI
{
    NSString* lstrDate = [[PopcliqsAPI sharedManager].dateFormatter stringFromDate:self.event.objStartDate];
    if (lstrDate)
    {
        self.objDateLabel.text = lstrDate;
    }
    
    NSString* lstrTitle = self.event.strTitle;
    if (lstrTitle)
    {
        self.objTitleLabel.text = lstrTitle;
    }
    
    NSString* lstrStartTime = [[PopcliqsAPI sharedManager].timeFormatter stringFromDate:self.event.objStartDate];
    if (lstrStartTime)
    {
        self.objStartTimeLabel.text = lstrStartTime;
    }
    
    NSString* lstrEndTime = [[PopcliqsAPI sharedManager].timeFormatter stringFromDate:self.event.objEndDate];
    if (lstrEndTime)
    {
        self.objEndTimeLabel.text = lstrEndTime;
    }
    
    NSString* lstrLocation = self.event.strLocation;
    if (lstrLocation)
    {
        self.objLocationLabel.text = lstrLocation;
    }
    
    NSString* lstrAddress = self.event.strAddress;
    if (lstrAddress)
    {
        self.objAddressLabel.text = lstrAddress;
    }
    
    NSString* lstrCity = self.event.strCity;
    if (lstrCity)
    {
        self.objCityLabel.text = lstrCity;
    }
    
    NSString* lstrPostalCode = self.event.strPostalCode;
    if (lstrPostalCode)
    {
        self.objPostalCodeLabel.text = lstrPostalCode;
    }

    NSString* lstrDescription = self.event.strDescription;
    if (lstrDescription)
    {
        self.objDescription.text = lstrDescription;
    }
    
    CLLocation* lobjEventLocation = [[CLLocation alloc] initWithLatitude:self.event.doubleLatitude longitude:self.event.doubleLongitude];
    float lfloatDistanceFromEvent = fabsf([lobjEventLocation distanceFromLocation:self.currentLocation]);
//    self.objDistance.text = [NSString stringWithFormat:@"%f", lfloatDistanceFromEvent];
    
    switch (self.event.enumEventState)
    {
        case TimeUntilCheckInEventState:
        {
            self.objStatusLabel.hidden = NO;
            self.objStatusLabel.text = [self timeLeftStatusMessage];
            
            self.objCancelButton.enabled = self.event.bUserCreated ? YES : NO;
            self.objSnoozeButton.enabled = NO;
            self.objCheckInButton.enabled = NO;
            
            break;
        }

        case WaitingForUserActionEventState:
        {
            if (self.currentLocation == nil)
            {
                self.objStatusLabel.hidden = NO;
                self.objStatusLabel.text = @"Detecting current location...";
                
                self.objCancelButton.enabled = NO;
                self.objSnoozeButton.enabled = NO;
                self.objCheckInButton.enabled = NO;
            }
            else if (lfloatDistanceFromEvent < GEO_ALERT_TRIGGER_RADIUS)
            {
                self.objStatusLabel.hidden = NO;
                self.objStatusLabel.text = @"Event can be checked-in now";
                
                self.objCancelButton.enabled = self.event.bUserCreated ? YES : NO;
                self.objSnoozeButton.enabled = YES;
                self.objCheckInButton.enabled = YES;
            }
            else
            {
                self.objStatusLabel.hidden = NO;
                self.objStatusLabel.text = @"Not close to event";
                
                self.objCancelButton.enabled = self.event.bUserCreated ? YES : NO;
                self.objSnoozeButton.enabled = NO;
                self.objCheckInButton.enabled = NO;
            }
        
            break;
        }

        case SnoozedEventState:
        {
            self.objStatusLabel.hidden = NO;
            self.objStatusLabel.text = @"Snoozed";

            self.objCancelButton.enabled = self.event.bUserCreated ? YES : NO;
            self.objSnoozeButton.enabled = NO;
            self.objCheckInButton.enabled = YES;
            
            break;
        }

        case CheckingInEventState:
        {
            self.objStatusLabel.hidden = NO;
            self.objStatusLabel.text = @"Checking in ...";
            
            self.objCancelButton.enabled = NO;
            self.objSnoozeButton.enabled = NO;
            self.objCheckInButton.enabled = NO;
            
            break;
        }

        case CheckingInFailedEventState:
        {
            self.objStatusLabel.hidden = NO;
            self.objStatusLabel.text = @"Checking in failed ...";
            
            self.objCancelButton.enabled = NO;
            self.objSnoozeButton.enabled = NO;
            self.objCheckInButton.enabled = NO;
            
            break;
        }
            
        case CheckedInEventState:
        {
            self.objStatusLabel.hidden = NO;
            self.objStatusLabel.text = @"Check-in Successful";
            
            self.objCancelButton.enabled = NO;
            self.objSnoozeButton.enabled = NO;
            self.objCheckInButton.enabled = NO;
            
            break;
        }

        case CancellingEventState:
        {
            self.objStatusLabel.hidden = NO;
            self.objStatusLabel.text = @"Cancelling ...";
            
            self.objCancelButton.enabled = NO;
            self.objSnoozeButton.enabled = NO;
            self.objCheckInButton.enabled = NO;
            
            break;
        }
            
        case CancellingFailedEventState:
        {
            self.objStatusLabel.hidden = NO;
            self.objStatusLabel.text = @"Cancelling failed ...";
            
            self.objCancelButton.enabled = NO;
            self.objSnoozeButton.enabled = NO;
            self.objCheckInButton.enabled = NO;
            
            break;
        }

        case CancelledEventState:
        {
            self.objStatusLabel.hidden = NO;
            self.objStatusLabel.text = @"Cancel Successful";
            
            self.objCancelButton.enabled = NO;
            self.objSnoozeButton.enabled = NO;
            self.objCheckInButton.enabled = NO;
            
            break;
        }

        default:
        {
            self.objStatusLabel.hidden = YES;
            self.objStatusLabel.text = nil;
            
            self.objCancelButton.enabled = YES;
            self.objSnoozeButton.enabled = YES;
            self.objCheckInButton.enabled = YES;
            
            break;
        }
    }
    
    self.objSnoozeButton.hidden = YES;
    self.objCheckInButton.alpha = self.objCheckInButton.enabled ? 1.0f : 0.5f;
    self.objCancelButton.alpha = self.objCancelButton.enabled ? 1.0f : 0.5f;
}

- (IBAction)snoozeButtonPressed:(UIButton*)lobjSnoozeButton
{
    if (self.event)
    {
        [self.event snooze];
    }
}

- (IBAction)checkInButtonPressed:(UIButton*)lobjCheckInButton
{
    if (self.event)
    {
        [self.event checkIn];
    }
}

- (IBAction)cancelButtonPressed:(UIButton*)lobjCancelButton
{
    if (self.event)
    {
        [self.event cancel];
    }
}

- (NSString*)timeLeftStatusMessage
{
    NSDate* lobjDate = [NSDate date];
    NSDate* lobjCheckInStartDate = self.event.objCheckInStartTime;
    NSInteger lintTimeUntilCheckInSeconds = [lobjCheckInStartDate timeIntervalSinceDate:lobjDate];
    NSInteger lintTimeUntilCheckInMins = lintTimeUntilCheckInSeconds/60;
    NSInteger lintHoursUntilCheckin = lintTimeUntilCheckInMins / 60;
    NSInteger lintMinsUntilCheckin = lintTimeUntilCheckInMins - (lintHoursUntilCheckin * 60);
    
    NSString* lstrMinuteString = nil;
    {
        if (lintMinsUntilCheckin == 1)
        {
            lstrMinuteString = @"min";
        }
        else
        {
            lstrMinuteString = @"mins";
        }
    }
    
    NSString* lstrHourString = nil;
    {
        if (lintMinsUntilCheckin == 1)
        {
            lstrHourString = @"hour";
        }
        else
        {
            lstrHourString = @"hours";
        }
    }
    
    NSString* lstrTimeLeftMessage = nil;
    
    if (lintHoursUntilCheckin == 0)
    {
        lstrTimeLeftMessage = [NSString stringWithFormat:@"Time left until checkin is %ld %@",
                                 (long)lintMinsUntilCheckin,
                                 lstrMinuteString];
    }
    else
    {
        lstrTimeLeftMessage =
        [NSString stringWithFormat:@"Time left until checkin is %ld %@ %ld %@",
         (long)lintHoursUntilCheckin,
         lstrHourString,
         (long)lintMinsUntilCheckin,
         lstrMinuteString];
    }
    
    return lstrTimeLeftMessage;
}

- (void)eventDidChangeState:(CDEvent *)lobjEvent
{
    if (self.event == lobjEvent)
    {
        [self updateCellUI];
    }
}

@end
