//
//  EventsController.m
//  AppleSolutions
//
//  Created by Dennis Persson on 6/3/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "EventsController.h"
#import "EventsRowController.h"
@interface EventsController ()

@end

@implementation EventsController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [[self eventsTable] setNumberOfRows:3 withRowType:@"eventsRowController"];
    
    for (NSInteger i = 0 ; i< self.eventsTable.numberOfRows; i++)
    {
        EventsRowController * theRow = [self.eventsTable rowControllerAtIndex:i];
        NSString * eventTitle = [NSString stringWithFormat:@"New Event %d",i];
        
        [theRow.eventTitle setText: eventTitle];
    }
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



