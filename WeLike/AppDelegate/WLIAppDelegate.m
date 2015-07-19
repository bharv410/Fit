//
//  WLIAppDelegate.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIAppDelegate.h"
#import "WLIPopularViewController.h"
#import "WLIProfileViewController.h"
#import "WLITimelineViewController.h"
#import "WLIConnect.h"
#import "WLINewPostViewController.h"
#import "WLINearbyViewController.h"
#import <Parse/Parse.h>
#import "ConferenceViewController.h"
#import <Fabric/Fabric.h>
#import "FitovateData.h"
#import <Crashlytics/Crashlytics.h>
#import "MainViewController.h"

NSString *const BFTaskMultipleExceptionsException = @"BFMultipleExceptionsException";
NSString *const OOVOOToken = @"MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoE%2FTxwzvba3Wy%2FupvESaKZhg1ngT4E8V7bqvT1RpL5F0UIW8FKbWarcsUJ51Nx%2BGwlHpeETeLbU4B8AYBUSRsopL5aGEZx7OrKL%2B%2B60kOeKuNLZuf%2FTVdRXKNLa1LuXU%3D";

@implementation WLIAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self initSDKs];
    
    // Override point for customization after application launch.
   WLIRegisterViewController *vc= [[WLIRegisterViewController alloc] init];
    self.window.rootViewController = vc;

    
    CLAuthorizationStatus locationAuthorizationStatus = [CLLocationManager authorizationStatus];
    if (locationAuthorizationStatus != kCLAuthorizationStatusDenied) {
        self.locationManager = [[CLLocationManager alloc] init];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
            [self.locationManager performSelector:@selector(requestWhenInUseAuthorization) withObject:nil];
        }
    }
    
    [self createViewHierarchy];
    [self setNavBarAppearance];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    [self setStatusBarAppearance];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [Fabric with:@[CrashlyticsKit]];
    WLIConnect *myConnect = [WLIConnect sharedConnect];
    [myConnect setLayerClientNow];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
//    // Extract the notification data
//    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
//    NSString *sender = [notificationPayload objectForKey:@"sender"];
//    NSString *conference = [notificationPayload objectForKey:@"conference"];
//    if([sender length]>2){
//        ConferenceViewController *cvc = [[ConferenceViewController alloc]init];
//        cvc.conferenceToJoin = conference;
//        cvc.notificationSender = sender;
//        [self.window.rootViewController presentViewController:cvc animated:YES completion:^{
//            NSLog(@"presented oovvoo conference");
//        }];
//    }else{
//        NSLog(@"no conference");
//    }
//    
//    NSString *mes = [NSString stringWithFormat:@"sender = %@, conf = %@", sender, conference];
//
    if (launchOptions != nil) {
        double delayInSeconds = 2.5; // number of seconds to wait
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSArray *subscribedChannels = [PFInstallation currentInstallation].channels;
            [self openConferenceFor:[subscribedChannels firstObject]];
        });
    }else{
        NSLog(@"opened app not from push");
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    if(application.applicationState == UIApplicationStateInactive && [WLIConnect sharedConnect].currentUser.userUsername!=nil) {
        [self openConferenceFor:[WLIConnect sharedConnect].currentUser.userUsername];
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else if ([WLIConnect sharedConnect].currentUser.userUsername!=nil){
        [self openConferenceFor:[WLIConnect sharedConnect].currentUser.userUsername];
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void) openConferenceFor :(NSString *)username{
    FitovateData *fd =[FitovateData sharedFitovateData];
    fd.confernceId = username;
    fd.participantId = username;
    UIStoryboard *mainstoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    MainViewController *mainViewController = [mainstoryBoard instantiateViewControllerWithIdentifier:@"MainNav"];
    [self.window.rootViewController presentViewController:mainViewController animated:YES completion:^{
        NSLog(@"presented oovvoo conference");
    }];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - UITabBarControllerDelegate methods

- (BOOL)tabBarController:(UITabBarController *)tabBarController  shouldSelectViewController:(UIViewController *)viewController {
    
    UINavigationController *navigationViewController = (UINavigationController *)viewController;
    if ([navigationViewController.topViewController isKindOfClass:[WLIWelcomeViewController class]]) {
        WLIWelcomeViewController *newPostViewController = [[WLINewPostViewController alloc] initWithNibName:@"WLINewPostViewController" bundle:nil];
        UINavigationController *newPostNavigationController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
        newPostNavigationController.navigationBar.translucent = NO;
        [tabBarController presentViewController:newPostNavigationController animated:YES completion:nil];
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - Other methods

- (void)setNavBarAppearance {
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:92.0f/255.0f green:173.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Pacifico-Regular" size:24
       ],
      NSFontAttributeName, nil]];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-back64.png"] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    } else {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-back44.png"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void) setStatusBarAppearance{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    navigationBarAppearance.backgroundColor = [UIColor clearColor];
    [navigationBarAppearance setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    navigationBarAppearance.shadowImage = [[UIImage alloc] init];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],UITextAttributeTextColor,
      [UIColor clearColor], UITextAttributeTextShadowColor,
      [UIFont fontWithName:@"Pacifico-Regular" size:24],
      NSFontAttributeName, nil]];
}
- (void)initSDKs {
    //benmark parse
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"M7f82n8HbyJZs9tmXpi4LXg0kRnIc1GaxYbFfzxr"
                  clientKey:@"cXd06hH0Ox8DNUoyZxFQ5RvWipg0UagSEvYuzBPW"];
    
    
    ooVooInitResult result = [[ooVooController sharedController] initSdk:@"12349983352060"
                                                        applicationToken:OOVOOToken baseUrl:[[NSUserDefaults standardUserDefaults] stringForKey:@"production"]];
    if (result != ooVooInitResultOk)
    {
        NSLog(@"ooVoo SDK initialization failed with result %d", result);
        
        NSString *reason;
        if (result == ooVooInitResultAppIdNotValid) {
            reason = @"AppID invalid, might be empty.\n\nGet your App ID and App Token at http://developer.oovoo.com.\nGo to Settings->ooVooSample screen and set the values, or set @DEFAULT_APP_ID and @DEFAULT_APP_TOKEN constants in code.";
        } else if(result == ooVooInitResultInvalidToken) {
            reason = @"Token invalid, might be empty.\n\nGet your App ID and App Token at http://developer.oovoo.com.\nGo to Settings->ooVooSample screen and set the values, or set @DEFAULT_APP_ID and @DEFAULT_APP_TOKEN constants in code.";
        } else {
            reason = [[ooVooController sharedController] errorMessageForOoVooInitResult:result];
        }
        
        double delayInSeconds = 0.75;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [[[UIAlertView alloc] initWithTitle:@"Init ooVoo Sdk"
                                        message:[NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), reason]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
        });
    } else {
        NSLog(@"ooVoo seccuess");
        WLIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.isSdkInited = YES;
    }
}

