//
//  TPAddNewspaperViewController.m
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "TPAddNewspaperViewController.h"
#import "TPStates.h"
#import "CANewspaperApi.h"
#import "TPNewspaper.h"
#import "TPConfiguration.h"

@interface TPAddNewspaperViewController ()

@end

@implementation TPAddNewspaperViewController

@synthesize dismissBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
        
        [[self navigationItem] setRightBarButtonItem:doneItem];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        [[self navigationItem] setLeftBarButtonItem:cancelItem];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // make initial selection
    NSUInteger stateIndex = [[TPStates states] indexOfObject:[[TPConfiguration instance] preferredState]];
    
    if (stateIndex != NSNotFound) {
        [_statePicker selectRow:stateIndex inComponent:0 animated:YES];
        [self pickerView:_statePicker didSelectRow:stateIndex inComponent:0];
    } else {
        [self pickerView:_statePicker didSelectRow:0 inComponent:0];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
// save subscription 
//
- (void)save:(id)sender
{
    TPConfiguration *config = [TPConfiguration instance];
    
    NSArray *selectedRows = [[self newspaperTable] indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedRows) {
        [config addNewspaper:[[availableNewspapers objectAtIndex:[indexPath row]] lccn]];
    }
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissBlock];
    
}

- (void)cancel:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissBlock];
}


//
// State picker methods
//
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[TPStates states] count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[TPStates states] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *state = [[TPStates states] objectAtIndex:row];
    
    TPConfiguration *config = [TPConfiguration instance];
    [config setPreferredState:state];
    int portalYear = [[config portalDateComponent] year];
    
    availableNewspapers = [CANewspaperApi newspapersForState:state year:portalYear];
    
    // refresh table
    [[self newspaperTable] reloadData];
}
     
     
//
// table view methods
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [availableNewspapers count];
}


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
    TPNewspaper *newspaper = [availableNewspapers objectAtIndex:indexPath.row];
    [[cell textLabel] setText:[newspaper title]];
    [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
    [[cell detailTextLabel] setText:[newspaper detailText]];
    [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

@end
