//
//  APSTrackingStatusTVC.h
//  AppleSolutions
//
//  Created by Dennis Persson on 10/25/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APSTrackingStatusTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *m_lblDate;
@property (weak, nonatomic) IBOutlet UILabel *m_lblMessage;
@property (weak, nonatomic) IBOutlet UILabel *m_lblRegion;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgStatus;

@end
