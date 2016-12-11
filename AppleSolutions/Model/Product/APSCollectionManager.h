//
//  APSCollectionManager.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/13/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APSCollectionManager : NSObject

@property (strong, nonatomic) NSMutableArray *m_arrCollections;
@property (strong, nonatomic) NSMutableArray *m_arrFeaturedCollections;
@property (strong, nonatomic) NSMutableArray *m_arrDisplayCollections;

+ (instancetype) sharedInstance;
- (id) init;
- (void) initializeManager;

#pragma mark -AFNetworking

- (void) requestCollectionWithCallback: (void (^)(int status)) callback;

@end
