//
//  APSProductManager.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/14/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APSProductManager : NSObject

@property int m_nCategoryId;
@property int m_indexCategory;
@property int m_indexSelectedProduct;

@property (strong, nonatomic) NSMutableArray *m_arrProducts;

+ (instancetype) sharedInstance;
- (id) init;
- (void) initializeManager;

#pragma mark -AFNetworking

- (void) requestProductWithCollectionId: (int) collectionId Callback: (void (^)(int status)) callback;

@end
