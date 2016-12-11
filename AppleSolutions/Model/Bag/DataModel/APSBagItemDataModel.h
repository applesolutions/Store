//
//  APSBagItemDataModel.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/23/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APSShopifyBuyManager.h"

@interface APSBagItemDataModel : NSObject

@property BUYProduct *m_product;
@property BUYProductVariant *m_variant;

@property int m_indexCollection;
@property int m_indexProduct;
@property int m_indexVariant;
@property int m_nQuantity;
@property NSString *m_szNotes;

- (id) init;
- (void) setWithCollectionIndex: (int) indexCollection ProductIndex: (int) indexProduct VariantIndex: (int) indexVariant;

@end
