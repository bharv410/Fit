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
    
    self.cityStateLabel.delegate = self;
    self.dateLabel.delegate = self;
    self.textFieldAddress.delegate = self;
    self.textFieldBio.delegate = self;
    self.textFieldEmail.delegate = self;
    self.textFieldFullName.delegate = self;
    self.textFieldPassword.delegate = self;
    self.textFieldRepassword.delegate = self;
    self.textFieldUsername.delegate = self;
    self.textFieldWeb.delegate = self;

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
            if (!self.textFieldWeb.text.length || !self.textFieldRepassword.text.length) {
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
                        newUser[@"password"] = self.textFieldPassword.text;
                        newUser[@"email"] = self.textFieldEmail.text;
                        newUser[@"fullname"] = self.textFieldFullName.text;
                        newUser[@"username"] = self.textFieldUsername.text;
                        newUser[@"usertype"] = @"trainer";
                        newUser[@"youtubeString"] = @"";
                        newUser[@"userinfo"] = self.textFieldBio.text;
                        newUser[@"followersCount"] = [NSNumber numberWithInt:0];
                        newUser[@"followingCount"] = [NSNumber numberWithInt:0];
                        newUser[@"website"] = self.textFieldWeb.text;
                        newUser[@"gender"] = [self.malefemaleControl titleForSegmentAtIndex:self.malefemaleControl.selectedSegmentIndex];
                        
                        if(self.dateLabel.text != nil)
                            newUser[@"citystate"] = self.cityStateLabel.text;
                        
                        if(self.dateLabel.text != nil)
                            newUser[@"birthdate"] = self.dateLabel.text;
                        
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
                                
                                NSLog(@"%@", [myData parseUserToDictionary:newUser]);
                                
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
            newUser[@"userID"] = self.numberOfUsers;
            newUser[@"username"] = self.textFieldUsername.text;
            newUser[@"password"] = self.textFieldPassword.text;
            newUser[@"email"] = self.textFieldEmail.text;
            newUser[@"usertype"] = @"trainee";
            newUser[@"userinfo"] = self.textFieldBio.text;
            newUser[@"fullname"] = self.textFieldFullName.text;
            newUser[@"followersCount"] = [NSNumber numberWithInt:0];
            newUser[@"followingCount"] = [NSNumber numberWithInt:0];
            
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
        newToolbar.textFields = @[self.textFieldEmail, self.textFieldPassword, self.textFieldRepassword, self.textFieldUsername, self.textFieldFullName, self.textFieldBio, self.dateLabel ,self.cityStateLabel, self.textFieldWeb];
        
        NSLog(@"seg = 1");
        
        
        
    } else  {
        self.viewCompany.hidden = YES;
        self.buttonRegister.frame = CGRectMake(self.buttonRegister.frame.origin.x, CGRectGetMaxY(self.malefemaleControl.frame) +20.0f, self.buttonRegister.frame.size.width, self.buttonRegister.frame.size.height);
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

- (IBAction)chooseSpecialtyTouchUpInside:(id)sender {
    [self.view endEditing:YES];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //hides keyboard when another part of layout was touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(void)rel{
    //[dropDown release];
    dropDown = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.cityStateLabel) {
        [theTextField resignFirstResponder];
    } else if (theTextField == self.dateLabel) {
        [theTextField resignFirstResponder];
    }else{
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(![textField isEqual:self.dateLabel]){
        return (![textField isEqual:self.dateLabel]);
    }else{
        [self callDP];
        return (![textField isEqual:self.dateLabel]);
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.dateLabel) {
        //[self callDP];
    }
}

- (void)changeDate:(UIDatePicker *)sender {
    NSLog(@"New Date: %@", sender.date);
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yy"];
    NSString *date = [dateFormat stringFromDate:sender.date];
    NSLog(@"date is >>> , %@",date);
    
    self.dateLabel.text = date;
    
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

- (void)callDP{
    if ([self.view viewWithTag:9]) {
        return;
    }
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    [self.view endEditing:YES];
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 320, 216);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    darkView.alpha = 0;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)] ;
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    datePicker.tag = 10;
    datePicker.backgroundColor = [UIColor whiteColor];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)] ;
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)] ;
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    datePicker.frame = datePickerTargetFrame;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
}

@end
