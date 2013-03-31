//
//  TPNewspaperWrapperViewController.h
//  timeportal
//
//  Created by Tong Wang on 2/15/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "TPNewspaperPageViewController.h"

@interface TPNewspaperWrapperViewController : UIViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate>
{
    
    __weak IBOutlet UIView *titleBar;
    __weak IBOutlet UIView *footerBar;
    __weak IBOutlet UILabel *newspaperTitle;
    __weak IBOutlet UIButton *doneButton;
    __weak IBOutlet UIPageControl *pageControl;
    
    TPNewspaperPageViewController *pageViewController;
    
    BOOL headerFooterHidden;
    
    UIDocumentInteractionController *docController;
}

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options newspaperEdition:(TPNewspaperEdition *)edition;

- (IBAction)done:(id)sender;
- (IBAction)share:(id)sender;

- (IBAction)viewTapped:(id)sender;

- (void)updatePageControl;

@end
