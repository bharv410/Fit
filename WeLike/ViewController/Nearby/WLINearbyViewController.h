//
//  WLINearbyViewController.h
//
//
//  Created by navneeth 
//  Copyright (c) 2015 Navneeth Ramprasad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"
#import "UIImageView+AFNetworking.h"

@interface WLINearbyViewController : WLIViewController

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) IBOutlet UITableView *nearbyTrainersTableView;

@end
