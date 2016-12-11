//
//  APSCollectionDataModel.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/13/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSCollectionDataModel.h"
#import "APSGenericFunctionManager.h"

@implementation APSCollectionDataModel

- (id) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.m_nId = 0;
    self.m_szHandle = @"";
    self.m_szImage = @"";
    self.m_szTitle = @"";
}

- (void) setWithDictionary: (NSDictionary *) dict{
    [self initialize];
    @try {
        self.m_nId = [[dict objectForKey:@"id"] intValue];
        self.m_szHandle = [APSGenericFunctionManager refineNSString:[dict objectForKey:@"handle"]];
        self.m_szTitle = [APSGenericFunctionManager refineNSString:[dict objectForKey:@"title"]];
        self.m_szImage = [APSGenericFunctionManager refineNSString:[[dict objectForKey:@"image"] objectForKey:@"src"]];
    }
    @catch (NSException *exception) {
        [self initialize];
    }
}

- (NSDictionary *) serializeToDictionary{
    NSDictionary *dict = @{@"id" : [NSNumber numberWithInt:self.m_nId],
                           @"handle": self.m_szHandle,
                           @"title": self.m_szTitle,
                           @"image": @{@"src": self.m_szImage},
                           };
    return dict;
}

- (BOOL) isSet{
    return (self.m_nId == 0) ? NO : YES;
}

@end
