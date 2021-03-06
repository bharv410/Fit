//
//  WLIProfileViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIProfileViewController.h"
#import "WLIEditProfileViewController.h"
#import "GlobalDefines.h"
#import "WLIFollowingViewController.h"
#import "WLIFollowersViewController.h"
#import "WLISearchViewController.h"
#import "WLIWelcomeViewController.h"
#import "WLIAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LQSViewController.h"
#import "FitovateData.h"
#import <Parse/Parse.h>
#import "ConferenceViewController.h"
#import "MainViewController.h"
#import "WLIUserPhotoControllerTableViewController.h"


@implementation WLIProfileViewController
NSArray *recipes;
MPMoviePlayerController *moviePlayerController;

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Profile";
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    recipes = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
    NSLog(@"benmark");
    
    self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.size.width/2;
    self.imageViewUser.layer.masksToBounds = YES;
    
    if (self.user.userID == [WLIConnect sharedConnect].currentUser.userID) {
        self.buttonFollow.alpha = 0.0f;
    } else {
        if (self.user.followingUser) {
            [self.buttonFollow setTitle:@"Following" forState:UIControlStateNormal];
            [self.buttonFollow setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            NSLog(@"Set to following2");
        } else {
            [self.buttonFollow setTitle:@"Follow!" forState:UIControlStateNormal];
            NSLog(@"Set to follow2");
        }
    }

    if (self.user == [WLIConnect sharedConnect].currentUser) {
        
//        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        editButton.adjustsImageWhenHighlighted = NO;
//        editButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
//        [editButton setImage:[UIImage imageNamed:@"nav-btn-edit.png"] forState:UIControlStateNormal];
        
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        
        
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(buttonLogoutTouchUpInside:)];
        
        
        
        self.scrollViewUserProfile.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.buttonLogout.frame) +20.0f);
        self.buttonMessage.hidden = YES;
        self.buttonEditProfile.alpha = 1.0f;
    } else {
        self.buttonEditProfile.alpha = 0.0f;
        self.buttonLogout.alpha = 0.0f;
        self.scrollViewUserProfile.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.labelEmail.frame) +20.0f);
        UIBarButtonItem *btn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"videochatimage.png"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(videoCallThisUser)];
        self.navigationItem.rightBarButtonItem=btn;
    }
    
    if (self.user.userType != WLIUserTypeCompany) {
        self.labelAddress.alpha = 0.0f;
        self.labelPhone.alpha = 0.0f;
        self.labelWeb.alpha = 0.0f;
        self.labelEmail.alpha = 0.0f;
    }
    
//    UIButton *button =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
//    [button setImage:[UIImage imageNamed:@"messagesbutton.png"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(goToMessages) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:button];
//    
//    self.navigationItem.rightBarButtonItem =back;
    //benmark messages button
    FitovateData *myData = [FitovateData sharedFitovateData];
    self.allFollowings = [myData getAllIdsThatUsersFollowing:^{
        if([self.allFollowings containsObject:[NSNumber numberWithInt:self.user.userID]]){
            [self.buttonFollow setTitle:@"Following" forState:UIControlStateNormal];
            [self.buttonFollow setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            NSLog(@"Set to following1");
        }else{
            [self.buttonFollow setTitle:@"Follow!" forState:UIControlStateNormal];
            NSLog(@"Set to follow1");
        }
    }];
    
    }

-(void)goToMorePhotos {
    NSLog(@"%d",self.labelBio.bounds.origin.y);
    //    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    //    LQSViewController *newVc = [[LQSViewController alloc]init];
    //    [self.navigationController pushViewController:newVc animated:YES];
    
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
        WLIUserPhotoControllerTableViewController *newVc = [[WLIUserPhotoControllerTableViewController alloc]init];
    newVc.currentUser = self.user;
        [self.navigationController pushViewController:newVc animated:YES];
    
    
    
}

