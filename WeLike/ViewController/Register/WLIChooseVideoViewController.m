//
//  WLIChooseVideoViewController.m
//  Fitovate
//
//  Created by Benjamin Harvey on 1/9/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "WLIChooseVideoViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <Parse/Parse.h>

@interface WLIChooseVideoViewController ()

@end

@implementation WLIChooseVideoViewController{
    UITextField *lastName;
}

@synthesize usersName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Your Intro Video!"
                                                    message:@"Upload a video on YouTube, copy the link, then paste the link for the video here. Trainers must have a video on their profile to complete registration."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.5];
//        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//        self.youtubeTextField.frame = CGRectMake(10, 200, 300, 40);
//        self.uploadButton.frame = CGRectMake(10, 260, self.uploadButton.frame.size.width, self.uploadButton.frame.size.height);
//        [UIView commitAnimations];
//    });
//    
    
     lastName = [[UITextField alloc] initWithFrame:CGRectMake(10, 100, 300, 30)];
    [self.view addSubview:lastName];
    
        lastName.placeholder = @"  Enter your Youtube Link here";   //for place holder
        lastName.textAlignment = UITextAlignmentLeft;          //for text Alignment
        lastName.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:14.0]; // text font
        lastName.adjustsFontSizeToFitWidth = YES;     //adjust the font size to fit width.
        lastName.textColor = [UIColor blackColor];             //text color
        lastName.keyboardType = UIKeyboardTypeAlphabet;        //keyboard type of ur choice
        lastName.returnKeyType = UIReturnKeyDone;              //returnKey type for keyboard
    
    lastName.layer.cornerRadius=8.0f;
    lastName.layer.masksToBounds=YES;
    lastName.layer.borderColor=[[self colorWithHexString:@"5cadff"]CGColor];
    lastName.layer.borderWidth= 1.0f;
    lastName.delegate = self;
    
    
        UIButton *butn = [[UIButton alloc]initWithFrame:CGRectMake(10, 135, 300, 40)];
    [butn addTarget:self
                 action:@selector(onUploadClicked)
       forControlEvents:UIControlEventTouchUpInside];
    [butn setTitle: @"Submit Video" forState: UIControlStateNormal];
    [butn setTitleColor:[self colorWithHexString:@"5cadff"] forState:UIControlStateNormal];
    [self.view addSubview: butn];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}


-(void)updateUserYoutubeLink:(NSString *) youtubeString{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query whereKey:@"username" equalTo:self.usersName];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * userStats, NSError *error) {
        if (!error) {
                [userStats setObject:youtubeString forKey:@"youtubeString"];
                NSLog(@"youtube id is %@", youtubeString);
            
            // Save
            [userStats saveInBackground];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (NSString *)extractYoutubeIdFromLink:(NSString *)link {
    
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    
    NSArray *array = [regExp matchesInString:link options:0 range:NSMakeRange(0,link.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [link substringWithRange:result.range];
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//        [picker dismissViewControllerAnimated:YES completion:NULL];
//    
//    PFObject *userVideo = [PFObject objectWithClassName:@"Videos"];
//    userVideo[@"username"] = self.usersName;
//    
//    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
//    NSString *path = [videoURL path];
//    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
//    
//    PFFile *userVideoFile = [PFFile fileWithName:@"userVideo.mp4" data:data];
//    userVideo[@"video"] = userVideoFile;
//    
//    [userVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"saved");
//            [self dismissViewControllerAnimated:YES completion:nil];
//        } else {
//            // There was a problem, check error.description
//            NSLog(@"error");
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        }
//    }];
//    
//    
//}
//
//
//
//
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [picker dismissViewControllerAnimated:YES completion:NULL];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)onUploadClicked {
    [self updateUserYoutubeLink:[self extractYoutubeIdFromLink:lastName.text]];
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
@end
