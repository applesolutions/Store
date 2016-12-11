//
//  APSBagManager.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/23/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSBagManager.h"
#import "APSUrlManager.h"
#import "APSErrorManager.h"
#import "APSBagItemDataModel.h"
#import <AFNetworking.h>

@implementation APSBagManager

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
    self.m_arrItems = [[NSMutableArray alloc] init];
    self.isCheckoutActive = NO;
}

#pragma mark -Biz Logic
- (void) incrementAppleGiftQuantity{
    self.appleGiftMessageQuantity++;
}
- (void) addProductToBagWithCollectionIndex: (int) indexCollection ProductIndex: (int) indexProduct VariantIndex: (int) indexVariant{
    //CONFIRM IF THE PRODUCT INDEXES ARE PASSED PROPERLY. IF YES, CONFIRM THE DATA IS PARSED PROPERLY FOR THOSE INDEXES. I.E HOW IS THE PRODUCT MAPPED FOR THOSE INDEXES AND IS IT RIGHT?
    APSBagItemDataModel *item = [[APSBagItemDataModel alloc] init];
    
    [item setWithCollectionIndex:indexCollection ProductIndex:indexProduct VariantIndex:indexVariant];
    [self.m_arrItems addObject:item];
}

- (NSString *) getNotesAtIndex: (int) index{
    APSBagItemDataModel *item = [self.m_arrItems objectAtIndex:index];
    return item.m_szNotes;
}

- (void) clearBag{
    self.appleGiftMessageQuantity = 0;
    [self.m_arrItems removeAllObjects];
}
#pragma mark –Shopify API Auth
- (void) setCheckOutActive:(NSDictionary *)orderInfo{
    self.isCheckoutActive = YES;
    self.m_orderInfo = orderInfo;
}
- (void) getShippingRates: (void (^) (NSDictionary * shippingRates)) callback{
    NSString *apiURL = [NSString stringWithFormat:@"%@/admin/carrier_services.json", SHOPIFY_MOBILEPAY_URL];
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [requestManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [requestManager GET:apiURL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSData * responseData = operation.responseData;
        NSError * responseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&responseError];
        NSLog(@"shipping rates are %@", responseDictionary);
        callback(responseDictionary);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"Response failure:%@",error);
        
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        NSLog(@"Failure error serialised - %@",serializedData);
        

    }];
    
    
}
- (void) setPaymentStatusWithID:(NSString *)orderID PaymentStatus:(NSString *)paymentStatus{
   // NSString *getURL = [NSString stringWithFormat:@"%@/admin/orders/%@/refunds/calculate.json", SHOPIFY_MOBILEPAY_URL,orderID];
    NSString *getURL = [NSString stringWithFormat:@"%@/admin/orders/%@/transactions.json", SHOPIFY_MOBILEPAY_URL,orderID];
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    requestManager.responseSerializer = [AFJSONResponseSerializer serializer];

    requestManager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:200];

    [requestManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
   // NSDictionary * refunDict = @{@"refund":@{@"shipping":@{@"amount":@2.0}}};
    [requestManager POST:getURL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSData * responseData = operation.responseData;
        NSError * responseError = nil;
        
        NSDictionary * responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&responseError] ;
        NSLog(@"response at payment status %@", responseObject);
        NSLog(@"value at dictionary %@", [responseDictionary objectForKey:@"transactions"]);
        NSArray * transactionArray = [responseDictionary objectForKey:@"transactions"];
        NSDictionary * transactionDictionary = [transactionArray objectAtIndex:0];
        
        requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
        requestManager.responseSerializer = [AFJSONResponseSerializer serializer];

        NSLog(@"new payment status %@ for id %@", paymentStatus, orderID);
        NSString * apiURL = [NSString stringWithFormat:@"%@/admin/orders/%@/transactions.json",SHOPIFY_MOBILEPAY_URL,orderID ];
        NSLog(@"ID is %@", [transactionDictionary objectForKey:@"id"]);
    //    NSString * p_id = [transactionDictionary objectForKey:@"id"];
      //  NSString *inStr = [NSString stringWithFormat:@"%ld", (long)p_id ];
   //     long pid = p_id.longLongValue;
      //  NSNumber * testNum = NSNumber number
        NSUInteger ppd = [[transactionDictionary objectForKey:@"id"] integerValue];
      //  NSNumber * test = [NSNumber numberWithUnsignedInteger:ppd];
        NSDictionary * transactionPaid =@{@"transaction":@{
                                                  @"parent_id":@1,
                                                  @"gateway":@"MobilePay",
                                                  @"kind":paymentStatus}
                                          };
        NSLog(@"DICT is %@, %@", transactionPaid, [NSNumber numberWithInteger:ppd]);
        //"not on 'store-credit' or 'cash' gateways require a parent_id"
        [requestManager POST:apiURL parameters:transactionPaid success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            NSLog(@"Response Success: %@",responseObject);
            
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"Response failure:%@",error);
            
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"Failure error serialised - %@",serializedData);
            
        }];
 
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
    }];
    
   }
