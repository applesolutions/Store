//
// Created by Feiko Lai on 1/8/14.
// Copyright (c) 2014 Aftership. All rights reserved.
//


#import "AftershipDeleteTrackingRequest.h"
#import "AftershipTracking.h"
#import "AftershipCourier.h"
#import "AftershipGetTrackingsResponse.h"


@implementation AftershipDeleteTrackingRequest {

}

#pragma mark - constructors

- (instancetype)initWithTrackingNumber:(NSString *)trackingNumber slug:(NSString *)slug completionBlock:(void (^)(AftershipDeleteTrackingRequest *, AftershipTracking *, NSError *))completionBlock {
  self = [super init];
  if (self) {
    self.trackingNumber = trackingNumber;
    self.slug = slug;
    self.completionBlock = completionBlock;
  }

  return self;
}

+ (instancetype)requestWithTrackingNumber:(NSString *)trackingNumber slug:(NSString *)slug completionBlock:(void (^)(AftershipDeleteTrackingRequest *, AftershipTracking *, NSError *))completionBlock {
  return [[self alloc] initWithTrackingNumber:trackingNumber slug:slug
                              completionBlock:completionBlock];
}

- (instancetype)initWithIdentifier:(NSString *)identifier completionBlock:(void (^)(AftershipDeleteTrackingRequest *, AftershipTracking *, NSError *))completionBlock {
  self = [super init];
  if (self) {
    self.identifier = identifier;
    self.completionBlock = completionBlock;
  }

  return self;
}

+ (instancetype)requestWithIdentifier:(NSString *)identifier completionBlock:(void (^)(AftershipDeleteTrackingRequest *, AftershipTracking *, NSError *))completionBlock {
  return [[self alloc] initWithIdentifier:identifier
                          completionBlock:completionBlock];
}





- (void)doExecuteWithManager:(RKObjectManager *)manager {

    [manager deleteObject:nil
                   path:self.path
             parameters:nil
                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    [self handleResult:mappingResult withError:nil];
                }
                failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    [self handleResult:nil withError:error];
                }];

}






@end