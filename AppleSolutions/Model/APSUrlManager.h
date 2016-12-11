//
//  APSUrlManager.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/13/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"

@interface APSUrlManager : NSObject

#pragma mark -Collections

+ (NSString *) getEndpointForCollections;
+ (NSString *) getEndpointForCollectionSettings;

#pragma mark -Customer

+ (NSString *) getEndpointForCustomerSearch;

#pragma mark -Products

+ (NSString *) getEndpointForProducts;

#pragma mark -Shopify

+ (NSString *) getEndpointForCartClear;
+ (NSString *) getEndpointForCartAdd;
+ (NSString *) getEndpointForCartCheckout;

@end
