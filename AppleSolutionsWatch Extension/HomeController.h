//
//  HomeController.h
//  AppleSolutions
//
//  Created by Dennis Persson on 6/4/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "HomeRowController.h"

@interface HomeController : WKInterfaceController
@property (weak,nonatomic) IBOutlet WKInterfaceTable *homeTable;

@end
