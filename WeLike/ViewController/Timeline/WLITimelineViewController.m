//
//  WLITimelineViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLITimelineViewController.h"
#import "WLIPostCell.h"
#import "WLILoadingCell.h"
#import "GlobalDefines.h"
#import "LQSViewController.h"
#import "ActivityController.h"
#import <Parse/Parse.h>
#import "ParseSingleton.h"
#import "FitovateData.h"
#import <ooVooSDK-iOS/ooVooSDK-iOS.h>
#import <Atlas/Atlas.h>
#import "MainViewController.h"
#import "PGConversationListViewController.h"
#import "WLINearbyViewController.h"
#import "JSBadgeView.h"

@implementation WLITimelineViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Fitovate";
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setAlertShowing:NO];
    if([WLIConnect sharedConnect].currentUser!=nil)//required
        [self firstLogin];
    
//    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"activityicon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goToActivity)];
   }


-(void)goToMessages {
    if(sharedConnect.layerClient!=nil && sharedConnect.layerClient.isConnected){
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        PGConversationListViewController *conversationListViewController = [PGConversationListViewController conversationListViewControllerWithLayerClient:sharedConnect.layerClient];
        [self.navigationController pushViewController:conversationListViewController animated:YES];
    }
}

-(void)getPosts {
    FitovateData *myData = [FitovateData sharedFitovateData];
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query orderByDescending:@"userID"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            myData.allUsersDictionary = [[NSMutableDictionary alloc]initWithCapacity:objects.count];
            
            for (PFObject *loggedInUserParse in objects) {
                WLIUser *currUser = [myData pfobjectToWLIUser:loggedInUserParse];
                [myData.allUsersDictionary setObject:currUser forKey:loggedInUserParse[@"userID"]];
                
                //adds all users for now by userID
            }
            [self reloadData:YES];
            
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            myData.allUsersDictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
            [self reloadData:YES];
        }
    }];
    
}

