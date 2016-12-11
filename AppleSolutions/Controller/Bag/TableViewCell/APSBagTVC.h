//
//  APSBagTVC.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/22/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APSBagTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *m_txtMessage;

@property (weak, nonatomic) IBOutlet UIImageView *m_imgProduct;
@property (weak, nonatomic) IBOutlet UILabel *m_lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *m_lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *m_lblNotes;
@property (weak, nonatomic) IBOutlet UIButton *m_btnNotes;
@property (weak, nonatomic) IBOutlet UITextView *m_textviewNotes;
@property (weak, nonatomic) IBOutlet UIButton *m_btnClear;
@property (weak, nonatomic) IBOutlet UIButton *m_btnSave;
@property (weak, nonatomic) IBOutlet UIView *m_viewNotesEdit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintNotesEditHeight;
@property (weak, nonatomic) IBOutlet UILabel * m_Description;
@property (weak, nonatomic) IBOutlet UIButton * m_btnAppleGiftMessage;
@property (weak, nonatomic) IBOutlet UIButton * m_btnFreeGiftMessage;
@property (weak, nonatomic) IBOutlet UIButton * m_btnGiftSave;
@property (weak,nonatomic) IBOutlet UIButton * m_btnGiftCancel;
@property (weak, nonatomic) IBOutlet UIView *m_giftMessageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * m_constraintGiftMessage;

@property (weak, nonatomic) IBOutlet UITextField *m_txtQuantity;
@property (assign, nonatomic) BOOL m_isEditingGift;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDeliveryCaption;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDeliveryDays;
@property (weak, nonatomic) IBOutlet UILabel *m_lblConfiguration;

@end
