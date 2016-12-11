//
//  AppDelegate.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/9/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//
//Issue in gift message: When adding to cart, it crashes when proceedtocheckout is called and item prices/data are being calling from cart.
//
#import "AppDelegate.h"
#import "APSCollectionManager.h"
#import "Global.h"
#import "APSBeaconNotificationManager.h"
#import "APSShopifyBuyManager.h"
#import <IQKeyboardManager.h>
#import "Intercom/intercom.h"
#import "MobilePayManager.h"

#import "APSBagManager.h"
#import <BuddyBuildSDK/BuddyBuildSDK.h>

@import GoogleMaps;

@interface AppDelegate ()

@property (nonatomic) APSBeaconNotificationManager *beaconNotificationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [BuddyBuildSDK setup];
    
    // Override point for customization after application launch.
    
    IQKeyboardManager *sharedInstance = [IQKeyboardManager sharedManager];
    sharedInstance.shouldResignOnTouchOutside = YES;
    sharedInstance.keyboardDistanceFromTextField = 50;
    sharedInstance.enableAutoToolbar = NO;
    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions
                                                        appId:@"84ef03ef-e0a9-4a9a-abcc-f42d8629e940"
                                           handleNotification:nil];
    
    [self initializeManagers];
    [Intercom setApiKey:@"ios_sdk-4dba62adfe20f450c8781116c206d012a2c66a98" forAppId:@"le990tbw"];
    [Intercom registerUnidentifiedUser];
   if ([[MobilePayManager sharedInstance]isMobilePayInstalled:MobilePayCountry_Denmark]) {
        NSLog(@"Mobile  pay installed");
    }
    else
    {
        NSLog(@"Mobile pay not installed");

    }
    //APPDK0000000000
    [[MobilePayManager sharedInstance] setupWithMerchantId:@"APPDK5399574001" merchantUrlScheme:@"AppleSolutions" country:MobilePayCountry_Denmark];
    
    return YES;
}

- (void) initializeManagers{
    [GMSServices provideAPIKey:GOOGLEMAPS_API_KEY];
    [ESTConfig setupAppID:APS_ESTIMOTE_APPID andAppToken:APS_ESTIMOTE_APPTOKEN];
    
    [[APSShopifyBuyManager sharedInstance] initializeManager];
    [[APSShopifyBuyManager sharedInstance] requestCollectionWithCallback:nil];
    
    [self loadCookies];
    
    self.beaconNotificationManager = [APSBeaconNotificationManager new];
    [self.beaconNotificationManager enableNotificationsForBeaconID:
                            [[APSBeaconID alloc] initWithUUIDString:APS_ESTIMOTE_UUID major:APS_ESTIMOTE_MAJOR minor:APS_ESTIMOTE_MINOR]
                                                      enterMessage:@"Du er nu i nærheden af AppleSolutions Store - Åboulevard"
                                                       exitMessage:@"Tak fordi at du besøgte AppleSolutions"
    ];

}

