//
//  APSCheckoutVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 9/8/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSCheckoutVC.h"
#import "APSCheckOutOptionTVC.h"
#import "APSCheckOutDetailsTVC.h"
#import "APSMobilePayInfoVC.h"

#import "Global.h"
#import "APSBagManager.h"
#import "APSBagItemDataModel.h"
#import "APSShopifyBuyManager.h"
#import "APSGenericFunctionManager.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <BUYPaymentButton.h>
#import "MobilePayManager.h"
#import "APSUserTypeVC.h"
#import "APSHelpCenterTVC.h"
#import "APSShippingRatesViewController.h"
#import "APSGiftCardVC.h"
#import "APSPaymentMethodsVC.h"
#import "APSGiftCardsVCDelegate.h"
#import "Intercom/intercom.h"

@import SafariServices;

typedef NS_ENUM(int, CheckoutOptionCells){
TVCDelivery,
TVCUserType,
TVCShippingAddress,
TVCShippingRates,
TVCGiftCard,
TVCPayment,
TVCSummary
};
typedef NS_ENUM(int, PaymentMethodCells){
    PaymentMethodNotChosen,
    PayViaMobilePay,
    PayViaCreditCard,
    PayInStore,
    PayViaInvoice
};

typedef NS_ENUM(int, SummaryItemCells){
    TVCSubtotal,
};

const int numOfOptions = 6;
float yOffset = 5;

@interface APSCheckoutVC()<UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate, APSGiftCardVCDelegate>

@property (weak, nonatomic) IBOutlet UITableView * m_tableView;
@property (strong, nonatomic) NSMutableArray * m_arrHideDescription;
@property (strong, nonatomic) APSCheckOutDetailsTVC *m_savedCell;
@property (strong, nonatomic) APSCheckOutOptionTVC * m_summaryCell;
@property (strong, nonatomic) NSMutableArray * summaryItems;
@property (strong, nonatomic) NSDictionary * userData;
@property (nonatomic, assign) BOOL isBusinessUser;
@property (nonatomic, assign) NSInteger m_paymentMethod;
@property (nonatomic, assign) NSInteger discounts;

@property (nonatomic, weak) NSString * paymentGateway;
@end


@implementation APSCheckoutVC




- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.m_tableView reloadData];
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.summaryItems = [[[APSShopifyBuyManager sharedInstance].m_checkout buy_summaryItems] mutableCopy];
    
    [self refreshFields];
    [self.m_tableView reloadData];
    
    
}

- (void) refreshFields{
    self.userData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"user_pay_dictionary"];
    self.m_paymentMethod = [[NSUserDefaults standardUserDefaults] integerForKey:@"PaymentMethod"];
    self.m_arrHideDescription = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserType"]!=nil)
    {
        NSString * userType = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"UserType"];
        if ([userType containsString:@"Business"])
            self.isBusinessUser = YES;
        else
            self.isBusinessUser = NO;
    }
    if ([APSShopifyBuyManager sharedInstance].m_checkout.shippingRate!=nil && self.checkout.shippingRate == nil)
    {
        self.checkout = [APSShopifyBuyManager sharedInstance].m_checkout;
    }
    for (int i = 0; i < (int) [[APSBagManager sharedInstance].m_arrItems count]; i++){
        [self.m_arrHideDescription addObject:[NSNumber numberWithBool:NO]];
    }
}

