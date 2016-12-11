//
//  APSGiftCardVC.h
//  AppleSolutions
//
//  Created by Dennis Persson on 9/21/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Buy/Buy.h>
#import "APSCheckoutVC.h"
#import "APSGiftCardsVCDelegate.h"


@interface APSGiftCardVC : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *m_lblGiftAmount;
@property (weak, nonatomic) IBOutlet UILabel *m_lblTotalPrice;
@property (weak, nonatomic) IBOutlet UILabel *m_lblTotal;
@property (weak, nonatomic) IBOutlet UILabel *m_lblGiftApplied;
@property (weak, nonatomic) IBOutlet UILabel *m_lblPin;
@property (weak, nonatomic) IBOutlet UITextField *m_txtPin;
@property (weak, nonatomic) IBOutlet UIButton *m_btnBarCode;
@property (weak, nonatomic) BUYCheckout * checkout;
@property (nonatomic, assign) float giftCardsAmount;
@property (strong, nonatomic) NSString * giftCards;
@property (nonatomic, assign) id <APSGiftCardVCDelegate> delegate;

@end
