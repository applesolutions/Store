//
//  InterfaceController.h
//  AppleSolutionsWatch Extension
//
//  Created by Dennis Persson on 6/2/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* orderLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* workshopLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* nearestLabel;

@end