- (void) createOrderWithParameters:(NSDictionary *)params Callback: (void (^)(NSDictionary * order))callback{

    //Variables to pass.
    //NS Dictionary
    //lineItems: NSDictionary: variant
    //Billing address: NSDictionary
    //
 
    NSString * apiURL = [NSString stringWithFormat:@"%@/admin/orders.json",SHOPIFY_MOBILEPAY_URL ];
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
   
    requestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    requestManager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:201];
    [requestManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [requestManager POST:apiURL parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"Response Success: %@",responseObject);
        NSError * responseError = nil;
        NSData * responseData = operation.responseData;
        NSDictionary * responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&responseError];
        NSDictionary * orderDictionary =[responseDictionary objectForKey:@"order"];
        NSLog(@"Order Number: %@, Order Id: %@", [orderDictionary objectForKey:@"order_number"], [orderDictionary objectForKey:@"id"]);
        NSNumber * orderID = [orderDictionary objectForKey:@"id"];
        
        NSNumber * orderNumber = [orderDictionary objectForKey:@"order_number"];
       callback(@{@"order":@"success",@"order_number":orderNumber.stringValue,@"order_id":orderID.stringValue});
        
        //Parse the number and id into an NS Dictionary and return
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"Response failure:%@",error);
        
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        NSLog(@"Failure error serialised - %@",serializedData);
    }];
    
    
}


#pragma mark -Checkout

- (void) requestShopifyCartClearWithCallback: (void (^)(int status)) callback{
    NSString *szUrl = [APSUrlManager getEndpointForCartClear];
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
//    requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
//    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [requestManager.requestSerializer setValue:APS_SHOPIFY_TOKEN forHTTPHeaderField:@"X-Shopify-Access-Token"];
    
    [requestManager GET:szUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int status = ERROR_NONE;
        if (callback){
            callback(status);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [APSErrorManager sharedInstance].m_szLastServerMessage = error.localizedDescription;
        int status = ERROR_INVALID_REQUEST;
        if (callback){
            callback(status);
        }
    }];
}

- (void) requestShopifyCartAddWithId: (NSString *) varientId Quantity: (int) quantity Notes: (NSString *) notes Callback: (void (^)(int status)) callback{
    NSString *szUrl = [APSUrlManager getEndpointForCartAdd];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    [param setObject:varientId forKey:@"id"];
    [param setObject:[NSNumber numberWithInt:quantity] forKey:@"quantity"];
    [param setObject:@{@"notes": notes} forKey:@"properties"];
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    //    [requestManager.requestSerializer setValue:APS_SHOPIFY_TOKEN forHTTPHeaderField:@"X-Shopify-Access-Token"];
    
    [requestManager POST:szUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int status = ERROR_NONE;
        if (callback){
            callback(status);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [APSErrorManager sharedInstance].m_szLastServerMessage = error.localizedDescription;
        int status = ERROR_INVALID_REQUEST;
        if (callback){
            callback(status);
        }
    }];
}

@end
