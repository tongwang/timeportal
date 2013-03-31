//
//  TPMasterViewController.m
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "TPMasterViewController.h"

#import "TPConfiguration.h"
#import "CANewspaperApi.h"
#import "TPNewspaperPageViewController.h"
#import "TPNewspaperWrapperViewController.h"


@implementation TPMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Get the tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        // Give it a label
        [tbi setTitle:@"Newsstand"];
        
        // Create a UIImage from a file
        // This will use Hypno@2x.png on retina display devices
        UIImage *i = [UIImage imageNamed:@"newspaper.png"];
        // Put that image on the tab bar item
        [tbi setImage:i];
        
        // set flag is network issue detected
        if (![CANewspaperApi newspapersLoaded]) {
            // network problem
            networkErrorDetected = YES;
        }

    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    networkErrorDetected = ![CANewspaperApi newspapersLoaded];
    if (!networkErrorDetected) {
        [self buildModel];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // display the date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, MMM d, yyyy"];    
    NSString *todayString = [df stringFromDate:[[TPConfiguration instance] portalDate]];
    [todayLabel setText:todayString];
    
    // check to see if need to rebuild model
    if ([self modelNeedRefresh]) {
        [self buildModel];
    }
}

- (BOOL)modelNeedRefresh
{
    if (networkErrorDetected) {
        // recover from last failure
        return YES;
    }
    NSDateComponents *dateComponent = [[TPConfiguration instance] portalDateComponent];
    if ([dateComponent year] != portalYear
        || [dateComponent month] != portalMonth
        || [dateComponent day] != portalDay) {
        // portal date has been changed
        return YES;
    }
    // check if subscription has been changed
    return ! ([subscription isEqualToArray:[[TPConfiguration instance] lccns]]);
}

- (void)buildModel
{
    // clear out existing newsstand
    newspaperEditions = [[NSMutableArray alloc] init];
    [[self newspaperTableView] reloadData];

    TPConfiguration *config = [TPConfiguration instance];
    subscription = [[NSArray alloc] initWithArray:[config lccns]];
    
    if ([subscription count] == 0) {
        [noSubscriptionLabel setHidden:NO];
        return;
    }
    
    // animate indicator, hide all labels
    [loadingIndicator startAnimating];
    [self setHiddenNoNewspapersLabel:YES];
    [noSubscriptionLabel setHidden:YES];
    
    NSDateComponents *portalDateComponent = [config portalDateComponent];
    portalYear = [portalDateComponent year];
    portalMonth = [portalDateComponent month];
    portalDay = [portalDateComponent day];
    
    newspaperRespondReceived = 0;
    
    // reset
    networkErrorDetected = NO;
    
    for (NSString *lccn in subscription) {
        //
        // load newspapers asynch since it can take some time
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            TPNewspaperEdition *edition = [self fetchNewspaperEdition:lccn year:portalYear month:portalMonth day:portalDay];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self newspaperEditionFetched:edition];
            });
        });
    }
}

//
// task to load a newspaper edition
//
- (TPNewspaperEdition *)fetchNewspaperEdition:(NSString *)lccn year:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    return [CANewspaperApi newspaperEdition:lccn year:year month:month day:day];
}

//
// task to update UI when newspaper edition is fetched
//
- (void)newspaperEditionFetched:(TPNewspaperEdition *)edition
{
    @synchronized(newspaperEditions) {
        newspaperRespondReceived ++;
        if (edition != nil && [edition pageCount] > 0) {
            // received an edition
            networkErrorDetected = NO;
            
            if ([loadingIndicator isAnimating]) {
                [loadingIndicator stopAnimating];
            }
            
            [newspaperEditions addObject:edition];
            
            // sort newspaper editions based on user's configuration
            [newspaperEditions sortUsingSelector:@selector(compare:)];
            
            // reload/refresh view
            [[self newspaperTableView] reloadData];
        } else if (edition == nil) {
            // network error
            networkErrorDetected = YES;
        }
        
        if (newspaperRespondReceived == [subscription count]) {
            // has received all response
            if ([loadingIndicator isAnimating]) {
                [loadingIndicator stopAnimating];
            }

            if (networkErrorDetected) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Can not load newspapers. Please check the internet connection."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
                [alert show];
            }
            
            if (!networkErrorDetected && [newspaperEditions count] == 0) {
                // no newspaper
                // display label
                [self setHiddenNoNewspapersLabel:NO];
            }
        }
    }
    
    if (edition != nil && [edition pageCount] > 0) {    
        //
        // pre-load first page of the newspaper asynch
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [CANewspaperApi pdfForNewspaperEdition:edition page:0];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @synchronized(newspaperEditions) {
        return [newspaperEditions count];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    UIImage *image = [UIImage imageNamed:@"arrow.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    // Get size of current image
    CGSize size = [image size];
    // Frame location in view to show original image
    [imageView setFrame:CGRectMake(0, 0, size.width, size.height)];
    [cell setAccessoryView:imageView];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TPNewspaperEdition *edition = [self newspaperEditionAtIndexPath:indexPath];
    TPNewspaper *newspaper = [edition newspaper];
    [[cell textLabel] setText:[newspaper title]];
    [[cell textLabel] setTextColor:[UIColor whiteColor]];
    [[cell textLabel] setFont: [UIFont fontWithName:@"AmericanTypewriter-Bold" size:16]];
    [[cell imageView] setImage:[edition thumbnail]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return 134;
    } else {
        return 110;
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPNewspaperEdition *edition = [self newspaperEditionAtIndexPath:indexPath];
    
    NSDictionary *options =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                forKey: UIPageViewControllerOptionSpineLocationKey];

    TPNewspaperWrapperViewController *wrapper = [[TPNewspaperWrapperViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options newspaperEdition:edition];
  
    [wrapper setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self presentViewController:wrapper animated:YES completion:nil];
}
         
- (TPNewspaperEdition *)newspaperEditionAtIndexPath:(NSIndexPath *)indexPath
{
    @synchronized(newspaperEditions) {
        return [newspaperEditions objectAtIndex:[indexPath row]];
    }
}

- (void)setHiddenNoNewspapersLabel:(BOOL)hidden
{
    [noNewspaperLabel setHidden:hidden];
}


@end