- (void)videoCallThisUser{
    
        FitovateData *fd =[FitovateData sharedFitovateData];
        fd.confernceId = self.user.userUsername;
        fd.participantId = [WLIConnect sharedConnect].currentUser.userUsername;
        
        [fd joinConference:[WLIConnect sharedConnect].currentUser.userUsername : self.user.userUsername];
        
        UIStoryboard *mainstoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        MainViewController *mainViewController = [mainstoryBoard instantiateViewControllerWithIdentifier:@"MainNav"];
        [self.navigationController presentViewController:mainViewController animated:YES completion:^{
            NSLog(@"presented");
        }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self updateFramesAndDataWithDownloads:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUser:(WLIUser *)user {
    
    _user = user;
}

- (WLIUser*)user {
    
    if (_user) {
        return _user;
    } else {
        return [WLIConnect sharedConnect].currentUser;
    }
}

- (void)updateFramesAndDataWithDownloads:(BOOL)downloads {
    
    self.labelName.text = self.user.userUsername;
    if (self.user.followingUser) {
        [self.buttonFollow setTitle:@"Following" forState:UIControlStateNormal];
        [self.buttonFollow setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    } else {
        [self.buttonFollow setTitle:@"Follow!" forState:UIControlStateNormal];
    }
    self.labelFollowingCount.text = [NSString stringWithFormat:@"following %d", self.user.followingCount];
    self.labelFollowersCount.text = [NSString stringWithFormat:@"followers %d", self.user.followersCount];
    
    self.labelAddress.text = self.user.companyAddress;
    self.labelPhone.text = self.user.companyPhone;
    self.labelWeb.text = self.user.companyWeb;
    self.labelEmail.text = self.user.companyEmail;
    self.labelBio.text = self.user.userInfo;
    self.labelBio.numberOfLines = 3;
    self.labelBio.sizeToFit;
    self.labelBio.textAlignment = NSTextAlignmentCenter;
    
    NSLog(@"Specialty equals %@", self.user.userSpecialty);
    
    if([self.user.userSpecialty isEqualToString:@""] || self.user.userSpecialty==nil){
        //user is not a trainer
        NSLog(@"not a trainer");
        [self.movieView setHidden:YES];
        [self reloadUsersPosts:YES];
    }else{
        [self.postsTableView setHidden:YES];
        NSLog(@"is a trainer");
    }
    
    if (downloads) {
//        PFQuery *query = [PFQuery queryWithClassName:@"Users"];
//        
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if (!error) {
//                for (PFObject *loggedInUserParse in objects) {
//                    
//                    if([loggedInUserParse[@"userID"] isEqualToNumber:[NSNumber numberWithInt:self.user.userID]]){
//                        NSNumber *oldFollowingAmount = loggedInUserParse[@"followingCount"];
//                        loggedInUserParse[@"followingCount"] = [NSNumber numberWithInt:[oldFollowingAmount intValue] - 1];
//                        [loggedInUserParse saveInBackground];
//                    }
//                }
//            } else {
//                NSLog(@"Error: %@ %@", error, [error userInfo]);
//            }
//        }];
        FitovateData *myData = [FitovateData sharedFitovateData];
        self.allFollowings = [myData getAllIdsThatUsersFollowing:^{
            if([self.allFollowings containsObject:[NSNumber numberWithInt:self.user.userID]]){
                [self.buttonFollow setTitle:@"Following" forState:UIControlStateNormal];
                [self.buttonFollow setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            }else{
                [self.buttonFollow setTitle:@"Follow!" forState:UIControlStateNormal];
            }
        }];
        
        [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.user.userAvatarPath]];
        
        
//        //update with parse data of current object
        [sharedConnect userWithUserID:self.user.userID onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
            _user = user;
            [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.user.userAvatarPath]];
            self.labelName.text = self.user.userUsername;
            self.labelFollowingCount.text = [NSString stringWithFormat:@"following %d", self.user.followingCount];
            self.labelFollowersCount.text = [NSString stringWithFormat:@"followers %d", self.user.followersCount];
            
            self.labelAddress.text = self.user.companyAddress;
            self.labelPhone.text = self.user.companyPhone;
            self.labelWeb.text = self.user.companyWeb;
            self.labelEmail.text = self.user.companyEmail;
        }];
        
        
        [sharedConnect followersForUserID:self.user.userID page:1 pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *followers, ServerResponse serverResponseCode) {
            self.labelFollowersCount.text = [NSString stringWithFormat:@"followers %d", followers.count];
        }];
        
        [sharedConnect followingForUserID:self.user.userID page:1 pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *followers, ServerResponse serverResponseCode) {
            self.labelFollowingCount.text = [NSString stringWithFormat:@"following %d", followers.count];
        }];
        
        
        //if its a trainer and its NOT ME
//        if ((self.user.userType == WLIUserTypeCompany) && (self.user.userID != [WLIConnect sharedConnect].currentUser.userID)) {
            //benharvey ben harvey edit change
        
        
        if(self.user.userID != [WLIConnect sharedConnect].currentUser.userID){ //not checking if they are a trainer right now
            
            FitovateData *myData = [FitovateData sharedFitovateData];
            
            //remove spaces in name for url
            NSString *usernameWithoutSpaces=[self.user.userUsername
                                             stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            PFQuery *videoQuery = [PFQuery queryWithClassName:@"Videos"];
            [videoQuery whereKey:@"username" equalTo:self.user.userUsername];
            NSLog(@"%@",self.user.userUsername);
            NSLog(@"%@",self.user.userUsername);
            NSLog(@"%@",self.user.userUsername);
            NSLog(@"%@",self.user.userUsername);NSLog(@"%@",self.user.userUsername);NSLog(@"%@",self.user.userUsername);NSLog(@"%@",self.user.userUsername);NSLog(@"%@",self.user.userUsername);NSLog(@"%@",self.user.userUsername);NSLog(@"%@",self.user.userUsername);NSLog(@"%@",self.user.userUsername);NSLog(@"%@",self.user.userUsername);
            [videoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    for (PFObject *object in objects) {
                        
                        PFFile *videoFile = object[@"video"];
                        NSString *urlOfVideo = videoFile.url;
                        NSURL *url =[[NSURL alloc]initWithString:urlOfVideo];
                        
                        moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:url];
                        [moviePlayerController.view setFrame:self.movieView.bounds];  // player's frame must match parent's
                        [self.movieView addSubview:moviePlayerController.view];
                        
                        // Configure the movie player controller
                        moviePlayerController.controlStyle = MPMovieControlStyleNone;
                        [moviePlayerController prepareToPlay];
                        // Start the movie
                        [moviePlayerController play];
                        
                        NSLog(@"%d",self.labelBio.frame.origin.y);
                        CGRect rect = CGRectMake(self.movieView.frame.origin.x, self.labelBio.frame.origin.y + 20.0f + self.labelBio.bounds.size.height, self.movieView.bounds.size.width, self.movieView.bounds.size.height);
                        self.movieView.frame = rect;
                        self.automaticallyAdjustsScrollViewInsets = NO;
                        
                    }
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    [_movieView setHidden:YES];
                    
                }
            }];
        }else{
            [_movieView setHidden:YES];
        }
    }
}


