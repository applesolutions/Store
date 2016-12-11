//
//  EventsRowController.h
//  AppleSolutions
//
//  Created by Dennis Persson on 6/3/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//
#import <WatchKit/WatchKit.h>

#import <Foundation/Foundation.h>

@interface EventsRowController : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* eventTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* eventTime;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* eventLocation;

@end
