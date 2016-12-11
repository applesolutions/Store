//
//  APSCheckoutVC.h
//  AppleSolutions
//
//  Created by Dennis Persson on 9/8/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//
#import <UIKit/UIKit.h>
#import  <Buy/Buy.h>

@interface APSCheckoutVC : UIViewController
@property (strong, nonatomic) BUYCheckout * checkout;
@property (strong, nonatomic) NSString * giftCards;
@end
