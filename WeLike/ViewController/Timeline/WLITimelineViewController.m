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
    [self firstLogin];
    
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

-(void)getPosts {
    NSLog(@"getting posts");
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
            NSLog(@"myData.followingTheseDICT = %@",myData.allUsersDictionary);
            [self reloadData:YES];
            
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            myData.allUsersDictionary = [[NSMutableArray alloc]initWithCapacity:0];
            [self reloadData:YES];
        }
    }];
    
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
    
    FitovateData *myData = [FitovateData sharedFitovateData];
    self.allFollowings = [myData getAllIdsThatUsersFollowing:^{
        loading = YES;
        int page;
        if (reloadAll) {
            loadMore = NO;
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
        
        //simulate me following these 19 userIDs
        FitovateData *myData = [FitovateData sharedFitovateData];
        
        NSMutableArray *wliPosts = [[NSMutableArray alloc]initWithCapacity:10];
        __block NSUInteger postCount = 0;
        
        PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
        
        [query addDescendingOrder:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
                    
                    NSString *postCaption = object[@"postTitle"];
                    
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
                        
                        NSLog(@"title = %@ numberOfLikes = %d",postFromParse.postTimeAgo, postFromParse.postLikesCount);
                        
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
}

- (void)firstLogin{
    WLIConnect *myConnect = [WLIConnect sharedConnect];
    if(![myConnect.currentUser.userUsername length] ==0)
        [myConnect authentWithLayer];
    [self.tableViewRefresh reloadData];
    
    FitovateData *myData = [FitovateData sharedFitovateData];
    self.allFollowings = [myData getAllIdsThatUsersFollowing:^{
        [self getPosts];
    }];
    
    if(self.allFollowings.count == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New User"
                                                        message:@"Follow some users in the nearby section!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
        
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
        
//        [[WLIConnect sharedConnect] removeLikeWithLikeID:post.postID onCompletion:^(ServerResponse serverResponseCode) {
//            if (serverResponseCode != OK) {
//                [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-liked.png"] forState:UIControlStateNormal];
//                post.postLikesCount++;
//                post.likedThisPost = YES;
//                if (post.postLikesCount == 1) {
//                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d like", post.postLikesCount] forState:UIControlStateNormal];
//                } else {
//                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d likes", post.postLikesCount] forState:UIControlStateNormal];
//                }
//            }
//        }];
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
        
//        [[WLIConnect sharedConnect] setLikeOnPostID:post.postID onCompletion:^(WLILike *like, ServerResponse serverResponseCode) {
//            if (serverResponseCode != OK) {
//                [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-like.png"] forState:UIControlStateNormal];
//                post.postLikesCount--;
//                post.likedThisPost = NO;
//                if (post.postLikesCount == 1) {
//                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d like", post.postLikesCount] forState:UIControlStateNormal];
//                } else {
//                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d likes", post.postLikesCount] forState:UIControlStateNormal];
//                }
//            }
//        }];
    }
}

@end
