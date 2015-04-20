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

@implementation WLIChooseVideoViewController

@synthesize usersName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [picker setMediaTypes: [NSArray arrayWithObject:kUTTypeMovie]];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    
    PFObject *userVideo = [PFObject objectWithClassName:@"Videos"];
    userVideo[@"username"] = self.usersName;
    
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSString *path = [videoURL path];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    PFFile *userVideoFile = [PFFile fileWithName:@"userVideo.mp4" data:data];
    userVideo[@"video"] = userVideoFile;
    
    [userVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"saved");
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            // There was a problem, check error.description
            NSLog(@"error");
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
    
    
}





- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
