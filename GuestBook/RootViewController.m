//
//  RootViewController.m
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

@synthesize eventsPopup, eventsView, addEntryPopup, addSigView;
@synthesize managedObjectContext=__managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set up the events and add signature buttons.
    UIBarButtonItem *events = [[UIBarButtonItem alloc] initWithTitle:@"Events" style:UIBarButtonItemStylePlain target:self action:@selector(chooseEvent:)];
    self.navigationItem.leftBarButtonItem = events;
    [events release];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewSignature:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];

    UISegmentedControl *ctrl = [[UISegmentedControl alloc] initWithFrame: CGRectZero];
    ctrl.segmentedControlStyle = UISegmentedControlStyleBar;
    [ctrl insertSegmentWithTitle: @"Print" atIndex: 0 animated: NO];
    [ctrl insertSegmentWithTitle: @"Book" atIndex: 0 animated: NO];
    [ctrl insertSegmentWithTitle: @"List" atIndex: 0 animated: NO];
    [ctrl sizeToFit];
    [ctrl setSelectedSegmentIndex:0];
    [ctrl addTarget:self action:@selector(segmentedControlIndexChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = ctrl;
    
    eventsView = [[EventListController alloc] initWithNibName:@"EventListController" bundle:nil];
    eventsView.managedObjectContext = self.managedObjectContext;
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:eventsView];
    eventsPopup = [[UIPopoverController alloc] initWithContentViewController:navCon];
    eventsView.title = @"Event List";
    [navCon release];
    
    addSigView = [[AddSignatureViewController alloc] initWithNibName:@"AddSignatureViewController" bundle:nil];
    //addSigView.managedObjectContext = self.managedObjectContext;
    UINavigationController *sigNavCon = [[UINavigationController alloc] initWithRootViewController:addSigView];
    addEntryPopup = [[UIPopoverController alloc] initWithContentViewController:sigNavCon];
    addSigView.title = @"Add Signature";
    [sigNavCon release];
}

-(IBAction) segmentedControlIndexChanged:(id)control
{
    switch ([control selectedSegmentIndex])
    {
        case 0:
            NSLog(@"List View Selected");
            break;
        case 1:
            NSLog(@"Book View Selected");
            break;
        case 2:
            NSLog(@"Print View Selected");
            break;
        default:
            break;
    }
}

- (void)insertNewSignature:(id)sender
{
    if([eventsPopup isPopoverVisible])
    {
        [eventsPopup dismissPopoverAnimated:YES];
    }
    if(![addEntryPopup isPopoverVisible])
    {
        [addEntryPopup presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [addEntryPopup dismissPopoverAnimated:YES];
    }
}

- (void)chooseEvent:(id)sender
{
    if([addEntryPopup isPopoverVisible])
    {
        [addEntryPopup dismissPopoverAnimated:YES];
    }
    if(![eventsPopup isPopoverVisible])
    {
        [eventsPopup presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [eventsPopup dismissPopoverAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell....

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
