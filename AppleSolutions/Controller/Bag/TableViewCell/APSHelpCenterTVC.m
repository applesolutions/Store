//
//  APSHelpCenterTVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 9/10/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSHelpCenterTVC.h"

@implementation APSHelpCenterTVC

- (void) awakeFromNib{
    [super awakeFromNib];
    self.m_btnCall.layer.borderColor = [UIColor colorWithWhite:0.72 alpha:1.0].CGColor;
    self.m_btnHelp.layer.borderColor = [UIColor colorWithWhite:0.72 alpha:1.0].CGColor;
    self.m_btnHelp.layer.borderWidth = 1;
    self.m_btnCall.layer.borderWidth = 1;
    self.m_btnHelp.layer.cornerRadius = 1;
    self.m_btnCall.layer.cornerRadius = 1;
    self.m_btnCall.titleLabel.text = NSLocalizedString(@"Call Us", nil);
    self.m_btnHelp.titleLabel.text = NSLocalizedString(@"Help", nil);
    self.m_lblDescription.preferredMaxLayoutWidth = self.m_lblDescription.frame.size.width;
}

@end