- (void)loadCookies
{
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"cookies"]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        [cookieStorage setCookie: cookie];
    }
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"registered for push notifications");
    [Intercom setDeviceToken:deviceToken];
}
- (void) handleMobilePayPaymentWithUrl: (NSURL *) url{
    [[MobilePayManager sharedInstance]handleMobilePayPaymentWithUrl:url success:^(MobilePaySuccessfulPayment * _Nullable mobilePaySuccessfulPayment) {
        NSString *orderId = mobilePaySuccessfulPayment.orderId;
        NSString *transactionId = mobilePaySuccessfulPayment.transactionId;
        NSString *amountWithdrawnFromCard = [NSString stringWithFormat:@"%f",mobilePaySuccessfulPayment.amountWithdrawnFromCard];
        NSLog(@"MobilePay purchase succeeded: Your have now paid for order with id '%@' and MobilePay transaction id '%@' and the amount withdrawn from the card is: '%@'", orderId, transactionId,amountWithdrawnFromCard);
        NSString * orderString = NSLocalizedString(@"You have now paid for order with id", nil);
        NSString * transactionString = NSLocalizedString(@" Your MobilePay transaction id is", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MobilePay Succeeded",nil) message:[NSString stringWithFormat:@"%@ '%@'.\n %@ '%@'",orderString,orderId,transactionString, transactionId ] preferredStyle:UIAlertControllerStyleAlert];
       
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^ (UIAlertAction * action){
            UITabBarController * tbbar = (UITabBarController *)self.window.rootViewController;
            NSLog(@"VIEW at root %@", self.window.rootViewController);
            [[APSShopifyBuyManager sharedInstance] clearCart];
            [[APSBagManager sharedInstance] clearBag];
            
            UINavigationController * nav = (UINavigationController *)tbbar.selectedViewController;
            [nav popToRootViewControllerAnimated:NO];
            
            
        }];
        [alertController addAction:ok];
//[[APSBagManager sharedInstance] setPaymentStatusWithID:mobilePaySuccessfulPayment.orderId PaymentStatus:@"capture"];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
        //finding transaction in order, if exists try to play with it status to see if payment method can be changed. 
        
    } error:^(NSError * _Nonnull error) {
        NSDictionary *dict = error.userInfo;
        NSString *errorMessage = [dict valueForKey:NSLocalizedFailureReasonErrorKey];
        NSLog(@"MobilePay purchase failed:  Error code '%li' and message '%@'",(long)error.code,errorMessage);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error occurred" message:[NSString stringWithFormat:@"Error Code %li and messaged %@",(long)error.code,errorMessage]  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];

        //TODO: show an appropriate error message to the user. Check MobilePayManager.h for a complete description of the error codes
        
        //An example of using the MobilePayErrorCode enum
        //if (error.code == MobilePayErrorCodeUpdateApp) {
        //    NSLog(@"You must update your MobilePay app");
        //}
        
    } cancel:^(MobilePayCancelledPayment * _Nullable mobilePayCancelledPayment) {
        NSLog(@"MobilePay purchase with order id '%@' cancelled by user", mobilePayCancelledPayment.orderId);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Payment Cancelled",nil) message:NSLocalizedString(@"You cancelled the payment",nil) preferredStyle:UIAlertControllerStyleAlert];
       UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }];

}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"Source App %@ URL %@ %@ annot", sourceApplication, url, annotation );
    if (![sourceApplication isEqualToString:@"com.danskebank.mobilepay"])
    [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_SHOPIFY_CHECKOUT_CALLBACK object:nil userInfo:@{@"url": url}];
    else
    {
        [self handleMobilePayPaymentWithUrl:url];
    }
    return YES;
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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        
        UIUserNotificationType types = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *mySettings =
        [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [application registerUserNotificationSettings:mySettings];
        [application registerForRemoteNotifications];
        
        
    }else{//this link should be like this. XCODE is trying to tell us that this code shouldn't be used in ios 8 and onwards, but if you look above, we are using this line for ios below 8. We cant have any other way for this :) 
        [application registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -Home Shortcut Items

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    UITabBarController *tab = (UITabBarController *) self.window.rootViewController;
    if ([tab isKindOfClass:[UITabBarController class]] == YES){
        NSString *type = shortcutItem.type;
        if ([type isEqualToString:@"com.applesolutions.app.shortcut.shop"] == YES){
            tab.selectedIndex = 1;
        }
        if ([type isEqualToString:@"com.applesolutions.app.shortcut.accessories"] == YES){
            tab.selectedIndex = 0;
        }
        if ([type isEqualToString:@"com.applesolutions.app.shortcut.store"] == YES){
            tab.selectedIndex = 2;
        }
        if ([type isEqualToString:@"com.applesolutions.app.shortcut.order"] == YES){
            tab.selectedIndex = 3;
        }
    }
    
    completionHandler(YES);
}

@end
