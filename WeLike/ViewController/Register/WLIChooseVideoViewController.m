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
                                                    message:@"Upload a video on YouTube and then paste the embed link for the video here."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.youtubeTextField.frame = CGRectMake(10, 200, 300, 40);
        self.uploadButton.frame = CGRectMake(10, 260, self.uploadButton.frame.size.width, self.uploadButton.frame.size.height);
        [UIView commitAnimations];
    });
    
    
     lastName = [[UITextField alloc] initWithFrame:CGRectMake(10, 100, 300, 30)];
    [self.view addSubview:lastName];
    
        lastName.placeholder = @"Enter your Youtube Link here";   //for place holder
        lastName.textAlignment = UITextAlignmentLeft;          //for text Alignment
        lastName.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:14.0]; // text font
        lastName.adjustsFontSizeToFitWidth = YES;     //adjust the font size to fit width.
        lastName.textColor = [UIColor blackColor];             //text color
        lastName.keyboardType = UIKeyboardTypeAlphabet;        //keyboard type of ur choice
        lastName.returnKeyType = UIReturnKeyDone;              //returnKey type for keyboard
    lastName.delegate = self;
    
        UIButton *butn = [[UIButton alloc]initWithFrame:CGRectMake(10, 150, self.uploadButton.frame.size.width, self.uploadButton.frame.size.height)];
    [self.view addSubview: butn];
                             
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self updateUserYoutubeLink:lastName.text];
    return [textField resignFirstResponder];
}


-(void)updateUserYoutubeLink:(NSString *) youtubeString{
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query whereKey:@"username" equalTo:self.usersName];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * userStats, NSError *error) {
        if (!error) {
            // Found UserStats
            [userStats setObject:youtubeString forKey:@"youtubeString"];
            
            // Save
            [userStats saveInBackground];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
            
            
            
            
            
            
        } else {
            // Did not find any UserStats for the current user
            NSLog(@"Error: %@", error);
        }
    }];
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

- (IBAction)onUploadClicked:(id)sender {
    NSLog(@" text = %@",self.youtubeTextField.text);
    [self updateUserYoutubeLink:self.youtubeTextField.text];
}
@end
