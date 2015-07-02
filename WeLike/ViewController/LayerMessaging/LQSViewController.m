           //
//  LQSViewController.m
//  Fitovate
//
//  Created by Benjamin Harvey on 1/23/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "LQSViewController.h"
#import "LQSChatMessageCell.h"
#import "WLIConnect.h"
#import "ConversationTableViewController.h"
#import "FitovateData.h"
#import "ConferenceViewController.h"

@interface LQSViewController ()


@end


@implementation LQSViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.convoNumber = 1;
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"All Messages" style:UIBarButtonItemStylePlain target:self action:@selector(nextConvo:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    [self.messageText setHidden:YES];
    
    // Do any additional setup after loading the view from its nib.
    //benmark
//    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"c6d3dfe6-a1a8-11e4-b169-142b010033d0"];
//    self.layerClient = [LYRClient clientWithAppID:appID];
//    [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
//        if (!success) {
//            NSLog(@"Failed to connect to Layer: %@", error);
//        } else {
//            NSString *userIDString = WLIConnect.sharedConnect.currentUser.userUsername;
//            // Once connected, authenticate user.
//            // Check Authenticate step for authenticateLayerWithUserID source
//            [self authenticateLayerWithUserID:userIDString completion:^(BOOL success, NSError *error) {
//                if (!success) {
//                    NSLog(@"Failed Authenticating Layer Client with error:%@", error);
//                }else{
//                    NSLog(@"grabbing conversations...");
//                    [self fetchLayerConversation];
//                }
//            }];
//        }
//    }];
    [self fetchLayerConversation];
}
//this displays all messages


- (void) nextConvo :(id)sender{
    self.convoNumber++;
    [self fetchLayerConversation];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display Alert Message
    [messageAlert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)SendBtnClick:(id)sender
{
    
    if([self.replyButton.currentTitle isEqualToString:@"Reply"]){
        NSLog(@"is equal to reply");
        [self.replyButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.messageText setHidden:NO];
        [self.videoCallButton setHidden:YES];
    }else if([self.replyButton.currentTitle isEqualToString:@"Send"]){
        NSLog(@"is equal to send");
        [self sendMessage:self.messageText.text];
        self.messageText.text = @"";
    }
}

- (IBAction) videoCall: (id) sender
{
//    NSSet *participantsInConvo = [self.conversation participants];
//    for(NSString* participant in participantsInConvo) {
//        
//        if(![participant containsString:[WLIConnect sharedConnect].currentUser.userUsername]){
//            NSLog(@"videocall = %@",participant);
//            ConferenceViewController *cvc = [[ConferenceViewController alloc]init];
//            cvc.conferenceToJoin = participant;
//            [self.navigationController pushViewController:cvc animated:NO];
//            FitovateData *myData = [FitovateData sharedFitovateData];
//            [myData joinConference:participant];
//            return;
//        }
//    }
}

- (void)sendMessage:(NSString *)messageText{
    WLIConnect *connect = [WLIConnect sharedConnect];
    // If no conversations exist, create a new conversation object with two participants
    if (!self.conversation) {
        NSError *error = nil;
        self.conversation = [connect.layerClient newConversationWithParticipants:[NSSet setWithArray:@[ connect.currentUser.userUsername, @ "Dashboard" ]] options:nil error:&error];
        if (!self.conversation) {
            NSLog(@"New Conversation creation failed: %@", error);
        }
    }
    
    // Creates a message part with text/plain MIME Type
    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithText:messageText];
    
    // Creates and returns a new message object with the given conversation and array of message parts
    LYRMessage *message = [connect.layerClient newMessageWithParts:@[messagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:nil];
    
    // Sends the specified message
    NSError *error;
    BOOL success = [self.conversation sendMessage:message error:&error];
    if (success) {
        NSLog(@"Message queued to be sent: %@", messageText);
    } else {
        NSLog(@"Message send failed: %@", error);
    }
}


- (void)fetchLayerConversation
{
    
    
    WLIConnect *connect = [WLIConnect sharedConnect];
    
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    
    query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES] ];
    
    NSError *error;
    NSOrderedSet *conversations = [connect.layerClient executeQuery:query error:&error];
    if(conversations.count==self.convoNumber)
        self.convoNumber=1;
    if (!error) {
        NSLog(@"%tu conversations with participants %@", conversations.count, @[ connect.currentUser.userUsername ]);
    
        
        NSMutableArray *arrayOfSenders = [[NSMutableArray alloc]init];
        NSMutableArray *arrayOfConvos = [[NSMutableArray alloc]init];
        for(LYRConversation *convers in conversations){
            NSSet *participantsInConvo = [convers participants];
            for(NSString* participant in participantsInConvo) {
                if(![participant containsString:connect.currentUser.userUsername]){
                    [arrayOfSenders addObject:participant];
                    [arrayOfConvos addObject:convers];
                }
            }
        }
                     self.pushedCTV = [[ConversationTableViewController alloc]init];
                     self.pushedCTV.conversationSenderList = arrayOfSenders;
                     self.pushedCTV.conversationsList = arrayOfConvos;
        self.pushedCTV.delegate=self;
        [self.navigationController pushViewController:self.pushedCTV animated:YES];
    
    
    } else {
        NSLog(@"Query failed with error %@", error);
    }
    
    // Retrieve the last conversation
    if (conversations.count) {
        
        NSUInteger currentConvo = conversations.count - self.convoNumber;
        
        self.conversation = [conversations objectAtIndex:currentConvo];
        NSLog(@"Get last conversation object: %@",self.conversation.identifier);
        // setup query controller with messages from last conversation
        [self setupQueryController];
    }
}
-(void)sendDataToA:(LYRConversation *)conversation
{
    // data will come here inside of ViewControllerA
    self.conversation = conversation;
    [self setupQueryController];
}

