//
//  APSReceiptVC.h
//  AppleSolutions
//
//  Created by Dennis Persson on 8/20/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//
#import  <Buy/Buy.h>

#import <UIKit/UIKit.h>

@interface APSReceiptVC : UITableViewController
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
- (instancetype) initWithCheckout: (BUYCheckout * )checkout UserData: (NSDictionary *) userData;
@property (nonatomic, strong) NSDictionary * userData;
@property (assign, nonatomic) BOOL isBusinessUser;
@property (nonatomic, strong) NSString * validGiftCard;
@end
