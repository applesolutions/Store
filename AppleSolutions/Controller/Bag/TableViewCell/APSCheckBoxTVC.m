//
//  APSCheckBoxTVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 8/25/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSCheckBoxTVC.h"

@implementation APSCheckBoxTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.m_switch= [[UISwitch alloc] init];
        self.m_label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.bounds.size.width-80, self.bounds.size.height)];
        [self addSubview:self.m_label];
        
        [self addSubview:self.m_switch];
        self.preservesSuperviewLayoutMargins = NO;
        [self setLayoutMargins:UIEdgeInsetsZero];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.m_switch.translatesAutoresizingMaskIntoConstraints = NO;
      //  self.m_label.translatesAutoresizingMaskIntoConstraints = NO;
        self.m_label.text = @"THis is a test";
        self.m_label.numberOfLines = 0;
        [self.m_switch.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-15].active = YES;
      //  [self.m_label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15].active = YES;
        //[self.m_label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.m_switch.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.m_switch setOn:YES];
        
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
