//
//  APSErrorManager.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/13/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APSErrorManager : NSObject

@property (strong, nonatomic) NSString *m_szLastServerMessage;

+ (instancetype) sharedInstance;
- (void) initializeManager;

@end
