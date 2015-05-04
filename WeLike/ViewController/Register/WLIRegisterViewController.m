//
//  WLIRegisterViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Modified by Navneeth Ramprasad on 03/06/2015
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIRegisterViewController.h"
#import "WLIChooseVideoViewController.h"
#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"
#import <Parse/Parse.h>
#import "FitovateData.h"

@interface WLIRegisterViewController ()

@end

@implementation WLIRegisterViewController

@synthesize chooseSpeciality = _chooseSpeciality;

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Register";

    [self.scrollViewRegister addSubview:self.viewContentRegister];
    [self adjustViewFrames];
    chooseSpeciality.layer.borderWidth = 1;
    chooseSpeciality.layer.borderColor = [[UIColor blackColor] CGColor];
    chooseSpeciality.layer.cornerRadius = 5;

    
    //Initializing picker data
    //pickerData = @[@"Personal Trainer", @"Group Fitness Trainer", @"Sport Specific Trainer", @"Yoga Intsructor", @"Pilates Instructor", @"Health Coach"];
    
    //Connect data
    
    //self.picker.dataSource = self;
    //self.picker.delegate = self;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            self.numberOfUsers = [NSNumber numberWithInt:objects.count];
        } else {
            self.numberOfUsers = [NSNumber numberWithInt:0];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


- (void)viewDidUnload {
    //    [btnSelect release];
    chooseSpeciality = nil;
    //[self chooseSpeciality:nil];
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// The number of columns of data
//- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
//{
    //return 1;
//}

// The number of rows of data
/*- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerData.count;
}*/

// The data to return for the row and component (column) that's being passed in
/*- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return pickerData[row];
}*/


#pragma mark - Button methods

- (IBAction)buttonSelectAvatarTouchUpInside:(UIButton *)sender {
    
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}

- (IBAction)buttonRegisterTouchUpInside:(id)sender {
    
    if (!self.textFieldEmail.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Email is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (self.textFieldPassword.text.length < 4 || self.textFieldRepassword.text.length < 4) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Password is required. Your password should be at least 4 characters long." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldUsername.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Username is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (![self.textFieldPassword.text isEqualToString:self.textFieldRepassword.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Password and repassword doesn't match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldFullName.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Full Name is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.imageViewAvatar.image) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Avatar image is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        
        if (self.segmentedControlUserType.selectedSegmentIndex == 1) {
            if (!self.textFieldPhone.text.length) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Phone is required for companies." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else if (!self.textFieldWeb.text.length || !self.textFieldRepassword.text.length) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Website is required for companies" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                CLLocationCoordinate2D coordinate;
                NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:self.mapViewLocation.annotations.count];
                if (self.mapViewLocation.annotations.count) {
                    [annotations addObjectsFromArray:self.mapViewLocation.annotations];
                    for (int i = 0; i < annotations.count; i++) {
                        id <MKAnnotation> annotation = annotations[i];
                        if ([annotation isKindOfClass:[MKUserLocation class]]) {
                            [annotations removeObjectAtIndex:i];
                            break;
                        }
                    }
                    if (annotations.count) {
                        coordinate = [annotations[0] coordinate];
                        
                        [self.view endEditing:YES];
                        [hud show:YES];
                        
                        FitovateData *myData = [FitovateData sharedFitovateData];
                        myData.myUsername = self.textFieldUsername.text;
                        
                        
                        PFObject *newUser = [PFObject objectWithClassName:@"Users"];
                        newUser[@"userID"] = self.numberOfUsers;
                        newUser[@"userTypeID"] = self.numberOfUsers;
                        newUser[@"password"] = self.textFieldPassword.text;
                        newUser[@"email"] = self.textFieldEmail.text;
                        newUser[@"fullname"] = self.textFieldFullName.text;
                        newUser[@"username"] = self.textFieldUsername.text;
                        newUser[@"usertype"] = @"trainer";
                        newUser[@"userinfo"] = @"trainer";
                        newUser[@"followersCount"] = [NSNumber numberWithInt:0];
                        newUser[@"followingCount"] = [NSNumber numberWithInt:0];
                        newUser[@"phone"] = self.textFieldPhone.text;
                        newUser[@"website"] = self.textFieldWeb.text;
                        
                        if(self.chooseSpeciality.titleLabel.text != nil)
                            newUser[@"specialty"] = self.chooseSpeciality.titleLabel.text;
                        
                        
                        PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
                        newUser[@"location"] = point;
                        
                        NSData *imageData = UIImagePNGRepresentation(self.imageViewAvatar.image);
                        PFFile *userAvatar = [PFFile fileWithName:@"userAvatar.png" data:imageData];
                        newUser[@"userAvatar"] = userAvatar;
                        
                        [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [hud hide:YES];
                            if (succeeded) {
                                NSLog(@"saved");
                                //benmark
                                WLIChooseVideoViewController *wcv = [[WLIChooseVideoViewController alloc]init];
                                wcv.usersName = self.textFieldUsername.text;
                                [self.navigationController pushViewController:wcv animated:YES];
                                //                                [self dismissViewControllerAnimated:YES completion:nil];
                                
                            } else {
                                // There was a problem, check error.description
                                NSLog(@"error");
                                [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            }
                        }];
                        
                        
                    } else {
                        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please drop pin on map to mark location of your company." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }
                }
            }
        } else {
            [self.view endEditing:YES];
            [hud show:YES];
            
            FitovateData *myData = [FitovateData sharedFitovateData];
            myData.myUsername = self.textFieldUsername.text;
            
            PFObject *newUser = [PFObject objectWithClassName:@"Users"];
            newUser[@"username"] = self.textFieldUsername.text;
            newUser[@"password"] = self.textFieldPassword.text;
            newUser[@"email"] = self.textFieldEmail.text;
            newUser[@"usertype"] = @"trainee";
            newUser[@"fullname"] = self.textFieldFullName.text;
            
            NSData *imageData = UIImagePNGRepresentation(self.imageViewAvatar.image);
            PFFile *userAvatar = [PFFile fileWithName:@"userAvatar.png" data:imageData];
            newUser[@"userAvatar"] = userAvatar;
            
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [hud hide:YES];
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
    }
}


- (IBAction)segmentedControlUserTypeValueChanged:(UISegmentedControl *)sender {
    
    [self adjustViewFrames];
}

- (IBAction)handleLongTapGesture:(UILongPressGestureRecognizer *)sender {
    
    CGPoint touchPoint = [sender locationInView:self.mapViewLocation];
    CLLocationCoordinate2D coordinate = [self.mapViewLocation convertPoint:touchPoint toCoordinateFromView:self.mapViewLocation];
    
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        if (self.mapViewLocation.annotations.count) {
            NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.mapViewLocation.annotations];
            for (int i = 0; i < annotations.count; i++) {
                id <MKAnnotation> annotation = annotations[i];
                if ([annotation isKindOfClass:[MKUserLocation class]]) {
                    [annotations removeObjectAtIndex:i];
                    break;
                }
            }
            [self.mapViewLocation removeAnnotations:annotations];
        }
        WLIUser *companyUser = [[WLIUser alloc] init];
        companyUser.coordinate = coordinate;
        if (companyUser.userFullName.length) {
            companyUser.title = self.textFieldFullName.text;
        } else if (companyUser.userUsername.length) {
            companyUser.title = self.textFieldUsername.text;
        } else {
            companyUser.title = @"Please add Full Name";
        }
        companyUser.subtitle = [NSString stringWithFormat:@"%.6f, %.6f", coordinate.latitude, coordinate.longitude];
        [self.mapViewLocation addAnnotation:companyUser];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count) {
                CLPlacemark *placemark = placemarks[0];
                
                NSMutableString *address = [NSMutableString string];
                if (placemark.thoroughfare.length) {
                    [address appendString:placemark.thoroughfare];
                }
                if (placemark.subThoroughfare.length) {
                    [address appendFormat:@" %@", placemark.subThoroughfare];
                }
                if (address.length) {
                    [address appendFormat:@", "];
                }
                if (placemark.locality.length) {
                    [address appendString:placemark.locality];
                }
                if (address.length) {
                    [address appendFormat:@", "];
                }
                if (placemark.administrativeArea.length) {
                    [address appendString:placemark.administrativeArea];
                }
                if (address.length) {
                    [address appendFormat:@", "];
                }
                if (placemark.country.length) {
                    [address appendString:placemark.country];
                }
                
                if (address.length) {
                    self.textFieldAddress.text = address;
                } else {
                    self.textFieldAddress.text = [NSString stringWithFormat:@"%.6f, %.6f", coordinate.latitude, coordinate.longitude];
                }
                
            } else {
                self.textFieldAddress.text = [NSString stringWithFormat:@"%.6f, %.6f", coordinate.latitude, coordinate.longitude];
            }
        }];
    }
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.imageViewAvatar.image = info[UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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


#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (!locatedUser) {
        MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.1, 0.1));
        [self.mapViewLocation setRegion:region animated:YES];
        locatedUser = YES;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    NSString *annotationIdentifier = @"CompanyPin";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        annotationView.image = [UIImage imageNamed:@"map-pin.png"];
        annotationView.canShowCallout = NO;
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    //view.selected = NO;
    //id < MKAnnotation > annotation = view.annotation;
}


