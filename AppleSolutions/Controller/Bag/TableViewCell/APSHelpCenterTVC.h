//
//  APSHelpCenterTVC.h
//  AppleSolutions
//
//  Created by Dennis Persson on 9/10/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APSHelpCenterTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel * m_lblDescription;
@property (weak, nonatomic) IBOutlet UIButton * m_btnHelp;
@property (weak, nonatomic) IBOutlet UIButton * m_btnCall;

@end
