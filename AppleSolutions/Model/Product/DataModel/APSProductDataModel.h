//
//  APSProductDataModel.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/14/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APSProductDataModel : NSObject

@property int m_nId;
@property (strong, nonatomic) NSString *m_szTitle;
@property (strong, nonatomic) NSString *m_szBodyHtml;
@property (strong, nonatomic) NSString *m_szImagePrimary;
@property (strong, nonatomic) NSMutableArray *m_arrVariants;
@property (strong, nonatomic) NSMutableArray *m_arrImages;
@property (strong, nonatomic) NSDate *m_datePublished;

- (id) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;

- (BOOL) isSet;
- (float) getPrimaryPrice;

@end