- (void) viewDidLoad{
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
   // self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    [self.m_tableView reloadData];
    self.giftCards = @"";
    self.title = NSLocalizedString(@"Checkout", nil);
    UIButton *btnBuyNow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBuyNow.frame = CGRectMake(0, 0, 60, 25);
    btnBuyNow.layer.masksToBounds = NO;
    btnBuyNow.layer.cornerRadius = 3;
    btnBuyNow.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    btnBuyNow.layer.borderWidth = 1;
    [btnBuyNow setTitle:NSLocalizedString(@"PAY NOW", nil) forState:UIControlStateNormal];
    [btnBuyNow.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]];
    
    [btnBuyNow setTitleColor:APSUICOLOR_BLUE forState:UIControlStateNormal];
    [btnBuyNow addTarget:self action:@selector(PayNow:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buyNowItem = [[UIBarButtonItem alloc] initWithCustomView:btnBuyNow];
    
    self.navigationItem.rightBarButtonItem=buyNowItem;

}
- (IBAction)PayNow : (id) sender{
    APSShopifyBuyManager * manager = [APSShopifyBuyManager sharedInstance];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserType"]==nil)
    {
        [APSGenericFunctionManager showAlertWithMessage:NSLocalizedString(@"Please choose a User Type", nil)];
            return;
    }
    if (self.userData == nil)
    {
        [APSGenericFunctionManager showAlertWithMessage:NSLocalizedString(@"Please enter a Shipping Address", nil)];
        return;
    }
    if (manager.m_checkout.shippingRate==nil)
    {
        [APSGenericFunctionManager showAlertWithMessage:NSLocalizedString(@"Please choose a Shipping Method", nil)];
        return;
    }
    if (self.m_paymentMethod == PaymentMethodNotChosen)
    {
        [APSGenericFunctionManager showAlertWithMessage:NSLocalizedString(@"Please choose a Payment Method", nil)];
        return;
    }
    
    switch (self.m_paymentMethod) {
        case PayViaCreditCard:
            [self doCheckoutViaCC];
            break;
        case PayViaInvoice:
            [self doCheckoutViaInvoice];
            break;
        case PayViaMobilePay:
            [self doCheckoutViaMobilePay];
            break;
        case PayInStore:
            [self doCheckoutPayInStore];
            break;
            
        default:
            break;
    }
    
}

- (void) placeCustomOrder{


}

- (void) doCheckoutViaInvoice{
self.paymentGateway = @"Faktura betaling";
    [self proceedToCheckout];

}
- (void) doCheckoutViaMobilePay{
    self.paymentGateway = @"Mobile Pay";
    [self proceedToCheckout];
}

- (void) doCheckoutPayInStore{
    self.paymentGateway = @"Betales i butikken";
    [self proceedToCheckout];

}

- (void) doCheckoutViaCC {
    
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    [managerBuy buildCartFromBag];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = NSLocalizedString(@"Please wait...", nil);
    
    [managerBuy requestCreateCheckoutWithCallback:^(int status) {
        [hud hideAnimated:YES];
        if (status == ERROR_NONE){
            
            [self checkoutViaWeb];
        }
        else{
            [APSGenericFunctionManager showAlertWithMessage:NSLocalizedString(@"Failed to request checkout. Please try again!", nil)];
        }
    }];
}
- (void)checkoutViaWeb
{
    // On iOS 9+ we should use the SafariViewController to display the checkout in-app
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    if ([SFSafariViewController class]) {
        
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:managerBuy.m_checkout.webCheckoutURL];
        safariViewController.delegate = self;
        
        [self presentViewController:safariViewController animated:YES completion:nil];
    }
    else {
        [[UIApplication sharedApplication] openURL:managerBuy.m_checkout.webCheckoutURL];
    }
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller{
    NSLog(@"Safari ViewController dismissed...");
}

- (void)didReceiveCallbackURLNotification:(NSNotification *)notification
{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    NSURL *url = notification.userInfo[@"url"];
    
    __weak APSCheckoutVC *welf = self;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [managerBuy.m_client getCompletionStatusOfCheckoutURL:url completion:^(BUYStatus status, NSError *error) {
        if (error == nil && status == BUYStatusComplete) {
            NSLog(@"Successfully completed checkout");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                NSString * orderString = NSLocalizedString(@"Your order has been placed successfully.", nil);
                [APSGenericFunctionManager showAlertWithMessage:orderString];
                [welf gotoThankyou];
                
            });
        }
        else {
            NSLog(@"Error completing checkout: %@", error);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [APSGenericFunctionManager showAlertWithMessage:[NSString stringWithFormat:NSLocalizedString(@"Sorry, we have encountered an error while processing your request. \n%@", nil), error.localizedDescription]];
            });
        }
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APSLOCALNOTIFICATION_SHOPIFY_CHECKOUT_CALLBACK object:nil];
}

