//
//  APSShippingRatesViewController.m
//  AppleSolutions
//
//  Created by Dennis Persson on 8/19/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//
#import "APSShippingRatesViewController.h"
#import "Global.h"
#import "APSShippingTableViewCell.h"
#import "APSReceiptVC.h"
@interface APSShippingRatesViewController ()
@property (strong, nonatomic) NSArray * shippingRates;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (weak, nonatomic) IBOutlet UITableView * m_tableView;

- (void) loadShippingRates;
@end

@implementation APSShippingRatesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadShippingRates];
    [self.tableView registerClass:[APSShippingTableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.title = NSLocalizedString(@"Shipping Rates",nil);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) loadShippingRates{
    
    APSShopifyBuyManager * manager = [APSShopifyBuyManager sharedInstance];
    self.currencyFormatter = [[NSNumberFormatter alloc] init];
    self.currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    self.currencyFormatter.currencyCode = manager.m_shop.currency;
    
    
    [manager buildCartFromBag];

  // NSLog(@"email %@",[self.userData objectForKey:@"Email"]);
    //[manager requestCreateCheckoutWithCallback:^(int status)
    [manager requestCreateCheckoutWithEmail:[self.userData objectForKey:NSLocalizedString(@"Email",nil)] ShippingAddress:self.shippingAddress Callback:^(int status)
    {
        if (status == ERROR_NONE)
        {
            
                {
                [manager.m_client getShippingRatesForCheckoutWithToken:manager.m_checkout.token completion:^(NSArray<BUYShippingRate *> * _Nullable shippingRates, BUYStatus status, NSError * _Nullable error) {
                    NSLog(@"Error in shipping %@", error);
                    NSLog(@"Shipping rates %@",shippingRates);
                    // [self setShippingRates:shippingRates];
                    if (error == nil)
                    {
                        self.shippingRates = shippingRates;
                        [self.tableView reloadData];
                    }
                }];}
 
            
            NSLog(@"created successfully %@", manager.m_checkout.token);
                   }
        NSLog(@"Status is %d", status);
    }];
    

    /*
    BUYCheckout *checkout = [manager.m_client.modelManager checkoutWithCart:manager.m_cart];
    checkout.shippingAddress = self.shippingAddress;
    checkout.email = [self.userData objectForKey:@"Email"];
    
    [manager.m_client createCheckout:checkout completion:^(BUYCheckout * _Nullable checkout, NSError * _Nullable error) {
        if (error == nil && checkout)
        {}
        else
        {
            NSLog(@"Error is %@", error);
            
        }
    }];
    //[bagManager getShippingRates:^(NSDictionary * shippingRates) {
      //  NSLog(@"got it");
    //}];
    [manager.m_client getShippingRatesForCheckoutWithToken:manager.m_checkout.token completion:^(NSArray<BUYShippingRate *> * _Nullable shippingRates, BUYStatus status, NSError * _Nullable error) {
       if ([shippingRates count ] > 0 && !error)
       {
           self.shippingRates = shippingRates;
           [self.tableView reloadData];
       }
        else
        {
            NSLog(@"Failed %@", error);
            
        }
    }];*/
    
    
}



#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    APSShopifyBuyManager * manager = [APSShopifyBuyManager sharedInstance];
    BUYShippingRate *selectedShippingRate = self.shippingRates[indexPath.row];
   manager.m_checkout.shippingRate = selectedShippingRate;
   if ([selectedShippingRate.price compare:[NSNumber numberWithInt:0] ] == NSOrderedSame)
   {
       [self.userData setObject:@"Zero" forKey:@"ShippingMethod"];
   }
   else
       [self.userData setObject:@"Amount" forKey:@"ShippingMethod"];

    
   [manager.m_client updateCheckout:manager.m_checkout completion:^(BUYCheckout * _Nullable checkout, NSError * _Nullable error) {
      if (error == nil && checkout)
      {
          
       
          manager.m_checkout = checkout;
       /*   APSReceiptVC * apsReceiptVC = [[APSReceiptVC alloc] initWithCheckout: checkout UserData: self.userData];
          apsReceiptVC.currencyFormatter = self.currencyFormatter;
          
          //apsReceiptVC.userData = self.userData;
      
          apsReceiptVC.isBusinessUser = self.isBusinessUser;
          
          [self.navigationController pushViewController:apsReceiptVC animated:YES];*/
          [self.navigationController popViewControllerAnimated:YES];
          
      }
       else
       {
           NSLog(@"Error updating shipping rate - %@", error);
       }
   }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.shippingRates count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    BUYShippingRate *shippingRate = self.shippingRates[indexPath.row];
    cell.textLabel.text = shippingRate.title;
    cell.detailTextLabel.text = [self.currencyFormatter stringFromNumber:shippingRate.price];
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

@end
