//
//  MessagesViewController.h
//  ooVooSample
//
//  Created by Clement Barry on 12/18/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import "JSMessagesViewController.h"
#import "MessagesController.h"

@interface MessagesViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate, MessagesControllerDelegate>

@property (nonatomic, strong) MessagesController *messagesController;

- (IBAction)done:(id)sender;

@end
