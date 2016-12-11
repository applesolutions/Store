//
//  APSLoginVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 12/16/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSAccountWebVC.h"
#import "APSCustomerManager.h"
#import "APSGenericFunctionManager.h"
#import "APSErrorManager.h"
#import "Global.h"
#import <MBProgressHUD.h>

@interface APSAccountWebVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *m_webview;
@property (weak, nonatomic) IBOutlet UINavigationItem *m_titleLbl;

@end

@implementation APSAccountWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSInteger pageSelected = [prefs integerForKey:@"PageSelected"];
    if (pageSelected == 1)
    {           NSLog(@"Opening  Levering");
        [self.m_titleLbl setTitle:@"Track n' Trace"];
        [self.m_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://dk.applesolutions.io/apps/levering"]]];
    }
    else if (pageSelected == 3)
    {
        NSLog(@"Opening Ticketstore");
        [self.m_titleLbl setTitle:@"Click & Collect"];

        [self.m_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ticketstore.applesolutions.nu"]]];
    }
 

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self saveCookies];
}

- (void)saveCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"cookies"];
    [defaults synchronize];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -Biz Logic



- (void) gotoAccount{
    [self performSegueWithIdentifier:@"SEGUE_FROM_LOGIN_TO_ACCOUNT" sender:nil];
    
}

#pragma mark -Text Field Event Listeners


#pragma mark -Button Event Listeners

@end
