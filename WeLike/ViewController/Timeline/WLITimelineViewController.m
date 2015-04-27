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
    [self reloadData:YES];
    
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Activity" style:UIBarButtonItemStylePlain target:self action:@selector(goToActivity)];
    self.navigationItem.leftBarButtonItem = anotherButton;
    
    
    
    UIButton *button =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [button setImage:[UIImage imageNamed:@"messagesbutton.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goToMessages) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem =back;
   }




-(void)goToMessages {
    NSLog(@"Eh up, someone just pressed the button!");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    LQSViewController *newVc = [[LQSViewController alloc]init];
    [self.navigationController pushViewController:newVc animated:YES];
                                
}
-(void)goToActivity {
    NSLog(@"Going to activity!");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    ActivityController *newVc = [[ActivityController alloc]init];
    [self.navigationController pushViewController:newVc animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll {
    
    loading = YES;
    int page;
    if (reloadAll) {
        loadMore = YES;
        page = 1;
    } else {
        page  = (self.posts.count / kDefaultPageSize) + 1;
    }
//    [sharedConnect timelineForUserID:sharedConnect.currentUser.userID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
//        loading = NO;
//        self.posts = posts;
//        loadMore = posts.count == kDefaultPageSize;
//        [self.tableViewRefresh reloadData];
//        [refreshManager tableViewReloadFinishedAnimated:YES];
//    }];
    loading = NO;
    NSMutableArray *allFollowings = [[NSMutableArray alloc]initWithCapacity:10];
    NSNumber *num = [NSNumber numberWithInt:4];
    [allFollowings insertObject:num atIndex:0];
    
    NSMutableArray *wliPosts = [[NSMutableArray alloc]initWithCapacity:10];
    __block NSUInteger postCount = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
    [query addDescendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d fitovate pgotos from parse.", objects.count);
            
            
            NSDictionary *userDict = [[NSDictionary alloc] initWithObjectsAndKeys:  [NSNumber numberWithInt:sharedConnect.currentUser.userID], @"userID",
                                      [NSNumber numberWithInt:sharedConnect.currentUser.userType], @"userTypeID",
                                      sharedConnect.currentUser.userPassword, @"password",
                                      sharedConnect.currentUser.userEmail, @"email",
                                      sharedConnect.currentUser.userFullName, @"userFullname",
                                      sharedConnect.currentUser.userUsername, @"username",
                                      sharedConnect.currentUser.userInfo, @"userInfo",
                                      sharedConnect.currentUser.userAvatarPath, @"userAvatar",
                                      sharedConnect.currentUser.followingUser, @"followingUser",
                                      [NSNumber numberWithInt:sharedConnect.currentUser.followersCount], @"followersCount",
                                      [NSNumber numberWithInt:sharedConnect.currentUser.followingCount], @"followingCount",
                                      sharedConnect.currentUser.companyAddress, @"userAddress",
                                      sharedConnect.currentUser.companyPhone, @"userPhone",
                                      sharedConnect.currentUser.companyWeb, @"userWeb",
                                      sharedConnect.currentUser.userEmail, @"userEmail",
                                      sharedConnect.currentUser.coordinate.latitude, @"userLat",
                                      sharedConnect.currentUser.coordinate.longitude,
                                      sharedConnect.currentUser.companyWeb, @"userWeb",
                                      sharedConnect.currentUser.companyEmail, @"userEmail",
                                      sharedConnect.currentUser.followingUser, @"followingUser"
                                      , nil];
            
            
            
            
            for (PFObject *object in objects) {
                
                NSString *playerName = object[@"postTitle"];
                NSLog(@"%@", object.createdAt);
                //NSLog(@"%@", object[@"userID"]);
                if([allFollowings containsObject:object[@"userID"]]){
                    NSLog(@"ADDED TO TIMELINE FOR POSTSSSS");
                    NSLog(@"each object needs to init a dictionary with WLIPost");
                    
                    PFFile *tempPhotoForUrl = object[@"userImage"];
                    
                    
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:  object[@"postID"], @"postID",
                                          object[@"postTitle"], @"postTitle",
                                          tempPhotoForUrl.url, @"postImage",
                                          object[@"createdAt"], @"postDate",
                                          object[@"createdAt"], @"timeAgo",
                                          userDict, @"user",
                                          object[@"totalLikes"], @"totalLikes",
                                          object[@"totalComments"], @"totalComments",
                                          object[@"isLiked"], @"isLiked",
                                          object[@"isCommented"], @"isCommented"
                                          , nil];
                    WLIPost *postFromParse = [[WLIPost alloc]initWithDictionary:dict];
                    [wliPosts insertObject:postFromParse atIndex:postCount];
                    postCount++;
                    
                    
                }
                //done
                NSLog(@"DONE loadnig from parse");
                self.posts = wliPosts;
                [self.tableViewRefresh reloadData];
                [refreshManager tableViewReloadFinishedAnimated:YES];
                
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

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
        [[WLIConnect sharedConnect] removeLikeWithLikeID:post.postID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-liked.png"] forState:UIControlStateNormal];
                post.postLikesCount++;
                post.likedThisPost = YES;
                if (post.postLikesCount == 1) {
                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d like", post.postLikesCount] forState:UIControlStateNormal];
                } else {
                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d likes", post.postLikesCount] forState:UIControlStateNormal];
                }
            }
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
        [ParseSingleton new];
        [ParseSingleton recordActivity:sharedConnect.currentUser.userUsername forSource:post.user.userUsername withActivitytype:@"like" withPostId:[NSString stringWithFormat:@"%d",post.postID]];
        
        [[WLIConnect sharedConnect] setLikeOnPostID:post.postID onCompletion:^(WLILike *like, ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-like.png"] forState:UIControlStateNormal];
                post.postLikesCount--;
                post.likedThisPost = NO;
                if (post.postLikesCount == 1) {
                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d like", post.postLikesCount] forState:UIControlStateNormal];
                } else {
                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d likes", post.postLikesCount] forState:UIControlStateNormal];
                }
            }
        }];
    }
}

@end
