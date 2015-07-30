//
//  WLIUserPhotoControllerTableViewController.m
//  Fitovate
//
//  Created by Benjamin Harvey on 7/28/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "WLIUserPhotoControllerTableViewController.h"
#import <Haneke/Haneke.h>
#import "WLIPostCell.h"
#import "WLILoadingCell.h"
#import "FitovateData.h"

@interface WLIUserPhotoControllerTableViewController ()

@end

@implementation WLIUserPhotoControllerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setHeader];
    self.loading = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 90, 90)];

    [imageView hnk_setImageFromURL:[[NSURL alloc]initWithString:self.currentUser.userAvatarPath]];
    
    [headerView addSubview:imageView];
    UILabel *fakelabelView = [[UILabel alloc] initWithFrame:CGRectMake(110, 25, self.view.frame.size.width - 110, 200)];
    
    CGSize labelSize = [self.currentUser.userInfo sizeWithFont:fakelabelView.font constrainedToSize:CGSizeMake(self.view.frame.size.width/2, 100) lineBreakMode:NSLineBreakByWordWrapping];

    CGRect rect = [self.currentUser.userInfo boundingRectWithSize:labelSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:nil context:nil];
    
    UILabel *labelView = [[UILabel alloc] initWithFrame:rect];
    labelView.numberOfLines = 0;
    [labelView setText:self.currentUser.userInfo];
    [labelView sizeToFit];
    [headerView addSubview:labelView];
    labelView.frame = CGRectMake(fakelabelView.frame.origin.x, fakelabelView.frame.origin.y
                                 , labelView.frame.size.width, labelView.frame.size.height);
    
    self.tableView.tableHeaderView = headerView;
    
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

@end
