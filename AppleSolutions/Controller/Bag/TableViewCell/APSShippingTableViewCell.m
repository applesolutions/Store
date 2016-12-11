//
//  APSShippingTableViewCell.m
//  AppleSolutions
//
//  Created by Dennis Persson on 8/19/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSShippingTableViewCell.h"

@implementation APSShippingTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

@end
