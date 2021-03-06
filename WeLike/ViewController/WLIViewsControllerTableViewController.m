//
//  WLIViewsControllerTableViewController.m
//  Fitovate
//
//  Created by Benjamin Harvey on 1/14/16.
//
//

#import "WLIViewsControllerTableViewController.h"
#import <Parse/Parse.h>
#import "WLIConnect.h"
#import "NormalUserProfileTableViewController.h"
#import "FitovateData.h"
#import "MyCustomCellTableViewCell.h"
#import "WLIUser.h"


@interface WLIViewsControllerTableViewController ()

@end

@implementation WLIViewsControllerTableViewController


@synthesize booksArray;
@synthesize imageArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Views"];
    [query addDescendingOrder:@"createdAt"];
    [query whereKey:@"viewed" equalTo:[WLIConnect sharedConnect].currentUser.userUsername];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            self.booksArray = objects;
            self.imageArray = [[NSMutableArray alloc]init];
            
            for (PFObject *object in objects) {
                NSString *username = object[@"viewer"];
                
                PFFile *imageFile = object[@"photo"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        [self.imageArray addObject:image];
                        [self.tableView reloadData];
                    }
                }];
                
                NSLog(@" %@ ", username);
            }
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.booksArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"myCell";
    
    MyCustomCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"MyCustomCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    PFObject *parseObject = [self.booksArray objectAtIndex:indexPath.row];
    NSString *username = parseObject[@"viewer"];
    cell.trainerName.text = username;
    
    if(self.imageArray.count > indexPath.row)
        cell.imageView.image = [self.imageArray objectAtIndex:indexPath.row];
    
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    
    PFObject *parseObject = [self.booksArray objectAtIndex:indexPath.row];
    NSString *username = parseObject[@"viewer"];
    NSLog(@"no user");
    
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query whereKey:@"username" equalTo:username];
    NSArray *returnedObkecs = [query findObjects];
    if([returnedObkecs count]>0){
        
        PFObject *loggedInUserParse = [returnedObkecs objectAtIndex:0];
        WLIUser *thisuser = [self pfobjectToWLIUser:loggedInUserParse];
        NSLog(@" %@", thisuser.userEmail);
        
        NormalUserProfileTableViewController *profileViewController = [[NormalUserProfileTableViewController alloc] initWithNibName:@"NormalUserProfileTableViewController" bundle:nil];
        
        profileViewController.currentUser = thisuser;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }else{
        NSLog(@"no user");
    }
}

- (WLIUser *) pfobjectToWLIUser : (PFObject *) userFromParse {
    FitovateData *myData = [FitovateData sharedFitovateData];
    WLIUser *currUser = [[WLIUser alloc]initFromParse:[myData parseUserToDictionary:userFromParse]];
    //inits it to parse and then fixes the userAvatar by using pffile data and pfgeopint data
    currUser.youtubeString = userFromParse[@"youtubeString"];
    currUser.companyAddress = userFromParse[@"citystate"];
    
    PFFile *imageUrl = userFromParse[@"userAvatar"];
    currUser.userAvatarPath = imageUrl.url;
    
    PFGeoPoint *selectedLocation = [userFromParse objectForKey:@"location"];
    float selectedLatitude = selectedLocation.latitude; // returns object latitude float
    float selectedLongitude = selectedLocation.longitude; // returns object longitude
    currUser.coordinate = CLLocationCoordinate2DMake(selectedLatitude, selectedLongitude);
    return currUser;
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
