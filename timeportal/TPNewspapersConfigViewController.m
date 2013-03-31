//
//  TPNewspapersConfigViewController.m
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "TPNewspapersConfigViewController.h"
#import "TPConfiguration.h"
#import "TPNewspaper.h"
#import "TPAddNewspaperViewController.h"
#import "CANewspaperApi.h"

@interface TPNewspapersConfigViewController ()

@end

@implementation TPNewspapersConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Get the tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        // Give it a label
        [tbi setTitle:@"Subscription"];
        
        // Create a UIImage from a file
        // This will use Time@2x.png on retina display devices
        UIImage *i = [UIImage imageNamed:@"subscription.png"];
        // Put that image on the tab bar item
        [tbi setImage:i];

        
        [self setTitle:@"Subscription"];
        
        // "add new" button
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        
        [[self navigationItem] setRightBarButtonItem:bbi];
        
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

//
// override viewWillAppear is necessary to refresh the test results
//
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // this is necessary to recover from network error
    [[self tableView] reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//
// UITableViewDataSource protocol methods
//

// number of rows in each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[TPConfiguration instance] lccns] count];
}



//
// create custom cell
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:CellIdentifier];
        } else {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleSubtitle
                    reuseIdentifier:CellIdentifier];
        }
    }
    
    
    // Set up the cell...
    TPNewspaper *newspaper = [self newspaperAtIndexPath:indexPath];
    [[cell textLabel] setText:[newspaper title]];
    [[cell detailTextLabel] setText:[newspaper detailText]];
    
    return cell;
}




- (TPNewspaper *)newspaperAtIndexPath:(NSIndexPath *)indexPath
{
    TPConfiguration *config = [TPConfiguration instance];
    NSString *lccn = [[config lccns] objectAtIndex:[indexPath row]];
    return [CANewspaperApi newspaperOfLccn:lccn];
}



//
// Add new newspaper
//
- (IBAction)addNewItem:(id)sender
{
    TPAddNewspaperViewController *addNewspaperViewController = [[TPAddNewspaperViewController alloc] init];
    
    
    [addNewspaperViewController setDismissBlock:^{
        [[self tableView] reloadData];
    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addNewspaperViewController];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentViewController:navController animated:YES completion:nil];
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TPConfiguration *config =[TPConfiguration instance];
        [config deleteNewspaperAtIndex:[indexPath row]];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    TPConfiguration *config =[TPConfiguration instance];
    [config moveNewspaperAtIndex:[sourceIndexPath row]
                                         toIndex:[destinationIndexPath row]];

}



@end
