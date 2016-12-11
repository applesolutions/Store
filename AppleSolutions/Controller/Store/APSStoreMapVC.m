//
//  APSStoreMapVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/27/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSStoreMapVC.h"
#import <GoogleMaps/GoogleMaps.h>

#import "Global.h"
@import MapKit;

@interface APSStoreMapVC ()

/*
@property (weak, nonatomic) IBOutlet UIView *m_viewMapContainer;
@property (strong, nonatomic) GMSMapView *m_mapview;
*/
@property (weak, nonatomic) IBOutlet MKMapView *m_mkMapView;

@end

@implementation APSStoreMapVC

- (void) viewDidLoad{
    [super viewDidLoad];
    
    /*
    self.m_mapview = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:APS_SHOP_LATITUDE
                                                                longitude:APS_SHOP_LONGITUDE
                                                                     zoom:15];
        
        CGRect rcMapView = self.m_viewMapContainer.frame;
        self.m_mapview = [GMSMapView mapWithFrame:CGRectMake(0, 0, rcMapView.size.width, rcMapView.size.height) camera:camera];
        self.m_mapview.myLocationEnabled = YES;
        [self.m_viewMapContainer addSubview:self.m_mapview];
        
        [self addMarker];
    });
     */
    
    [self setInitialLocation];
}

- (void) setInitialLocation{
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:APS_SHOP_LATITUDE longitude:APS_SHOP_LONGITUDE];
    CLLocationDistance radius = 1000;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc.coordinate, radius * 2, radius * 2);
    [self.m_mkMapView setRegion:region animated:YES];    
}

- (void) addMarker{
    /*
    UIImage *imgPin = [UIImage imageNamed:@"stores-map-pin"];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(APS_SHOP_LATITUDE, APS_SHOP_LONGITUDE);
    GMSMarker *markerMine = [GMSMarker markerWithPosition:coord];
    markerMine.map = self.m_mapview;
    markerMine.appearAnimation = kGMSMarkerAnimationPop;
    markerMine.icon = imgPin;
    markerMine.groundAnchor = CGPointMake(0.5, 1);    
     */
}
@end
