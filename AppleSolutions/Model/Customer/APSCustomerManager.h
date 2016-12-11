//
//  APSCustomerManager.h
//  AppleSolutions
//
//  Created by Chris Lin on 12/16/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APSCustomerManager : NSObject

@property (strong, nonatomic) NSMutableDictionary *m_dict;

+ (instancetype) sharedInstance;
- (id) init;
- (void) initializeManager;

- (BOOL) isUserLoggedIn;
- (int) getCustomerId;
- (int) getOrdersCount;

- (void) requestCustomerLoginWithEmail: (NSString *) email Password: (NSString *) password Callback: (void (^) (int status)) callback;

@end
