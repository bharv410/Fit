//
//  CustomButtons.h
//  Fitovate
//
//  Created by Benjamin Harvey on 8/20/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//
#pragma mark - Constants

#define floatVal(val) ((float)val/(float)255)
#define lightBlueColor [UIColor colorWithRed:floatVal(1) green:floatVal(126) blue:floatVal(204) alpha:1.0f]


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Custom button

@interface CustomButton : UIButton
@end

@implementation CustomButton

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    [UIView transitionWithView:self
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.tintColor = (enabled) ? lightBlueColor : [UIColor grayColor];
                    }
                    completion:nil];
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Share button

@interface ShareButton : CustomButton
@end

@implementation ShareButton

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self.tintColor setFill];
    
    //// Path drawing
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(7.846, 10.138)];
    [path addCurveToPoint:CGPointMake(9.201, 11.493) controlPoint1:CGPointMake(8.594, 10.138) controlPoint2:CGPointMake(9.201, 10.745)];
    [path addCurveToPoint:CGPointMake(7.846, 12.848) controlPoint1:CGPointMake(9.201, 12.241) controlPoint2:CGPointMake(8.594, 12.848)];
    [path addLineToPoint:CGPointMake(4.613, 12.848)];
    [path addCurveToPoint:CGPointMake(3.71, 13.751) controlPoint1:CGPointMake(4.114, 12.848) controlPoint2:CGPointMake(3.71, 13.252)];
    [path addLineToPoint:CGPointMake(3.71, 24.387)];
    [path addCurveToPoint:CGPointMake(4.613, 25.29) controlPoint1:CGPointMake(3.71, 24.886) controlPoint2:CGPointMake(4.114, 25.29)];
    [path addLineToPoint:CGPointMake(18.26, 25.29)];
    [path addCurveToPoint:CGPointMake(19.163, 24.387) controlPoint1:CGPointMake(18.759, 25.29) controlPoint2:CGPointMake(19.163, 24.886)];
    [path addLineToPoint:CGPointMake(19.163, 13.751)];
    [path addCurveToPoint:CGPointMake(18.26, 12.848) controlPoint1:CGPointMake(19.163, 13.252) controlPoint2:CGPointMake(18.759, 12.848)];
    [path addLineToPoint:CGPointMake(15.337, 12.848)];
    [path addCurveToPoint:CGPointMake(13.983, 11.493) controlPoint1:CGPointMake(14.589, 12.848) controlPoint2:CGPointMake(13.983, 12.241)];
    [path addCurveToPoint:CGPointMake(15.337, 10.138) controlPoint1:CGPointMake(13.983, 10.745) controlPoint2:CGPointMake(14.589, 10.138)];
    [path addLineToPoint:CGPointMake(18.26, 10.138)];
    [path addCurveToPoint:CGPointMake(21.873, 13.751) controlPoint1:CGPointMake(20.256, 10.138) controlPoint2:CGPointMake(21.873, 11.756)];
    [path addLineToPoint:CGPointMake(21.873, 24.387)];
    [path addCurveToPoint:CGPointMake(18.26, 28) controlPoint1:CGPointMake(21.873, 26.382) controlPoint2:CGPointMake(20.256, 28)];
    [path addLineToPoint:CGPointMake(4.613, 28)];
    [path addCurveToPoint:CGPointMake(1, 24.387) controlPoint1:CGPointMake(2.618, 28) controlPoint2:CGPointMake(1, 26.382)];
    [path addLineToPoint:CGPointMake(1, 13.751)];
    [path addCurveToPoint:CGPointMake(4.613, 10.138) controlPoint1:CGPointMake(1, 11.756) controlPoint2:CGPointMake(2.618, 10.138)];
    [path closePath];
    
    //Path color fill
    [path fill];
    
    //// Path2 drawing
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(11.613, 6.186)];
    [path2 addCurveToPoint:CGPointMake(12.968, 7.541) controlPoint1:CGPointMake(12.361, 6.186) controlPoint2:CGPointMake(12.968, 6.793)];
    [path2 addLineToPoint:CGPointMake(12.968, 19.989)];
    [path2 addCurveToPoint:CGPointMake(11.613, 21.344) controlPoint1:CGPointMake(12.968, 20.737) controlPoint2:CGPointMake(12.361, 21.344)];
    [path2 addCurveToPoint:CGPointMake(10.258, 19.989) controlPoint1:CGPointMake(10.865, 21.344) controlPoint2:CGPointMake(10.258, 20.737)];
    [path2 addLineToPoint:CGPointMake(10.258, 7.541)];
    [path2 addCurveToPoint:CGPointMake(11.613, 6.186) controlPoint1:CGPointMake(10.258, 6.793) controlPoint2:CGPointMake(10.865, 6.186)];
    [path2 closePath];
    
    //Path2 color fill
    [path2 fill];
    
    //// Path3 drawing
    UIBezierPath *path3 = [UIBezierPath bezierPath];
    [path3 moveToPoint:CGPointMake(12.846, 1.397)];
    [path3 addLineToPoint:CGPointMake(17.399, 5.95)];
    [path3 addCurveToPoint:CGPointMake(17.399, 7.866) controlPoint1:CGPointMake(17.928, 6.479) controlPoint2:CGPointMake(17.928, 7.337)];
    [path3 addCurveToPoint:CGPointMake(15.483, 7.866) controlPoint1:CGPointMake(16.87, 8.395) controlPoint2:CGPointMake(16.012, 8.395)];
    [path3 addLineToPoint:CGPointMake(11.888, 4.271)];
    [path3 addLineToPoint:CGPointMake(8.293, 7.866)];
    [path3 addCurveToPoint:CGPointMake(6.377, 7.866) controlPoint1:CGPointMake(7.764, 8.395) controlPoint2:CGPointMake(6.906, 8.395)];
    [path3 addCurveToPoint:CGPointMake(6.377, 5.95) controlPoint1:CGPointMake(5.848, 7.337) controlPoint2:CGPointMake(5.848, 6.479)];
    [path3 addLineToPoint:CGPointMake(10.93, 1.396)];
    [path3 addCurveToPoint:CGPointMake(12.846, 1.397) controlPoint1:CGPointMake(11.459, .868) controlPoint2:CGPointMake(12.317, .868)];
    [path3 closePath];
    
    //Path3 color fill
    [path3 fill];
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Back Arrow button

