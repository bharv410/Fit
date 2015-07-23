//
//  WLISearchViewController.m
//  WeLike
//
//  Created by Planet 1107 on 09/01/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "WLISearchViewController.h"
#import "WLIUserCell.h"
#import "WLILoadingCell.h"
#import "GlobalDefines.h"
#import "FitovateData.h"

@implementation WLISearchViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.users = [NSMutableArray array];
        self.title = @"Search users";
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.pressed = NO;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll {
    
    loading = YES;
    [self.tableViewSearch reloadData];
    NSString *searchString = self.searchBarSearchUsers.text;
    int page = reloadAll ? 1 : (self.users.count / kDefaultPageSize) + 1;
    [sharedConnect usersForSearchString:searchString page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *users, ServerResponse serverResponseCode) {
        loading = NO;
        if (reloadAll) {
            [self.users removeAllObjects];
        }
        
        if (users.count<1 && self.pressed) {
            [self noResults:searchString];
        }
        
        
        [self.users addObjectsFromArray:users];
        loadMore = users.count == kDefaultPageSize;
        [self.tableViewSearch reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
    
    
}

-(void) noResults : (NSString *)searchString{
    NSString *message = [NSString stringWithFormat:@"There are 0 results for %@. Remember searching names is case sensitive",searchString];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1){
        static NSString *CellIdentifier = @"WLIUserCell";
        WLIUserCell *cell = (WLIUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIUserCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        cell.user = self.users[indexPath.row];
        [cell setLoc];
        return cell;
    } else {
        static NSString *CellIdentifier = @"WLILoadingCell";
        WLILoadingCell *cell = (WLILoadingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLILoadingCell" owner:self options:nil] lastObject];
        }
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (section == 1) {
        return self.users.count;
    } else {
        if (loadMore) {
            return 1;
        } else {
            return 0;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return 91;
    } else if (indexPath.section == 0){
        return 91 * loading * self.users.count == 0;
    } else {
        return 91 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData:NO];
    }
}


#pragma mark - UISearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.pressed = YES;
    [self reloadData:YES];
    [self.searchBarSearchUsers resignFirstResponder];
    self.searchBarSearchUsers.text = @"";
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [self.users removeAllObjects];
    [self.tableViewSearch reloadData];
}


#pragma mark - WLIUserCellDelegate methods

- (void)followUser:(WLIUser *)user sender:(id)senderCell {
    
    WLIUserCell *cell = (WLIUserCell*)senderCell;
    [cell.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-unfollow.png"] forState:UIControlStateNormal];
    user.followingUser = YES;
    
    //benmark
    FitovateData *myData = [FitovateData sharedFitovateData];
    
    [myData followUserIdWithUserId:[NSNumber numberWithInt:myData.currentUser.userID]:[NSNumber numberWithInt:user.userID]];
}

- (void)unfollowUser:(WLIUser *)user sender:(id)senderCell {
    
    WLIUserCell *cell = (WLIUserCell*)senderCell;
    [cell.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-follow.png"] forState:UIControlStateNormal];
    user.followingUser = NO;
    
    FitovateData *myData = [FitovateData sharedFitovateData];
    
    [myData unfollowUserIdWithUserId:[NSNumber numberWithInt:myData.currentUser.userID]:[NSNumber numberWithInt:user.userID]];
}

@end
