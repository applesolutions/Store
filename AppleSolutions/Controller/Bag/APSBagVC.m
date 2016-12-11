//
//  APSBagVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/22/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSBagVC.h"
#import "APSBagTVC.h"
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

@import PassKit;
@import SafariServices;

@interface NSLayoutConstraint (Description)

@end

@implementation NSLayoutConstraint (Description)

-(NSString *)description {
    return [NSString stringWithFormat:@"id: %@, constant: %f", self.identifier, self.constant];
}

@end
@interface APSBagVC () <UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, PKPaymentAuthorizationViewControllerDelegate >

@property (weak, nonatomic) IBOutlet UIBarButtonItem *m_btnDone;
@property (weak, nonatomic) IBOutlet UITableView *m_tableview;

@property (weak, nonatomic) IBOutlet UIView *m_viewPaymentOptionWrapper;
@property (weak, nonatomic) IBOutlet UIView *m_viewPaymentOptionContainer;

@property (strong, nonatomic) APSBagTVC *m_savedCell;
@property (strong, nonatomic) NSMutableArray *m_arrAppleGiftSelected;
@property (strong, nonatomic) NSMutableArray *m_arrFreeGiftSelected;
@property (strong, nonatomic) NSMutableArray *m_arrDidPayForAppleGift;

@property (strong, nonatomic) NSMutableArray *m_arrItemEditingQuantity;

@property (nonatomic, strong) BUYApplePayAuthorizationDelegate *m_applePayHelper;
@property (weak, nonatomic) IBOutlet UILabel *m_lblSubtotalPrice;
@property (weak, nonatomic) IBOutlet UILabel *m_lblSubTotalText;
//@property (nonatomic,strong) BUYApplePayPaymentProvider *applePayProvider;
//@property (nonatomic, strong) BUYApplePayAuthorizationDelegate *applePayAuthorizationDelegate;

#define ALERTVIEW_TAG_ITEMDELETE                    1000

@end

@implementation APSBagVC

