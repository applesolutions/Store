//
//  APSReceiptVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 8/20/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
////


#import "APSReceiptVC.h"
#import "APSReceiptTVC.h"

#import "APSShopifyBuyManager.h"
#import "APSBagManager.h"
#import "MobilePayManager.h"

@import PassKit;

typedef NS_ENUM(NSInteger, UITableViewSections) {
    UITableViewSectionSummaryItems,
    UITableViewSectionDiscountGiftCard,
    UITableViewSectionContinue,
    UITableViewSectionCount
};

typedef NS_ENUM(NSInteger, UITableViewDiscountGiftCardSection) {
    UITableViewDiscountGiftCardSectionDiscount,
    UITableViewDiscountGiftCardSectionGiftCard,
    UITableViewDiscountGiftCardSectionCount
};

const float HEIGHT_FOR_TABLEHEADER = 80;
@interface APSReceiptVC ()
@property (nonatomic, strong) NSMutableArray *summaryItems;
@property (nonatomic,strong) BUYCheckout * checkout;
@property (nonatomic, assign) BOOL didApplyDiscount;
@property (nonatomic,assign) BOOL didApplyGiftCard;
@end

@implementation APSReceiptVC

- (instancetype) initWithCheckout: (BUYCheckout * )checkout UserData: (NSDictionary * ) userData{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        [self initHeader];
        self.userData = userData;
        [self setCheckout:checkout];
    }
    return self;
}

- (void) initHeader{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, HEIGHT_FOR_TABLEHEADER)];
    [headerView setBackgroundColor:[UIColor colorWithWhite:0.93 alpha:1.0]];
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.tableView.bounds.size.width, HEIGHT_FOR_TABLEHEADER)];
    titleLabel.center = headerView.center;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"Order Summary",nil);
    titleLabel.font = [UIFont fontWithDescriptor:[titleLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits: UIFontDescriptorTraitBold]  size:17.0];
    [headerView addSubview:titleLabel];
    self.tableView.tableHeaderView = headerView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[APSReceiptTVC class] forCellReuseIdentifier:@"SummaryCell"];
    self.didApplyDiscount = NO;
    self.title = @"";
    self.didApplyGiftCard = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) setCheckout:(BUYCheckout *)checkout{
    _checkout = checkout;
    self.summaryItems = [[checkout buy_summaryItems] mutableCopy];
    NSString * ShippingPrice = [self.userData objectForKey:@"ShippingMethod"];
    if ([ShippingPrice containsString:@"Zero"])
    {
        PKPaymentSummaryItem * shippingItem = [[PKPaymentSummaryItem alloc] init];
        shippingItem.label = @"SHIPPING";
        shippingItem.amount =  [[NSDecimalNumber alloc ] initWithInt:0];
        [self.summaryItems insertObject:shippingItem atIndex:self.summaryItems.count-2];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return UITableViewSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case UITableViewSectionSummaryItems:
            return [self.summaryItems count];
        case UITableViewSectionDiscountGiftCard:
            return UITableViewDiscountGiftCardSectionCount;
            break;
        default:
            return 1;
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case UITableViewSectionDiscountGiftCard:
            switch (indexPath.row) {
                case UITableViewDiscountGiftCardSectionDiscount:
                    [self addDiscount];
                    break;
                case UITableViewDiscountGiftCardSectionGiftCard:
                    [self applyGiftCard];
                    break;
                default:
                    break;
            }
            break;
        case UITableViewSectionContinue:
            [self proceedToCheckout];
            break;
        default:
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (NSDictionary * ) getShippingAddress{
    
    NSMutableDictionary * addr = [[NSMutableDictionary alloc] init];
    NSString * fullname = [NSString stringWithFormat:@"%@ %@", [self.userData objectForKey:NSLocalizedString(@"First Name",nil)], [self.userData objectForKey:NSLocalizedString(@"Last Name",nil)] ];
    
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"First Name",nil)] forKey:@"first_name"];
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"Last Name",nil)] forKey:@"last_name"];
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"Shipping Address",nil)] forKey:@"address1"];
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"Phone No",nil)] forKey:@"phone"];
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"City",nil)] forKey:@"city"];
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"Country",nil)] forKey:@"country"];
    [addr setObject:[self.userData objectForKey:@"CountryCode"] forKey:@"country_code"];

    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"ZIP",nil)] forKey:@"zip"];
    if (self.isBusinessUser)
        [addr setObject:[self.userData objectForKey:NSLocalizedString(@"Company Name",nil)] forKey:@"company"];
    [addr setObject:@"" forKey:@"address2"];
    [addr setObject:fullname forKey:@"name"];
    

    return addr;
}
- (NSDictionary *) getBillingAddress{

    NSMutableDictionary * addr = [[NSMutableDictionary alloc] init];
    NSString * fullname = [NSString stringWithFormat:@"%@ %@", [self.userData objectForKey:NSLocalizedString(@"First Name",nil)], [self.userData objectForKey:NSLocalizedString(@"Last Name",nil)] ];
    
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"First Name",nil)] forKey:@"first_name"];
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"Last Name",nil)] forKey:@"last_name"];
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"Address",nil)] forKey:@"address1"];
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"Phone No",nil)] forKey:@"phone"];
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"City",nil)] forKey:@"city"];
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"Country",nil)] forKey:@"country"];
    [addr setObject:[self.userData objectForKey:@"CountryCode"] forKey:@"country_code"];
    
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"ZIP",nil)] forKey:@"zip"];
    if (self.isBusinessUser)
    [addr setObject:[self.userData objectForKey:NSLocalizedString(@"Company Name",nil)] forKey:@"company"];
    [addr setObject:@"" forKey:@"address2"];
    [addr setObject:fullname forKey:@"name"];
    
    return addr;
}

