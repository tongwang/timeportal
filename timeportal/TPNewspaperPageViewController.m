//
//  TPNewspaperPageViewController.m
//  timeportal
//
//  Created by Tong Wang on 2/10/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "TPNewspaperPageViewController.h"
#import "TPNewspaperPdfViewController.h"
#import "CANewspaperApi.h"

@interface TPNewspaperPageViewController ()

@end

@implementation TPNewspaperPageViewController

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options newspaperEdition:(TPNewspaperEdition *)anEdition
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    if (self) {
        // Custom initialization
        _edition = anEdition;

        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//
// DataSource protocol methods
//

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    TPNewspaperPdfViewController *currentVC = (TPNewspaperPdfViewController *)viewController;
    int currentPage = [currentVC pageNumber];
    currentPage--;
    if (currentPage < 0) {
        return nil;
    }
    return [self viewControllerAtPage:currentPage];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    TPNewspaperPdfViewController *currentVC = (TPNewspaperPdfViewController *)viewController;
    int currentPage = [currentVC pageNumber];
    currentPage++;
    
    if (currentPage >= [_edition pageCount]) {
        return nil;
    }
    
    return [self viewControllerAtPage:currentPage];
}

- (void)displayPageLoadError
{
    // display error
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Can not load newspaper page. Please check Internet connection."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}

- (TPNewspaperPdfViewController *)viewControllerAtPage:(int) pageNumber
{
    TPNewspaperPdfViewController *vc = [[TPNewspaperPdfViewController alloc] initWithEdition:_edition pageNumber:pageNumber];
    
    if ([vc pdfLoaded] == NO) {
        [self displayPageLoadError];
        return nil;
    } else {
        //
        // pre-load next page of the newspaper asynch
        //
        if (pageNumber+1 < [_edition pageCount]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [CANewspaperApi pdfForNewspaperEdition:_edition page:pageNumber+1];
            });
        }
        
        return vc;
    }
}

//
// UIPageViewControllerDelegate methods
//
// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
- (void)pageViewController:(UIPageViewController *)thePageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        //updatePageControl
        SEL selector = NSSelectorFromString(@"updatePageControl");
        [[self parentViewController] performSelector:selector];
    }
    
}

@end