#pragma mark - Buttons methods

- (IBAction)barButtonItemEditTouchUpInside:(id)sender {
    
    WLIEditProfileViewController *editProfileViewController = [[WLIEditProfileViewController alloc] initWithNibName:@"WLIEditProfileViewController" bundle:nil];
    [self.navigationController pushViewController:editProfileViewController animated:YES];
}

- (IBAction)onMorePhotosClick:(id)sender {
    [self goToMorePhotos];
}

- (IBAction)buttonFollowToggleTouchUpInside:(id)sender {
    
    if (self.user.followingUser) {
        self.user.followingUser = NO;
        self.user.followersCount--;
        [self updateFramesAndDataWithDownloads:NO];
        
        FitovateData *myData = [FitovateData sharedFitovateData];
        
        [myData unfollowUserIdWithUserId:[NSNumber numberWithInt:myData.currentUser.userID]:[NSNumber numberWithInt:self.user.userID]];
    } else {
        self.user.followingUser = YES;
        self.user.followersCount++;
        [self updateFramesAndDataWithDownloads:NO];
        //benmark
        FitovateData *myData = [FitovateData sharedFitovateData];
        
        [myData followUserIdWithUserId:[NSNumber numberWithInt:myData.currentUser.userID]:[NSNumber numberWithInt:self.user.userID]];
    }
}



