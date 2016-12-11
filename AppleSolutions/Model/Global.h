//
//  Global.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/13/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#ifndef Global_h
#define Global_h

#define APS_BASEURL                                             @"https://dk.applesolutionsno.myshopify.com"
#define APS_HEROKU                                              @"https://mooncode.herokuapp.com/shopify_merchant"
#define APS_CART_BASEURL                                        @"https://dk.applesolutions.io/cart"
#define APS_CART_CHECKOUTURL                                    @"https://checkout.shopify.com"

#define APS_SHOPIFY_TOKEN                                       @"59ef85de6946a6108eb2eac6a232f360"
// @"9d6fc7d43f012520bf2863f1c3b77538"
#define APS_PHONENUMBER_ONETOONE                                @"+45 89 88 50 52"

#define APS_SHOP_LATITUDE                                       55.685229
#define APS_SHOP_LONGITUDE                                      12.550650

#define APS_ESTIMOTE_APPID                                      @"applesolutions-store-velko-4z1"
#define APS_ESTIMOTE_APPTOKEN                                   @"2db19a834103befe11282c40de939a15"
#define APS_ESTIMOTE_UUID                                       @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define APS_ESTIMOTE_MAJOR                                      20983
#define APS_ESTIMOTE_MINOR                                      51470

#define GOOGLEMAPS_API_KEY                                      @"AIzaSyAvrIo6cGEl-wLfr4d75HMdij5VjikgnxA"
#define SHOPIFY_MOBILEPAY_URL                                         @"https://59ef85de6946a6108eb2eac6a232f360:9105d77268ede98b9fbaa420f26168cb@applesolutionsno.myshopify.com"

#define SHOPIFYBUY_SHOP_DOMAIN                                  @"applesolutionsno.myshopify.com"
#define SHOPIFYBUY_API_KEY                                      @"f7aa9c8aade02182b229930bd46c5599"
#define SHOPIFYBUY_CHANNEL_ID                                   @"8558273"
#define SHOPIFYBUY_MERCHANT_ID                                  @"merchant.applesolutionsno.myshopify.com"
#define SHOPIFYBUY_APP_ID                                       @"8"

#define AFTERSHIP_CLIENT_ID                                     @"37463db1-eb68-4fcd-9a98-170c3e0990ed"

/*
 quantity=10&id=8274265089
 
 (lldb) po url_add_product_To_cart
 https://dk.applesolutions.io/cart/add.js
 
 https://checkout.shopify.com

 */

// Transition
#define TRANSITION_FADEOUT_DURATION         0.25f
#define TRANSITION_IMAGEVIEW_FADEIN         0.5f

#define APSUICOLOR_GRAY                                         [UIColor colorWithRed:(210 / 255.0) green:(210 / 255.0) blue:(210 / 255.0) alpha:1]
#define APSUICOLOR_BLUE                                         [UIColor colorWithRed:(0 / 255.0) green:(122 / 255.0) blue:(255 / 255.0) alpha:1]
#define APSUICOLOR_GREEN                                        [UIColor colorWithRed:(0 / 255.0) green:(200 / 255.0) blue:(0 / 255.0) alpha:1]

#pragma mark -NSNotification

#define APSLOCALNOTIFICATION_COLLECTION_UPDATED                                         @"APSLOCALNOTIFICATION_COLLECTION_UPDATED"
#define APSLOCALNOTIFICATION_COLLECTION_FAILED                                          @"APSLOCALNOTIFICATION_COLLECTION_FAILED"
#define APSLOCALNOTIFICATION_COLLECTION_FEATURED_UPDATED                                @"APSLOCALNOTIFICATION_COLLECTION_FEATURED_UPDATED"
#define APSLOCALNOTIFICATION_PRODUCT_UPDATED                                            @"APSLOCALNOTIFICATION_PRODUCT_UPDATED"
#define APSLOCALNOTIFICATION_PRODUCT_FAILED                                             @"APSLOCALNOTIFICATION_PRODUCT_FAILED"
#define APSLOCALNOTIFICATION_USER_LOGIN_FAILED                                          @"APSLOCALNOTIFICATION_USER_LOGIN_FAILED"
#define APSLOCALNOTIFICATION_USER_SIGNUP_FAILED                                         @"APSLOCALNOTIFICATION_USER_SIGNUP_FAILED"
#define APSLOCALNOTIFICATION_SHOPIFY_CHECKOUT_CALLBACK                                  @"APSLOCALNOTIFICATION_SHOPIFY_CHECKOUT_CALLBACK"
#define APSLOCALNOTIFICATION_BARCODE_RECOGNIZED                                         @"APSLOCALNOTIFICATION_BARCODE_RECOGNIZED"
#define APSLOCALNOTIFICATION_GIFTCARD_RECOGNIZED @"APSLOCALNOTIFICATION_GIFTCARD_RECOGNIZED"
// Error Code
#pragma mark - Error Code

#define ERROR_NONE                              0
#define ERROR_CONNECTION_FAILED                 1
#define ERROR_INVALID_PARAMETER                 2
#define ERROR_INVALID_REQUEST                   3

// Localstorage Key

#define LOCALSTORAGE_PREFIX                 @"PLT_LOCALSTORAGE_"
#define LOCALSTORAGE_USERLOOKUP             @"USERLOOKUP"
#define LOCALSTORAGE_USERLASTLOGIN          @"USERLASTLOGIN"
#define LOCALSTORAGE_USERINFO               @"USERINFO"
#define LOCALSTORAGE_USERPAYMENTINFO        @"USERPAYMENTINFO"

typedef NS_ENUM(int,BarCodeRequests){
    GiftCardsVC,
    ProductCategoryVC
};

#endif /* Global_h */
