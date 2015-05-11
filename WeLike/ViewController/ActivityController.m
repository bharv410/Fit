//
//  ActivityController.m
//  Fitovate
//
//  Created by Benjamin Harvey on 4/27/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "ActivityController.h"
#import <Parse/Parse.h>
#import "WLIPost.h"
#import "WLIPostViewController.h"
#import "WLIConnect.h"
#import "GlobalDefines.h"

@interface ActivityController ()

@end

@implementation ActivityController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query addDescendingOrder:@"createdAt"];
    [query whereKey:@"userID" equalTo:@"bharv410"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d fitovate ativity from parse.", objects.count);
            NSMutableArray *stringsOfActivity = [[NSMutableArray alloc]initWithCapacity:10];
            NSMutableArray *postIds = [[NSMutableArray alloc]initWithCapacity:10];
            
            for (PFObject *object in objects) {
                
                NSString *activityType = object[@"activityType"];
                NSString *sourceId = object[@"sourceId"];
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                NSNumber *postId = [f numberFromString:@"postID"];
                
                NSString *activityText = [NSString stringWithFormat:@"You added a %@ on %@'s photo",activityType,sourceId];
                
                
                
                [stringsOfActivity insertObject:activityText atIndex:0];
                [postIds addObject:postIds];
            }
            self.posts = stringsOfActivity;
            self.postIDs = postIds;
            [self.tableViewRefresh reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.posts.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    cell.textLabel.text = [self.posts
                           objectAtIndex: [indexPath row]];
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


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
//    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
//    
//    // Pass the selected object to the new view controller.
//    
//    // Push the view controller.
//    [self.navigationController pushViewController:detailViewController animated:YES];
    
    
    NSNumber *postId = [self.postIDs objectAtIndex:indexPath.section];
    
    for(NSObject *num in self.postIDs){
        NSLog(@"postId include %@",num);
        NSLog(@"indexpathsec is %i",indexPath.section);
        NSLog(@"indexpathsec is %i",indexPath.row);
    }
    
    NSLog(@"postId is %@",postId);
    
    PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
    [query whereKey:@"postID" equalTo:postId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {

            PFObject *object = [objects objectAtIndex:0];
            
                NSString *playerName = object[@"postTitle"];
                NSLog(@"%@", object.createdAt);
                    
                    PFFile *tempPhotoForUrl = object[@"userImage"];
                    
                    
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:  object[@"postID"], @"postID",
                                          object[@"postTitle"], @"postTitle",
                                          tempPhotoForUrl.url, @"postImage",
                                          object[@"createdAt"], @"postDate",
                                          object[@"createdAt"], @"timeAgo",
                                          [[NSDictionary alloc]init], @"user",
                                          object[@"totalLikes"], @"totalLikes",
                                          object[@"totalComments"], @"totalComments",
                                          object[@"isLiked"], @"isLiked",
                                          object[@"isCommented"], @"isCommented"
                                          , nil];
                    WLIPost *postFromParse = [[WLIPost alloc]initWithDictionary:dict];
            
            WLIPostViewController *postViewController = [[WLIPostViewController alloc] initWithNibName:@"WLIPostViewController" bundle:nil];
            postViewController.post = postFromParse;
            [self.navigationController pushViewController:postViewController animated:YES];
                    //benmark
            //set use
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
