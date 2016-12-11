//
//  APSMobilePayInfoVC.h
//  AppleSolutions
//
//  Created by Dennis Persson on 8/18/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APSMobilePayInfoTVC.h"

@interface APSMobilePayInfoVC : UITableViewController
@property (weak, nonatomic) IBOutlet UITableView * m_tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *m_titleLbl;
//@property (weak, nonatomic) IBOutlet UILabel * DeliveryInStock;

@property (strong, nonatomic)NSArray * fields;
@property (weak, nonatomic)NSArray *sections;
@property (strong, nonatomic) NSMutableDictionary * userData;
@property (nonatomic, assign) BOOL isBusinessUser;

- (void) configureCell: (APSMobilePayInfoTVC *) infoCell AtIndexPath: (NSIndexPath *) indexPath;
@property (strong, nonatomic) UIView * header;
@end
