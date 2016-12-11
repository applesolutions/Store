//
//  APSProductVariantDataModel.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/14/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APSProductVariantDataModel : NSObject

@property (strong, nonatomic) NSString *m_szId;
@property (strong, nonatomic) NSString *m_szTitle;
@property float m_fPrice;
@property float m_fPriceToCompare;
@property BOOL m_isShippingRequired;

- (id) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;

@end
