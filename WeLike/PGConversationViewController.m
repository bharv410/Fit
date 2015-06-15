//
//  PGConversationViewController.m
//  Fitovate
//
//  Created by Benjamin Harvey on 6/14/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "PGConversationViewController.h"
#import "PGUser.h"
#import "WLIConnect.h"

@interface PGConversationViewController ()

@end

@implementation PGConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark - Conversation Data Source

- (id <ATLParticipant>)conversationViewController:(ATLConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier {
    // TODO Return the user corresponding to this participant identifier
    WLIConnect *sharedConnect = [WLIConnect sharedConnect];
    if(![participantIdentifier containsString:sharedConnect.currentUser.userUsername]){
        self.title = participantIdentifier;
    }
    return [PGUser userWithParticipantIdentifier:participantIdentifier];
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date {
    return [[NSAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus {
    NSMutableDictionary *mutableRecipientStatus = [recipientStatus mutableCopy];
    if ([mutableRecipientStatus valueForKey:self.layerClient.authenticatedUserID]) {
        [mutableRecipientStatus removeObjectForKey:self.layerClient.authenticatedUserID];
    }
    
    NSString *statusString = [NSString new];
    if (mutableRecipientStatus.count > 1) {
        __block NSUInteger readCount = 0;
        __block BOOL delivered;
        __block BOOL sent;
        [mutableRecipientStatus enumerateKeysAndObjectsUsingBlock:^(NSString *userID, NSNumber *statusNumber, BOOL *stop) {
            LYRRecipientStatus status = (LYRRecipientStatus) statusNumber.integerValue;
            switch (status) {
                case LYRRecipientStatusInvalid:
                    break;
                case LYRRecipientStatusSent:
                    sent = YES;
                    break;
                case LYRRecipientStatusDelivered:
                    delivered = YES;
                    break;
                case LYRRecipientStatusRead:
                    NSLog(@"Read");
                    readCount += 1;
                    break;
            }
        }];
        if (readCount) {
            NSString *participantString = readCount > 1 ? @"Participants" : @"Participant";
            statusString = [NSString stringWithFormat:@"Read by %lu %@", (unsigned long) readCount, participantString];
        } else if (delivered) {
            statusString = @"Delivered";
        } else if (sent) {
            statusString = @"Sent";
        }
    } else {
        __block NSString *blockStatusString = [NSString new];
        [mutableRecipientStatus enumerateKeysAndObjectsUsingBlock:^(NSString *userID, NSNumber *statusNumber, BOOL *stop) {
            if ([userID isEqualToString:self.layerClient.authenticatedUserID]) return;
            LYRRecipientStatus status = (LYRRecipientStatus) statusNumber.integerValue;
            switch (status) {
                case LYRRecipientStatusInvalid:
                    blockStatusString = @"Not Sent";
                case LYRRecipientStatusSent:
                    blockStatusString = @"Sent";
                case LYRRecipientStatusDelivered:
                    blockStatusString = @"Delivered";
                    break;
                case LYRRecipientStatusRead:
                    blockStatusString = @"Read";
                    break;
            }
        }];
        statusString = blockStatusString;
    }
    return [[NSAttributedString alloc] initWithString:statusString attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:11]}];
    
}

@end