- (BUYAddress *) getAddress{
    
    BUYAddress * address = [[APSShopifyBuyManager sharedInstance].m_client.modelManager insertAddressWithJSONDictionary:nil];
    
    address.address1 = [self.userData objectForKey:NSLocalizedString(@"Shipping Address",nil)];
    address.city = [self.userData objectForKey:NSLocalizedString(@"City",nil)];
    
    
    address.city = [self.userData objectForKey:NSLocalizedString(@"City",nil)];
    if (self.isBusinessUser)
        address.company = [self.userData objectForKey:NSLocalizedString(@"Company",nil)];
    
    
    address.firstName = [self.userData objectForKey:NSLocalizedString(@"First Name",nil)];
    
    address.lastName = [self.userData objectForKey:NSLocalizedString(@"Last Name",nil)];
    
    address.phone = [self.userData objectForKey:NSLocalizedString(@"Phone No",nil)];
    address.countryCode = [self.userData objectForKey:@"CountryCode"];
    
    address.zip = [self.userData objectForKey:NSLocalizedString(@"ZIP",nil)];
    return address;
    
    
}
- (IBAction)onHideDetailsClick:(id)sender {
    /*
    APSCheckOutDetailsTVC * cell = (APSCheckOutDetailsTVC *)[sender superview];
    [self.m_tableView beginUpdates];
    cell.m_descriptionHidden = !cell.m_descriptionHidden ;
    [self.m_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.m_tableView endUpdates];*/
    UIButton * hideButton = (UIButton * ) sender;
    
    BOOL status = [[self.m_arrHideDescription objectAtIndex:hideButton.tag] boolValue];
   
    status = !status;
    [self.m_arrHideDescription replaceObjectAtIndex:hideButton.tag withObject:[NSNumber numberWithBool: status ]];
    [UIView setAnimationsEnabled:NO];
   [self.m_tableView beginUpdates];
    [self.m_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:hideButton.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.m_tableView endUpdates];
    [UIView setAnimationsEnabled:YES];

}

