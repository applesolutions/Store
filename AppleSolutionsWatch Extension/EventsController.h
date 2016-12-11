//
//  EventsController.h
//  AppleSolutions
//
//  Created by Dennis Persson on 6/3/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface EventsController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceTable* eventsTable;

@end
