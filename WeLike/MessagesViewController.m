//
//  MessagesViewController.m
//  ooVooSample
//
//  Created by Clement Barry on 12/18/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import "MessagesViewController.h"
#import <ooVooSDK-iOS/ooVooSDK-iOS.h>

@interface MessagesViewController ()

@end

@implementation MessagesViewController

- (void)viewDidLoad
{
    self.dataSource = self;
    self.delegate = self;
    [super viewDidLoad];
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.messagesController.delegate = self;
}

- (IBAction)done:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messagesController.messages count];
}

- (Message *)messageAt:(NSIndexPath *)indexPath
{
    return [self.messagesController.messages objectAtIndex:indexPath.row];
}

#pragma mark - JSMessagesViewDataSource

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self messageAt:indexPath].text;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self messageAt:indexPath].timestamp;
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self messageAt:indexPath].from;
}

#pragma mark - JSMessagesViewDelegate

- (void)didSendText:(NSString *)text
{
    [self finishSend];
    [self.messagesController sendText:text];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self messageAt:indexPath].incoming) ? JSBubbleMessageTypeIncoming : JSBubbleMessageTypeOutgoing;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *color;
    
    if (type == JSBubbleMessageTypeIncoming)
    {
        color = [UIColor js_bubbleLightGrayColor];
    }
    else if (type == JSBubbleMessageTypeOutgoing)
    {
        if (self.messagesController.participantID)
        {
            color = [UIColor js_bubbleGreenColor];
        }
        else
        {
            color = [UIColor js_bubbleBlueColor];
        }
    }
    
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:color];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAll;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyAll;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - MessagesControllerDelegate
- (void)controllerWillChangeContent:(MessagesController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(MessagesController *)controller didInsertMessage:(Message *)message atIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)controllerDidChangeContent:(MessagesController *)controller
{
    [self.tableView endUpdates];
    [self scrollToBottomAnimated:YES];
}

@end