- (void)createViewHierarchy {
    
    WLITimelineViewController *timelineViewController = [[WLITimelineViewController alloc] initWithNibName:@"WLITimelineViewController" bundle:nil];
    UINavigationController *timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:timelineViewController];
    timelineNavigationController.navigationBar.translucent = NO;
    
    WLIPopularViewController *popularViewController = [[WLIPopularViewController alloc] initWithNibName:@"WLIPopularViewController" bundle:nil];
    UINavigationController *popularNavigationController = [[UINavigationController alloc] initWithRootViewController:popularViewController];
    popularNavigationController.navigationBar.translucent = NO;
    
    WLINewPostViewController *newPostViewController = [[WLINewPostViewController alloc] initWithNibName:@"WLINewPostViewController" bundle:nil];
    UINavigationController *newPostNavigationController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
    newPostNavigationController.navigationBar.translucent = NO;
    
    WLINearbyViewController *nearbyViewController = [[WLINearbyViewController alloc] initWithNibName:@"WLINearbyViewController" bundle:nil];
    UINavigationController *nearbyNavigationController = [[UINavigationController alloc] initWithRootViewController:nearbyViewController];
    nearbyNavigationController.navigationBar.translucent = NO;
    
    WLIProfileViewController *profileViewController = [[WLIProfileViewController alloc] initWithNibName:@"WLIProfileViewController" bundle:nil];
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    profileNavigationController.navigationBar.translucent = NO;
    
    self.tabBarController = [[WLITabBarController alloc] init];
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[timelineNavigationController, popularNavigationController,newPostNavigationController, nearbyNavigationController, profileNavigationController];
    
    
    //get white image
    UIImage *source=[UIImage imageNamed:@"tabbar-newpost"];
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *color=[UIColor whiteColor];
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UITabBarItem *timelineTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Timeline" image:[[UIImage imageNamed:@"tabbartimeline"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbartimeline"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    timelineViewController.tabBarItem = timelineTabBarItem;
    UITabBarItem *popularTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Popular" image:[[UIImage imageNamed:@"tabbarpopular"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbarpopular"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    popularViewController.tabBarItem = popularTabBarItem;
    UITabBarItem *newPostTabBarItem = [[UITabBarItem alloc] initWithTitle:@"New post" image:[[UIImage imageNamed:@"tabbarnewpost"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbarnewpost"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    newPostViewController.tabBarItem = newPostTabBarItem;
    UITabBarItem *nearbyTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Trainers" image:[[UIImage imageNamed:@"tabbarnearby"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbarnearby"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    nearbyViewController.tabBarItem = nearbyTabBarItem;
    
    UITabBarItem *profileTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Profile" image:[[UIImage imageNamed:@"tabbarprofile"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbarprofile"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    profileViewController.tabBarItem = profileTabBarItem;
    
    self.window.rootViewController = self.tabBarController;
}

@end