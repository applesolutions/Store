//
//  APSErrorManager.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/13/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSErrorManager.h"

@implementation APSErrorManager

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.m_szLastServerMessage = @"";
}

- (void) initializeManager{
    [self initialize];
}

@end
