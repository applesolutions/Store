//
//  APSTrackingListVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 9/30/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSTrackingListVC.h"
#import "Global.h"
#import "APSTrackingStatusVC.h"
@implementation APSTrackingListVC


- (void)viewDidLoad{
    self.tableView.allowsMultipleSelectionDuringEditing = NO;

    self.client = [AftershipClient clientWithApiKey:AFTERSHIP_CLIENT_ID];
  //  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
     UIButton *btnBuyNow = [UIButton buttonWithType:UIButtonTypeCustom];
     btnBuyNow.frame = CGRectMake(0, 0, 30, 25);
     btnBuyNow.layer.masksToBounds = NO;
     btnBuyNow.layer.cornerRadius = 3;
     btnBuyNow.layer.borderColor = APSUICOLOR_BLUE.CGColor;
     btnBuyNow.layer.borderWidth = 1;
     [btnBuyNow setTitle:NSLocalizedString(@"+", nil) forState:UIControlStateNormal];
     [btnBuyNow.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    
    
     [btnBuyNow setTitleColor:APSUICOLOR_BLUE forState:UIControlStateNormal];
     [btnBuyNow addTarget:self action:@selector(AddTracking:) forControlEvents:UIControlEventTouchUpInside];
     
     UIBarButtonItem *buyNowItem = [[UIBarButtonItem alloc] initWithCustomView:btnBuyNow];
    [self.navigationItem setTitle:@"Track n'Trace"];
    self.navigationItem.rightBarButtonItem = buyNowItem;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
}
-(void) viewWillAppear:(BOOL)animated{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSArray * trackingNums = [prefs objectForKey:@"tracking_numbers"];
    self.m_trackingNumbers =  [trackingNums mutableCopy];
    NSLog(@"Tracking %@", self.m_trackingNumbers);
    if (self.m_trackingNumbers == nil)
    {
        self.m_trackingNumbers = [[NSMutableArray alloc] init];
        [prefs setObject:self.m_trackingNumbers forKey:@"tracking_numbers"];
    }
    NSLog(@"Tracking %@", self.m_trackingNumbers);
    [self.tableView reloadData];

}
- (IBAction) AddTracking: (id) sender{
    UIStoryboard * main = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController * vc = [main instantiateViewControllerWithIdentifier:@"ADD_TRACKING"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.m_trackingNumbers.count;

}

- (UIImage * ) imageWithFileName: (NSString * ) fileName withSize: (float ) size{
    UIImage *thumbnail = [UIImage imageNamed:fileName];
    UIImage *result;
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [thumbnail drawInRect:imageRect];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    NSDictionary * orderTrack = [self.m_trackingNumbers objectAtIndex:indexPath.row];
    NSLog(@"dict %@", orderTrack);
   // UIImageView * imgCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    
    if (orderTrack){
        
        cell.textLabel.text = [orderTrack objectForKey:@"order_number"];
     
        
        cell.detailTextLabel.text = [orderTrack objectForKey:@"order_message"];
        
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica" size:11.0]];
        [cell.detailTextLabel setTextColor:[UIColor colorWithWhite:0.4 alpha:1.0]];
        NSString * status = [orderTrack objectForKey:@"order_status"];
        if ([status containsString:@"Delivered"])
        {
            [cell.imageView setImage: [self imageWithFileName:@"status-delivered" withSize:30] ];
          //  [imgCell setImage:[UIImage imageNamed:@"status-delivered" ]];
        }
        else if ([status containsString:@"InTransit"])
        {
            [cell.imageView setImage: [self imageWithFileName:@"status-delivered" withSize:30] ];

    //        [imgCell setImage:[UIImage imageNamed:@"status-in-transit" ]];
        }
        else if ([status containsString:@"InfoReceived"])
        {
            [cell.imageView setImage: [self imageWithFileName:@"status-info-receive" withSize:30] ];

            //[imgCell setImage:[UIImage imageNamed:@"status-info-receive" ]];
            
        }
        else if ([status containsString:@"Pending"])
        {
            [cell.imageView setImage: [self imageWithFileName:@"status-pending" withSize:30] ];

      //      [imgCell setImage:[UIImage imageNamed:@"status-pending" ]];
        }
        else if ([status containsString:@"OutForDelivery"])
        {
            [cell.imageView setImage: [self imageWithFileName:@"status-out-for-delivery" withSize:30] ];

      //      [imgCell setImage:[UIImage imageNamed:@"status-out-for-delivery" ]];
        }
        else if ([status containsString:@"AttemptFail"])
        {
            [cell.imageView setImage: [self imageWithFileName:@"status-attemptfail" withSize:30] ];

    //        [imgCell setImage:[UIImage imageNamed:@"status-attemptfail" ]];
        }
        else if ([status containsString:@"Exception"])
        {
            [cell.imageView setImage: [self imageWithFileName:@"status-exception" withSize:30] ];

    //        [imgCell setImage:[UIImage imageNamed:@"status-exception" ]];
        }
        else if ([status containsString:@"Expired"])
        {
            [cell.imageView setImage: [self imageWithFileName:@"status-expired" withSize:30] ];

     //       [imgCell setImage:[UIImage imageNamed:@"status-expired" ]];
        }
     ///   [cell.imageView setImage:[UIImage imageNamed:@"gls.png"]];

    }
   // [cell.imageView addSubview:imgCell];
    [cell setSeparatorInset:UIEdgeInsetsZero];

    return cell;
}

- (CGFloat)tableView: (UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * currentTracking = [self.m_trackingNumbers objectAtIndex:indexPath.row];

    
    AftershipGetTrackingsRequest *request = [AftershipGetTrackingsRequest requestWithCompletionBlock:^(AftershipGetTrackingsRequest* request, AftershipGetTrackingsResponse* response, NSError* error) {
       // NSLog(@"%@--- breaking", (response.trackings[0]));
        if (response.trackings.count>0){

        UIStoryboard * main = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        APSTrackingStatusVC * trackingVC = [main instantiateViewControllerWithIdentifier:@"OrderTrackView"];
        trackingVC.orderId = [self.m_trackingNumbers objectAtIndex:indexPath.row];
        
            NSLog(@"All trackings %@", response.trackings);
           // NSLog(@" tracking at index 1 %@", response.trackings[1]);

        trackingVC.currentTracking = response.trackings[0];
        //_currentTracking = response.trackings[0];
        NSLog(@"%@", (response.trackings[0]));
        //NSLog(@"Tracking Tag: %@", _currentTracking.tag);
        NSLog(@"Current Tracking Tag %@" ,trackingVC.currentTracking.tag );
        [self.navigationController pushViewController:trackingVC animated:YES];
            NSMutableDictionary * curTracking = [currentTracking mutableCopy];
            
            [curTracking setObject:trackingVC.currentTracking.tag forKey:@"order_status"];
            AftershipCheckpoint * lastCheckpoint = trackingVC.currentTracking.checkpoints[trackingVC.currentTracking.checkpoints.count-1];
            [curTracking setObject:lastCheckpoint.message forKey:@"order_message"];
            [self.m_trackingNumbers replaceObjectAtIndex:indexPath.row withObject:curTracking];
            
        }
        /*3564 - In transit
         3552 - Delivered
         3435 - Ready for pickup
         3567 - Info Received
         3592 - Pending*/
        
    }];
              NSLog(@"Tracking Current Dict %@", [self.m_trackingNumbers objectAtIndex:indexPath.row]);
    
    request.keyword = [currentTracking objectForKey:@"order_number"] ;
    NSLog(@"Request has keyword %@", request.keyword);
  //  request.keyword = [[self.m_trackingNumbers objectAtIndex:indexPath.row] objectForKey:@"order_number"];
    [self.client executeRequest:request];
    
      [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];

        [self.m_trackingNumbers removeObjectAtIndex: indexPath.row];
        [prefs setObject:self.m_trackingNumbers forKey:@"tracking_numbers"];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
@end
