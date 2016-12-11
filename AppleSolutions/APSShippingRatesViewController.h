//
//  APSShippingRatesViewController.h
//  AppleSolutions
//
//  Created by Dennis Persson on 8/19/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "APSShopifyBuyManager.h"
#import "APSBagManager.h"


@interface APSShippingRatesViewController : UITableViewController
@property (strong, nonatomic) BUYAddress * shippingAddress;
@property (strong, nonatomic) NSMutableDictionary * userData;
@property (assign, nonatomic) BOOL isBusinessUser;
@end
