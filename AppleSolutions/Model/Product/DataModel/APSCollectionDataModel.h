//
//  APSCollectionDataModel.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/13/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APSCollectionDataModel : NSObject

@property int m_nId;
@property (strong, nonatomic) NSString *m_szHandle;
@property (strong, nonatomic) NSString *m_szTitle;
@property (strong, nonatomic) NSString *m_szImage;

- (id) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;

- (BOOL) isSet;

@end
