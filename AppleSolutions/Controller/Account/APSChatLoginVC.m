//
//  APSChatLoginVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 08/06/2016.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSChatLoginVC.h"
#import "APSGenericFunctionManager.h"
#import "Intercom/intercom.h"

@interface APSChatLoginVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *m_txtEmailAddress;
@property (weak, nonatomic) IBOutlet UIButton *m_btnLogin;
- (IBAction)loginTapped:(id)sender;

@end

@implementation APSChatLoginVC




- (void)viewDidLoad {
    [self.m_txtEmailAddress becomeFirstResponder];
    self.m_txtEmailAddress.enabled = YES;
    self.m_txtEmailAddress.layer.borderWidth = 2.0f;
    self.m_txtEmailAddress.layer.borderColor = [[UIColor colorWithRed:0 green:0.6 blue:0.8 alpha:1.0] CGColor];
    self.m_txtEmailAddress.placeholder =  NSLocalizedString(@"Please enter your email address", nil) ;
    [self.m_txtEmailAddress setUserInteractionEnabled:YES];
    self.m_btnLogin.layer.borderColor = [[UIColor colorWithRed:0 green:0.6 blue:0.8 alpha:1.0] CGColor];
    self.m_txtEmailAddress.delegate = self;

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *email = self.m_txtEmailAddress.text;
    [self.m_txtEmailAddress resignFirstResponder];
    NSLog(@"Detected Event");
    if ([APSGenericFunctionManager isValidEmailAddress:email] == NO){
        [APSGenericFunctionManager showAlertWithMessage:@"Invalid email address."];
        return false;
    }
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:email forKey:@"intercomChatEmail"];
    [Intercom presentConversationList];
    [self.navigationController popViewControllerAnimated:YES];
    return true;
}

- (IBAction)loginTapped:(id)sender {
    NSString *email = self.m_txtEmailAddress.text;
    [self.m_txtEmailAddress resignFirstResponder];
    NSLog(@"Detected Event");
    if ([APSGenericFunctionManager isValidEmailAddress:email] == NO){
        [APSGenericFunctionManager showAlertWithMessage:@"Invalid email address."];
        return ;}
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:email forKey:@"intercomChatEmail"];
    [Intercom presentConversationList];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
