//
//  APSShopifyBuyManager.h
//  AppleSolutions
//
//  Created by Chris Lin on 12/6/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Buy.h"

@interface APSShopifyBuyManager : NSObject

@property (strong, nonatomic) BUYClient *m_client;
@property (strong, nonatomic) BUYModelManager * m_modelManager;
@property (strong, nonatomic) NSMutableArray *m_arrCollection;
@property (strong, nonatomic) NSMutableArray *m_arrSearchResult;
@property (strong, nonatomic) BUYCart *m_cart;
@property (strong, nonatomic) BUYCheckout *m_checkout;
@property (strong, nonatomic) BUYShop *m_shop;

@property int m_indexCollectionSelected;
@property int m_indexProductSelected;
@property int m_indexAccountPageSelected;

@property (strong, nonatomic) BUYProductVariant * m_appleGiftProductVariant;
@property (assign, nonatomic) int appleGiftMessageQuantity;

@property (strong, nonatomic) NSString * m_allGiftMessages;

+ (instancetype) sharedInstance;
- (id) init;
- (void) initializeManager;

// Utils
- (NSString *) getImageUrlWithCollectionIndex: (int) indexCollection ProductIndex: (int) indexProduct VariantIndex: (int) indexVariant;
- (int) getIndexFromFeaturedIndex: (int) index;
- (int) getIndexFromNonFeaturedIndex: (int) index;
- (int) getNumberOfNonFeatured;
- (void) searchProductsByKeywords: (NSString *) keyword;
- (NSDictionary *) getProductPathWithBarcode: (NSString *) barcode;

// Collection
- (void) requestCollectionWithCallback: (void (^)(int status)) callback;

// Product
- (void) requestProductWithCollectionIndex: (int) collectionIndex Callback: (void (^) (int status)) callback;
- (void) requestCreateCheckoutWithEmail: (NSString *) email ShippingAddress: (BUYAddress *) shippingAddress Callback: (void (^) (int status)) callback;

// Cart
- (void) clearCart;
- (void) addCartLineItemWithCollectionIndex: (int) indexCollection ProductIndex: (int) indexProduct VariantIndex: (int) indexVariant Quantity: (int) quantity Notes: (NSString *) notes;
- (void) buildCartFromBag;

// Checkout
- (void) requestCreateCheckoutWithCallback: (void (^) (int status)) callback;



@end
