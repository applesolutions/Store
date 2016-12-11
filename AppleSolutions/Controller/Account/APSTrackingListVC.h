//
//  APSTrackingListVC.h
//  AppleSolutions
//
//  Created by Dennis Persson on 9/30/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Aftership.h"

@interface APSTrackingListVC : UITableViewController
@property (strong, nonatomic) NSMutableArray * m_trackingNumbers;
@property (strong, nonatomic) AftershipClient * client;

- (UIImage *) imageWithFileName: (NSString *) fileName withSize: (float) size;


@end
