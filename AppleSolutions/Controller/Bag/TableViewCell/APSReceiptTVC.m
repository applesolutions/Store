//
//  APSReceiptTVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 8/20/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSReceiptTVC.h"

@implementation APSReceiptTVC

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];

}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.preservesSuperviewLayoutMargins = NO;
        [self setLayoutMargins:UIEdgeInsetsZero];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
