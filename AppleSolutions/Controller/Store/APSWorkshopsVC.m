//
//  APSWorkshopsVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 12/17/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSWorkshopsVC.h"

@interface APSWorkshopsVC ()

@property (weak, nonatomic) IBOutlet UIWebView *m_webview;

@end

@implementation APSWorkshopsVC

- (void) viewDidLoad{
    [super viewDidLoad];
    [self refreshFields];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void) refreshFields{
    [self.m_webview loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://dk.applesolutions.io/blogs/nyheder/"]]];
}

@end
