//
//  LQSViewController.h
//  Fitovate
//
//  Created by Benjamin Harvey on 1/23/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "ConversationTableViewController.h"

@interface LQSViewController : UIViewController <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource,LYRQueryControllerDelegate>

@property (strong, nonatomic) LYRClient *layerClient;
@property (nonatomic) NSUInteger convoNumber;
@property (nonatomic, retain) LYRQueryController *queryController;
@property (nonatomic) LYRConversation *conversation;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageText;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *videoCallButton;

@property (strong, nonatomic)  ConversationTableViewController *pushedCTV;

- (IBAction) videoCall: (id) sender;

@end
