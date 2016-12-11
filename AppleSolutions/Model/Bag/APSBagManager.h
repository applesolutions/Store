//
//  APSBagManager.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/23/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APSProductDataModel.h"

@interface APSBagManager : NSObject

@property (strong, nonatomic) NSMutableArray *m_arrItems;
@property BOOL isCheckoutActive;
@property (strong, nonatomic) NSDictionary * m_orderInfo;
@property (assign, nonatomic) int appleGiftMessageQuantity;

+ (instancetype) sharedInstance;
- (id) init;

- (void) clearBag;

- (void) addProductToBagWithCollectionIndex: (int) indexCollection ProductIndex: (int) indexProduct VariantIndex: (int) indexVariant;
- (NSString *) getNotesAtIndex: (int) index;
- (void) createOrderWithParameters: (NSDictionary * ) params Callback:(void (^) (NSDictionary * order)) callback;

- (void) setCheckOutActive: (NSDictionary * ) orderInfo;
- (void) getShippingRates: (void (^) ( NSDictionary *)) callback;
- (void) setPaymentStatusWithID: (NSString *) orderID PaymentStatus: (NSString *) paymentStatus ;
- (void) requestShopifyCartClearWithCallback: (void (^)(int status)) callback;
- (void) requestShopifyCartAddWithId: (NSString *) varientId Quantity: (int) quantity Notes: (NSString *) notes Callback: (void (^)(int status)) callback;

- (void) incrementAppleGiftQuantity;

@end
