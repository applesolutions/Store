//
//  APSAddTrackingVC.m
//  AppleSolutions
//
//  Created Dennis Persson on 9/30/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSAddTrackingVC.h"
#import "Global.h"
#import "Aftership.h"
#import "APSTrackingStatusVC.h"

@implementation APSAddTrackingVC

- (void) viewDidLoad{
   
    /*3549
     3480
     3434A
     3544*/
    
    UIButton *btnBuyNow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBuyNow.frame = CGRectMake(0, 0, 60, 25);
    btnBuyNow.layer.masksToBounds = NO;
    btnBuyNow.layer.cornerRadius = 3;
    btnBuyNow.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    btnBuyNow.layer.borderWidth = 1;
    [btnBuyNow setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
    [btnBuyNow.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]];
    
    [btnBuyNow setTitleColor:APSUICOLOR_BLUE forState:UIControlStateNormal];
    [btnBuyNow addTarget:self action:@selector(Done:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buyNowItem = [[UIBarButtonItem alloc] initWithCustomView:btnBuyNow];
    self.navigationItem.rightBarButtonItem = buyNowItem;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.navigationItem setTitle: NSLocalizedString(@"Enter order number",nil)];
    
}

- (IBAction)Done:(id)sender{
    
    
   AftershipClient * client = [AftershipClient clientWithApiKey:AFTERSHIP_CLIENT_ID];

    AftershipGetTrackingsRequest *request = [AftershipGetTrackingsRequest requestWithCompletionBlock:^(AftershipGetTrackingsRequest* request, AftershipGetTrackingsResponse* response, NSError* error) {
        // NSLog(@"%@--- breaking", (response.trackings[0]));
        if (response.trackings.count>0){
            
            
            NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
            NSArray * track = [prefs objectForKey:@"tracking_numbers"];
            NSMutableArray * trackingNumbers = [track mutableCopy];
            
            AftershipTracking * aftershipTrack = response.trackings[0];
            
            AftershipCheckpoint * lastCheckpoint = aftershipTrack.checkpoints[aftershipTrack.checkpoints.count-1];
            
            NSDictionary * trackingOrder = [[NSDictionary alloc] initWithObjects:@[self.m_txtOrderNum.text,aftershipTrack.tag,lastCheckpoint.message] forKeys:@[@"order_number",@"order_status",@"order_message" ]];
            [trackingNumbers addObject:trackingOrder];
            [prefs setObject:trackingNumbers forKey:@"tracking_numbers"];
            NSLog(@"All trackings %@", response.trackings);
            
        }
        else
        {
        
        }
        [self.navigationController popViewControllerAnimated:YES];

        
    }];
    request.keyword = self.m_txtOrderNum.text;
    NSLog(@"Request has keyword %@", request.keyword);
    [client executeRequest:request];
    
 //   NSLog(@"Text %@", self.m_txtOrderNum.text);
   
  //  UIStoryboard * main = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
   // APSTrackingStatusVC * trackingVC = [main instantiateViewControllerWithIdentifier:@"OrderTrackView"];
    //trackingVC.orderId = self.m_txtOrderNum.text;
    
    //NSLog(@"Dictionary %@", trackingOrder);
    //NSLog(@"Tracking numbers %@", trackingNumbers);
    
}
-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    view.tintColor = [UIColor clearColor];
}

@end