-(IBAction)goToMessages:(id)sender {
    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
//    LQSViewController *newVc = [[LQSViewController alloc]init];
//    [self.navigationController pushViewController:newVc animated:YES];
    
    self.messageAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Send to: %@",self.user.userUsername] message:@"Enter message text" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",nil];
    self.messageAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //[alert show];
    [self.messageAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}


- (IBAction)buttonLogoutTouchUpInside:(UIButton *)sender {
    
    [[[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure that you want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

- (void)sendMessage:(NSString *)messageText{
    WLIConnect *connect = [WLIConnect sharedConnect];
    // If no conversations exist, create a new conversation object with two participants
    FitovateData *myData = [FitovateData sharedFitovateData];
    [myData hasAMessage:_user.userUsername];
        NSError *error = nil;
        self.conversation = [connect.layerClient newConversationWithParticipants:[NSSet setWithArray:@[ _user.userUsername, connect.currentUser.userUsername ]] options:nil error:&error];
        if (!self.conversation) {
            NSLog(@"New Conversation creation failed: %@", error);
        }else{
            NSSet *participantsInConvo = [self.conversation participants];
            for(NSString* participant in participantsInConvo) {
                NSLog(@"participant name = %@",participant);
            }
        }
    
    // Creates a message part with text/plain MIME Type
    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithText:messageText];
    
    // Creates and returns a new message object with the given conversation and array of message parts
    LYRMessage *message = [connect.layerClient newMessageWithParts:@[messagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:nil];
    
    // Sends the specified message
    BOOL success = [self.conversation sendMessage:message error:&error];
    if (success) {
        NSLog(@"Message queued to be sent: %@", messageText);
        [[[UIAlertView alloc] initWithTitle:@"Sent" message:@"Your message has been sent" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
        FitovateData *myData = [FitovateData sharedFitovateData];
        [myData hasAMessage:_user.userUsername];
        
    } else {
        NSLog(@"Message send failed: %@", error);
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    WLIConnect *connect = [WLIConnect sharedConnect];
    if ([alertView.title isEqualToString:@"Logout"] && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        if (connect.layerClient.authenticatedUserID) {
            [connect.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
                
            }];
        }
        [[WLIConnect sharedConnect] logout];
        NSLog(@"logging out");
        WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate createViewHierarchy];
        [appDelegate.tabBarController showWelcome];
        
    }else if([alertView.title isEqualToString:[NSString stringWithFormat:@"Send to: %@",self.user.userUsername]]){
        if (buttonIndex == [alertView cancelButtonIndex]) {

        }else{
            NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
            [self sendMessage:[[alertView textFieldAtIndex:0] text]];
            
            //benmark10
        }
    }
}

//tablesource protocol methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WLIPostCell";
    WLIPostCell *cell = (WLIPostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:self options:nil] lastObject];
        cell.delegate = self;
    }
    cell.post = self.posts[indexPath.row];
    return cell;
}

- (void)reloadUsersPosts:(BOOL)reloadAll {
    self.posts = [[NSMutableArray alloc]initWithCapacity:20];
    FitovateData *myData = [FitovateData sharedFitovateData];
    __block NSUInteger postCount = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
    
    [query addDescendingOrder:@"createdAt"];
    
    [query whereKey:@"userID" equalTo:[NSNumber numberWithInt:self.user.userID]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"returned photos size = %tu", objects.count);
            
            
            for (PFObject *object in objects) {
                NSLog(@"post title on parse = %@", object[@"postTitle"]);
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
                [self.posts insertObject:postFromParse atIndex:postCount];
                postCount++;
                WLIPost *lasP = self.posts.lastObject;
                self.postsTableView.rowHeight= [WLIPostCell sizeWithPost:lasP].height;
                [self.postsTableView reloadData];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
