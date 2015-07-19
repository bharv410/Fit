//
//  SwitchCell.m
//  ooVooSample
//
//  Created by Clement Barry on 12/16/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import "SwitchCell.h"

@implementation SwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.accessoryView = self.switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.textLabel.numberOfLines = 0;
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
