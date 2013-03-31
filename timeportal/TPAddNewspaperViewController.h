//
//  TPAddNewspaperViewController.h
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPAddNewspaperViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate>
{
    NSArray *availableNewspapers;
}

@property (weak, nonatomic) IBOutlet UIPickerView *statePicker;

@property (weak, nonatomic) IBOutlet UITableView *newspaperTable;

@property (nonatomic, copy) void (^dismissBlock)(void);

@end
