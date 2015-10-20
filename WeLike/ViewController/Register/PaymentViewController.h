//
//  PaymentViewController.h
//  Fitovate
//
//  Created by Benjamin Harvey on 10/20/15.
//
//

#import <UIKit/UIKit.h>

@class PaymentViewController;

@protocol PaymentViewControllerDelegate<NSObject>

- (void)paymentViewController:(PaymentViewController *)controller didFinish:(NSError *)error;

@end

@interface PaymentViewController : UIViewController

@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic, weak) id<PaymentViewControllerDelegate> delegate;

@end