//
//  WLIChooseVideoViewController.h
//  Fitovate
//
//  Created by Benjamin Harvey on 1/9/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLIChooseVideoViewController : UIViewController

@property (strong, nonatomic) NSString *usersName;
@property (strong, nonatomic) IBOutlet UITextField *youtubeTextField;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
- (IBAction)onUploadClicked:(id)sender;

@end
