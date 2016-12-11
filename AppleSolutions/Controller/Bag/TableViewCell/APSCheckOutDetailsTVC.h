//
//  APSCheckOutDetailsTVC.h
//  AppleSolutions
//
//  Created by Dennis Persson on 9/8/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APSCheckOutDetailsTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *m_imgProduct;
@property (weak, nonatomic) IBOutlet UILabel *m_lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *m_lblTitle;

@property (weak, nonatomic) IBOutlet UIButton *m_btnHideDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintNotesEditHeight;
@property (weak, nonatomic) IBOutlet UILabel * m_Description;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * m_constraintGiftMessage;

@property (weak, nonatomic) IBOutlet UITextField *m_txtQuantity;
@property (assign, nonatomic) BOOL m_descriptionHidden;
@property (weak, nonatomic) IBOutlet UILabel * lblQuantity;
@property (weak, nonatomic) IBOutlet UILabel * lblConfiguration;


@end
