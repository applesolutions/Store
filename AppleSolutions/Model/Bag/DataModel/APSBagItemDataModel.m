//
//  APSBagItemDataModel.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/23/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSBagItemDataModel.h"

@implementation APSBagItemDataModel

- (id) init{
    self = [super init];
    if (self){
        self.m_nQuantity = 1;
    }
    return self;
}


- (void) setWithCollectionIndex: (int) indexCollection ProductIndex: (int) indexProduct VariantIndex: (int) indexVariant{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    BUYCollection *collection = [managerBuy.m_arrCollection objectAtIndex:indexCollection];
    BUYProduct *product = [collection.m_products objectAtIndex:indexProduct];
    BUYProductVariant *variant = [product.variants objectAtIndex:indexVariant];
    NSLog(@"Title %@",product.title);
    self.m_product = product;
    self.m_variant = variant;
    self.m_indexCollection = indexCollection;
    self.m_indexProduct = indexProduct;
    self.m_indexVariant = indexVariant;
    self.m_szNotes = @"";
    NSLog(@"My product Title %@",self.m_product.title);
    
}

@end
