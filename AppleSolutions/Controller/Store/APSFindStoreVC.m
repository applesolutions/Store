//
//  APSFindStoreVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/26/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSFindStoreVC.h"
#import "APSGenericFunctionManager.h"
@import MapKit;
#import "Global.h"

@interface APSFindStoreVC () <UIAlertViewDelegate>

#define APSUIALERTVIEWTAG_STORE_PHONE                   1000

@end

@implementation APSFindStoreVC

- (IBAction)onBtnMapClick:(id)sender {
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:APS_SHOP_LATITUDE longitude:APS_SHOP_LONGITUDE];

//    NSString* url = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=AppleSolutions&saddr=%f,%f&daddr=%f,%f",loc.coordinate.latitude, loc.coordinate.longitude, loc2.coordinate.latitude, loc2.coordinate.longitude];
    NSString* url = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=AppleSolutions&daddr=%f,%f",loc.coordinate.latitude, loc.coordinate.longitude];

    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];

}

- (IBAction)onBtnPhoneNumberClick:(id)sender {
    NSString *szPhoneNumber = [APSGenericFunctionManager stripNonnumericsFromNSString:APS_PHONENUMBER_ONETOONE];
    NSURL *phoneUrl = [NSURL URLWithString:[[NSString  stringWithFormat:@"tel:%@",szPhoneNumber] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", nil)
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"Please click YES to call %@", nil), APS_PHONENUMBER_ONETOONE]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No", nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        
        alert.tag = APSUIALERTVIEWTAG_STORE_PHONE;
        [alert show];
    }
    else {
        [APSGenericFunctionManager showAlertWithMessage:NSLocalizedString(@"Phone call is not available on your device.", nil)];
    }
    return;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == APSUIALERTVIEWTAG_STORE_PHONE){
        // the user clicked OK
        if (buttonIndex == 1) {
            NSString *szPhoneNumber = [APSGenericFunctionManager stripNonnumericsFromNSString:APS_PHONENUMBER_ONETOONE];
            NSURL *phoneUrl = [NSURL URLWithString:[[NSString  stringWithFormat:@"tel:%@",szPhoneNumber] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            [[UIApplication sharedApplication] openURL:phoneUrl];
        }
    }
}

@end
