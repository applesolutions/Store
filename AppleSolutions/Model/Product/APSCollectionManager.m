//
//  APSCollectionManager.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/13/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSCollectionManager.h"
#import <AFNetworking.h>
#import "APSGenericFunctionManager.h"
#import "APSUrlManager.h"
#import "APSErrorManager.h"
#import "APSCollectionDataModel.h"
#import "APSShopifyBuyManager.h"

@implementation APSCollectionManager

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
    self.m_arrCollections = [[NSMutableArray alloc] init];
    self.m_arrDisplayCollections = [[NSMutableArray alloc] init];
    self.m_arrFeaturedCollections = [[NSMutableArray alloc] init];
}

#pragma mark -Biz Logic

#pragma mark -AFNetworking

- (void) requestCollectionViaSDKWithCallback: (void (^)(int status)) callback{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    [managerBuy requestCollectionWithCallback:^(int status) {
        if (status == ERROR_NONE){
            [self.m_arrCollections removeAllObjects];
            for (int i = 0; i < (int) [managerBuy.m_arrCollection count]; i++){
                BUYCollection *collection = [managerBuy.m_arrCollection objectAtIndex:i];
                NSDictionary *dict = @{@"id": collection.identifier,
                                       @"title": [APSGenericFunctionManager refineNSString: collection.title],
                                       @"image": @{@"src": [APSGenericFunctionManager refineNSString:[collection.image.sourceURL absoluteString]]},
                                       @"handle": [APSGenericFunctionManager refineNSString:collection.handle]};
                APSCollectionDataModel *item = [[APSCollectionDataModel alloc] init];
                [item setWithDictionary:dict];
                [self.m_arrCollections addObject:item];
            }
            [self.m_arrDisplayCollections removeAllObjects];
            [self.m_arrFeaturedCollections removeAllObjects];
            [self.m_arrDisplayCollections addObjectsFromArray:self.m_arrCollections];
            [self.m_arrFeaturedCollections addObjectsFromArray:self.m_arrCollections];
        }
        if (status == ERROR_NONE){
            [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_COLLECTION_UPDATED object:nil];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_COLLECTION_FAILED object:nil];
        }
    }];
}

- (void) requestCollectionWithCallback: (void (^)(int status)) callback{
    NSString *szUrl = [APSUrlManager getEndpointForCollections];
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [requestManager.requestSerializer setValue:APS_SHOPIFY_TOKEN forHTTPHeaderField:@"X-Shopify-Access-Token"];
    
    [requestManager GET:szUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int status = ERROR_NONE;
        NSArray *arr = [responseObject objectForKey:@"custom_collections"];
        [self.m_arrCollections removeAllObjects];
        
        if ([arr isKindOfClass:[NSArray class]] == YES && [arr count] > 0){
            for (int i = 0; i < (int) [arr count]; i++){
                NSDictionary *dict = [arr objectAtIndex:i];
                APSCollectionDataModel *collection = [[APSCollectionDataModel alloc] init];
                [collection setWithDictionary:dict];
                [self.m_arrCollections addObject:collection];
            }
        }
        else {
            status = ERROR_INVALID_PARAMETER;
        }
        
        [self requestSettingsForCollectionsWithCallback:callback];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [APSErrorManager sharedInstance].m_szLastServerMessage = @"";
        int status = ERROR_CONNECTION_FAILED;
        if (callback){
            callback(status);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_COLLECTION_FAILED object:nil];
    }];

}

- (void) requestSettingsForCollectionsWithCallback: (void (^)(int status)) callback{
    NSString *szUrl = [APSUrlManager getEndpointForCollectionSettings];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[APSGenericFunctionManager getUUID] forKey:@"udid"];
    [params setObject:@"applesolutionsno.myshopify.com" forKey:@"shopName"];
    [params setObject:@"shopify" forKey:@"shopType"];
    [params setObject:@"sanfrancisco" forKey:@"password"];
    [params setObject:@"0" forKey:@"version"];
    [params setObject:@"" forKey:@"resourcesPath"];
    [params setObject:@"" forKey:@"memoryPath"];
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [requestManager.requestSerializer setValue:APS_SHOPIFY_TOKEN forHTTPHeaderField:@"X-Shopify-Access-Token"];
    
    [requestManager POST:szUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int status = ERROR_NONE;
        NSDictionary *dict = responseObject;
        NSArray *arrFeatured = [dict objectForKey:@"featured_collections"];
        NSArray *arrDisplay = [dict objectForKey:@"displayed_collections"];
        
        [self.m_arrFeaturedCollections removeAllObjects];
        [self.m_arrDisplayCollections removeAllObjects];
        
        for (int i = 0; i < (int) [arrFeatured count]; i++){
            NSDictionary *d = [arrFeatured objectAtIndex:i];
            int nId = [[d objectForKey:@"shopify_collection_id"] intValue];
            for (int j = 0; j < (int) [self.m_arrCollections count]; j++){
                APSCollectionDataModel *collection = [self.m_arrCollections objectAtIndex:j];
                if (collection.m_nId == nId){
                    [self.m_arrFeaturedCollections addObject:collection];
                    break;
                }
            }
        }
        
        for (int i = 0; i < (int) [arrDisplay count]; i++){
            NSDictionary *d = [arrDisplay objectAtIndex:i];
            int nId = [[d objectForKey:@"shopify_collection_id"] intValue];
            for (int j = 0; j < (int) [self.m_arrCollections count]; j++){
                APSCollectionDataModel *collection = [self.m_arrCollections objectAtIndex:j];
                if (collection.m_nId == nId){
                    [self.m_arrDisplayCollections addObject:collection];
                    break;
                }
            }
        }
        
        if (callback){
            callback(status);
        }
        
        if (status == ERROR_NONE){
            [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_COLLECTION_UPDATED object:nil];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_COLLECTION_FAILED object:nil];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [APSErrorManager sharedInstance].m_szLastServerMessage = @"";
        int status = ERROR_CONNECTION_FAILED;
        if (callback){
            callback(status);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_COLLECTION_FAILED object:nil];
    }];
    
}

@end
