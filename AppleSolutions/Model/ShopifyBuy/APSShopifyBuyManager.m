//
//  APSShopifyBuyManager.m
//  AppleSolutions
//
//  Created by Chris Lin on 12/6/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSShopifyBuyManager.h"
#import "APSBagManager.h"
#import "APSBagItemDataModel.h"
#import "APSErrorManager.h"
#import "Global.h"
#import "APSGenericFunctionManager.h"
#import "APSUrlManager.h"
#import <AFNetworking.h>

@implementation APSShopifyBuyManager

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
    }
    return self;
}

- (void) initializeManager{
    self.m_client = [[BUYClient alloc] initWithShopDomain:SHOPIFYBUY_SHOP_DOMAIN
                                                   apiKey:SHOPIFYBUY_API_KEY
                                                appId:SHOPIFYBUY_APP_ID];
    self.m_client.pageSize = 250;
    self.m_client.urlScheme = @"AppleSolutions://";
    self.m_modelManager = [BUYModelManager modelManager];
    
    //self.m_cart = [[BUYCart alloc] init];
    self.m_cart = [self.m_modelManager insertCartWithJSONDictionary:nil];
    
    self.m_arrCollection = [[NSMutableArray alloc] init];
    self.m_arrSearchResult = [[NSMutableArray alloc] init];
    self.m_indexCollectionSelected = 0;
    
    // Prefetch the shop object for Apple Pay
    [self.m_client getShop:^(BUYShop *shop, NSError *error) {
        self.m_shop = shop;
    }];
    
    [self.m_client getProductById:[NSNumber numberWithLong:(long)9068986700] completion:^(BUYProduct * _Nullable product, NSError * _Nullable error) {
         self.m_appleGiftProductVariant = [product.variantsArray objectAtIndex:0];
         NSLog(@"Collections %@", product.collections);
         NSLog(@"COST %@", self.m_appleGiftProductVariant.price);
         
    }];
    NSLog(@"COST asass%@", self.m_appleGiftProductVariant.price);

}

#pragma mark -Utils

- (NSString *) getImageUrlWithCollectionIndex: (int) indexCollection ProductIndex: (int) indexProduct VariantIndex: (int) indexVariant{
    BUYCollection *collection = [self.m_arrCollection objectAtIndex:indexCollection];
    BUYProduct *product = [collection.m_products objectAtIndex:indexProduct];
//    BUYProductVariant *variant = [product.variants objectAtIndex:indexVariant];
    BUYImageLink *image0 = [product.images objectAtIndex:0];
    return [APSGenericFunctionManager refineNSString: [image0.sourceURL absoluteString]];
}

- (int) getIndexFromFeaturedIndex: (int) index{
    int count = -1;
    for (int i = 0; i < (int) [self.m_arrCollection count]; i++){
        BUYCollection *collection = [self.m_arrCollection objectAtIndex:i];
        if (collection.isFeatured == YES) count++;
        if (count == index){
            return i;
        }
    }
    return -1;
}

- (int) getIndexFromNonFeaturedIndex: (int) index{
    int count = -1;
    for (int i = 0; i < (int) [self.m_arrCollection count]; i++){
        BUYCollection *collection = [self.m_arrCollection objectAtIndex:i];
        if (collection.isFeatured == NO) count++;
        if (count == index){
            return i;
        }
    }
    return -1;
}

- (int) getNumberOfNonFeatured{
    int count = 0;
    for (int i = 0; i < (int) [self.m_arrCollection count]; i++){
        BUYCollection *collection = [self.m_arrCollection objectAtIndex:i];
        if (collection.isFeatured == NO) count++;
    }
    return count;
}

