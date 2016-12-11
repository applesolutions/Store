//
//  APSGenericFunctionManager.h
//  AppleSolutions
//
//  Created by Chris Lin on 11/13/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APSGenericFunctionManager : NSObject

+ (NSString *)getUUID;
+ (NSString *) getAppVersionString;
+ (NSString *) getAppBuildString;

#pragma mark -String Manipulation

+ (NSString *) refineNSString: (NSString *)sz;
+ (int) getWeekdayForToday;
+ (BOOL) isValidEmailAddress: (NSString *) candidate;
+ (BOOL) isValidString: (NSString *) candidate;

+ (NSString *) beautifyPhoneNumber :(NSString *)szOriginalPhoneNumber isBackspace:(BOOL) isBackspace;
+ (NSString *) getLongStringFromDate: (NSDate *) dt;
+ (NSString *) getDateStringRepresentation: (NSDate *) dt;
+ (NSDate *) getDateFromString: (NSString *) sz;
+ (NSString *) stripNonnumericsFromNSString :(NSString *) sz;
+ (NSString *) beautifyPrice: (float) price;

#pragma mark -UI

+ (UITableView *)getTableViewFromCell: (UITableViewCell *)cell ;
+ (CGRect) getAttributedStringBounding: (NSAttributedString *) attributedText Width: (int) width;
+ (void) showAlertWithMessage: (NSString *) szMessage;
+ (void) showPromptViewWithTitle: (NSString *) title CancelButtonTitle: (NSString *) cancelButtonTitle OtherButtonTitle: (NSString *) otherButtonTitle Tag: (int) tag Delegate: (id) delegate;
+ (NSMutableAttributedString *) generateAttributedStringForLabelFromPList: (NSString *) plist;
//+ (void) setUIImageView: (UIImageView *) imageView WithUrl: (NSString *) url DefaultImage: (NSString *) imageDefault;

#pragma mark -Utils

+ (NSString *) getJSONStringRepresentation: (id) object;

@end
