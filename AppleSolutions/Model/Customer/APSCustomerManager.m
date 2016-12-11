//
//  APSCustomerManager.m
//  AppleSolutions
//
//  Created by Chris Lin on 12/16/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSCustomerManager.h"
#import "APSUrlManager.h"
#import "APSGenericFunctionManager.h"
#import "Global.h"
#import "APSErrorManager.h"
#import <AFNetworking.h>

@implementation APSCustomerManager

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]){
        [self initializeManager];
    }
    return self;
}

- (void) initializeManager{
    self.m_dict = [[NSMutableDictionary alloc] init];
}

#pragma mark -Utils

- (BOOL) isUserLoggedIn{
    if ([self getCustomerId] == -1) return NO;
    return YES;
}

- (int) getCustomerId{
    if (self.m_dict == nil) return -1;
    
    id customerId = [self.m_dict objectForKey:@"id"];
    if (customerId == nil || [customerId isKindOfClass:[NSNull class]] == YES) return -1;
    return [customerId intValue];
}

- (int) getOrdersCount{
    id orderCount = [self.m_dict objectForKey:@"orders_count"];
    if (orderCount == nil) return 0;
    return [orderCount intValue];
}

- (NSString *) getEmailAddress{
    return [APSGenericFunctionManager refineNSString:[self.m_dict objectForKey:@"email"]];
}

#pragma mark -AFNetworking

- (void) requestCustomerLoginWithEmail: (NSString *) email Password: (NSString *) password Callback: (void (^) (int status)) callback{
    NSString *szUrl = [APSUrlManager getEndpointForCustomerSearch];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:email forKey:@"query"];
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestManager.requestSerializer setValue:APS_SHOPIFY_TOKEN forHTTPHeaderField:@"X-Shopify-Access-Token"];
    
    [requestManager GET:szUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int status = ERROR_NONE;
        NSArray *arr = [responseObject objectForKey:@"customers"];
        if (arr != nil && [arr isKindOfClass:[NSArray class]] == YES && ([arr count] == 1)){
            NSDictionary *dict = [arr objectAtIndex:0];
            [self.m_dict removeAllObjects];
            [self.m_dict addEntriesFromDictionary:dict];
        }
        else {
            status = ERROR_INVALID_REQUEST;
        }
        
        if (callback){
            callback(status);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [APSErrorManager sharedInstance].m_szLastServerMessage = error.localizedDescription;
        int status = ERROR_CONNECTION_FAILED;
        if (callback){
            callback(status);
        }
    }];

}

@end
