//
//  APSTrackingInfoVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 10/27/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSTrackingInfoVC.h"

@interface APSTrackingInfoVC ()

@end

@implementation APSTrackingInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem setTitle:_currentTracking.title];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame: CGRectZero]];
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.93 alpha:1.0]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 4;
    return 2;
}

- (UIImage * ) imageWithFileName: (NSString * ) fileName withSize: (float ) size{
    UIImage *thumbnail = [UIImage imageNamed:fileName];
    UIImage *result;
    CGSize itemSize = CGSizeMake(size, size);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [thumbnail drawInRect:imageRect];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    switch (indexPath.row) {
        case 0:
            if (indexPath.section == 0){
            [cell.detailTextLabel setText:_currentTracking.trackingNumber];
            [cell.imageView setImage:[self imageWithFileName:@"tracking" withSize:40]];
            }
            
            else
            {
                [cell.textLabel setText:NSLocalizedString(@"Latest Status", nil)];
                [cell.detailTextLabel setText:NSLocalizedString(_currentTracking.tag,nil)];
                
            }
            break;
        case 1:
            if (indexPath.section == 0) {
                [cell.imageView setImage:[self imageWithFileName:@"truck" withSize:40]];
            [cell.detailTextLabel setText:[_currentTracking.slug uppercaseString]];
            }
            else{
                [cell.textLabel setText:NSLocalizedString(@"Shipment Type", nil)];
                [cell.detailTextLabel setText:_currentTracking.shipmentType];
                
            }
            break;
        case 2:
            if ([_currentTracking.slug containsString:@"gls"])
            {
                [cell.detailTextLabel setText:@"+45 76 33 11 11" ];
            }
            else   if ([_currentTracking.slug containsString:@"posten-norge"])
            {    [cell.detailTextLabel setText:@"+46 771-33 33 10" ];

            }
            else   if ([_currentTracking.slug containsString:@"postnord"])
            {
                 [cell.detailTextLabel setText:@"+45 70 70 70 30" ];

            }
            else   if ([_currentTracking.slug containsString:@"danmark-post"])
            {
                [cell.detailTextLabel setText:@"+45 70 70 70 30" ];

            }
            else   if ([_currentTracking.slug containsString:@"dhl"])
            {   [cell.detailTextLabel setText:@"+45 70 34 53 45" ];

            }
            else   if ([_currentTracking.slug containsString:@"sweden-posten"])
            {   [cell.detailTextLabel setText:@"+45 70 28 60 70" ];

            }
            [cell.imageView setImage:[self imageWithFileName:@"phone" withSize:35]];
            break;
        case 3:
            [cell.imageView setImage:[self imageWithFileName:@"label" withSize:40]];
            [cell.detailTextLabel setText:_currentTracking.title];
            break;
        case 4:
          break;
        case 5:
            break;
        default:
            break;
    }
    [cell setSeparatorInset:UIEdgeInsetsZero];
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
 1. Looking these issues
 a)This app attempts to access privacy-sensitive data without a usage description. The app's Info.plist must contain an NSPhotoLibraryUsageDescription key with a string value explaining to the user how the app uses this data.
 
 b)This app attempts to access privacy-sensitive data without a usage description. The app's Info.plist must contain an NSBluetoothPeripheralUsageDescription key with a string value explaining to the user how the app uses this data.
 
 c)This app attempts to access privacy-sensitive data without a usage description. The app's Info.plist must contain an NSCameraUsageDescription key with a string value explaining to the user how the app uses this data.
'Attempted to start scanning on a device with no camera. Check requestCameraPermissionWithSuccess: method before calling startScanningWithResultBlock:'
 
 */
@end
