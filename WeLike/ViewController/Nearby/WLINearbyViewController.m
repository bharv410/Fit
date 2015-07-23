//
//  WLINearbyViewController.m
//
//
//  Created by Navneeth
//  Copyright (c) 2015 Navneeth Ramprasad. All rights reserved.
//

#import "WLINearbyViewController.h"
#import "WLIProfileViewController.h"
#import "WLIUser.h"
#import "GlobalDefines.h"
#import "UIKit+AFNetworking.h"
#import "WLIUserCell.h"
#import "WLILoadingCell.h"
#import "GlobalDefines.h"
#import <Parse/Parse.h>
#import "FitovateData.h"

@interface WLINearbyViewController ()

@end

@implementation WLINearbyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.users = [NSMutableArray array];
        self.title = @"Nearby Trainers";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateLocation];
    
            FitovateData *myData = [FitovateData sharedFitovateData];
            self.allFollowings = [myData getAllIdsThatUsersFollowing:^{
                [self loadNearbyUsers];
            }];
    
    if([myData.currentUser.userType isEqualToString:@"trainer"] ){
        self.title= @"Nearby Followers";
    }
}

- (void)loadNearbyUsers{
    FitovateData *myData = [FitovateData sharedFitovateData];
    if([myData.currentUser.userType isEqualToString:@"trainer"] ){
        // Create a query for places
        PFQuery *query = [PFQuery queryWithClassName:@"Users"];
        // Interested in locations near user.
        [query whereKey:@"location" nearGeoPoint:self.userCurrentLocation];
        query.limit = 50;
        [query whereKey:@"usertype" equalTo:@"trainee"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                
                if(objects.count<1)
                    [self noneNearby];
                
                
                NSLog(@"got  results without error!");
                //[self.users removeAllObjects];
                for(PFObject *parseObject in objects){
                    WLIUser *parseUser = [myData pfobjectToWLIUser:parseObject];
                    if([self.allFollowings containsObject:[NSNumber numberWithInt:parseUser.userID]]){
                        parseUser.followingUser = YES;
                    }else{
                        parseUser.followingUser = NO;
                    }
                    [self.users addObject:parseUser];
                }
                //loadMore = objects.count == kDefaultPageSize;
                [self reloadTable];
                [refreshManager tableViewReloadFinishedAnimated:YES];
            }else{
                NSLog(@"error geoquerying");
            }
        }];
    }else{

        PFQuery *query = [PFQuery queryWithClassName:@"Users"];
        [query whereKey:@"location" nearGeoPoint:self.userCurrentLocation];
        query.limit = 50;
        [query whereKey:@"usertype" equalTo:@"trainer"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                
                if(objects.count<1)
                    [self noneNearby];
                
                
                //[self.users removeAllObjects];
                for(PFObject *parseObject in objects){
                    WLIUser *parseUser = [myData pfobjectToWLIUser:parseObject];
                    if([self.allFollowings containsObject:[NSNumber numberWithInt:parseUser.userID]]){
                        parseUser.followingUser = YES;
                    }else{
                        parseUser.followingUser = NO;
                    }
                    [self.users addObject:parseUser];
                }
                //loadMore = objects.count == kDefaultPageSize;
                [self reloadTable];
                [refreshManager tableViewReloadFinishedAnimated:YES];
            }else{
                NSLog(@"error geoquerying");
            }
        }];
    }
}

-(void) noneNearby{
    NSString *message = [NSString stringWithFormat:@"There are 0 %@",self.title];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)reloadData:(BOOL)reloadAll {
    
    loading = YES;
    [self.nearbyTrainersTableView reloadData];
    int page = reloadAll ? 1 : (self.users.count / kDefaultPageSize) + 1;
    [sharedConnect usersForSearchString:@" " page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *users, ServerResponse serverResponseCode) {
        loading = NO;
        if (reloadAll) {
            [self.users removeAllObjects];
        }
        [self.users addObjectsFromArray:users];
        loadMore = users.count == kDefaultPageSize;
        [self.nearbyTrainersTableView reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

- (void)loadMoreUsersFromAWS {
    
    loading = YES;
    int page = YES ? 1 : (self.users.count / kDefaultPageSize) + 1;
    [sharedConnect usersForSearchString:@" " page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *users, ServerResponse serverResponseCode) {
        loading = NO;
        [self.users addObjectsFromArray:users];
        loadMore = users.count == kDefaultPageSize;
        [self.nearbyTrainersTableView reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

- (void) reloadTable { dispatch_async(dispatch_get_main_queue(), ^{
    [self.nearbyTrainersTableView reloadData];
}); }

- (void)updateLocation
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            self.userCurrentLocation = geoPoint;
            NSLog(@"got location!");
        }
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1){
        static NSString *CellIdentifier = @"WLIUserCell";
        WLIUserCell *cell = (WLIUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIUserCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        cell.user = self.users[indexPath.row];
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
        NSLog(@"[self reloadData:NO];");
    }
}


#pragma mark - WLIUserCellDelegate methods

- (void)followUser:(WLIUser *)user sender:(id)senderCell {
    
    WLIUserCell *cell = (WLIUserCell*)senderCell;
    [cell.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-unfollow.png"] forState:UIControlStateNormal];
    user.followingUser = YES;
    
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

