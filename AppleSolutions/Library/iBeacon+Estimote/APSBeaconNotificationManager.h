//
//  APSBeaconNotificationManager.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/27/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APSBeaconID.h"

@interface APSBeaconNotificationManager : NSObject

- (void)enableNotificationsForBeaconID:(APSBeaconID *)beaconID
                          enterMessage:(NSString *)enterMessage
                           exitMessage:(NSString *)exitMessage;

@end
