//
//  APSGenericFunctionManager.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/13/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSGenericFunctionManager.h"
#import <AFNetworking.h>

@implementation APSGenericFunctionManager

+ (NSString *)getUUID {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSString *) getAppVersionString{
    NSString *szVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return szVersion;
}

+ (NSString *) getAppBuildString{
    NSString *szVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    return szVersion;
}

#pragma mark -String Manipulation

+ (NSString *) refineNSString: (NSString *)sz{
    NSString *szResult = @"";
    if ((sz == nil) || ([sz isKindOfClass:[NSNull class]] == YES)) szResult = @"";
    else szResult = [NSString stringWithFormat:@"%@", sz];
    return szResult;
}

+ (int) getWeekdayForToday{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [cal components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    int weekday = (int) [comp weekday];     // Sunday: 1, Monday: 2, ...
    return (weekday - 1);
}
+ (BOOL) isValidString: (NSString *) candidate{
    return (candidate.length > 2);
    

    
}
+ (BOOL) isValidEmailAddress: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

+ (NSString *) beautifyPhoneNumber :(NSString *)szOriginalPhoneNumber isBackspace:(BOOL) isBackspace{
    NSString *szPhoneNumber = szOriginalPhoneNumber;
    szPhoneNumber = [[szPhoneNumber componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    if (szPhoneNumber.length == 0) return @"";
    
    NSString *szResult = @"(";
    szResult = [szResult stringByAppendingString: [szPhoneNumber substringWithRange:NSMakeRange(0, MIN(3, szPhoneNumber.length))]];
    if (szPhoneNumber.length <= 3 && isBackspace == YES) return szResult;
    if (szPhoneNumber.length < 3 && isBackspace == NO) return szResult;
    
    szResult = [NSString stringWithFormat:@"%@) %@", szResult, [szPhoneNumber substringWithRange:NSMakeRange(3, MIN(3, szPhoneNumber.length - 3))]];
    if (szPhoneNumber.length <= 6 && isBackspace == YES) return szResult;
    if (szPhoneNumber.length < 6 && isBackspace == NO) return szResult;
    
    szResult = [NSString stringWithFormat:@"%@-%@", szResult, [szPhoneNumber substringWithRange:NSMakeRange(6, MIN(4, szPhoneNumber.length - 6))]];
    return szResult;
}

+ (NSString *) stripNonnumericsFromNSString :(NSString *) sz{
    NSString *szResult = sz;
    
    szResult = [[szResult componentsSeparatedByCharactersInSet: [[NSCharacterSet characterSetWithCharactersInString:@"0123456789*●"] invertedSet]] componentsJoinedByString:@""];
    return szResult;
}

+ (NSString *) getLongStringFromDate: (NSDate *) dt{
    if (dt == nil) return @"";
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:dt];
    return [NSString stringWithFormat:@"%02d-%02d-%04dT%02d:%02d", (int) dateComps.month, (int) dateComps.day, (int) dateComps.year, (int) dateComps.hour,  (int) dateComps.minute];
}

+ (NSDate *) getDateFromString: (NSString *) sz{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormatter dateFromString:sz];
    return date;
}

+ (NSString *) getDateStringRepresentation: (NSDate *) dt{
    if (dt == nil) return @"";
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:dt];
    return [NSString stringWithFormat:@"%d/%d/%d", (int) dateComps.month, (int) dateComps.day, (int) dateComps.year];
}

+ (NSString *) beautifyPrice: (float) price{
    // 6999 => 6.999 kr.
    // 1234567.99 => 1.234.567 kr.
    
    int p = (int) price;
    NSString *sz = @"";
    while (p >= 1000){
        sz = [NSString stringWithFormat:@".%03d%@", (p % 1000), sz];
        p = p / 1000;
    }
    sz = [NSString stringWithFormat:@"%d%@ kr.", p, sz];
    return sz;
}

#pragma mark -UI

+ (UITableView *)getTableViewFromCell: (UITableViewCell *)cell {
    UIView *superView = cell.superview;
    while (superView && ![superView isKindOfClass:[UITableView class]]) {
        superView = superView.superview;
    }
    if (superView) {
        return (UITableView *)superView;
    }
    return nil;
}

+ (CGRect) getAttributedStringBounding: (NSAttributedString *) attributedText Width: (int) width{
    CGRect rc = [attributedText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             context:nil];
    return rc;
}

+ (void) showAlertWithMessage: (NSString *) szMessage{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:szMessage message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void) showPromptViewWithTitle: (NSString *) title CancelButtonTitle: (NSString *) cancelButtonTitle OtherButtonTitle: (NSString *) otherButtonTitle Tag: (int) tag Delegate: (id) delegate{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    alertView.tag = tag;
    
    [alertView show];
}

+ (NSMutableAttributedString *) generateAttributedStringForLabelFromPList: (NSString *) plist{
    NSString *path = [[NSBundle mainBundle] pathForResource: plist ofType:@"plist"];
    NSArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:path];
    NSMutableAttributedString *attrContents = [[NSMutableAttributedString alloc] init];
    
    for (int i = 0; i < (int) [arr count]; i++){
        NSDictionary *dict = [arr objectAtIndex:i];
        NSString *font = [dict objectForKey:@"_FONT"];
        int size = [[dict objectForKey:@"_SIZE"] intValue];
        NSString *contents = [dict objectForKey:@"_CONTENTS"];
        NSDictionary *dictColor = [dict objectForKey:@"_COLOR"];
        int colorR = 0, colorG = 0, colorB = 0;
        
        if (dictColor != nil && [dictColor isKindOfClass:[NSNull class]] == NO){
            colorR = [[dictColor objectForKey:@"_R"] intValue];
            colorG = [[dictColor objectForKey:@"_G"] intValue];
            colorB = [[dictColor objectForKey:@"_B"] intValue];
        }
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n \n", contents] attributes:@{NSFontAttributeName: [UIFont fontWithName:font size:size], NSForegroundColorAttributeName: [UIColor colorWithRed:colorR green:colorG blue:colorB alpha:1]}];
        [attrContents appendAttributedString:attrString];
    }
    return attrContents;
}

//+ (void) setUIImageView: (UIImageView *) imageView WithUrl: (NSString *) url DefaultImage: (NSString *) imageDefault{
//    if (imageDefault != nil){
//        [imageView setImage:[UIImage imageNamed:imageDefault]];
//    }
//    else{
//        [imageView setImage:nil];
//    }
//    
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    AFHTTPRequestOperation *reqOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
//    reqOperation.responseSerializer = [AFImageResponseSerializer serializer];
//    [reqOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
//        [imageView setImage:responseObject];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
//        NSLog(@"%@", error);
//    }];
//    [reqOperation start];
//}

#pragma mark -Utils

+ (NSString *) getJSONStringRepresentation: (id) object{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    NSString *szResult = @"";
    if (!jsonData){
        NSLog(@"Error while serializing customer details into JSON\r\n%@", error.localizedDescription);
    }
    else{
        szResult = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return szResult;
}


@end
