//
//  ConferenceToolbar.h
//  ooVooSample
//
//  Created by Clement Barry on 12/12/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConferenceToolbar : UIToolbar

@property (nonatomic, strong) UIBarButtonItem *messagesBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *filtersBarButtonItem;
@property (nonatomic, assign) BOOL filtersEnabled;

@end