-(void)goToActivity {
    NSLog(@"Going to activity!");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    ActivityController *newVc = [[ActivityController alloc]init];
    [self.navigationController pushViewController:newVc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll {
    loading = YES;
    FitovateData *myData = [FitovateData sharedFitovateData];
    
    if([myData.currentUser.userType isEqualToString:@"trainer"] ){
        WLINearbyViewController *nearbyViewController = [self.tabBarController.viewControllers objectAtIndex:3];
        UITabBarItem *nearbyTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Nearby Followers" image:[[UIImage imageNamed:@"tabbarnearby"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbarnearby"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        nearbyViewController.tabBarItem = nearbyTabBarItem;
    }else{
        WLINearbyViewController *nearbyViewController = [self.tabBarController.viewControllers objectAtIndex:3];
        UITabBarItem *nearbyTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Trainers" image:[[UIImage imageNamed:@"tabbarnearby"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbarnearby"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        nearbyViewController.tabBarItem = nearbyTabBarItem;
    }
    
    self.allFollowings = [myData getAllIdsThatUsersFollowing:^{
        
        int page;
        if (reloadAll) {
            loadMore = NO;
            page = 1;
        } else {
            page  = (self.posts.count / kDefaultPageSize) + 1;
        }
        
        
        NSMutableArray *wliPosts = [[NSMutableArray alloc]initWithCapacity:10];
        __block NSUInteger postCount = 0;
        
        PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
        
        [query addDescendingOrder:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            loading = NO;
            if (!error) {
                for (PFObject *object in objects) {
        
                    if([self.allFollowings containsObject:object[@"userID"]]){ // if im following this person
                        
                        PFFile *tempPhotoForUrl = object[@"userImage"];
                        
                        
                        
                        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:  object[@"postID"], @"postID",
                                              object[@"postTitle"], @"postTitle",
                                              tempPhotoForUrl.url, @"postImage",
                                              object[@"createdAt"], @"postDate",
                                              object[@"createdAt"], @"timeAgo",
                                              object[@"totalLikes"], @"totalLikes",
                                              object[@"totalComments"], @"totalComments",
                                              object[@"isLiked"], @"isLiked",
                                              object[@"isCommented"], @"isCommented"
                                              , nil];
                        
                        WLIPost *postFromParse = [[WLIPost alloc]initWithDictionary:dict];
                        postFromParse.user = [myData.allUsersDictionary objectForKey:object[@"userID"]];
                        NSNumber *number = object[@"totalLikes"];
                        postFromParse.postLikesCount =[number integerValue];
                        [wliPosts insertObject:postFromParse atIndex:postCount];
                        postCount++;
                    }
                    self.posts = wliPosts;
                    [self.tableViewRefresh reloadData];
                    [refreshManager tableViewReloadFinishedAnimated:YES];
                    
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    UITapGestureRecognizer *gesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]; // Declare the Gesture.
    gesRecognizer.delegate = self;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    headerView.backgroundColor = [UIColor grayColor];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    labelView.textAlignment = NSTextAlignmentCenter;
    labelView.text = @"Fitness Articles   |   Fitness Videos";
    labelView.textColor = [UIColor whiteColor];
    [headerView addSubview:labelView];
    [headerView addGestureRecognizer:gesRecognizer];
    self.tableViewRefresh.tableHeaderView = headerView;
}

- (void)firstLogin{
    FitovateData *myData = [FitovateData sharedFitovateData];
    [myData startOovoo];
    self.allFollowings = [myData getAllIdsThatUsersFollowing:^{
        [self getPosts];
    }];
    [self performSelector:@selector(setupActivityBadge) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(showMessagesButton:) withObject:0 afterDelay:2.0];
    NSLog(@"username is %@", [WLIConnect sharedConnect].currentUser.userUsername);
    //[WLIConnect sharedConnect].currentUser.userUsername = @"xyzxyz";
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer{
    CGPoint tappedPoint = [gestureRecognizer locationInView:self.view];
    CGFloat xCoordinate = tappedPoint.x;
    CGFloat yCoordinate = tappedPoint.y;
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat halfScreenWidth = screenRect.size.width/2;
    if(xCoordinate>halfScreenWidth){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.youtube.com/channel/UCDHPje8XtRC8mo3XemFeIPw/playlists?shelf_id=0&sort=dd&view=1"]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.fitovateapp.com/blog"]];
    }
    
    
//    WebViewController *webViewController = [[WebViewController alloc] init];
//    [webViewController setURL:[NSURL URLWithString:@"http://www.fitovateapp.com/blog"]];
//    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1){
        static NSString *CellIdentifier = @"WLIPostCell";
        WLIPostCell *cell = (WLIPostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        cell.post = self.posts[indexPath.row];
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
        return self.posts.count;
    } else {
        if (loadMore) {
            return 1;
        } else {
            return 0;
        }
    }
}


#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return [WLIPostCell sizeWithPost:self.posts[indexPath.row]].height;
    } else if (indexPath.section == 0){
        return 44 * loading * self.posts.count == 0;
    } else {
        return 44 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData:NO];
    }
}


#pragma mark - WLIPostCellDelegate methods

- (void)toggleLikeForPost:(WLIPost*)post sender:(WLIPostCell*)senderCell {
    
    if (post.likedThisPost) {
        [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-like.png"] forState:UIControlStateNormal];
        post.postLikesCount--;
        post.likedThisPost = NO;
        if (post.postLikesCount == 1) {
            [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d like", post.postLikesCount] forState:UIControlStateNormal];
        } else {
            [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d likes", post.postLikesCount] forState:UIControlStateNormal];
        }
        FitovateData *myData = [FitovateData sharedFitovateData];
        [myData unlikeUserIdWithPostId:[NSNumber numberWithInt:myData.currentUser.userID] :[NSNumber numberWithInt:post.postID] :^{
            [senderCell updateLikes];
        }];
        
    } else {
        [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-liked.png"] forState:UIControlStateNormal];
        post.postLikesCount++;
        post.likedThisPost = YES;
        if (post.postLikesCount == 1) {
            [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d like", post.postLikesCount] forState:UIControlStateNormal];
        } else {
            [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d likes", post.postLikesCount] forState:UIControlStateNormal];
        }
        FitovateData *myData = [FitovateData sharedFitovateData];
        [myData likeUserIdWithPostId:[NSNumber numberWithInt:myData.currentUser.userID] :[NSNumber numberWithInt:post.postID] :^{
            [senderCell updateLikes];
        }];
        
        [ParseSingleton new];
        [ParseSingleton recordActivity:sharedConnect.currentUser.userUsername forSource:post.user.userUsername withActivitytype:@"like" withPostId:[NSString stringWithFormat:@"%d",post.postID]];
    }
}
-(void)showMessagesButton: (int)unreadMessages{
    UIButton *button =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [button setImage:[UIImage imageNamed:@"messagesbutton.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goToMessages) forControlEvents:UIControlEventTouchUpInside];
    
    if(unreadMessages>0){
    JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:button alignment:JSBadgeViewAlignmentTopRight];
    badgeView.badgeText=[NSString stringWithFormat:@"%d",unreadMessages];
    }
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem =back;
    }

-(void)setupActivityBadge{
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query addDescendingOrder:@"createdAt"];
    [query whereKey:@"sourceId" equalTo:[WLIConnect sharedConnect].currentUser.userUsername];
    [query whereKey:@"read" equalTo:[NSNumber numberWithBool:NO]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
    
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 30, 30);
        [button setImage:[UIImage imageNamed:@"activityicon.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goToActivity)forControlEvents:UIControlEventTouchUpInside];
        
        if(objects.count >0){ //only show if its not 0
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:button alignment:JSBadgeViewAlignmentTopLeft];
        badgeView.badgeText=[NSString stringWithFormat:@"%lu", (unsigned long)objects.count];
        }
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = anotherButton;
    }];
}

@end
