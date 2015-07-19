//
// TextFieldCell.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "TextFieldCell.h"

@implementation TextFieldCell

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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.highlightedTextColor = [UIColor clearColor];
    self.detailTextLabel.text = @"Using a very long string here to make sure that the UILabel is rendered at the maximum width so we can copy it for the UITextField.";
    
    _textField = [[UITextField alloc] initWithFrame:self.detailTextLabel.frame];
    _textField.textAlignment = self.detailTextLabel.textAlignment;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.backgroundColor = [UIColor clearColor];
    _textField.adjustsFontSizeToFitWidth = NO;
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.textColor = self.detailTextLabel.textColor;
    
    _textField.backgroundColor = [UIColor clearColor];
    _textField.transform = self.detailTextLabel.transform;
    _textField.clipsToBounds = self.detailTextLabel.clipsToBounds;
    _textField.clearsContextBeforeDrawing = self.detailTextLabel.clearsContextBeforeDrawing;
    _textField.contentMode = self.detailTextLabel.contentMode;
    _textField.autoresizingMask = self.detailTextLabel.autoresizingMask;
    _textField.autoresizesSubviews = YES;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self addSubview:_textField];
    
    self.detailTextLabel.textColor = [UIColor clearColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.size.width = [@"Conference ID" sizeWithFont:self.textLabel.font].width;
    self.textLabel.frame = textLabelFrame;
    
    CGRect detailTextLabelFrame = self.detailTextLabel.frame;
    detailTextLabelFrame.origin.x = CGRectGetMaxX(self.textLabel.frame) + 5.0f;
    detailTextLabelFrame.size.width = CGRectGetWidth(self.contentView.bounds) - detailTextLabelFrame.origin.x - 10.0f;
    self.detailTextLabel.frame = detailTextLabelFrame;
    

    CGFloat offsetX = 10.0f;
    CGFloat offsetY = 1.0f;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (self.modalPresentationStyle == UIModalPresentationFormSheet)
        {
            offsetX = 31.0;
        }
        else
        {
            offsetX = 45.0;
        }
    }

    CGRect textFieldFrame = self.detailTextLabel.frame;
    textFieldFrame.origin.x += offsetX;
    textFieldFrame.origin.y += offsetY;
    self.textField.frame = textFieldFrame;
    
    self.textField.font = self.detailTextLabel.font;
}

@end
