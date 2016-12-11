//
//  HomeController.m
//  AppleSolutions
//
//  Created by Dennis Persson on 6/4/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "HomeController.h"

@interface HomeController ()

@end

@implementation HomeController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self.homeTable setNumberOfRows:2 withRowType:@"homeRowController"];
    
    HomeRowController * storeRow = [self.homeTable rowControllerAtIndex:0];
    [storeRow.lblRow setText:@"Nearest Store"];
    [storeRow.imgRow setImage:[UIImage imageNamed: @"stores-findstore" ]];
    HomeRowController * workshopRow = [self.homeTable rowControllerAtIndex:1];
    [workshopRow.lblRow setText:@"Events & Workshops"];
    [workshopRow.imgRow setImage:[UIImage imageNamed:@"stores-workshops"] ];
    
    
    // Configure interface objects here.
}

- (void) table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    if (rowIndex == 0)
        [self presentControllerWithName:@"nearestStore" context:@"0"];
    else if (rowIndex == 1)
             [self presentControllerWithName:@"eventsScreen" context:@"1"];
    
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



