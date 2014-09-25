//
//  AppDelegate.h
//  Popcliqs
//
//  Created by Praveen Kansara on 17/08/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocationManager*    objLocationManager;

- (BOOL)geoFenceLocation:(CLLocationCoordinate2D)lclLocationCoordinate
              withRadius:(CLLocationDistance)lclLocationDistance
              identifier:(NSString*)lstrIdentifier;

- (BOOL)removeGeoFenceWithIdentifier:(NSString*)lstrIdentifier;

@end
