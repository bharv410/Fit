//
//  ConversationTableViewController.h
//  Fitovate
//
//  Created by Benjamin Harvey on 5/14/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>

@protocol senddataProtocol <NSObject>

-(void)sendDataToA:(LYRConversation *)conversation;
@end

@interface ConversationTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *conversationListTableView;
@property (strong, nonatomic) NSArray *conversationSenderList;
@property (strong, nonatomic) NSArray *conversationsList;
@property (strong, nonatomic) NSString *title;
@property (nonatomic) NSInteger chosenRow;

@property(nonatomic,assign)id delegate;


@end
