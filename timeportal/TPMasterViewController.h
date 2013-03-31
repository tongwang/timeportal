//
//  TPMasterViewController.h
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPDetailViewController;

@interface TPMasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    // array of TPNewspaperEditions
    NSMutableArray *newspaperEditions;
    
    // portal date this view is based on
    NSUInteger portalYear;
    NSUInteger portalMonth;
    NSUInteger portalDay;
    
    // subscripton this view is based on
    NSArray *subscription;
    
    __weak IBOutlet UILabel *todayLabel;
    
    __weak IBOutlet UIActivityIndicatorView *loadingIndicator;
    
    __weak IBOutlet UILabel *noNewspaperLabel;
    __weak IBOutlet UILabel *noSubscriptionLabel;
    
    int newspaperRespondReceived;
    BOOL networkErrorDetected;
    
}
@property (weak, nonatomic) IBOutlet UITableView *newspaperTableView;

@end
