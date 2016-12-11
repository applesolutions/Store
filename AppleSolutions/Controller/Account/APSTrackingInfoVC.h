//
//  APSTrackingInfoVC.h
//  AppleSolutions
//
//  Created by Dennis Persson on 10/27/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Aftership.h"

@interface APSTrackingInfoVC : UITableViewController
@property (nonatomic, strong) AftershipTracking * currentTracking;
- (UIImage * ) imageWithFileName: (NSString * ) fileName withSize: (float ) size;

@end
