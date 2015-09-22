//
//  NormalUserProfileTableViewController.m
//  Fitovate
//
//  Created by Benjamin Harvey on 8/12/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "NormalUserProfileTableViewController.h"
#import <Haneke/Haneke.h>
#import "WLIPostCell.h"
#import "WLILoadingCell.h"
#import "FitovateData.h"
#import "WLIConnect.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WLIAppDelegate.h"
#import "CustomHeaderView.h"
#import "WLIFollowersViewController.h"
#import "WLIFollowingViewController.h"
#import "WLIEditProfileViewController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface NormalUserProfileTableViewController (){
    BOOL playing;
}

@end

@implementation NormalUserProfileTableViewController{
    XCDYouTubeVideoPlayerViewController *moviePlayerController;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    playing = YES;
    
    if([self.currentUser.userUsername containsString:@"xyzxyz"] || (self.currentUser == nil)){
        self.currentUser = [WLIConnect sharedConnect].currentUser;
        NSLog(@"setit");
    }else{
        NSLog(@"name is %@", self.currentUser.userUsername);
    }
    
    [self setHeader];
    self.loading = NO;
    
    [self reloadData:YES];
    
}

- (void)buttonLogoutTouchUpInside {
    [[[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure that you want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

- (void)reloadData:(BOOL)reloadAll {
    self.loading = YES;
    
    [self.posts removeAllObjects];
    self.posts = [[NSMutableArray alloc]initWithCapacity:20];
    
    
    FitovateData *myData = [FitovateData sharedFitovateData];
    
    __block NSUInteger postCount = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
    [query addDescendingOrder:@"createdAt"];
    [query whereKey:@"userID" equalTo:[NSNumber numberWithInt:self.currentUser.userID]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loading = NO;
        if (!error) {
            
            for (PFObject *object in objects) {
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
                postFromParse.postLikesCount = [number integerValue];
                [self.posts insertObject:postFromParse atIndex:postCount];
                postCount++;
                WLIPost *lasP = self.posts.lastObject;
                self.tableView.rowHeight = [WLIPostCell sizeWithPost:lasP].height;
                [self.tableView reloadData];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)buttonFollowingTouchUpInside:(id)sender {
    
    WLIFollowingViewController *followingViewController = [[WLIFollowingViewController alloc] initWithNibName:@"WLIFollowingViewController" bundle:nil];
    followingViewController.user = self.currentUser;
    [self.navigationController pushViewController:followingViewController animated:YES];
}

- (IBAction)buttonFollowersTouchUpInside:(id)sender {
    
    WLIFollowersViewController *followersViewController = [[WLIFollowersViewController alloc] initWithNibName:@"WLIFollowersViewController" bundle:nil];
    followersViewController.user = self.currentUser;
    [self.navigationController pushViewController:followersViewController animated:YES];
}


- (void) setHeader {
    
    if([self userIsTrainer] ){
        [self setupTrainerPage];
    }else{
        [self setupTraineePage];
    }
    [self setupMyPage];
    
    self.allFollowings = [[FitovateData sharedFitovateData] getAllIdsThatUsersFollowing:^{
        
        if([self.allFollowings containsObject:[NSNumber numberWithInt:self.currentUser.userID]]){
            [self.headerView.buttonFollow setTitle:@"Following" forState:UIControlStateNormal];
        }else{
            [self.headerView.buttonFollow setTitle:@"Follow!" forState:UIControlStateNormal];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.posts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"WLIPostCell";
    WLIPostCell *cell = (WLIPostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:self options:nil] lastObject];
        cell.delegate = self;
    }
    cell.post = self.posts[indexPath.row];
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)buttonFollowToggleTouchUpInside {
    
//    if (self.currentUser.followingUser) {
//        self.currentUser.followingUser = NO;
//        self.currentUser.followersCount--;
//
//        [self.headerView.buttonFollow setTitle:@"Follow!" forState:UIControlStateNormal];
//        
//        FitovateData *myData = [FitovateData sharedFitovateData];
//        
//        [myData unfollowUserIdWithUserId:[NSNumber numberWithInt:myData.currentUser.userID]:[NSNumber numberWithInt:self.currentUser.userID]];
//    } else {
        self.currentUser.followingUser = YES;
        self.currentUser.followersCount++;

        FitovateData *myData = [FitovateData sharedFitovateData];
        [self.headerView.buttonFollow setTitle:@"Following" forState:UIControlStateNormal];
        
        [myData followUserIdWithUserId:[NSNumber numberWithInt:myData.currentUser.userID]:[NSNumber numberWithInt:self.currentUser.userID]];
    //}
}

-(void)goToMessages {
    
    //    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    //    LQSViewController *newVc = [[LQSViewController alloc]init];
    //    [self.navigationController pushViewController:newVc animated:YES];
    
    self.messageAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Send to: %@",self.currentUser.userUsername] message:@"Enter message text" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",nil];
    self.messageAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //[alert show];
    [self.messageAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

- (void)sendMessage:(NSString *)messageText{
    WLIConnect *connect = [WLIConnect sharedConnect];
    // If no conversations exist, create a new conversation object with two participants
    FitovateData *myData = [FitovateData sharedFitovateData];
    [myData hasAMessage:self.currentUser.userUsername];
    NSError *error = nil;
    self.conversation = [connect.layerClient newConversationWithParticipants:[NSSet setWithArray:@[ self.currentUser.userUsername, connect.currentUser.userUsername ]] options:nil error:&error];
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
        [myData hasAMessage:self.currentUser.userUsername];
        
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
        
        WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate createViewHierarchy];
        [appDelegate.tabBarController showWelcome];
    }else if([alertView.title isEqualToString:[NSString stringWithFormat:@"Send to: %@",self.currentUser.userUsername]]){
        if (buttonIndex == [alertView cancelButtonIndex]) {
            
        }else{
            NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
            [self sendMessage:[[alertView textFieldAtIndex:0] text]];
            
            //benmark10
        }
    }
}
- (IBAction)editProfileButtonTouchUpInside:(id)sender{
    WLIEditProfileViewController *editProfileViewController = [[WLIEditProfileViewController alloc] initWithNibName:@"WLIEditProfileViewController" bundle:nil];
    [self.navigationController pushViewController:editProfileViewController animated:YES];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    NSLog(@"tapped");
    if(playing){
        [moviePlayerController.moviePlayer pause];
        playing = NO;
        
    }else{
        [moviePlayerController.moviePlayer play];
        playing = YES;
    }
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)buttonContactUsTouchUpInside{
    
    // Email Subject
    NSString *emailTitle = @"Contacting Fitovate";
    // Email Content
    NSString *messageBody = @"Enter text here";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"fitovate@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

// this allows you to dispatch touches
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(BOOL)userIsTheCurrentUser{
    if(self.currentUser.userID == [WLIConnect sharedConnect].currentUser.userID)
        return YES;
    else
        return NO;
    
}

-(BOOL)userIsTrainer{
    if([self.currentUser.userType isEqualToString:@"trainer"] ){
        NSLog(@"is a trainer");
        return YES;
    }else{
        NSLog(@"is a trainee");
        return NO;
    }
}

-(void)setupTraineePage{
    CustomHeaderView *headerView = [[CustomHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240)];
    if(self.currentUser.userAvatarPath!=nil){
        [headerView.imageViewUser hnk_setImageFromURL:[[NSURL alloc]initWithString:self.currentUser.userAvatarPath]];
    }
    
    [headerView.buttonMessage addTarget:self action:@selector(goToMessages) forControlEvents:UIControlEventTouchUpInside];
    
    headerView.labelName.text = self.currentUser.userUsername;
    headerView.labelFollowingCount.text = [NSString stringWithFormat:@"following %d", self.currentUser.followingCount];
    headerView.labelFollowersCount.text = [NSString stringWithFormat:@"followers %d", self.currentUser.followersCount];
    
    headerView.labelBio.text = self.currentUser.userBio;
    self.tableView.tableHeaderView = headerView;
}

-(void)setupMyPage{
    if ([self userIsTheCurrentUser]) {
        NSLog(@"setingupMyPage");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Contact Us" style:UIBarButtonItemStylePlain target:self action:@selector(buttonContactUsTouchUpInside)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(buttonLogoutTouchUpInside)];
        self.headerView.buttonMessage.hidden = YES;
        self.headerView.buttonFollow.hidden = YES;
        [self.headerView.editProfileButton addTarget:self action:@selector(editProfileButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self.headerView.buttonFollow addTarget:self
                                         action:@selector(buttonFollowToggleTouchUpInside)
                               forControlEvents:UIControlEventTouchUpInside];
        self.headerView.editProfileButton.hidden = YES;
    }
}
-(void)setupTrainerPage{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.headerView = [[CustomHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240 + screenWidth)];
    [self.headerView.imageViewUser hnk_setImageFromURL:[[NSURL alloc]initWithString:self.currentUser.userAvatarPath]];
    
    [self.headerView.buttonMessage addTarget:self action:@selector(goToMessages) forControlEvents:UIControlEventTouchUpInside];
    
    self.headerView.labelName.text = [NSString stringWithFormat:@"@%@",self.currentUser.userUsername];
    self.headerView.labelFollowingCount.text = [NSString stringWithFormat:@"following %d", self.currentUser.followingCount];
    self.headerView.labelFollowersCount.text = [NSString stringWithFormat:@"followers %d", self.currentUser.followersCount];
    
    self.headerView.labelBio.text = self.currentUser.userBio;
    
    UIView *videoPlaceHolderVIew = [[UIView alloc]initWithFrame:CGRectMake(0, 240, screenWidth, screenWidth)];
    
    [self.headerView addSubview:videoPlaceHolderVIew];
    
    self.tableView.tableHeaderView = self.headerView;
    
    
    NSString *usernameWithoutSpaces=[self.currentUser.userUsername
                                     stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSURL *url =[[NSURL alloc]initWithString:self.currentUser.youtubeString];
    
    moviePlayerController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:@"9bZkp7q19f0"];
    [moviePlayerController.view setFrame:videoPlaceHolderVIew.bounds];
    [moviePlayerController presentInView:videoPlaceHolderVIew];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    [moviePlayerController.view addGestureRecognizer:tap];
    
    [moviePlayerController.moviePlayer play];
    self.automaticallyAdjustsScrollViewInsets = NO;
}


@end
