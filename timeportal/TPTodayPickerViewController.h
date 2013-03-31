//
//  TPTodayPickerViewController.h
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPTodayPickerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *todayPicker;
- (IBAction)todayPicked:(id)sender;

@end
