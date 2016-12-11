//
//  APSProductVariantDataModel.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/14/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSProductVariantDataModel.h"
#import "APSGenericFunctionManager.h"

@implementation APSProductVariantDataModel

- (id) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.m_szId= @"";
    self.m_szTitle = @"";
    self.m_fPrice = 0;
    self.m_fPriceToCompare = -1;
    self.m_isShippingRequired = NO;
}

- (void) setWithDictionary: (NSDictionary *) dict{
    [self initialize];
    @try {
        self.m_szId = [APSGenericFunctionManager refineNSString:[dict objectForKey:@"id"]];
        self.m_szTitle = [APSGenericFunctionManager refineNSString:[dict objectForKey:@"title"]];
        self.m_fPrice = [[dict objectForKey:@"price"] floatValue];
        if ([[dict objectForKey:@"compare_at_price"] isKindOfClass:[NSNull class]] == NO){
            self.m_fPriceToCompare = [[dict objectForKey:@"compare_at_price"] floatValue];
        }
        else {
            self.m_fPriceToCompare = -1;
        }
        
        self.m_isShippingRequired = [[dict objectForKey:@"requires_shipping"] boolValue];
    }
    @catch (NSException *exception) {
        [self initialize];
    }
}

- (NSDictionary *) serializeToDictionary{
    NSDictionary *dict = @{@"id" : self.m_szId,
                           @"title": self.m_szTitle,
                           @"price": [NSNumber numberWithFloat:self.m_fPrice],
                           @"compare_at_price": [NSNumber numberWithFloat:self.m_fPriceToCompare],
                           @"requires_shipping": [NSNumber numberWithBool:self.m_isShippingRequired]
                           };
    return dict;
}

@end
