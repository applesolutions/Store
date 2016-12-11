//
//  APSProductManager.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/14/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSProductManager.h"
#import "APSUrlManager.h"
#import <AFNetworking.h>
#import "APSProductDataModel.h"
#import "APSErrorManager.h"
#import "APSShopifyBuyManager.h"

@implementation APSProductManager

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
    self.m_nCategoryId = 0;
    self.m_indexCategory = 0;
    self.m_indexSelectedProduct = 0;
    self.m_arrProducts = [[NSMutableArray alloc] init];
}

#pragma mark -AFNetworking

- (void) requestProductWithCollectionId: (int) collectionId Callback: (void (^)(int status)) callback{
    NSString *szUrl = [APSUrlManager getEndpointForProducts];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"published" forKey:@"published_status"];
    [params setObject:[NSNumber numberWithInt:collectionId] forKey:@"collection_id"];
    [params setObject:@"1" forKey:@"page"];
    [params setObject:@"250" forKey:@"limit"];
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestManager.requestSerializer setValue:APS_SHOPIFY_TOKEN forHTTPHeaderField:@"X-Shopify-Access-Token"];
    
    [self.m_arrProducts removeAllObjects];
    
    [requestManager GET:szUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int status = ERROR_NONE;
        NSDictionary *dict = responseObject;
        NSArray *arrProducts = [dict objectForKey:@"products"];
        
        [self.m_arrProducts removeAllObjects];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < (int) [arrProducts count]; i++){
            NSDictionary *d = [arrProducts objectAtIndex:i];
            APSProductDataModel *product = [[APSProductDataModel alloc] init];
            [product setWithDictionary:d];
            [arr addObject:product];
        }
        
        NSArray *arr2 = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            APSProductDataModel *p1 = (APSProductDataModel *)obj1;
            APSProductDataModel *p2 = (APSProductDataModel *)obj2;
            return ![p1.m_datePublished compare:p2.m_datePublished];
        }];
        [self.m_arrProducts addObjectsFromArray:arr2];
        
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