- (void) searchProductsByKeywords: (NSString *) keyword{
    if (keyword.length == 0){
        [self.m_arrSearchResult removeAllObjects];
        return;
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSString *keywordLower = keyword.lowercaseString;
    
    for (int i = 0; i < (int) [self.m_arrCollection count]; i++){
        BUYCollection *collection = [self.m_arrCollection objectAtIndex:i];
        for (int j = 0; j < (int) [collection.m_products count]; j++){
            BUYProduct *product = [collection.m_products objectAtIndex:j];
            NSString *title = [product.title lowercaseString];
            if ([title containsString:keywordLower] == YES){
                [arr addObject:@{@"_COLLECTION": [NSNumber numberWithInt:i],
                                 @"_PRODUCT": [NSNumber numberWithInt:j]
                                }];
            }
        }
    }
    self.m_arrSearchResult = arr;
    NSLog(@"search results %@",arr);
}

- (NSDictionary *) getProductPathWithBarcode: (NSString *) barcode{
    if (barcode == nil || barcode.length == 0) return nil;
    
    if (barcode.length > 12){
        barcode = [barcode substringFromIndex:(barcode.length - 12)];
    }
    
    for (int i = 0; i < (int) [self.m_arrCollection count]; i++){
        BUYCollection *collection = [self.m_arrCollection objectAtIndex:i];
        for (int j = 0; j < (int) [collection.m_products count]; j++){
            BUYProduct *product = [collection.m_products objectAtIndex:j];
            for (int k = 0; k < (int) [product.variants count]; k++){
                BUYProductVariant *variant = [product.variants objectAtIndex:k];
                if ([variant.sku isEqualToString:barcode] == YES){
                    return @{@"_COLLECTION": @(i),
                             @"_PRODUCT": @(j),
                             @"_VARIANT": @(k)};
                }
            }
        }
    }
    return nil;
}

#pragma mark -Collection

- (BOOL) isFeaturedCollectionByTitle: (NSString *) title{
    if ([title caseInsensitiveCompare:@"Favoritter"] == NSOrderedSame) return YES;
    return NO;
}

- (void) requestCollectionWithCallback: (void (^)(int status)) callback{
  
   [self.m_client getCollectionsPage:1 completion:^(NSArray *collections, NSUInteger page, BOOL reachedEnd, NSError * error)  {
        int status = ERROR_NONE;
        if (error == nil){
            [self.m_arrCollection removeAllObjects];
            [self.m_arrCollection addObjectsFromArray:collections];
            
            for (int i = 0; i < (int) [self.m_arrCollection count]; i++){
                BUYCollection *collection = [self.m_arrCollection objectAtIndex:i];
               collection.m_products = [[NSMutableArray alloc] init];
                collection.isFeatured = [self isFeaturedCollectionByTitle:collection.title];
                [self requestProductWithCollectionIndex:i Callback:nil];                
            }
            
            [self requestSettingsFromHerokuWithCallback:callback];
            [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_COLLECTION_UPDATED object:nil];
        }
        else {
            status = ERROR_INVALID_REQUEST;
            [APSErrorManager sharedInstance].m_szLastServerMessage = error.localizedDescription;
            [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_COLLECTION_FAILED object:nil];
        }
        if (callback) callback(status);
    }];
}

- (void) requestSettingsFromHerokuWithCallback: (void(^) (int status)) callback{
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
        
        for (int i = 0; i < (int) [arrFeatured count]; i++){
            NSDictionary *d = [arrFeatured objectAtIndex:i];
            int nId = [[d objectForKey:@"shopify_collection_id"] intValue];
            for (int j = 0; j < (int) [self.m_arrCollection count]; j++){
                BUYCollection *collection = [self.m_arrCollection objectAtIndex:j];
                if ((int) collection.identifier == nId){
                    collection.isFeatured = YES;
                    break;
                }
            }
        }
        if (callback){
            callback(status);
        }
        
        if (status == ERROR_NONE){
            [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_COLLECTION_FEATURED_UPDATED object:nil];
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

#pragma mark -Product

- (void) requestProductWithCollectionIndex: (int) collectionIndex Callback: (void (^) (int status)) callback{

    BUYCollection *collection = [self.m_arrCollection objectAtIndex:collectionIndex];
    
    
    
    [self.m_client getProductsPage:1 inCollection:collection.identifier completion:^(NSArray *products, NSUInteger page, BOOL reachedEnd, NSError *error) {
        int status = ERROR_NONE;
        if (error == nil){
            [collection.m_products removeAllObjects];
            [collection.m_products addObjectsFromArray:products];
        }
        else {
            status = ERROR_INVALID_REQUEST;
            [APSErrorManager sharedInstance].m_szLastServerMessage = error.localizedDescription;
        }
        if (callback) callback(status);
    }];
}

#pragma mark -Cart

- (void) clearCart{
    self.appleGiftMessageQuantity = 0;
    self.m_allGiftMessages = @"";
    [self.m_cart clearCart];
}

- (void) addCartLineItemWithCollectionIndex: (int) indexCollection ProductIndex: (int) indexProduct VariantIndex: (int) indexVariant Quantity: (int) quantity Notes: (NSString *) notes{
    BUYCollection *collection = [self.m_arrCollection objectAtIndex:indexCollection];
    BUYProduct *product = [collection.m_products objectAtIndex:indexProduct];
    BUYProductVariant *variant = [product.variants objectAtIndex:indexVariant];
    [self.m_cart setVariant:variant withTotalQuantity:quantity];
    
    if (![notes isEqualToString:@""])
    {
        self.m_allGiftMessages = [NSString stringWithFormat:@"%@ Product:%@ %@", self.m_allGiftMessages,variant.title, notes ];
    }
}


- (void) buildCartFromBag{
    [self clearCart];
    
    APSBagManager *managerBag = [APSBagManager sharedInstance];
    for (int i = 0; i < (int) [managerBag.m_arrItems count]; i++){
        APSBagItemDataModel *item = [managerBag.m_arrItems objectAtIndex:i];
        [self addCartLineItemWithCollectionIndex:item.m_indexCollection ProductIndex:item.m_indexProduct VariantIndex:item.m_indexVariant Quantity:item.m_nQuantity Notes:item.m_szNotes];
        
    }
    self.appleGiftMessageQuantity = managerBag.appleGiftMessageQuantity;
    [self.m_cart setVariant:self.m_appleGiftProductVariant withTotalQuantity:self.appleGiftMessageQuantity];
  }

#pragma mark -Checkout
- (void) requestCreateCheckoutWithEmail: (NSString *) email ShippingAddress: (BUYAddress *) shippingAddress Callback: (void (^) (int status)) callback{
    // BUYCheckout *check = [[BUYCheckout alloc] initWithCart:self.m_cart];
    BUYCheckout *check = [self.m_client.modelManager checkoutWithCart:self.m_cart];
    check.email = email;
    check.shippingAddress = shippingAddress;
    [self.m_client createCheckout:check completion:^(BUYCheckout *checkout, NSError *error) {
        int status = ERROR_NONE;
        NSLog(@"Error in Shipping %@",error);
        if (error == nil){
            self.m_checkout = checkout;
        }
        else {
            status = ERROR_INVALID_REQUEST;
            [APSErrorManager sharedInstance].m_szLastServerMessage = error.localizedDescription;
        }
        if (callback) callback(status);
    }];
}
- (void) requestCreateCheckoutWithCallback: (void (^) (int status)) callback{
   // BUYCheckout *check = [[BUYCheckout alloc] initWithCart:self.m_cart];
    BUYCheckout *check = [self.m_client.modelManager checkoutWithCart:self.m_cart];
    [self.m_client createCheckout:check completion:^(BUYCheckout *checkout, NSError *error) {
        int status = ERROR_NONE;
        if (error == nil){
            self.m_checkout = checkout;
        }
        else {
            status = ERROR_INVALID_REQUEST;
            [APSErrorManager sharedInstance].m_szLastServerMessage = error.localizedDescription;
        }
        if (callback) callback(status);
    }];
}

@end
