//
//  TPTodayPickerViewController.m
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "TPTodayPickerViewController.h"
#import "TPConfiguration.h"

@interface TPTodayPickerViewController ()

@end

@implementation TPTodayPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Get the tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        // Give it a label
        [tbi setTitle:@"Portal"];
        
        // Create a UIImage from a file
        // This will use Time@2x.png on retina display devices
        UIImage *i = [UIImage imageNamed:@"Time.png"];
        // Put that image on the tab bar item
        [tbi setImage:i];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDate *portalDate = [[TPConfiguration instance] portalDate];
    [_todayPicker setDate:portalDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)todayPicked:(id)sender {
    [[TPConfiguration instance] setPortalDate:[_todayPicker date]];
}
@end
