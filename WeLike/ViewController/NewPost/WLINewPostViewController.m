//
//  WLINewPostViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLINewPostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "GlobalDefines.h"

@implementation WLINewPostViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"New post";
        [AFPhotoEditorController setAPIKey:kAviaryKey secret:kAviarySecret];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.imageViewPost.layer.cornerRadius = 3.0f;
    self.imageViewPost.layer.masksToBounds = YES;
    self.textViewPost.layer.cornerRadius = 3.0f;
    
    [self.textViewPost becomeFirstResponder];
    self.numberOfPhotos = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            self.numberOfPhotos = objects.count;
            
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Buttons methods

- (IBAction)buttonPostImageTouchUpInside:(id)sender {
    
    if ([self.textViewPost isFirstResponder]) {
        [self.textViewPost resignFirstResponder];
    }
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}

- (IBAction)buttonSendTouchUpInside:(id)sender {
    
    if (!self.textViewPost.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.imageViewPost.image) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please choose image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [hud show:YES];
        if ([self.textViewPost isFirstResponder]) {
            [self.textViewPost resignFirstResponder];
        }
        
        PFObject *newPhoto = [PFObject objectWithClassName:@"FitovatePhotos"];
        NSUInteger photoId = self.numberOfPhotos + 1;
        NSNumber *status = [NSNumber numberWithInteger:photoId];
        NSNumber *realId = [NSNumber numberWithInteger:sharedConnect.currentUser.userID];
        NSData *imageData = UIImagePNGRepresentation(self.imageViewPost.image);
        PFFile *userImage = [PFFile fileWithName:@"userImage.png" data:imageData];
        
        newPhoto[@"postID"] = status;
        newPhoto[@"postTitle"] = self.textViewPost.text;
        newPhoto[@"userID"] = realId;
        newPhoto[@"userImage"] = userImage;
        newPhoto[@"totalLikes"] = @0;
        newPhoto[@"totalComments"] = @0;
        newPhoto[@"isLiked"] = @NO;
        newPhoto [@"isCommented"] = @NO;
        
        
        [newPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [hud hide:YES];
            if (succeeded) {
                // The object has been saved.
                self.imageViewPost.image = nil;
                self.textViewPost.text = @"";

                
                if (self == self.navigationController.visibleViewController){
                    NSLog(@"self = visibile");
                    [self.navigationController.visibleViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
                }
                
                if (self == self.presentingViewController.presentingViewController){
                    NSLog(@"self = presenting");
                    [self.presentingViewController.presentingViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
                }

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                                message:@"Your post is now viewable by all of your followers."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            } else {
                // There was a problem, check error.description
                NSLog(error.description);
            }
            
        }];
        
        
//        [sharedConnect sendPostWithTitle:self.textViewPost.text postKeywords:nil postImage:self.imageViewPost.image onCompletion:^(WLIPost *post, ServerResponse serverResponseCode) {
//            [hud hide:YES];
//            self.imageViewPost.image = nil;
//            self.textViewPost.text = @"";
//            [self dismissViewControllerAnimated:YES completion:nil];
//            NSLog(@"BAMMM");
//        }];
    }
}


#pragma mark - UIImagePickerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    AFPhotoEditorController *photoEditorController = [[AFPhotoEditorController alloc] initWithImage:image];
    photoEditorController.delegate = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:photoEditorController animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (![self.textViewPost isFirstResponder]) {
            [self.textViewPost becomeFirstResponder];
        }
    }];
}


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Gallery"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}


#pragma - AFPhotoEditorController methods

- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image {
    
    self.imageViewPost.image = image;
    [self.buttonPostImage setTitle:@"" forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:^{
        if (![self.textViewPost isFirstResponder]) {
            [self.textViewPost becomeFirstResponder];
        }
    }];
}

- (void) photoEditorCanceled:(AFPhotoEditorController *)editor {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
