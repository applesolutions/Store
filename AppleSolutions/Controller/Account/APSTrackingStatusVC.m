//
//  APSTrackingStatusVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 10/24/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//
#import "APSGenericFunctionManager.h"
#import "APSTrackingStatusVC.h"
#import "Global.h"
#import "APSTrackingStatusTVC.h"
#import "APSTrackingInfoVC.h"
@interface APSTrackingStatusVC () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSDateFormatter * df;


@end

@implementation APSTrackingStatusVC


- (void) viewWillAppear:(BOOL)animated{
    _df = [[NSDateFormatter alloc] init];
    [_df setDateFormat:@"MMM dd, yyyy hh:mm a"];
    
    
  /*  if ([self.m_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.m_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.m_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.m_tableView setLayoutMargins:UIEdgeInsetsZero];
    }*/
    if ([_currentTracking.slug containsString:@"gls"])
    {    [self.m_imgDeliveryService setImage: [UIImage imageNamed: @"gls"]];
          self.m_lblDeliveryService.text = @"GLS";
        [self.m_btnPhoneNumber setTitle:@"+45 76 33 11 11" forState:UIControlStateNormal];
    }
    else   if ([_currentTracking.slug containsString:@"posten-norge"])
    {    [self.m_imgDeliveryService setImage: [UIImage imageNamed: @"posten-norge"]];
        self.m_lblDeliveryService.text = @"Posten Norge";
        [self.m_btnPhoneNumber setTitle:@"+46 771-33 33 10" forState:UIControlStateNormal];

    }
    else   if ([_currentTracking.slug containsString:@"postnord"])
    {    [self.m_imgDeliveryService setImage: [UIImage imageNamed: @"PostNord"]];
        self.m_lblDeliveryService.text = @"PostNord";
        
        [self.m_btnPhoneNumber setTitle:@"+45 70 70 70 30" forState:UIControlStateNormal];

    }
    else   if ([_currentTracking.slug containsString:@"danmark-post"])
    {    [self.m_imgDeliveryService setImage: [UIImage imageNamed: @"PostDanmark"]];
        self.m_lblDeliveryService.text = @"DanmarkPost";
        [self.m_btnPhoneNumber setTitle:@"+45 70 70 70 30" forState:UIControlStateNormal];

    }
    else   if ([_currentTracking.slug containsString:@"dhl"])
    {    [self.m_imgDeliveryService setImage: [UIImage imageNamed: @"dhl"]];
        self.m_lblDeliveryService.text = @"DHL";
        [self.m_btnPhoneNumber setTitle:@"+45 70 34 53 45" forState:UIControlStateNormal];

    }
    else   if ([_currentTracking.slug containsString:@"sweden-posten"])
    {    [self.m_imgDeliveryService setImage: [UIImage imageNamed: @"sweden-posten"]];
        self.m_lblDeliveryService.text = @"Sweden Posten";
        [self.m_btnPhoneNumber setTitle: @"+45 70 28 60 70" forState:UIControlStateNormal];

    }
    
    _m_lblDeliveryStatus.text = NSLocalizedString(_currentTracking.tag, nil);
    if ([_currentTracking.tag containsString:@"Delivered"])
    {
        
        [self.m_lblDeliveryStatus setBackgroundColor:[UIColor colorWithRed:0 green:0.7411 blue:0.521 alpha:1.0]];
    }
    else if ([_currentTracking.tag containsString:@"Pending"])
    {
        [self.m_lblDeliveryStatus setBackgroundColor:[UIColor colorWithRed:0.8039 green:0.8039 blue:0.8039 alpha:1.0]];
        
        //green - 0,189,133
        //out for deliver - 255, 167,73
        //pending - 205,205,205
        //info received, 0,72,122
        //in transit = 26,176,227
        //expired: 91,110,127
        //exception: 239,103,88
        //
    }
    else if ([_currentTracking.tag containsString:@"InTransit"])
    {
        [self.m_lblDeliveryStatus setBackgroundColor:[UIColor colorWithRed:0.1019 green:0.6901 blue:0.8901 alpha:1.0]];
    }
    else if ([_currentTracking.tag containsString:@"InfoReceived"])
    {
        [self.m_lblDeliveryStatus setBackgroundColor:[UIColor colorWithRed:0 green:0.2823 blue:0.4784 alpha:1.0]];
    }
    else if ([_currentTracking.tag containsString:@"OutForDelivery"])
    {
        [self.m_lblDeliveryStatus setBackgroundColor:[UIColor colorWithRed:1.0 green:0.6549 blue:0.2862 alpha:1.0]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btnBuyNow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBuyNow.frame = CGRectMake(0, 0, 30, 25);
    btnBuyNow.layer.masksToBounds = NO;
    btnBuyNow.layer.cornerRadius = 3;
    btnBuyNow.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    btnBuyNow.layer.borderWidth = 1;
    [btnBuyNow setTitle:NSLocalizedString(@"i", nil) forState:UIControlStateNormal];
    [btnBuyNow.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    
    [btnBuyNow setTitleColor:APSUICOLOR_BLUE forState:UIControlStateNormal];
    [btnBuyNow addTarget:self action:@selector(onBtnInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buyNowItem = [[UIBarButtonItem alloc] initWithCustomView:btnBuyNow];
    self.navigationItem.rightBarButtonItem = buyNowItem;
    [self.btnCopyURL setTitle:NSLocalizedString(@"Copy URL", nil) forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view.
    
}

- (IBAction) onBtnInfo: (id) sender{
    APSTrackingInfoVC * vc = [[APSTrackingInfoVC alloc] init];
    vc.currentTracking = self.currentTracking;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"total checkpoints %ld", _currentTracking.checkpoints.count);
    
    //NSLog(@"Cell for row %ld", indexPath.row);
    APSTrackingStatusTVC * cell = [tableView dequeueReusableCellWithIdentifier:@"TrackingStatusCell"];
    AftershipCheckpoint * currentCheckpoint = [_currentTracking.checkpoints objectAtIndex: (_currentTracking.checkpoints.count -1) - indexPath.row];
    cell.m_lblDate.text = [_df stringFromDate:currentCheckpoint.createTime];
    

    cell.m_lblRegion.text = [NSString stringWithFormat:@"%@", currentCheckpoint.location ];
    cell.m_lblMessage.text = currentCheckpoint.message;
    
    NSString * status = currentCheckpoint.tag;
    
    if ([status containsString:@"Delivered"])
    {
        [cell.m_imgStatus setImage:[UIImage imageNamed:@"status-delivered" ]];
    }
    else if ([status containsString:@"InTransit"])
    {
        [cell.m_imgStatus setImage:[UIImage imageNamed:@"status-in-transit" ]];
    }
    else if ([status containsString:@"InfoReceived"])
    {
        [cell.m_imgStatus setImage:[UIImage imageNamed:@"status-info-receive" ]];

    }
    else if ([status containsString:@"Pending"])
    {
        [cell.m_imgStatus setImage:[UIImage imageNamed:@"status-pending" ]];
    }
    else if ([status containsString:@"OutForDelivery"])
    {
        [cell.m_imgStatus setImage:[UIImage imageNamed:@"status-out-for-delivery" ]];
    }
    else if ([status containsString:@"AttemptFail"])
    {
        [cell.m_imgStatus setImage:[UIImage imageNamed:@"status-attemptfail" ]];
    }
    else if ([status containsString:@"Exception"])
    {
        [cell.m_imgStatus setImage:[UIImage imageNamed:@"status-exception" ]];
    }
    else if ([status containsString:@"Expired"])
    {
        [cell.m_imgStatus setImage:[UIImage imageNamed:@"status-expired" ]];
    }

    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _currentTracking.checkpoints.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}
- (IBAction)onBtnCopyUrl:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    NSString * copyUrl = [NSString stringWithFormat:@"http://spor.applesolutions.io/%@/%@",_currentTracking.slug,_currentTracking.trackingNumber ];
    pasteboard.string = copyUrl;
    [APSGenericFunctionManager showAlertWithMessage:[NSString stringWithFormat:@"Tracking link is copied %@",copyUrl]];
    
}

- (IBAction)onBtnDeliveryCall:(id)sender {
    NSString *phNo = self.m_btnPhoneNumber.currentTitle;
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        [APSGenericFunctionManager showAlertWithMessage:@"Call facility is not available!"];
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
