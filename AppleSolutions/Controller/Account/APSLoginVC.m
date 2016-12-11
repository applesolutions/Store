//
//  APSLoginVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 12/16/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSLoginVC.h"
#import "APSCustomerManager.h"
#import "APSGenericFunctionManager.h"
#import "APSErrorManager.h"
#import "Global.h"
#import <MBProgressHUD.h>

@interface APSLoginVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *m_txtEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *m_txtPassword;
@property (weak, nonatomic) IBOutlet UIWebView *m_webview;
@property (weak, nonatomic) IBOutlet UINavigationItem *m_titleLbl;

@end

@implementation APSLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.m_titleLbl setTitle:NSLocalizedString(@"My Account", nil)];

    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.m_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://dk.applesolutions.io/account/login"]]];
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

- (BOOL) checkMandatoryFields{
    NSString *email = self.m_txtEmailAddress.text;
    NSString *password = self.m_txtPassword.text;
    
    if (email.length == 0){
        [APSGenericFunctionManager showAlertWithMessage:@"Please input your email address."];
        return NO;
    }
    if ([APSGenericFunctionManager isValidEmailAddress:email] == NO){
        [APSGenericFunctionManager showAlertWithMessage:@"Invalid email address."];
        return NO;
    }
    if (password.length == 0){
        [APSGenericFunctionManager showAlertWithMessage:@"Please input your password."];
        return NO;
    }
    return YES;
}

- (void) doLogin{
    if ([self checkMandatoryFields] == NO) return;

    NSString *email = self.m_txtEmailAddress.text;
    NSString *password = self.m_txtPassword.text;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Please wait...";
    
    [[APSCustomerManager sharedInstance] requestCustomerLoginWithEmail:email Password:password Callback:^(int status) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (status == ERROR_NONE){
            [self gotoAccount];
        }
        else {
            [APSGenericFunctionManager showAlertWithMessage:@"Invalid username or password."];
        }
    }];
}

- (void) gotoAccount{
    [self performSegueWithIdentifier:@"SEGUE_FROM_LOGIN_TO_ACCOUNT" sender:nil];
}

#pragma mark -Text Field Event Listeners

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == self.m_txtPassword){
        [self doLogin];
    }
    return YES;
}

#pragma mark -Button Event Listeners

- (IBAction)onBtnLoginClick:(id)sender {
    [self.view endEditing:YES];
    [self doLogin];
}


@end
