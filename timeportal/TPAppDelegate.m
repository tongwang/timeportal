//
//  TPAppDelegate.m
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "TPAppDelegate.h"

#import "TPMasterViewController.h"
#import "TPTodayPickerViewController.h"
#import "TPNewspapersConfigViewController.h"
#import "TPConfiguration.h"
#import "CANewspaperApi.h"

@implementation TPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    [self loadNewspapers];
    
    mvc = [[TPMasterViewController alloc] init];
    
    TPTodayPickerViewController *tvc = [[TPTodayPickerViewController alloc] init];
    
    TPNewspapersConfigViewController *newsvc = [[TPNewspapersConfigViewController alloc] init];
    
    UINavigationController *configNavController = [[UINavigationController alloc]initWithRootViewController:newsvc];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    NSArray *viewControllers = [NSArray arrayWithObjects:mvc, tvc, configNavController, nil];
    [tabBarController setViewControllers:viewControllers];
    
    
    [[self window] setRootViewController:tabBarController];
    
    //
    // locate user
    //
    if ([[TPConfiguration instance] preferredState] == nil) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        // doesn't need to be accurate
        [locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
        [locationManager startUpdatingLocation];
    }

    
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)loadNewspapers {
    static BOOL newspaperLoaded = NO;
    
    if (!newspaperLoaded) {
        // load newspapers
        NSArray *newspapers = [CANewspaperApi newspapers];
        if ([newspapers count] == 0) {
            return NO;
        } else {
            newspaperLoaded = YES;
        }
    }
    return YES;
}

//
// CLLocationManagerDelegate methods
//
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // How many seconds ago was this new location created?
    NSTimeInterval t = [[newLocation timestamp] timeIntervalSinceNow];
    
    // CLLocationManagers will return the last found location of the
    // device first, you don't want that data in this case.
    // If this location was made more than 3 minutes ago, ignore it.
    if (t < -180) {
        // This is cached data, you don't want it, keep looking
        return;
    }
    
    [self foundLocation:newLocation];
}

- (void)foundLocation:(CLLocation *)loc
{
    [locationManager stopUpdatingLocation];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation: loc completionHandler: ^(NSArray *placemarks, NSError *error)
     {
         //Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         
         [[TPConfiguration instance] setPreferredState:[placemark administrativeArea]];
         
         NSLog(@"Location :%@",[placemark administrativeArea]);
     }];

    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // refresh master view, in case need to display new newspapers as enter tomorrow
    // another chance to load newspaper in case if failed before
    [self loadNewspapers];
    [mvc viewWillAppear:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