- (NSArray *) getShippingLines{
    NSMutableDictionary * shipping = [[NSMutableDictionary alloc] init];
    BUYShippingRate * shippingRate = self.checkout.shippingRate;
    
    [shipping setObject:shippingRate.title forKey:@"title"];
    
    [shipping setObject:shippingRate.shippingRateIdentifier forKey:@"id"];
    [shipping setObject:shippingRate.price forKey:@"price"];
    [shipping setObject:shippingRate.title forKey:@"title"];
    
    return @[shipping];
}
- (void) proceedToCheckout{

    
    NSString *  giftCard = @"false";
    NSString * notes = @"";
 
    
    NSDecimalNumber * discount = [[NSDecimalNumber alloc] initWithInt:0] ;

    APSShopifyBuyManager * managerBuy = [APSShopifyBuyManager sharedInstance];
    APSBagManager * bagManager = [APSBagManager sharedInstance];
    
    NSMutableArray * lineItemMutableArray= [NSMutableArray array];
    NSDictionary * lineItemDict = @{@"variant_id":managerBuy.m_checkout,@"quantity":@1,@"name":@"Iphone5s",
                                    @"price":@"21",
                                    @"title":@"Iphone5s"};
    
    for (id lineItem in managerBuy.m_cart.lineItemsArray){
        BUYCartLineItem * lineItemAtIndex = (BUYCartLineItem *) lineItem;
        lineItemDict = @{@"variant_id":[lineItemAtIndex variantId],
                         @"quantity":[lineItemAtIndex quantity],
                         @"title": lineItemAtIndex.variant.product.title,
                         @"name": [NSString stringWithFormat:@"%@ %@", lineItemAtIndex.variant.product.title, lineItemAtIndex.variant.title ],
                         @"price": lineItemAtIndex.variant.price,
                         @"gift_card": giftCard};
        [lineItemMutableArray addObject:lineItemDict];
        
    }
    
    NSDictionary * shipAddress = [self getShippingAddress];
    NSDictionary * buyAddress = [self getBillingAddress];
    NSDictionary * transactions = @{@"kind":@"authorization",
                                    @"status":@"success",
                                    @"gateway":@"MobilePay",
                                    @"amount":self.checkout.paymentDue
                                    };
    NSMutableArray * transactionArray = [NSMutableArray arrayWithObject:transactions];
    // No need to create a transaction when amount == 0
    // Mark the line item as gift card
    // compare pricing/total bill in shopify  vs one charged in transaction to verify giftcard did work.
    // ALSO add the discounts from both discounts and giftcards.
    
    if (self.didApplyDiscount)
    {
        discount =  self.checkout.discount.amount;
        notes = [NSString stringWithFormat:@"Discount code: %@", self.checkout.discount.code ];
    }
    else
        NSLog(@" NO discount found");
    if (self.didApplyGiftCard)
    {giftCard = @"true";
        notes = [NSString stringWithFormat:@"%@. Gift card used: %@", notes ,self.validGiftCard ];
        discount = [managerBuy.m_checkout.paymentDue decimalNumberBySubtracting:self.checkout.paymentDue];
    }
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary: @{@"order":@{
                                      @"email":[self.userData objectForKey:NSLocalizedString(@"Email",nil)],
                                      @"fulfillment_status":@"unfulfilled",
                                      @"financial_status":@"pending",
                                      @"payment_gateway_names":@"MobilePay",
                                      @"line_items":lineItemMutableArray,
                                      @"shipping_lines":[self getShippingLines],
                                      @"billing_address":buyAddress,
                                      @"shipping_address":shipAddress,
                                      @"total_discounts":discount,
                                      @"send_receipt":@"true",
                                      @"send_fulfillment_receipt":@"true",
                                      @"note":notes
                                      }}];
    if (self.checkout.paymentDue!=0){
        [params setObject:transactionArray forKey:@"transactions"]; 
    }

    [bagManager createOrderWithParameters:params Callback:^(NSDictionary *order) {
  //      NSString * orderID = [order objectForKey:@"order_id"];
        NSString * orderNumber = [order objectForKey:@"order_number"];
        
        if ([[order objectForKey:@"order"]  isEqual: @"success"]){
            [bagManager setCheckOutActive:order];
            
            MobilePayPayment * payment = [[MobilePayPayment alloc] initWithOrderId: orderNumber productPrice:self.checkout.paymentDue.floatValue];
            NSLog(@"creating mobile pay");
            if (payment && (payment.orderId.length >0) && (payment.productPrice>=0))
            {
                [[MobilePayManager sharedInstance]beginMobilePaymentWithPayment:payment error:^(NSError * _Nonnull error)
                 {
                     
                     
                     
                     /*  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                      message:[NSString stringWithFormat:@"reason: %@, suggestion: %@",error.localizedFailureReason, error.localizedRecoverySuggestion]
                      delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Install MobilePay",nil];
                      [alert show];
                      
                      */
                     if (error)
                         NSLog(@"Error in Mobile Pay %@", error);
                 }        ];
                
            }
        }
    }];

   
    
    
 /*   APSShopifyBuyManager * buyManager = [APSShopifyBuyManager sharedInstance];
    [buyManager.m_client completeCheckoutWithToken:self.checkout.token paymentToken:nil completion:^(BUYCheckout * _Nullable checkout, NSError * _Nullable error) {
        NSLog(@"Status is %@", error);
        
    }];*/

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case UITableViewSectionSummaryItems: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SummaryCell" forIndexPath:indexPath];
            PKPaymentSummaryItem *summaryItem = self.summaryItems[indexPath.row];
            if ([summaryItem.label containsString:@"DISCOUNT"])
            {
                NSString * dc = @"DISCOUNT";
                
                summaryItem.label = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"DISCOUNT", nil), [summaryItem.label substringFromIndex:dc.length]];
                
            }
            else if ([summaryItem.label containsString:@"GIFT CARD"])
            {
                NSString * dc = @"GIFT CARD";
                
                summaryItem.label = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"GIFT CARD", nil), [summaryItem.label substringFromIndex:dc.length]];
            }
            else
            {
                summaryItem.label = NSLocalizedString(summaryItem.label, nil);
            }
            cell.textLabel.text = summaryItem.label;
            cell.detailTextLabel.text = [self.currencyFormatter stringFromNumber:summaryItem.amount];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            // Only show a line above the last cell
            if (indexPath.row != [self.summaryItems count] - 2) {
                cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
            }
        }
            break;
        case UITableViewSectionDiscountGiftCard:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsZero;
            switch (indexPath.row) {
                case UITableViewDiscountGiftCardSectionDiscount:
                    cell.textLabel.text = NSLocalizedString(@"Add Discount",nil);
                    break;
                case UITableViewDiscountGiftCardSectionGiftCard:
                    cell.textLabel.text = NSLocalizedString(@"Apply Gift Card",nil);
                    break;
                default:
                    break;
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            break;
        case UITableViewSectionContinue:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Pay Now", nil);
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            break;
        default:
            break;
    }
    
    cell.preservesSuperviewLayoutMargins = NO;
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    return cell;
}
- (void)addDiscount
{
    APSShopifyBuyManager * manager = [APSShopifyBuyManager sharedInstance];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter Discount Code",nil) message:nil preferredStyle:UIAlertControllerStyleAlert];;
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Discount Code",nil);
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          NSLog(@"Cancel action");
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
    {
        if ([[alertController.textFields[0] text] isEqualToString:@""])
            return;
    BUYDiscount *discount = [manager.m_client.modelManager discountWithCode:[alertController.textFields[0] text]];
        
   self.checkout.discount = discount;
                                                          
   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                                                          
    [manager.m_client updateCheckout:self.checkout completion:^(BUYCheckout *checkout, NSError *error) {
                                                              
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                              
    if (error == nil && checkout) {
                                                                  
    NSLog(@"Successfully added discount");
    self.checkout = checkout;
        self.didApplyDiscount = YES;
    [self.tableView reloadData];
     }
    else {
    NSLog(@"Error applying checkout: %@", error);
    }
    }];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    NSLog(@"Discount");
}

- (void)applyGiftCard
{
    NSLog(@"GiftCard");
    APSShopifyBuyManager * manager = [APSShopifyBuyManager sharedInstance];

    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter Gift Card Code",nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Gift Card Code",nil);
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          NSLog(@"Cancel action");
                                                      }]];
  /*  [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Wallet",nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
    {
        NSLog(@"Wallet");
        if (![PKPassLibrary isPassLibraryAvailable]) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Pass Library Error" message:@"The Pass Library is not available." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        PKPassLibrary * passLib = [[PKPassLibrary alloc] init];
        
        NSArray * passArray = [passLib passes];
        
        if (passArray.count > 0)
        {
            PKPass *onePass = [passArray objectAtIndex:0];
            NSLog(@"We have a pass %@ %@", [onePass localizedName], [onePass organizationName]);
        }
                                                      }]];*/
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          
     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if ([[alertController.textFields[0] text] isEqualToString:@""])
        return;
                                                          
    [manager.m_client applyGiftCardCode:[alertController.textFields[0] text] toCheckout:self.checkout completion:^(BUYCheckout *checkout, NSError *error) {
                                                              
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    if (error == nil && checkout) {
        
        NSLog(@"Successfully added gift card");
        self.checkout = checkout;
        self.validGiftCard = [alertController.textFields[0] text];
        [self.tableView reloadData];
        self.didApplyGiftCard = YES;
        
    }
    else {
        NSLog(@"Error applying gift card: %@", error);
            }
        }];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
