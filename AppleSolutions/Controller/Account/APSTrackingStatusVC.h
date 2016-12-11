//
//  APSTrackingStatusVC.h
//  AppleSolutions
//
//  Created by Dennis Persson on 10/24/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Aftership.h"

@interface APSTrackingStatusVC : UIViewController

@property (nonatomic, strong) AftershipTracking * currentTracking;
@property (weak, nonatomic) IBOutlet UIButton *m_btnPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnCopyURL;

@property( nonatomic,strong) NSString* orderId;
@property (weak, nonatomic) IBOutlet UITableView *m_tableView;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDeliverPhone;

@property (weak, nonatomic) IBOutlet UILabel *m_lblDeliveryStatus;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgDeliveryService;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDeliveryService;
@property (strong, nonatomic) NSDateFormatter * dateFormat;

@end