@interface BackArrowButton : CustomButton
@end

@implementation BackArrowButton

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //// Path drawing
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(32.5, 11)];
    [path addLineToPoint:CGPointMake(8.5, 11)];
    [path addLineToPoint:CGPointMake(14.275, 5.225)];
    [path addCurveToPoint:CGPointMake(15, 3.5) controlPoint1:CGPointMake(14.768, 4.733) controlPoint2:CGPointMake(15, 4.145)];
    [path addCurveToPoint:CGPointMake(12.5, 1) controlPoint1:CGPointMake(15, 2.27) controlPoint2:CGPointMake(13.984, 1)];
    [path addCurveToPoint:CGPointMake(10.775, 1.725) controlPoint1:CGPointMake(11.836, 1) controlPoint2:CGPointMake(11.258, 1.241)];
    [path addLineToPoint:CGPointMake(.828, 11.672)];
    [path addCurveToPoint:CGPointMake(0, 13.5) controlPoint1:CGPointMake(.418, 12.082) controlPoint2:CGPointMake(0, 12.589)];
    [path addCurveToPoint:CGPointMake(.808, 15.309) controlPoint1:CGPointMake(0, 14.411) controlPoint2:CGPointMake(.349, 14.85)];
    [path addLineToPoint:CGPointMake(10.775, 25.275)];
    [path addCurveToPoint:CGPointMake(12.5, 26) controlPoint1:CGPointMake(11.258, 25.759) controlPoint2:CGPointMake(11.836, 26)];
    [path addCurveToPoint:CGPointMake(15, 23.5) controlPoint1:CGPointMake(13.985, 26) controlPoint2:CGPointMake(15, 24.73)];
    [path addCurveToPoint:CGPointMake(14.275, 21.775) controlPoint1:CGPointMake(15, 22.855) controlPoint2:CGPointMake(14.768, 22.267)];
    [path addLineToPoint:CGPointMake(8.5, 16)];
    [path addLineToPoint:CGPointMake(32.5, 16)];
    [path addCurveToPoint:CGPointMake(35, 13.5) controlPoint1:CGPointMake(33.88, 16) controlPoint2:CGPointMake(35, 14.88)];
    [path addCurveToPoint:CGPointMake(32.5, 11) controlPoint1:CGPointMake(35, 12.12) controlPoint2:CGPointMake(33.88, 11)];
    [path closePath];
    
    //Path color fill
    [self.tintColor setFill];
    [path fill];
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Forward Arrow button

@interface ForwardArrowButton : CustomButton
@end

@implementation ForwardArrowButton

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //// Path drawing
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(2.5, 11)];
    [path addLineToPoint:CGPointMake(26.5, 11)];
    [path addLineToPoint:CGPointMake(20.725, 5.225)];
    [path addCurveToPoint:CGPointMake(20, 3.5) controlPoint1:CGPointMake(20.232, 4.733) controlPoint2:CGPointMake(20, 4.145)];
    [path addCurveToPoint:CGPointMake(22.5, 1) controlPoint1:CGPointMake(20, 2.27) controlPoint2:CGPointMake(21.016, 1)];
    [path addCurveToPoint:CGPointMake(24.225, 1.725) controlPoint1:CGPointMake(23.164, 1) controlPoint2:CGPointMake(23.742, 1.241)];
    [path addLineToPoint:CGPointMake(34.172, 11.672)];
    [path addCurveToPoint:CGPointMake(35, 13.5) controlPoint1:CGPointMake(34.582, 12.082) controlPoint2:CGPointMake(35, 12.589)];
    [path addCurveToPoint:CGPointMake(34.192, 15.309) controlPoint1:CGPointMake(35, 14.411) controlPoint2:CGPointMake(34.651, 14.85)];
    [path addLineToPoint:CGPointMake(24.225, 25.275)];
    [path addCurveToPoint:CGPointMake(22.5, 26) controlPoint1:CGPointMake(23.742, 25.759) controlPoint2:CGPointMake(23.164, 26)];
    [path addCurveToPoint:CGPointMake(20, 23.5) controlPoint1:CGPointMake(21.015, 26) controlPoint2:CGPointMake(20, 24.73)];
    [path addCurveToPoint:CGPointMake(20.725, 21.775) controlPoint1:CGPointMake(20, 22.855) controlPoint2:CGPointMake(20.232, 22.267)];
    [path addLineToPoint:CGPointMake(26.5, 16)];
    [path addLineToPoint:CGPointMake(2.5, 16)];
    [path addCurveToPoint:CGPointMake(0, 13.5) controlPoint1:CGPointMake(1.12, 16) controlPoint2:CGPointMake(0, 14.88)];
    [path addCurveToPoint:CGPointMake(2.5, 11) controlPoint1:CGPointMake(0, 12.12) controlPoint2:CGPointMake(1.12, 11)];
    [path closePath];
    
    //Path color fill
    [self.tintColor setFill];
    [path fill];
}

@end