- (void) configureCell:(UITableViewCell *) TableCell AtIndex: (int) index{
    if (index < [APSBagManager sharedInstance].m_arrItems.count){
        APSCheckOutDetailsTVC * cell = (APSCheckOutDetailsTVC *) TableCell;
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    APSBagItemDataModel *item = [[APSBagManager sharedInstance].m_arrItems objectAtIndex:index];
    
    cell.m_txtQuantity.tag = index;
    cell.m_lblTitle.text = [NSString stringWithFormat:@"%@ %@", item.m_product.title, item.m_variant.title];
    cell.lblQuantity.text = [NSString stringWithFormat:@"%d", item.m_nQuantity];
    cell.m_Description.preferredMaxLayoutWidth = cell.m_Description.frame.size.width;

    cell.m_lblPrice.text = [APSGenericFunctionManager beautifyPrice:[item.m_variant.price floatValue] * item.m_nQuantity];
        NSLog(@"Item %@", item);
    [self setUIImageView:cell.m_imgProduct WithUrl:[managerBuy getImageUrlWithCollectionIndex:item.m_indexCollection
                                                                                 ProductIndex:item.m_indexProduct
                                                                                 VariantIndex:item.m_indexVariant] DefaultImage:nil];
    BOOL hiddenDescription = [[self.m_arrHideDescription objectAtIndex:index] boolValue];
    if (hiddenDescription == NO)
    {
        cell.m_Description.text = item.m_variant.product.stringDescription;
        cell.lblConfiguration.text = NSLocalizedString(@"Configuration", nil);
        [cell.m_btnHideDescription setTitle:NSLocalizedString(@"Hide Product Details", nil) forState:(UIControlStateNormal)];
    }
    else {
        cell.m_Description.text = @"";
        cell.lblConfiguration.text = @"";
        [cell.m_btnHideDescription setTitle:NSLocalizedString(@"Show Product Details", nil) forState:(UIControlStateNormal)];
    }
    cell.m_btnHideDescription.tag = index;
    cell.tag = index;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (index >= [APSBagManager sharedInstance].m_arrItems.count && index < [APSBagManager sharedInstance].m_arrItems.count + numOfOptions)
    {
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        NSDictionary * userDict;
        BUYCheckout * m_checkout = [APSShopifyBuyManager sharedInstance].m_checkout;

        if ([prefs dictionaryForKey:@"user_pay_dictionary"]!=nil)
            userDict = [prefs dictionaryForKey:@"user_pay_dictionary"];
        APSCheckOutOptionTVC * cell = (APSCheckOutOptionTVC *) TableCell;
        int optionIndex = index -  (int)([APSBagManager sharedInstance].m_arrItems.count);
        switch (optionIndex) {
            case TVCDelivery:
                cell.m_fieldDescription.text = NSLocalizedString(@"1 - 10 Days",nil);
                cell.m_fieldName.text = NSLocalizedString(@"Delivery", nil);
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case TVCUserType:
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserType"]!=nil)
                {
                    cell.m_fieldDescription.text = NSLocalizedString([[NSUserDefaults standardUserDefaults] objectForKey:@"UserType"], nil);
                }
                else
                    cell.m_fieldDescription.text = NSLocalizedString(@"Private or Business", nil);

                cell.m_fieldName.text = NSLocalizedString(@"User Type", nil);
                break;
                
            case TVCShippingRates:
                if (m_checkout.shippingRate!=nil)
                {
                    cell.m_fieldDescription.text = m_checkout.shippingRate.title;
                }
                else
                    cell.m_fieldDescription.text = NSLocalizedString(@"Choose shipping rate", nil);

                cell.m_fieldName.text = NSLocalizedString(@"Shipping Rate", nil);
                break;
            
            case TVCShippingAddress:
                if (userDict != nil)
                {
                    cell.m_fieldDescription.text =  [NSString stringWithFormat:@"%@ %@", [userDict objectForKey:NSLocalizedString(@"First Name", nil) ], [userDict objectForKey:NSLocalizedString(@"Last Name", nil)] ];
                }
                else
                cell.m_fieldDescription.text = NSLocalizedString(@"Enter address", nil);

                cell.m_fieldName.text = NSLocalizedString(@"Shipping Address", nil);
                break;
            case TVCGiftCard:
                if (self.discounts>0)
                   cell.m_fieldDescription.text = self.giftCards;
                else
                cell.m_fieldDescription.text = NSLocalizedString(@"Add a gift card", nil);
                cell.m_fieldName.text = NSLocalizedString(@"Gift Cards", nil);

                break;
            case TVCPayment:
                switch (self.m_paymentMethod) {
                    case PaymentMethodNotChosen:
                        cell.m_fieldDescription.text = NSLocalizedString(@"Enter payment", nil);
                        break;
                    case PayViaCreditCard:
                        cell.m_fieldDescription.text = NSLocalizedString(@"Credit Card", nil);
                        break;
                    case PayViaInvoice:
                        cell.m_fieldDescription.text = NSLocalizedString(@"Invoice", nil);
                        break;
                    case PayViaMobilePay:
                        cell.m_fieldDescription.text = NSLocalizedString(@"MobilePay", nil);
                        break;
                    case PayInStore:
                        cell.m_fieldDescription.text = NSLocalizedString(@"In Store", nil);
                        break;

                    default:
                        break;
                }
                cell.m_fieldName.text = NSLocalizedString(@"Payment", nil);
                  break;
            default:
                break;
        }
    
    }
    else if (index >= [[APSBagManager sharedInstance].m_arrItems count] + numOfOptions && index< [[APSBagManager sharedInstance].m_arrItems count] + numOfOptions + self.summaryItems.count)
    {
        int indexSummary = index - (int)[APSBagManager sharedInstance].m_arrItems.count - numOfOptions;
        APSCheckOutOptionTVC * cell = (APSCheckOutOptionTVC *) TableCell;
        [self configureSummaryCell:cell AtIndex:indexSummary];
    }

}


- (void) configureSummaryCell: (APSCheckOutOptionTVC *) cell AtIndex: (int)index{
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
 
    if (index == TVCSubtotal)
        cell.m_fieldName.text = NSLocalizedString(@"Summary", nil);
    else
        cell.m_fieldName.text = @"";

    PKPaymentSummaryItem * item = [self.summaryItems objectAtIndex:index];
    NSLog(@"All summary items %@", self.summaryItems);
    cell.m_fieldDescription.text = NSLocalizedString([item.label capitalizedString],nil);

    CGRect fieldRect = cell.m_fieldDescription.frame;
    UILabel * amount = [[UILabel alloc] initWithFrame:CGRectMake(self.m_tableView.bounds.origin.x, 0, self.m_tableView.bounds.size.width - 10, fieldRect.size.height)];
    amount.text =  [APSGenericFunctionManager beautifyPrice: [item.amount floatValue]];
    amount.font = cell.m_fieldDescription.font;
    amount.textAlignment = NSTextAlignmentRight;
    UIView * container = [[UIView alloc] initWithFrame:CGRectMake(self.m_tableView.bounds.origin.x, fieldRect.origin.y, self.m_tableView.bounds.size.width - 10, fieldRect.size.height)];
    [container addSubview:amount];
    cell.accessoryView = container;

}
- (void) setUIImageView: (UIImageView *) imageView WithUrl: (NSString *) url DefaultImage: (NSString *) imageDefault{
    if (imageDefault != nil){
        [imageView setImage:[UIImage imageNamed:imageDefault]];
    }
    else{
        [imageView setImage:nil];
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *reqOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    reqOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [reqOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        [UIView transitionWithView:imageView duration:TRANSITION_IMAGEVIEW_FADEIN options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [imageView setImage:responseObject];
        } completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@", error);
    }];
    [reqOperation start];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//if (indexPath.row >= [[APSBagManager sharedInstance].m_arrItems count])
    int index = (int)( indexPath.row - [[APSBagManager sharedInstance].m_arrItems count]);
    NSLog(@"Index %d IndexPath %ld Acount %lu", index, (long)indexPath.row , (unsigned long)[[APSBagManager sharedInstance].m_arrItems count]);
    switch (index) {
        case TVCDelivery:
            break;
        case TVCShippingAddress:
            [self initUserInfoView];
            break;
        case TVCUserType:
            [self initUserTypeView];
            break;
        case TVCShippingRates:
            [self initShippingRatesView];
            break;
        case TVCGiftCard:
            [self initGiftCardView];
            break;
        case TVCPayment:
            [self initPaymentMethodView];
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void) initPaymentMethodView{
    APSPaymentMethodsVC * paymentMethodsVC = [[APSPaymentMethodsVC alloc] init];
    [self.navigationController pushViewController:paymentMethodsVC animated:YES];
    
}

- (void) APSGiftCardDismissWithData:(NSDictionary *)data{
   //
    if (data == nil)
        return;
    NSLog(@"data %@ giftcards %@", data, self.giftCards);
    
    self.discounts =  self.discounts + [[data objectForKey:@"GiftAmount"] integerValue];
     self.giftCards = [NSString stringWithFormat:@"%@%@", self.giftCards, [data objectForKey:@"GiftCards"] ];
    self.summaryItems = [[[APSShopifyBuyManager sharedInstance].m_checkout buy_summaryItems] mutableCopy];

    [self.m_tableView reloadData];
}
- (void) initGiftCardView{
    if(self.checkout.shippingRate == nil)
    { [APSGenericFunctionManager showAlertWithMessage:NSLocalizedString(@"Please choose shipping rates first", nil)];
        return;
    }
    UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    APSGiftCardVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"APS_GIFTCARD_SCENE"];
    vc.checkout = self.checkout;
    vc.delegate = self;
   // APSGiftCardVC * giftCardVC = [[APSGiftCardVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void) initUserTypeView{

    APSUserTypeVC * userTypeVC = [[APSUserTypeVC alloc] init];
    
    [self.navigationController pushViewController:userTypeVC animated:YES];
    return;
}
- (void) initShippingRatesView{
    if (self.userData == nil)
    { [APSGenericFunctionManager showAlertWithMessage:NSLocalizedString(@"Please enter address first", nil)];
        return;
    }
    UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    APSShippingRatesViewController * vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"APS_ShippingRates"];
    vc.shippingAddress = [self getAddress];
    vc.isBusinessUser =  self.isBusinessUser ;
    vc.userData = [self.userData mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) initUserInfoView{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    APSMobilePayInfoVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"APSMobilePayUserInfo"];
    NSLog(@"Isbusiess %@", self.isBusinessUser ? @"Yes":@"No" );
    vc.isBusinessUser=  self.isBusinessUser ;
    [self.navigationController pushViewController:vc animated:YES];

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    if (indexPath.row < [APSBagManager sharedInstance].m_arrItems.count){
        cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"TVC_Checkout_Details"];
        [self configureCell:cell AtIndex:(int) indexPath.row];

    }
    else if (indexPath.row >= [[APSBagManager sharedInstance].m_arrItems count] && indexPath.row < [[APSBagManager sharedInstance].m_arrItems count] + numOfOptions)
    {
        cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"TVC_Checkout_Option" forIndexPath:indexPath];
        [self configureCell:cell AtIndex:(int) indexPath.row];
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row >= [[APSBagManager sharedInstance].m_arrItems count] + numOfOptions && indexPath.row< [[APSBagManager sharedInstance].m_arrItems count] + numOfOptions + self.summaryItems.count)
    {
        cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"TVC_Checkout_Option" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        [self configureCell:cell AtIndex:(int) indexPath.row];
        
    }
    else
    {
        APSHelpCenterTVC *  helpCell =  (APSHelpCenterTVC *) [tableView dequeueReusableCellWithIdentifier:@"TVC_HELPCENTER"];
        [helpCell.m_btnHelp setTitle:NSLocalizedString(@"Help", nil) forState:UIControlStateNormal];
        [helpCell.m_btnCall setTitle:NSLocalizedString(@"Call Us", nil) forState:UIControlStateNormal];
        cell = (UITableViewCell * ) helpCell;
    }
   
 
    if (indexPath.row >= [APSBagManager sharedInstance].m_arrItems.count + numOfOptions && indexPath.row< [[APSBagManager sharedInstance].m_arrItems count] + numOfOptions + self.summaryItems.count)
    {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset: UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.frame.size.width)];
            
            [cell setIndentationWidth:10];
            [cell setIndentationLevel:2];
        }
    }
    else
    {
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        [cell setNeedsLayout];
        [cell layoutIfNeeded ];
        
        [cell setIndentationLevel:0];
        
        [cell setSeparatorInset: UIEdgeInsetsMake(0.f, 0, 0.f, 0.f)];

    }
    
     if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"items %d" , (int) [APSBagManager sharedInstance].m_arrItems.count);
    return (int) [[APSBagManager sharedInstance].m_arrItems count] + numOfOptions + self.summaryItems.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < [[APSBagManager sharedInstance].m_arrItems count])
    {static NSString *szCellIdentifier = @"TVC_Checkout_Details";
    if (self.m_savedCell == nil)
    {
        self.m_savedCell = [tableView dequeueReusableCellWithIdentifier:szCellIdentifier];
    }
    
    [self configureCell:self.m_savedCell AtIndex:(int) indexPath.row];
    
    [self.m_savedCell setNeedsUpdateConstraints];
    [self.m_savedCell updateConstraintsIfNeeded];
    self.m_savedCell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.m_savedCell.bounds));
    
    [self.m_savedCell setNeedsLayout];
    [self.m_savedCell layoutIfNeeded];
    CGFloat height = [self.m_savedCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    NSLog(@"Height for Cell %f",  height);
        return height;}
    else if (indexPath.row >= [[APSBagManager sharedInstance].m_arrItems count] && indexPath.row < [[APSBagManager sharedInstance].m_arrItems count] + numOfOptions)
    {return 44.0;
    }
    else if (indexPath.row >= [[APSBagManager sharedInstance].m_arrItems count] + numOfOptions && indexPath.row < [[APSBagManager sharedInstance].m_arrItems count] + numOfOptions + self.summaryItems.count)
    return 26;
    else
        return 200;
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
    
    NSDecimalNumber * discount = [[NSDecimalNumber alloc] initWithInt:0] ;
    
    APSShopifyBuyManager * managerBuy = [APSShopifyBuyManager sharedInstance];
    APSBagManager * bagManager = [APSBagManager sharedInstance];
    NSString * notes = managerBuy.m_allGiftMessages;

    NSMutableArray * lineItemMutableArray= [NSMutableArray array];
    NSDictionary * lineItemDict = @{@"variant_id":managerBuy.m_checkout,@"quantity":@1,@"name":@"Iphone5s",
                                    @"price":@"21",
                                    @"title":@"Iphone5s"};
    
    for (id lineItem in managerBuy.m_cart.lineItemsArray){
        BUYCartLineItem * lineItemAtIndex = (BUYCartLineItem *) lineItem;
        NSLog(@" Cart Item %@", lineItemAtIndex.variant.title);
        NSLog(@" Quantity %@", [lineItemAtIndex quantity]);
        NSLog(@" Price  %@", lineItemAtIndex.variant.price);
        NSLog(@" ID  %@", [lineItemAtIndex variantId]);
        NSLog(@" Name %@", lineItemAtIndex.variant.product.title);

        
        lineItemDict = @{@"variant_id":[lineItemAtIndex variantId],
                         @"quantity":[lineItemAtIndex quantity],
                         @"title": lineItemAtIndex.variant.product.title,
                         @"name": [NSString stringWithFormat:@"%@ %@", lineItemAtIndex.variant.product.title, lineItemAtIndex.variant.title ],
                         @"price": lineItemAtIndex.variant.price,
                         @"gift_card": giftCard};
        [lineItemMutableArray addObject:lineItemDict];
        
    }
    NSLog(@"Payment due %@, %@", self.checkout.paymentDue, [APSShopifyBuyManager sharedInstance].m_checkout.paymentDue);
    NSDictionary * shipAddress = [self getShippingAddress];
    NSDictionary * buyAddress = [self getBillingAddress];
   /* NSDictionary * transactions = @{@"kind":@"authorization",
                                    @"status":@"success",
                                    @"gateway":@"MobilePay",
                                    @"amount":self.checkout.paymentDue
                                    };*/
  //  NSArray * transArray  = @[@{@"kind":@"authorization",
    //                    @"status":@"success",
      //                  @"gateway":@"MobilePay",
        //                @"amount":self.checkout.paymentDue
          //                                           }];
   // NSMutableArray * transactionArray = [NSMutableArray arrayWithObject:transactions];
    // No need to create a transaction when amount == 0
    // Mark the line item as gift card
    // compare pricing/total bill in shopify  vs one charged in transaction to verify giftcard did work.
    // ALSO add the discounts from both discounts and giftcards.
    
   /* if (self.didApplyDiscount)
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
    }*/
  /*
    for (BUYGiftCard * gift in self.checkout.giftCards) {
        discount = [discount decimalNumberByAdding:gift.amountUsed] ;
        
       // notes = [NSString stringWithFormat:@"%@ Gift Card: %@",notes, gift.code ];
    }*/
    discount = [managerBuy.m_checkout.paymentDue decimalNumberBySubtracting:self.checkout.paymentDue];

    NSLog(@"gift cards parent %@", self.giftCards);

    if (self.discounts>0)
    {giftCard = @"true";
    notes = [NSString stringWithFormat:@"%@ - %@",notes, self.giftCards ];
    }
    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary: @{@"order":@{
                                                                                              @"email":[self.userData objectForKey:NSLocalizedString(@"Email",nil)],
                                                                                              @"fulfillment_status":@"unfulfilled",
                                                                                              @"financial_status":@"authorized",
                                                                                              @"payment_gateway_names":@[self.paymentGateway],
                                                                                              @"line_items":lineItemMutableArray,
                                                                                              @"shipping_lines":[self getShippingLines],
                                                                                              @"billing_address":buyAddress,
                                                                                              @"shipping_address":shipAddress,
                                                                                              @"total_discounts":[NSDecimalNumber numberWithInteger:self.discounts],
                                                                                              @"send_receipt":@"true",
                                                                                              @"send_fulfillment_receipt":@"true",
                                                                                              @"note":notes,
                                                                                              @"transactions":@[@{@"kind":@"authorization",
                                                                                                                  @"status":@"success",
                                                                                                                  @"gateway":self.paymentGateway ,
                                                                                      @"amount":self.checkout.paymentDue
                                                                                                                  }]
                                                                                              }}];
   
    if (self.checkout.paymentDue>0){
     // [params setObject:transArray forKey:@"transactions"];
    }
    NSLog(@"Params %@", params);
    [bagManager createOrderWithParameters:params Callback:^(NSDictionary *order) {
     //   NSString * orderID = [order objectForKey:@"order_id"];
        NSString * orderNumber = [order objectForKey:@"order_number"];
        
        if ([[order objectForKey:@"order"]  isEqual: @"success"]){
            [bagManager setCheckOutActive:order];
            if (self.m_paymentMethod != PayViaMobilePay)
            {
                NSString * orderString = NSLocalizedString(@"Your order has been placed successfully. You order number is", nil);
                [APSGenericFunctionManager showAlertWithMessage:[NSString stringWithFormat:@"%@ %@",orderString, orderNumber ]];
                [self gotoThankyou];

                return;
            
            }
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
- (IBAction)onCallUsClick:(id)sender {
   // NSString *phNo = @"+919876543210";
    NSString *phNo = @"+4589885052";
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        [APSGenericFunctionManager showAlertWithMessage:@"Call facility is not available!"];
}
}
- (IBAction)onHelpClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    
    NSString * userEmail = [prefs objectForKey:@"intercomChatEmail"];
    if (userEmail != NULL)
    {
        [Intercom presentConversationList];
    }
    else
    {
        
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_CHATLOGIN"];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }

}

- (void) gotoThankyou{
    [[APSBagManager sharedInstance] clearBag];
    [[APSShopifyBuyManager sharedInstance] clearCart];
  [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
