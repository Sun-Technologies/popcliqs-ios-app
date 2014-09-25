//
//  EventCell.h
//  Popcliqs
//
//  Created by Praveen Kansara on 09/09/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataStack.h"

@interface EventCell : UITableViewCell <CDEventObserver>

@property (nonatomic, weak) CDEvent* event;
@property (nonatomic, weak) CLLocation* currentLocation;

@property IBOutlet UILabel* objDateLabel;
@property IBOutlet UILabel* objTitleLabel;
@property IBOutlet UILabel* objStartTimeLabel;
@property IBOutlet UILabel* objEndTimeLabel;
@property IBOutlet UILabel* objDescription;
@property IBOutlet UILabel* objLocationLabel;
@property IBOutlet UILabel* objAddressLabel;
@property IBOutlet UILabel* objCityLabel;
@property IBOutlet UILabel* objPostalCodeLabel;

@property IBOutlet UILabel* objStatusLabel;

@property IBOutlet UIButton* objCheckInButton;
@property IBOutlet UIButton* objSnoozeButton;
@property IBOutlet UIButton* objCancelButton;

@property IBOutlet NSLayoutConstraint* objDescriptionLabelHeightConstraint;
@property IBOutlet NSLayoutConstraint* objAddressLabelHeightConstraint;


- (void)setEvent:(CDEvent *)event currentLocation:(CLLocation*)lobjCurrentLocation;

@end
