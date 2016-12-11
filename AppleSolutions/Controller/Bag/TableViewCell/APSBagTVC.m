//
//  APSBagTVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/22/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSBagTVC.h"
#import "Global.h"

@implementation APSBagTVC

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.m_btnAppleGiftMessage.layer.borderColor = [[UIColor colorWithWhite:0.9 alpha:1.0] CGColor];
    self.m_btnFreeGiftMessage.layer.borderColor = [[UIColor colorWithWhite:0.9 alpha:1.0] CGColor];
    self.m_btnGiftCancel.layer.borderWidth = 1;
    self.m_btnGiftSave.layer.borderWidth = 2;
    self.m_btnGiftSave.layer.cornerRadius = 6;
    self.m_btnGiftCancel.layer.cornerRadius = 6;
    self.m_btnGiftCancel.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    self.m_btnGiftSave.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    
    self.m_btnFreeGiftMessage.layer.borderWidth = 2;
    self.m_btnAppleGiftMessage.layer.borderWidth = 2;
    self.m_btnFreeGiftMessage.layer.cornerRadius = 6;
    self.m_btnAppleGiftMessage.layer.cornerRadius = 6;
    UIImageView * imgFreeMessage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"free-giftmessage"]];
    [imgFreeMessage setFrame:CGRectMake(10 ,15, 35, 35)];
    imgFreeMessage.contentMode = UIViewContentModeScaleAspectFill;
    [self.m_btnFreeGiftMessage addSubview:imgFreeMessage];
    UIImageView * imgAppleMessage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"apple-giftmessage"]];
    [imgAppleMessage setFrame:CGRectMake(10 ,15, 35, 35)];
    imgAppleMessage.contentMode = UIViewContentModeScaleAspectFill;
    [self.m_btnAppleGiftMessage addSubview:imgAppleMessage];
    self.m_isEditingGift = NO;
    

    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
}

@end
