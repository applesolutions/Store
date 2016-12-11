//
//  APSGiftCardsVCDelegate.h
//  AppleSolutions
//
//  Created by Dennis Persson on 9/23/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol APSGiftCardVCDelegate <NSObject>

@optional
- (void) APSGiftCardDismissWithData: (NSDictionary *) data;
@end
