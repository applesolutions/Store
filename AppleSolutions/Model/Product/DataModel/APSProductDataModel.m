//
//  APSProductDataModel.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/14/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSProductDataModel.h"
#import "APSGenericFunctionManager.h"
#import "APSProductVariantDataModel.h"

@implementation APSProductDataModel

- (id) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.m_nId = 0;
    self.m_szTitle = @"";
    self.m_szBodyHtml = @"";
    self.m_szImagePrimary = @"";
    self.m_arrVariants = [[NSMutableArray alloc] init];
    self.m_arrImages = [[NSMutableArray alloc] init];
    self.m_datePublished = nil;
}

- (void) setWithDictionary: (NSDictionary *) dict{
    [self initialize];
    @try {
        self.m_nId = [[dict objectForKey:@"id"] intValue];
        self.m_szTitle = [APSGenericFunctionManager refineNSString:[dict objectForKey:@"title"]];
        self.m_szBodyHtml = [APSGenericFunctionManager refineNSString:[dict objectForKey:@"body_html"]];
        self.m_szImagePrimary = [APSGenericFunctionManager refineNSString:[[dict objectForKey:@"image"] objectForKey:@"src"]];
        NSString *szPublishedDate = [APSGenericFunctionManager refineNSString:[dict objectForKey:@"published_at"]];
        self.m_datePublished = [APSGenericFunctionManager getDateFromString:szPublishedDate];
        
        NSArray *arrImages = [dict objectForKey:@"images"];
        [self.m_arrImages removeAllObjects];
        for (int i = 0; i < (int) [arrImages count]; i++){
            NSDictionary *d = [arrImages objectAtIndex:i];
            NSString *szImage = [d objectForKey:@"src"];
            [self.m_arrImages addObject:szImage];
        }
        
        NSArray *arrVariants = [dict objectForKey:@"variants"];
        [self.m_arrVariants removeAllObjects];
        for (int i = 0; i < (int) [arrVariants count]; i++){
            NSDictionary *d = [arrVariants objectAtIndex:i];
            APSProductVariantDataModel *variant = [[APSProductVariantDataModel alloc] init];
            [variant setWithDictionary:d];
            [self.m_arrVariants addObject:variant];
        }
    }
    @catch (NSException *exception) {
        [self initialize];
    }
}

- (NSDictionary *) serializeToDictionary{
    NSMutableArray *arrVariants = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [self.m_arrVariants count]; i++){
        APSProductVariantDataModel *variant = [self.m_arrVariants objectAtIndex:i];
        [arrVariants addObject:[variant serializeToDictionary]];
    }
    
    NSDictionary *dict = @{@"id" : [NSNumber numberWithInt:self.m_nId],
                           @"title": self.m_szTitle,
                           @"body_html": self.m_szBodyHtml,
                           @"image": @{@"src": self.m_szImagePrimary},
                           @"variants": arrVariants
                           };
    return dict;
}

- (BOOL) isSet{
    return (self.m_nId == 0) ? NO : YES;
}

- (float) getPrimaryPrice{
    float price = 0;
    if ([self.m_arrVariants count] > 0){
        APSProductVariantDataModel *variant = [self.m_arrVariants objectAtIndex:0];
        price = variant.m_fPrice;
    }
    return price;
}

@end
