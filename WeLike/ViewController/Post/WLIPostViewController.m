//
//  WLICommentsViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPostViewController.h"
#import "WLICommentCell.h"
#import "WLILoadingCell.h"
#import "GlobalDefines.h"
#import "ParseSingleton.h"
#import "FitovateData.h"
#import "WLIConnect.h"
#import <Parse/Parse.h>

@implementation WLIPostViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.comments = [NSMutableArray array];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Post";
    
    [self.textFieldEnterComment setPlaceholder:@"... Leave a comment!"];
    self.textFieldEnterComment.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self reloadData:YES];
    
    UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reportButton.adjustsImageWhenHighlighted = NO;
    reportButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
    [reportButton setImage:[UIImage imageNamed:@"reportphotoimage.png"] forState:UIControlStateNormal];
    [reportButton addTarget:self action:@selector(barButtonItemReportTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:reportButton];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll {
    
    loading = YES;
    int page = reloadAll ? 1 : (self.comments.count / kDefaultPageSize) + 1;
    [sharedConnect commentsForPostID:self.post.postID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *comments, ServerResponse serverResponseCode) {
        loading = NO;
        if (reloadAll) {
            [self.comments removeAllObjects];
        }
        [self.comments addObjectsFromArray:comments];
        loadMore = comments.count == kDefaultPageSize;
        [self.tableViewRefresh reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
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
        cell.post = self.post;
        return cell;
        
    } else if (indexPath.section == 2) {
        static NSString *CellIdentifier = @"WLICommentCell";
        WLICommentCell *cell = (WLICommentCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLICommentCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        cell.comment = self.comments[indexPath.row];
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
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (section == 1) {
        return 1;
    } else if (section == 2) {
        return self.comments.count;
    } else {
        if (loadMore) {
            return 1;
        } else {
            return 0;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WLIComment *comment = self.comments[indexPath.row];
        [sharedConnect removeCommentWithCommentID:comment.commentID onCompletion:^(ServerResponse serverResponseCode) {
            [self reloadData:YES];
        }];
    }
}


#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return [WLIPostCell sizeWithPost:self.post].height;
    } else if (indexPath.section == 2){
        return [WLICommentCell sizeWithComment:self.comments[indexPath.row]].height;
    } else if (indexPath.section == 0){
        return 44 * loadMore * self.comments.count == 0;
    } else {
        return 44 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 3 && loadMore && !loading) {
        [self reloadData:NO];
    }
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.31 animations:^{
        self.viewEnterComment.center = CGPointMake(self.viewEnterComment.center.x, self.viewEnterComment.center.y - 216 + 49);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.31 animations:^{
        self.viewEnterComment.center = CGPointMake(self.viewEnterComment.center.x, self.viewEnterComment.center.y + 216 - 49);
    } completion:^(BOOL finished) {
        if (self.textFieldEnterComment.text.length) {
            
            [ParseSingleton new];
            [ParseSingleton recordActivity:sharedConnect.currentUser.userUsername forSource:self.post.user.userUsername withActivitytype:@"comment" withPostId:[NSString stringWithFormat:@"%d",self.post.postID]];
            
            
            [hud show:YES];
            [sharedConnect sendCommentOnPostID:self.post.postID withCommentText:self.textFieldEnterComment.text onCompletion:^(WLIComment *comment, ServerResponse serverResponseCode) {
                [hud hide:YES];
                [self.comments insertObject:comment atIndex:0];
                [self.tableViewRefresh reloadData];
                self.textFieldEnterComment.text = @"";
            }];
        }
    }];
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
        
        [myData unlikeUserIdWithPostId:[NSNumber numberWithInt:myData.currentUser.userID] :[NSNumber numberWithInt:self.post.postID] :^{
            //[senderCell updateLikes];
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
        [ParseSingleton new];
        [ParseSingleton recordActivity:sharedConnect.currentUser.userUsername forSource:self.post.user.userUsername withActivitytype:@"like" withPostId:[NSString stringWithFormat:@"%d",self.post.postID]];
        
        FitovateData *myData = [FitovateData sharedFitovateData];
        [myData likeUserIdWithPostId:[NSNumber numberWithInt:myData.currentUser.userID] :[NSNumber numberWithInt:self.post.postID] :^{
            [senderCell updateLikes];
        }];
        
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


#pragma mark - Actions methods

- (void)barButtonItemReportTouchUpInside:(UIBarButtonItem *)barButtonItem {
    if([self.post.user.userUsername isEqualToString:[WLIConnect sharedConnect].currentUser.userUsername]){
        [[[UIAlertView alloc] initWithTitle:@"Delete Photo" message:@"Are you sure you want to delete this photo?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil] show];
        
                //if its my post delete it. if not then report it
    }else{
        if ([MFMailComposeViewController canSendMail]) {
            
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Report" message:@"Are you sure you want to report this post?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Report!", nil];
            [alrt dismissWithClickedButtonIndex:[alrt cancelButtonIndex] animated:YES];
            [alrt show];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Report" message:@"This device is not configured to send mails, please enable mail and contact us at report@foodspotting.com" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}


#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    if (result == MFMailComposeResultFailed) {
        [[[UIAlertView alloc] initWithTitle:@"Mail not sent!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:^{ }];
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        NSLog(@"The cancel button was clicked for alertView");
        [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
    }else if([alertView.title isEqualToString:@"Delete Photo"] && [[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:@"OK"]){
        PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
        [query whereKey:@"postID" equalTo:[NSNumber numberWithInt:self.post.postID]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *hospitals, NSError *error) {
            if (!error)
            {
                for (PFObject *hospital in hospitals)
                {
                    [hospital deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded){
                            NSLog(@"BOOOOOM"); // this is my function to refresh the data
                            [[[UIAlertView alloc] initWithTitle:@"Delete Photo" message:@"Deleted" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        } else {
                            NSLog(@"DELETE ERRIR");
                        }
                    }];
                }
            }
            else
            {
                NSLog(@"%@",error);
            }
        }];
        
    }else {
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.navigationBar.tintColor = [UIColor whiteColor];
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setToRecipients:@[@"claytonminott29@gmail.com"]];
        [mailComposeViewController setSubject:@"Report"];
        NSString *message = [NSString stringWithFormat:@"Reporting post with id: %d\n\nDescription: %@  from username = %@", self.post.postID, self.post.postTitle, self.post.user.userUsername];
        [mailComposeViewController setMessageBody:message isHTML:NO];
        [self presentViewController:mailComposeViewController animated:YES completion:^{
            [[mailComposeViewController navigationBar] setTintColor:[UIColor blackColor]];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    }
}

@end