#pragma mark - Other methods

- (void)adjustViewFrames {
    
    if (self.segmentedControlUserType.selectedSegmentIndex == 1) {
        self.viewCompany.hidden = NO;
        self.buttonRegister.frame = CGRectMake(self.buttonRegister.frame.origin.x, CGRectGetMaxY(self.viewCompany.frame) +20.0f, self.buttonRegister.frame.size.width, self.buttonRegister.frame.size.height);
        self.viewContentRegister.frame = CGRectMake(self.viewContentRegister.frame.origin.x, self.viewContentRegister.frame.origin.y, self.viewContentRegister.frame.size.width, CGRectGetMaxY(self.buttonRegister.frame) +20.0f);
        PNTToolbar *newToolbar = [PNTToolbar defaultToolbar];
        newToolbar.mainScrollView = self.scrollViewRegister;
        newToolbar.textFields = @[self.textFieldEmail, self.textFieldPassword, self.textFieldRepassword, self.textFieldUsername, self.textFieldFullName, self.textFieldPhone, self.textFieldWeb];
    } else  {
        self.viewCompany.hidden = YES;
        self.buttonRegister.frame = CGRectMake(self.buttonRegister.frame.origin.x, CGRectGetMaxY(self.textFieldFullName.frame) +20.0f, self.buttonRegister.frame.size.width, self.buttonRegister.frame.size.height);
        self.viewContentRegister.frame = CGRectMake(self.viewContentRegister.frame.origin.x, self.viewContentRegister.frame.origin.y, self.viewContentRegister.frame.size.width, CGRectGetMaxY(self.buttonRegister.frame) +20.0f);
        PNTToolbar *newToolbar = [PNTToolbar defaultToolbar];
        newToolbar.mainScrollView = self.scrollViewRegister;
        newToolbar.textFields = @[self.textFieldEmail, self.textFieldPassword, self.textFieldRepassword, self.textFieldUsername, self.textFieldFullName];
    }
    self.scrollViewRegister.contentSize = self.viewContentRegister.frame.size;
}


- (void)dealloc {
    
    self.mapViewLocation.delegate = nil;
    self.mapViewLocation.userTrackingMode = MKUserTrackingModeNone;
}

- (IBAction)selectClients:(id)sender {
    
    NSArray *arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@"Personal Trainer", @"Group Fitness Instructor", @"Sport Specific Trainer", @"Yoga Instructor", @"Pilates Instructor", @"Health Coach",nil];
    NSArray * arrImage = [[NSArray alloc] init];
    
    /*arrImage = [NSArray arrayWithObjects:[UIImage imageNamed:@"apple.png"], [UIImage *imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], nil];*/
    
    
    if(dropDown == nil) {
        CGFloat f = 250;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down"];
        dropDown.delegate = self;
    }
    else {
        
        [dropDown hideDropDown:sender];
        [self rel];
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    [self rel];
}

-(void)rel{
    //[dropDown release];
    dropDown = nil;
}


@end