- (void) viewDidLoad{
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.m_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableview.allowsMultipleSelectionDuringEditing = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCallbackURLNotification:) name:APSLOCALNOTIFICATION_SHOPIFY_CHECKOUT_CALLBACK object:nil];
    UIButton *btnBuyNow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBuyNow.frame = CGRectMake(0, 0, 70, 25);
    btnBuyNow.layer.masksToBounds = NO;
    btnBuyNow.layer.cornerRadius = 3;
    btnBuyNow.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    btnBuyNow.layer.borderWidth = 1;
    [btnBuyNow setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [btnBuyNow setTitleColor:APSUICOLOR_BLUE forState:UIControlStateNormal];
    btnBuyNow.backgroundColor = [UIColor clearColor];
    [btnBuyNow.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]];
    
    [self.m_btnDone setCustomView:btnBuyNow];
    
    [btnBuyNow addTarget:self action:@selector(onBtnBuyNowClick:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *creditCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [creditCardButton setTitle:@"Checkout with Credit Card" forState:UIControlStateNormal];
//    creditCardButton.backgroundColor = [UIColor colorWithRed:0.48f green:0.71f blue:0.36f alpha:1.0f];
    creditCardButton.layer.cornerRadius = 6;
//    [creditCardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [creditCardButton setImage:[UIImage imageNamed:@"bag-cc"] forState:UIControlStateNormal];
    creditCardButton.translatesAutoresizingMaskIntoConstraints = NO;
    creditCardButton.layer.borderColor = [UIColor blackColor].CGColor;
    creditCardButton.layer.borderWidth = 1;
    creditCardButton.clipsToBounds = YES;
    creditCardButton.backgroundColor = [UIColor whiteColor];
    creditCardButton.adjustsImageWhenHighlighted = NO;
    self.m_viewPaymentOptionContainer.backgroundColor = [UIColor colorWithRed:1.0f green:0.0f blue:1.0f alpha:0.4f];
    CGSize winSize = [UIScreen mainScreen].bounds.size;

    self.m_viewPaymentOptionContainer.frame = CGRectMake(0.0f, 0.0f, winSize.height, winSize.width);
    self.view.clipsToBounds = YES;
    [creditCardButton addTarget:self action:@selector(doCheckoutViaCC) forControlEvents:UIControlEventTouchUpInside];
    [self.m_viewPaymentOptionContainer addSubview:creditCardButton];
    UIButton *applePayButton = [BUYPaymentButton buttonWithType:BUYPaymentButtonTypeBuy style:BUYPaymentButtonStyleWhiteOutline];
    applePayButton.translatesAutoresizingMaskIntoConstraints = NO;
    [applePayButton addTarget:self action:@selector(doCheckoutViaApplePay) forControlEvents:UIControlEventTouchUpInside];
    [self.m_viewPaymentOptionContainer addSubview:applePayButton];
    self.m_viewPaymentOptionContainer.clipsToBounds = YES;

    NSDictionary *views = NSDictionaryOfVariableBindings(creditCardButton, applePayButton);
    [self.m_viewPaymentOptionContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(60)-[creditCardButton]-(60)-|" options:0 metrics:nil views:views]];
    [self.m_viewPaymentOptionContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(60)-[applePayButton]-(60)-|" options:0 metrics:nil views:views]];
    
    [self.m_viewPaymentOptionContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[creditCardButton(44)]-(10)-[applePayButton(==creditCardButton)]-(10)-|" options:0 metrics:nil views:views]];
   // self.m_lblSubtotalPrice.text = [APSShopifyBuyManager sharedInstance].m_checkout.paymentDue.stringValue;
    //NSLog(@"Price is %@",[APSShopifyBuyManager sharedInstance].m_checkout.paymentDue );
    self.m_viewPaymentOptionWrapper.hidden = YES;
    self.m_lblSubTotalText.text = NSLocalizedString(@"Bag subtotal", nil);


}
- (void) reloadSubTotal{
    float price = 0;
    for (int i =0 ; i < (int) [[APSBagManager sharedInstance].m_arrItems count]; i++) {
        APSBagItemDataModel * item = [[APSBagManager sharedInstance].m_arrItems objectAtIndex:i];
        price = price + [item.m_variant.price floatValue] * item.m_nQuantity;
    }
    price = price + [APSBagManager sharedInstance].appleGiftMessageQuantity * [[APSShopifyBuyManager sharedInstance].m_appleGiftProductVariant.price floatValue];
    self.m_lblSubtotalPrice.text = [APSGenericFunctionManager beautifyPrice:price];
}
- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self refreshFields];
    [self reloadSubTotal];
}

- (void) refreshFields{
    self.m_arrAppleGiftSelected = [[NSMutableArray alloc] init];
    self.m_arrDidPayForAppleGift = [[NSMutableArray alloc] init];

    self.m_arrFreeGiftSelected = [[NSMutableArray alloc] init];

    self.m_arrItemEditingQuantity = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [[APSBagManager sharedInstance].m_arrItems count]; i++){
        [self.m_arrAppleGiftSelected addObject:[NSNumber numberWithBool:NO]];
        [self.m_arrFreeGiftSelected addObject:[NSNumber numberWithBool:NO]];
        [self.m_arrDidPayForAppleGift addObject:[NSNumber numberWithBool:NO]];

        [self.m_arrItemEditingQuantity addObject:[NSNumber numberWithBool:NO]];
    }
    
    [self.m_tableview reloadData];
}

#pragma mark -Biz Logic

- (void) configureCell:(APSBagTVC *) cell AtIndex: (int) index{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    APSBagItemDataModel *item = [[APSBagManager sharedInstance].m_arrItems objectAtIndex:index];
    NSLog(@"Quantity %d", item.m_nQuantity);
    cell.m_lblNotes.text = item.m_szNotes;
    NSString * appleGiftMsg =@"Apple Gift Message:";
    NSString * freeGiftMessage =@"Free Gift Message:";

    if ([item.m_szNotes containsString:appleGiftMsg])
        cell.m_txtMessage.text = [item.m_szNotes substringFromIndex:appleGiftMsg.length];
    else if ([item.m_szNotes containsString:freeGiftMessage])
        cell.m_txtMessage.text = [item.m_szNotes substringFromIndex:freeGiftMessage.length];
    else
        cell.m_txtMessage.text = item.m_szNotes;
    
    cell.m_textviewNotes.text = item.m_szNotes;
    cell.m_txtQuantity.text = [NSString stringWithFormat:@"%d", item.m_nQuantity];
    cell.m_txtQuantity.tag = index;
    cell.m_lblTitle.text = [NSString stringWithFormat:@"%@ %@", item.m_product.title, item.m_variant.title];
    cell.m_Description.preferredMaxLayoutWidth = cell.m_Description.frame.size.width;
    cell.m_Description.text = item.m_variant.product.stringDescription;
    cell.m_lblConfiguration.text = NSLocalizedString(@"Configuration", nil);
    cell.m_lblDeliveryCaption.text = NSLocalizedString(@"Delivery time", nil);
    cell.m_lblDeliveryDays.text = NSLocalizedString(@"1 - 10 Days", nil);
    cell.m_lblPrice.text = [APSGenericFunctionManager beautifyPrice:[item.m_variant.price floatValue] * item.m_nQuantity];
    [self setUIImageView:cell.m_imgProduct WithUrl:[managerBuy getImageUrlWithCollectionIndex:item.m_indexCollection
                                                                                 ProductIndex:item.m_indexProduct
                                                                                 VariantIndex:item.m_indexVariant] DefaultImage:nil];
    
    cell.m_textviewNotes.layer.cornerRadius = 3;
    cell.m_textviewNotes.layer.borderWidth = 1;
    cell.m_textviewNotes.layer.borderColor = APSUICOLOR_GRAY.CGColor;
    cell.m_btnClear.backgroundColor = APSUICOLOR_GRAY;
    cell.m_btnClear.layer.cornerRadius = 3;
    cell.m_btnClear.clipsToBounds = YES;
    cell.m_btnClear.layer.borderWidth = 0;
    cell.m_btnSave.backgroundColor = APSUICOLOR_GREEN;
    cell.m_btnSave.layer.cornerRadius = 3;
    cell.m_btnSave.clipsToBounds = YES;
    cell.m_btnSave.layer.borderWidth = 0;
    cell.m_btnNotes.layer.borderWidth = 1;
    cell.m_btnNotes.layer.cornerRadius = 3;
  

    BOOL appleSelected = [[self.m_arrAppleGiftSelected objectAtIndex:index] boolValue];
    BOOL freeSelected = [[self.m_arrFreeGiftSelected objectAtIndex:index] boolValue];

    if (appleSelected == YES || freeSelected){
     //   cell.m_constraintNotesEditHeight.constant = 110;
       // cell.m_viewNotesEdit.hidden = NO;
        //cell.m_btnNotes.layer.borderColor = APSUICOLOR_BLUE.CGColor;
            cell.m_constraintGiftMessage.constant = 120;
        cell.m_giftMessageView.hidden = NO;
      //  cell.m_btnAppleGiftMessage.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    }
    else {
        //cell.m_constraintNotesEditHeight.constant = 0;
        //cell.m_viewNotesEdit.hidden = YES;
        //cell.m_btnNotes.layer.borderColor = APSUICOLOR_GRAY.CGColor;
            cell.m_constraintGiftMessage.constant = 0;
        cell.m_giftMessageView.hidden = YES;
     //   cell.m_btnAppleGiftMessage.layer.borderColor = APSUICOLOR_GRAY.CGColor;
        
    }
    
    BOOL editingQuantity = [[self.m_arrItemEditingQuantity objectAtIndex:index] boolValue];
    if (editingQuantity == YES){
        cell.m_lblPrice.hidden = YES;
       // cell.m_txtQuantity.hidden = NO;
    }
    else {
        cell.m_lblPrice.hidden = NO;
     //   cell.m_txtQuantity.hidden = YES;
    }
    
    cell.m_btnAppleGiftMessage.tag = index;
    cell.m_btnFreeGiftMessage.tag = index;
    cell.m_btnGiftCancel.tag = index;
    cell.m_btnGiftSave.tag = index;
    
    cell.m_btnSave.tag = index;
    cell.m_btnNotes.tag = index;
    cell.m_btnClear.tag = index;
    
    [cell.m_btnGiftSave setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [cell.m_btnAppleGiftMessage setTitle:NSLocalizedString(@"Apple Gift Package $5", nil) forState:UIControlStateNormal];
    [cell.m_btnFreeGiftMessage setTitle:NSLocalizedString(@"Gift Message Free", nil) forState:UIControlStateNormal];
    [cell.m_btnGiftCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
  
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}



- (void) onNotesClickAtIndex: (int) index{
    BOOL selected = [[self.m_arrAppleGiftSelected objectAtIndex:index] boolValue];
    selected = !selected;
    [self.m_arrAppleGiftSelected replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    
    [self.m_tableview beginUpdates];
    [self.m_tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    [self configureCell:[self.m_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] AtIndex:index];

    [self.m_tableview endUpdates];
}

- (void) onNotesClearClickAtIndex: (int) index{
    APSBagItemDataModel *item = [[APSBagManager sharedInstance].m_arrItems objectAtIndex:index];
    APSBagTVC *cell = [self.m_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    item.m_szNotes = @"";
    cell.m_textviewNotes.text = item.m_szNotes;
    cell.m_lblNotes.text = item.m_szNotes;
    
    [self onNotesClickAtIndex:index];
}

- (void) onNotesSaveClickAtIndex: (int) index{
    APSBagItemDataModel *item = [[APSBagManager sharedInstance].m_arrItems objectAtIndex:index];
    APSBagTVC *cell = [self.m_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    item.m_szNotes = cell.m_textviewNotes.text;
    cell.m_lblNotes.text = item.m_szNotes;
    
    [self onNotesClickAtIndex:index];
}

- (void) onEditQuantityClickedAtIndex: (int) index{
    [self.m_arrItemEditingQuantity replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:YES]];
    
    [self.m_tableview beginUpdates];
    APSBagTVC *cell = [self.m_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self configureCell:cell AtIndex:index];
    [cell.m_txtQuantity becomeFirstResponder];
    [self.m_tableview endUpdates];
}

- (void) onSaveQuantityAtIndex: (int) index{
    [self.m_arrItemEditingQuantity replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];
    APSBagTVC *cell = [self.m_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    int quantity = [cell.m_txtQuantity.text intValue];
    if (quantity < 1 || quantity > 999) quantity = 1;
    
    APSBagItemDataModel *item = [[APSBagManager sharedInstance].m_arrItems objectAtIndex:index];
    item.m_nQuantity = quantity;
    
    [self.m_tableview beginUpdates];
    [self configureCell:[self.m_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] AtIndex:index];
    [self.m_tableview endUpdates];
    [self reloadSubTotal];
}

- (void) deleteItemAtIndex: (int) index{
    APSBagManager *managerBag = [APSBagManager sharedInstance];
    [managerBag.m_arrItems removeObjectAtIndex:index];
    
    [self.m_tableview beginUpdates];
    [self.m_tableview deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.m_tableview endUpdates];
}

- (void) onDeleteClickedAtIndex: (int) index{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Warning!", nil)
                                          message:NSLocalizedString(@"Are you sure you want to delete this item?", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionDelete = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Delete", @"Delete action")
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action)
                                  {
                                      [self deleteItemAtIndex:index];
                                  }];
    UIAlertAction *actionCancel = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    [alertController addAction:actionDelete];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
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

- (void) doCheckoutViaCC {
    [self hidePaymentOption];
    
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

- (void) doCheckoutViaApplePay{
    [self hidePaymentOption];
    
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    [managerBuy buildCartFromBag];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = NSLocalizedString(@"Please wait...", nil);
    
    [managerBuy requestCreateCheckoutWithCallback:^(int status) {
        [hud hideAnimated:YES];
        if (status == ERROR_NONE){
            [self checkoutViaApplePay];
        }
        else{
            [APSGenericFunctionManager showAlertWithMessage:NSLocalizedString(@"Failed to request checkout. Please try again!", nil)];
        }
    }];
}
- (void) checkoutViaApplePay{
    //Loop through all lineitems and generate NSDictionary for each item, and add them to the mutablearray.
    
  }




/*
- (void) checkoutViaApplePay{
 
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
  //  self.applePayAuthorizationDelegate = [[BUYApplePayAuthorizationDelegate alloc] initWithClient:managerBuy.m_client checkout:managerBuy.m_checkout shopName:managerBuy.m_shop.name];

    PKPaymentRequest *request = [self paymentRequestForApplePay];
    
    PKPaymentAuthorizationViewController *paymentController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    if (paymentController == nil){
        [APSGenericFunctionManager showAlertWithMessage:@"This device cannot make payments via Apple Pay."];
        
        return;
    }
#warning Apple Pay helper code removed in this class! add the delegates for payment provider
    self.m_applePayHelper = [[BUYApplePayAuthorizationDelegate alloc] initWithClient:managerBuy.m_client checkout:managerBuy.m_checkout shopName:managerBuy.m_shop.name];
   // self.m_applePayHelper = [[BUYApplePayHelpers alloc] initWithClient:managerBuy.m_client checkout:managerBuy.m_checkout shop:managerBuy.m_shop];
    //self.applePayProvider = [[BUYApplePayPaymentProvider alloc]initWithClient:managerBuy.m_client merchantID:SHOPIFYBUY_MERCHANT_ID];
 //   self.applePayProvider.delegate = self;
    
    paymentController.delegate = self;
    
    //  https://help.shopify.com/api/sdks/mobile-buy-sdk/ios/integration-guide/checkout#apple-pay
    
     Payment Providers
     
     If your app does not require a custom checkout experience, you should use a payment provider to manage checkout for you. The SDK includes two provider types: Web and Apple Pay.
     
     In order to use a payment provider, you do the following:
     
     Instantiate the provider type you intend to use (BUYApplePayPaymentProvider or BUYWebCheckoutPaymentProvider).
     Optionally, instantiate BUYPaymentController to keep shared instances of payment providers.
     Register the payment provider with the payment controller.
     Before starting checkout, set a delegate object on the payment provider.
     Send the -startCheckout: message to the payment provider, and include the checkout object.
     Your payment provider delegate must adopt the BUYPaymentProviderDelegate protocol:
     
     - (void)paymentProvider:(id <BUYPaymentProvider>)provider wantsControllerPresented:(UIViewController *)controller
     {
     [self presentViewController:controller];
     }
     
     - (void)paymentProviderWantsControllerDismissed:(id <BUYPaymentProvider>)provider
     {
     [self dismissViewControllerAnimated:YES completion:nil];
     }
     
     - (void)paymentProvider:(id <BUYPaymentProvider>)provider didCompleteCheckout:(BUYCheckout *)checkout withStatus:(BUYStatus)status
     {
     if (status == BUYStatusComplete) {
     // Now the checkout is complete and you can discard it, and clean up
     self.checkout = nil;
     }
     else {
     // status will be 'BUYStatusFailed'; handle error
     }
     }
     The payment provider will manage interactions with the view controller.. Your delegate only needs to present and dismiss the payment view controller.
     
     To be notified when the checkout completes, you can implement -paymentProvider:didCompleteCheckout:withStatus:. Alternately, listen for the BUYPaymentProviderDidCompleteCheckoutNotificationKey notification.
     
     Additional delegate methods are available to provide more fine-grained updates on the progress of the payment process.
     

     ----------
     BUYApplePayPaymentProvider
     
     Use the BUYApplePayPaymentProvider class to facilitate payment with Apple Pay. This class will handle the work of showing the Apple Pay view controller.
     
     Create an instance of BUYApplePayPaymentProvider, passing in an instance of BUYClient, and your Apple Pay merchant ID:
     
     BUYApplePayPaymentProvider *applePayProvider = [[BUYApplePayPaymentProvider alloc] initWithClient:self.client merchantID:self.merchantID];
     applePayProvider.delegate = self;
     [applePayProvider startCheckout:self.checkout];
     The payment provider will invoke the completion delegate callback -paymentProvider:didCompleteCheckout:withStatus:
     
     */
    
    /**
     *  Alternatively we can set the delegate to self.applePayHelper.
     *  If you do not care about any PKPaymentAuthorizationViewControllerDelegate callbacks
     *  uncomment the code below to let BUYApplePayHelpers take care of them automatically.
     *  You can then also safely remove the PKPaymentAuthorizationViewControllerDelegate
     *  methods below.
     *
     *  // paymentController.delegate = self.applePayHelper
     *
     *  If you keep self as the delegate, you have a chance to intercept the
     *  PKPaymentAuthorizationViewControllerDelegate callbacks and add any additional logging
     *  and method calls as you need. Ensure that you forward them to the BUYApplePayHelpers
     *  class by calling the delegate methods on BUYApplePayHelpers which already implements
     *  the PKPaymentAuthorizationViewControllerDelegate protocol.
     *
     
    [self presentViewController:paymentController animated:YES completion:nil];

}
*/
- (PKPaymentRequest *)paymentRequestForApplePay
{
    APSShopifyBuyManager *managerShopify = [APSShopifyBuyManager sharedInstance];
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    
    [paymentRequest setMerchantIdentifier:SHOPIFYBUY_MERCHANT_ID];
    [paymentRequest setRequiredBillingAddressFields:PKAddressFieldAll];
    [paymentRequest setRequiredShippingAddressFields:managerShopify.m_checkout.requiresShipping ? PKAddressFieldAll : PKAddressFieldEmail|PKAddressFieldPhone];
    [paymentRequest setSupportedNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard]];
    [paymentRequest setMerchantCapabilities:PKMerchantCapability3DS];
    [paymentRequest setCountryCode:managerShopify.m_shop.country ?: @"US"];
    [paymentRequest setCurrencyCode:managerShopify.m_shop.currency ?: @"USD"];
    
    [paymentRequest setPaymentSummaryItems:[managerShopify.m_checkout buy_summaryItemsWithShopName:managerShopify.m_shop.name]];
    
    return paymentRequest;
}

- (void) startCheckout{
    APSBagManager *managerBag = [APSBagManager sharedInstance];
    if ([managerBag.m_arrItems count] == 0){
        [APSGenericFunctionManager showAlertWithMessage:NSLocalizedString(@"Please add item to cart before checkout.", nil)];
        return;
    }
  //  [self showPaymentOption];
     [[APSShopifyBuyManager sharedInstance] buildCartFromBag];
    [[APSShopifyBuyManager sharedInstance] requestCreateCheckoutWithCallback:^(int status) {
        if (status == ERROR_NONE)
        {
            UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle] ];
            UIViewController * vc = [storyBoard instantiateViewControllerWithIdentifier:@"APS_CHECKOUT_VC"];
            [self.navigationController pushViewController:vc animated:YES];

        }
    }];
    
}

- (void) showPaymentOption{
    if (self.m_viewPaymentOptionWrapper.hidden == NO) return;

    self.m_viewPaymentOptionWrapper.hidden = NO;
    self.m_viewPaymentOptionWrapper.alpha = 0;
    [UIView animateWithDuration:0.25f animations:^{
        self.m_viewPaymentOptionWrapper.alpha = 1;
    } completion:^(BOOL finished) {
        self.m_viewPaymentOptionWrapper.alpha = 1;
    }];
}

- (void) hidePaymentOption{
    if (self.m_viewPaymentOptionWrapper.hidden == YES) return;
    self.m_viewPaymentOptionWrapper.hidden = NO;
    self.m_viewPaymentOptionWrapper.alpha = 1;
    [UIView animateWithDuration:0.25f animations:^{
        self.m_viewPaymentOptionWrapper.alpha = 0;
    } completion:^(BOOL finished) {
        self.m_viewPaymentOptionWrapper.hidden = YES;
        self.m_viewPaymentOptionWrapper.alpha = 1;
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

- (void) gotoThankyou{
    [[APSBagManager sharedInstance] clearBag];
    [[APSShopifyBuyManager sharedInstance] clearCart];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Bag" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_BAG_THANKYOU"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark -UITableview Event Listeners

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (int) [[APSBagManager sharedInstance].m_arrItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *szCellIdentifier = @"TVC_BAG";
    if (self.m_savedCell == nil){
        self.m_savedCell = [tableView dequeueReusableCellWithIdentifier:szCellIdentifier];
    }
    
    [self configureCell:self.m_savedCell AtIndex:(int) indexPath.row];
    
    [self.m_savedCell setNeedsUpdateConstraints];
    [self.m_savedCell updateConstraintsIfNeeded];
    self.m_savedCell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.m_savedCell.bounds));
    
    [self.m_savedCell setNeedsLayout];
    [self.m_savedCell layoutIfNeeded];
    CGFloat height = [self.m_savedCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    APSBagTVC *cell = (APSBagTVC *) [tableView dequeueReusableCellWithIdentifier:@"TVC_BAG"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    int index = (int) indexPath.row;
    BOOL selected = [[self.m_arrAppleGiftSelected objectAtIndex:index] boolValue];
    BOOL editingQuantity = [[self.m_arrItemEditingQuantity objectAtIndex:index] boolValue];
    if (selected == YES || editingQuantity == YES) return NO;
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
//        [tableView endEditing:YES];
    }
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *actionEdit = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Edit", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your editAction here
        [self onEditQuantityClickedAtIndex:(int) indexPath.row];
        [tableView setEditing:NO animated:YES];
    }];
    actionEdit.backgroundColor = [UIColor blueColor];

    UITableViewRowAction *actionDelete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Delete", nil)  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your deleteAction here
        [self onDeleteClickedAtIndex:(int) indexPath.row];
    }];
    actionDelete.backgroundColor = [UIColor redColor];
    return @[actionDelete, actionEdit];
}

- (IBAction)onBtnCancelGiftMessage:(id)sender {
    UIButton * giftButton = (UIButton *) sender;
    
    int index = (int)giftButton.tag;
    
  
    [self.m_arrFreeGiftSelected replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];
    [self.m_arrAppleGiftSelected replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];

    [self.m_tableview beginUpdates];
    [self.m_tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.m_tableview endUpdates];
    APSBagTVC * cellAtIndex = [self.m_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cellAtIndex.m_btnAppleGiftMessage.layer.borderColor = APSUICOLOR_GRAY.CGColor;
    cellAtIndex.m_btnFreeGiftMessage.layer.borderColor = APSUICOLOR_GRAY.CGColor;
    if ([cellAtIndex.m_txtMessage isFirstResponder])
        [cellAtIndex.m_txtMessage resignFirstResponder];

}

- (IBAction)onBtnSaveGiftMessage:(id)sender {
    UIButton * saveButton = (UIButton *) sender;
    
    int index = (int)saveButton.tag;
    BOOL freeSelected = [[self.m_arrFreeGiftSelected objectAtIndex:index] boolValue];
    BOOL appleSelected = [[self.m_arrAppleGiftSelected objectAtIndex:index] boolValue];
    
    APSBagItemDataModel *item = [[APSBagManager sharedInstance].m_arrItems objectAtIndex:index];
    
    APSBagTVC * cellAtIndex = [self.m_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    if (freeSelected && !appleSelected)
    {
    if (![cellAtIndex.m_txtMessage.text  isEqual: @""])
    {
    if ( [item.m_szNotes containsString:@"Apple Gift Message"] )
    {[APSGenericFunctionManager showAlertWithMessage:@"You already have Apple Gift Message, cannot add free gift message"];
        [self onBtnCancelGiftMessage:sender];
        return;
    }
        
    item.m_szNotes = [NSString stringWithFormat:@"Free Gift Message:%@ ", cellAtIndex.m_txtMessage.text ];
        NSLog(@"MESSAGE %@",item.m_szNotes);
        
    [APSGenericFunctionManager showAlertWithMessage:@"Gift message saved"];
        [self onBtnCancelGiftMessage:sender];
    }
    else
        [APSGenericFunctionManager showAlertWithMessage:@"Cannot save empty gift message"];
    }
    else if (appleSelected && !freeSelected)
    {
        if (![cellAtIndex.m_txtMessage.text  isEqual: @""])
        {
        item.m_szNotes = [NSString stringWithFormat:@"Apple Gift Message:%@ ", cellAtIndex.m_txtMessage.text ];
        [APSGenericFunctionManager showAlertWithMessage:@"Gift message saved"];
        [self onBtnCancelGiftMessage:sender];
            BOOL giftPaid = [[self.m_arrDidPayForAppleGift objectAtIndex:index] boolValue];
            if (!giftPaid){
        [[APSBagManager sharedInstance] incrementAppleGiftQuantity];
                [self reloadSubTotal];
                [self.m_arrDidPayForAppleGift replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:YES]];
            }
        }
        else
            [APSGenericFunctionManager showAlertWithMessage:@"Cannot save empty gift message"];
    }
}

#pragma mark -UIButton Gift Event Listeners
- (IBAction)onBtnFreeGiftMessage:(id)sender {
    
    UIButton * giftButton = (UIButton *) sender;
    
    int index = (int)giftButton.tag;
    
    BOOL selected = [[self.m_arrFreeGiftSelected objectAtIndex:index] boolValue];

    selected = !selected;
    [self.m_arrFreeGiftSelected replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    [self.m_arrAppleGiftSelected replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];

    [self.m_tableview beginUpdates];
    [self.m_tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.m_tableview endUpdates];
    
    
    APSBagTVC * cellAtIndex = [self.m_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if (selected)
    {
    cellAtIndex.m_btnFreeGiftMessage.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    cellAtIndex.m_btnAppleGiftMessage.layer.borderColor = APSUICOLOR_GRAY.CGColor;
    if (![cellAtIndex.m_txtMessage isFirstResponder])
        [cellAtIndex.m_txtMessage becomeFirstResponder];
    }
    else
    {
        cellAtIndex.m_btnAppleGiftMessage.layer.borderColor = APSUICOLOR_GRAY.CGColor;
        cellAtIndex.m_btnFreeGiftMessage.layer.borderColor = APSUICOLOR_GRAY.CGColor;
    }

}


- (IBAction)onBtnAppleGiftMessage:(id)sender {
    UIButton * giftButton = (UIButton *) sender;

    int index = (int)giftButton.tag;

    BOOL selected = [[self.m_arrAppleGiftSelected objectAtIndex:index] boolValue];
    selected = !selected;
    [self.m_arrAppleGiftSelected replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    [self.m_arrFreeGiftSelected replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];

    [self.m_tableview beginUpdates];
    [self.m_tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.m_tableview endUpdates];

    
    APSBagTVC * cellAtIndex = [self.m_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if (selected)
    {
    cellAtIndex.m_btnAppleGiftMessage.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    cellAtIndex.m_btnFreeGiftMessage.layer.borderColor = APSUICOLOR_GRAY.CGColor;
        if (![cellAtIndex.m_txtMessage isFirstResponder])
            [cellAtIndex.m_txtMessage becomeFirstResponder];
    
    }
    else
    {
        cellAtIndex.m_btnAppleGiftMessage.layer.borderColor = APSUICOLOR_GRAY.CGColor;
        cellAtIndex.m_btnFreeGiftMessage.layer.borderColor = APSUICOLOR_GRAY.CGColor;
        
    }
  //  cellAtIndex.m_constraintGiftMessage.priority = 999;*/
    
    //cellAtIndex.m_isEditingGift = YES;
  //    //
}

#pragma mark -UIButton Event Listeners

- (IBAction)onBtnNotesEditClick:(id)sender {
    [self onNotesClickAtIndex:(int)((UIButton *)sender).tag];
}

- (IBAction)onBtnNotesClearClick:(id)sender {
    [self onNotesClearClickAtIndex:(int)((UIButton *)sender).tag];
}

- (IBAction)onBtnNotesSaveClick:(id)sender {
    [self onNotesSaveClickAtIndex:(int)((UIButton *)sender).tag];
}

- (IBAction)onBtnBuyNowClick:(id)sender {
    [self startCheckout];
}

- (IBAction)onTxtQuantityChanged:(id)sender {
    UITextField *textField = sender;
    [textField endEditing:YES];
    
    int index = (int) textField.tag;
    [self onSaveQuantityAtIndex:index];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    return YES;
}

- (IBAction)onBtnHidePaymentOptionClick:(id)sender {
    APSUserTypeVC * userTypeVC = [[APSUserTypeVC alloc] init];
    
      [self.navigationController pushViewController:userTypeVC animated:YES];
     return;

  //  [self hidePaymentOption];
}

# pragma mark - Web checkout

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller{
    NSLog(@"Safari ViewController dismissed...");
}

- (void)didReceiveCallbackURLNotification:(NSNotification *)notification
{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    NSURL *url = notification.userInfo[@"url"];

    __weak APSBagVC *welf = self;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [managerBuy.m_client getCompletionStatusOfCheckoutURL:url completion:^(BUYStatus status, NSError *error) {
        if (error == nil && status == BUYStatusComplete) {
            NSLog(@"Successfully completed checkout");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

#pragma mark - PKPaymentAuthorizationViewControllerDelegate


- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    // Add additional methods if needed and forward the callback to BUYApplePayHelpers
    [self.m_applePayHelper paymentAuthorizationViewController:controller didAuthorizePayment:payment completion:completion];
    
    [APSShopifyBuyManager sharedInstance].m_checkout = self.m_applePayHelper.checkout;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self gotoThankyou];
    });
    
   /* [self.applePayAuthorizationDelegate paymentAuthorizationViewController:controller didAuthorizePayment:payment completion:^(PKPaymentAuthorizationStatus status) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self gotoThankyou];
        });
        completion(status);

    }];*/
    
}
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    // Add additional methods if needed and forward the callback to BUYApplePayHelpers
    [self.m_applePayHelper paymentAuthorizationViewControllerDidFinish:controller];
  //  [self.applePayAuthorizationDelegate paymentAuthorizationViewControllerDidFinish:controller];
    
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingAddress:(ABRecordRef)address completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKShippingMethod *> * _Nonnull, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
    // Add additional methods if needed and forward the callback to BUYApplePayHelpers
    [self.m_applePayHelper paymentAuthorizationViewController:controller didSelectShippingAddress:address completion:completion];
   /* [self.applePayAuthorizationDelegate paymentAuthorizationViewController:controller didSelectShippingAddress:address completion:^(PKPaymentAuthorizationStatus status, NSArray<PKShippingMethod *> * _Nonnull shippingMethods, NSArray<PKPaymentSummaryItem *> * _Nonnull summaryItems){
        completion(status,shippingMethods,summaryItems);
    }
     ];*/
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingContact:(PKContact *)contact completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKShippingMethod *> * _Nonnull, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
    
    // Add additional methods if needed and forward the callback to BUYApplePayHelpers
    [self.m_applePayHelper paymentAuthorizationViewController:controller didSelectShippingContact:contact completion:completion];
 /*   [self.applePayAuthorizationDelegate paymentAuthorizationViewController:controller didSelectShippingContact:contact completion:^(PKPaymentAuthorizationStatus status, NSArray<PKShippingMethod *> * _Nonnull shippingMethods, NSArray<PKPaymentSummaryItem *> * _Nonnull summaryItems) {
        completion(status,shippingMethods,summaryItems);
    }];*/
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingMethod:(PKShippingMethod *)shippingMethod completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
    // Add additional methods if needed and forward the callback to BUYApplePayHelpers
    [self.m_applePayHelper paymentAuthorizationViewController:controller didSelectShippingMethod:shippingMethod completion:completion];
    
   /* [self.applePayAuthorizationDelegate paymentAuthorizationViewController:controller didSelectShippingMethod:shippingMethod completion:^(PKPaymentAuthorizationStatus status, NSArray<PKPaymentSummaryItem *> * _Nonnull summaryItems) {
        completion(status,summaryItems);
    }];*/
}
/*
- (void)paymentProvider:(id <BUYPaymentProvider>)provider wantsControllerPresented:(UIViewController *)controller
{
    [self presentViewController:controller animated:NO completion:NULL];
 //
}

- (void)paymentProviderWantsControllerDismissed:(id <BUYPaymentProvider>)provider
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentProvider:(id <BUYPaymentProvider>)provider didCompleteCheckout:(BUYCheckout *)checkout withStatus:(BUYStatus)status
{
    if (status == BUYStatusComplete) {
        // Now the checkout is complete and you can discard it, and clean up
        APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
        
        managerBuy.m_checkout = checkout;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self gotoThankyou];
        });
    }
    else {
        // status will be 'BUYStatusFailed'; handle error
    }
}*/
@end
