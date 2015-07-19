//
//  FiltersViewController.m
//  ooVooSample
//
//  Created by Clement Barry on 1/1/14.
//  Copyright (c) 2014 ooVoo. All rights reserved.
//

#import "FiltersViewController.h"
#import <ooVooSDK-iOS/ooVooSDK-iOS.h>

@interface FiltersViewController ()
@property (nonatomic, strong) NSArray *filtersArray;
@end

@implementation FiltersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.filtersArray = [[ooVooController sharedController] availableVideoFilters];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filtersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FilterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ooVooVideoFilter *filter = [self.filtersArray objectAtIndex:indexPath.row];
    cell.textLabel.text = filter.name;
    cell.accessoryType = ([filter.filterId isEqualToString:[[ooVooController sharedController] activeVideoFilter]]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ooVooVideoFilter *filter = [self.filtersArray objectAtIndex:indexPath.row];
    [[ooVooController sharedController] setActiveVideoFilter:filter.filterId];
    [self.tableView reloadData];    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
