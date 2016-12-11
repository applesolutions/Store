//
//  APSUrlManager.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/13/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSUrlManager.h"

@implementation APSUrlManager

#pragma mark -Collections

+ (NSString *) getEndpointForCollections{
    return [NSString stringWithFormat:@"%@/admin/custom_collections.json?limit=250", APS_BASEURL];
}

+ (NSString *) getEndpointForCollectionSettings{
    return [NSString stringWithFormat:@"%@/settings", APS_HEROKU];
}

#pragma mark -Customer

+ (NSString *) getEndpointForCustomerSearch{
    return [NSString stringWithFormat:@"%@/admin/customers/search.json", APS_BASEURL];
}

#pragma mark -Products

+ (NSString *) getEndpointForProducts{
    return [NSString stringWithFormat:@"%@/admin/products.json", APS_BASEURL];
}

#pragma mark -Shopify

+ (NSString *) getEndpointForCartClear{
    return [NSString stringWithFormat:@"%@/clear.js", APS_CART_BASEURL];
}

+ (NSString *) getEndpointForCartAdd{
    return [NSString stringWithFormat:@"%@/add.js", APS_CART_BASEURL];
}

+ (NSString *) getEndpointForCartCheckout{
    return [NSString stringWithFormat:@"%@/checkout", APS_CART_BASEURL];
}

@end
