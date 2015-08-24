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
#import "CustomHeaderView.h"

@interface NormalUserProfileTableViewController ()

@end

@implementation NormalUserProfileTableViewController{
    MPMoviePlayerController *moviePlayerController;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setHeader];
    self.loading = NO;
    
    NSLog(@"current username = %@", self.currentUser.userUsername);
    [self reloadData:YES];
}

- (void)reloadData:(BOOL)reloadAll {
    self.loading = YES;
    self.posts = [[NSMutableArray alloc]initWithCapacity:20];
    FitovateData *myData = [FitovateData sharedFitovateData];
    __block NSUInteger postCount = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
    
    [query addDescendingOrder:@"createdAt"];
    
    [query whereKey:@"userID" equalTo:[NSNumber numberWithInt:self.currentUser.userID]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loading = NO;
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
                self.tableView.rowHeight = [WLIPostCell sizeWithPost:lasP].height;
                [self.tableView reloadData];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


- (void) setHeader {
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 90, 90)];
//    
//    [imageView hnk_setImageFromURL:[[NSURL alloc]initWithString:self.currentUser.userAvatarPath]];
//    
//    [headerView addSubview:imageView];
//    UILabel *fakelabelView = [[UILabel alloc] initWithFrame:CGRectMake(110, 25, self.view.frame.size.width - 110, 200)];
//    
//    CGSize labelSize = [self.currentUser.userInfo sizeWithFont:fakelabelView.font constrainedToSize:CGSizeMake(self.view.frame.size.width/2, 100) lineBreakMode:NSLineBreakByWordWrapping];
//    
//    CGRect rect = [self.currentUser.userInfo boundingRectWithSize:labelSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:nil context:nil];
//    
//    UILabel *labelView = [[UILabel alloc] initWithFrame:rect];
//    labelView.numberOfLines = 0;
//    [labelView setText:self.currentUser.userInfo];
//    [labelView sizeToFit];
//    [headerView addSubview:labelView];
//    labelView.frame = CGRectMake(fakelabelView.frame.origin.x, fakelabelView.frame.origin.y
//                                 , labelView.frame.size.width, labelView.frame.size.height);
//    
//    self.tableView.tableHeaderView = headerView;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    if([self.currentUser.userType isEqualToString:@"trainer"] ){

        CustomHeaderView *headerView = [[CustomHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240 + screenWidth)];
        [headerView.imageViewUser hnk_setImageFromURL:[[NSURL alloc]initWithString:self.currentUser.userAvatarPath]];
        
        FitovateData *myData = [FitovateData sharedFitovateData];
        self.allFollowings = [myData getAllIdsThatUsersFollowing:^{
            if([self.allFollowings containsObject:[NSNumber numberWithInt:self.currentUser.userID]]){
                [headerView.buttonFollow setTitle:@"Following" forState:UIControlStateNormal];
                NSLog(@"Set to following1");
            }else{
                [headerView.buttonFollow setTitle:@"Follow!" forState:UIControlStateNormal];
                NSLog(@"Set to follow1");
            }
        }];
        [headerView.buttonFollow addTarget:self
                     action:@selector(buttonFollowToggleTouchUpInside)
           forControlEvents:UIControlEventTouchUpInside];
        [headerView.buttonMessage addTarget:self action:@selector(goToMessages) forControlEvents:UIControlEventTouchUpInside];
        
        headerView.labelName.text = [NSString stringWithFormat:@"@%@",self.currentUser.userUsername];
        headerView.labelFollowingCount.text = [NSString stringWithFormat:@"following %d", self.currentUser.followingCount];
        headerView.labelFollowersCount.text = [NSString stringWithFormat:@"followers %d", self.currentUser.followersCount];
        
        headerView.labelBio.text = self.currentUser.userBio;
        
        UIView *videoPlaceHolderVIew = [[UIView alloc]initWithFrame:CGRectMake(0, 240, screenWidth, screenWidth)];
        
        [headerView addSubview:videoPlaceHolderVIew];
        
        self.tableView.tableHeaderView = headerView;
        
        
        NSString *usernameWithoutSpaces=[self.currentUser.userUsername
                                         stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        PFQuery *videoQuery = [PFQuery queryWithClassName:@"Videos"];
        [videoQuery whereKey:@"username" equalTo:self.currentUser.userUsername];
        NSLog(@"%@",self.currentUser.userUsername);
        [videoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                for (PFObject *object in objects) {
                    
                    PFFile *videoFile = object[@"video"];
                    NSString *urlOfVideo = videoFile.url;
                    NSURL *url =[[NSURL alloc]initWithString:urlOfVideo];
                    
                    moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:url];
                    [moviePlayerController.view setFrame:videoPlaceHolderVIew.bounds];  // player's frame must match parent's
                    [videoPlaceHolderVIew addSubview:moviePlayerController.view];
                    
                    // Configure the movie player controller
                    moviePlayerController.controlStyle = MPMovieControlStyleNone;
                    [moviePlayerController prepareToPlay];
                    // Start the movie
                    [moviePlayerController play];
                    
//                    CGRect rect = CGRectMake(videoPlaceHolderVIew.frame.origin.x, self.labelBio.frame.origin.y + 20.0f + self.labelBio.bounds.size.height, self.movieView.bounds.size.width, self.movieView.bounds.size.height);
//                    self.movieView.frame = rect;
                    self.automaticallyAdjustsScrollViewInsets = NO;
                    
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                [videoPlaceHolderVIew setHidden:YES];
            }
        }];
        
        
    }else{
    
    
    CustomHeaderView *headerView = [[CustomHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240)];
        [headerView.imageViewUser hnk_setImageFromURL:[[NSURL alloc]initWithString:self.currentUser.userAvatarPath]];
    
    FitovateData *myData = [FitovateData sharedFitovateData];
    self.allFollowings = [myData getAllIdsThatUsersFollowing:^{
        if([self.allFollowings containsObject:[NSNumber numberWithInt:self.currentUser.userID]]){
            [headerView.buttonFollow setTitle:@"Following" forState:UIControlStateNormal];
            NSLog(@"Set to following1");
        }else{
            [headerView.buttonFollow setTitle:@"Follow!" forState:UIControlStateNormal];
            NSLog(@"Set to follow1");
        }
    }];
        [headerView.buttonFollow addTarget:self
                                    action:@selector(buttonFollowToggleTouchUpInside)
                          forControlEvents:UIControlEventTouchUpInside];
        [headerView.buttonMessage addTarget:self action:@selector(goToMessages) forControlEvents:UIControlEventTouchUpInside];
        headerView.labelName.text = self.currentUser.userUsername;
        headerView.labelFollowingCount.text = [NSString stringWithFormat:@"following %d", self.currentUser.followingCount];
        headerView.labelFollowersCount.text = [NSString stringWithFormat:@"followers %d", self.currentUser.followersCount];
    
        headerView.labelBio.text = self.currentUser.userBio;
        self.tableView.tableHeaderView = headerView;
    }
    