-(void)setupQueryController
{
    WLIConnect *connect = [WLIConnect sharedConnect];
    // Query for all the messages in conversation sorted by index
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:self.conversation];
    //query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:NO]];
    
    // Set up query controller
    self.queryController = [connect.layerClient queryControllerWithQuery:query];
    self.queryController.delegate = self;
    NSError *error;
    BOOL success = [self.queryController execute:&error];
    if (success) {
        NSLog(@"Query fetched %tu message objects", [self.queryController numberOfObjectsInSection:0]);
        [self.tableView reloadData];
    } else {
        NSLog(@"Query failed with error: %@", error);
    }
}
- (void)queryControllerWillChangeContent:(LYRQueryController *)queryController
{
    [self.tableView beginUpdates];
}


- (void)queryController:(LYRQueryController *)controller
didChangeObject:(id)object
atIndexPath:(NSIndexPath *)indexPath
forChangeType:(LYRQueryControllerChangeType)type
newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSLog(@"Noticed a change");
    // Automatically update tableview when there are change events
    switch (type) {
        case LYRQueryControllerChangeTypeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController
{
    [self.tableView endUpdates];
}
//this displays all messages


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.queryController numberOfObjectsInSection:0];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"myCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLIConnect *sharedConnect = [WLIConnect sharedConnect];
    // Get Message Object from queryController
    LYRMessage *message = [self.queryController objectAtIndexPath:indexPath];
    
    LYRMessagePart *messagePart = message.parts[0];
    LYRActor *sender = [message sender];
    NSString *senderName = [sender userID];
    NSSet *participantsInConvo = [self.conversation participants];
    for(NSString* participant in participantsInConvo) {
        NSLog(@"participant name = %@",participant);
        if(![participant containsString:sharedConnect.currentUser.userUsername])
            self.title = [NSString stringWithFormat:@"%@",participant];
    }
    
    if([sharedConnect.currentUser.userUsername containsString:[sender userID]]){
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:92.0f/255.0f green:173.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        cell.textLabel.backgroundColor = [UIColor colorWithRed:92.0f/255.0f green:173.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding]];
    
}


@end
