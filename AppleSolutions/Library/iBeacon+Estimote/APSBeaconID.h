//
//  APSBeaconID.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/27/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EstimoteSDK/EstimoteSDK.h>

@interface APSBeaconID : NSObject <NSCopying>

@property (nonatomic, readonly) NSUUID *proximityUUID;
@property (nonatomic, readonly) CLBeaconMajorValue major;
@property (nonatomic, readonly) CLBeaconMinorValue minor;

@property (nonatomic, readonly) NSString *asString;
@property (nonatomic, readonly) CLBeaconRegion *asBeaconRegion;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithProximityUUID:(NSUUID *)proximityUUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithUUIDString:(NSString *)UUIDString major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;

- (BOOL)isEqualToBeaconID:(APSBeaconID *)beaconID;

@end

@interface CLBeacon (APSBeaconID)

@property (nonatomic, readonly) APSBeaconID *beaconID;

@end