//        self.labelAddress.text = self.user.companyAddress;
//        self.labelPhone.text = self.user.companyPhone;
//        self.labelWeb.text = self.user.companyWeb;
//        self.labelEmail.text = self.user.companyEmail;
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
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
    
    if (self.currentUser.followingUser) {
        self.currentUser.followingUser = NO;
        self.currentUser.followersCount--;
        [self setHeader];
        
        FitovateData *myData = [FitovateData sharedFitovateData];
        
        [myData unfollowUserIdWithUserId:[NSNumber numberWithInt:myData.currentUser.userID]:[NSNumber numberWithInt:self.currentUser.userID]];
    } else {
        self.currentUser.followingUser = YES;
        self.currentUser.followersCount++;
        [self setHeader];
        FitovateData *myData = [FitovateData sharedFitovateData];
        
        [myData followUserIdWithUserId:[NSNumber numberWithInt:myData.currentUser.userID]:[NSNumber numberWithInt:self.currentUser.userID]];
    }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    WLIConnect *connect = [WLIConnect sharedConnect];
    if([alertView.title isEqualToString:[NSString stringWithFormat:@"Send to: %@",self.currentUser.userUsername]]){
        if (buttonIndex == [alertView cancelButtonIndex]) {
            
        }else{
            NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
            [self sendMessage:[[alertView textFieldAtIndex:0] text]];
            
            //benmark10
        }
    }
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


@end
