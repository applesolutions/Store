//
//  APSGiftCardVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 9/21/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSGiftCardVC.h"
#import "APSMobilePayInfoTVC.h"
#import "Global.h"
#import "APSShopifyBuyManager.h"
#import "APSGenericFunctionManager.h"
#import "APSBarcodeScannerVC.h"



@implementation APSGiftCardVC

- (void)viewDidLoad {
    self.giftCardsAmount = 0;
    [super viewDidLoad];
    [self.tableView registerClass:[APSMobilePayInfoTVC class] forCellReuseIdentifier:@"GiftCell"];
    UIButton *btnBuyNow = [UIButton buttonWithType:UIButtonTypeCustom];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
    
    btnBuyNow.frame = CGRectMake(0, 0, 60, 25);
    btnBuyNow.layer.masksToBounds = NO;
    btnBuyNow.layer.cornerRadius = 3;
    btnBuyNow.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    btnBuyNow.layer.borderWidth = 1;
    [btnBuyNow setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    [btnBuyNow.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]];
    
    [btnBuyNow setTitleColor:APSUICOLOR_BLUE forState:UIControlStateNormal];
    [btnBuyNow addTarget:self action:@selector(doneView:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:btnBuyNow];
    self.giftCards = @"";
    [self.m_txtPin setPlaceholder:NSLocalizedString(@"Required", nil)];
    self.navigationItem.rightBarButtonItem=rightBarItem;
    [self.navigationItem setHidesBackButton:YES];
    self.title = NSLocalizedString(@"Gift Cards",nil);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self reloadAmountViews];
}
- (void) viewWillAppear:(BOOL)animated{
    self.giftCards = @"";
    self.giftCardsAmount = 0;

}
- (IBAction)doneView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    //self.parentVC.checkout = self.checkout;
    APSCheckoutVC * vc = (APSCheckoutVC *) [self.navigationController topViewController];
    vc.checkout = self.checkout;
   // [[NSUserDefaults standardUserDefaults] setObject:self.giftCards forKey:@"GiftCards"];
   /* if (_delegate && [_delegate respondsToSelector:@selector(APSGiftCardDismissWithData:)])
    {
        if (self.giftCards == nil)
            self.giftCards = @"";
        NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
        [data setObject:self.giftCards forKey:@"GiftCards"];
        [data setObject:[NSDecimalNumber numberWithFloat: self.giftCardsAmount] forKey:@"GiftAmount"];
        [_delegate APSGiftCardDismissWithData:data];
    }*/
}
- (IBAction)onBarCodeClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    APSBarcodeScannerVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_BARCODE"];
    vc.isRequestFrom = GiftCardsVC;
    [self presentViewController:vc animated:YES completion:^{
        //        [self searchBarCancelButtonClicked:self.m_barSearch];
        //self.m_barSearch.text = @"";
       // [self.m_barSearch endEditing:YES];
      //  [[APSShopifyBuyManager sharedInstance] searchProductsByKeywords:@""];
    //    [self.m_tableviewSearchResults reloadData];
      //  self.m_isSearchResultShown = NO;
        //[self refreshViewsWithAnimation:NO];
        
    }];

}
- (void) onLocalNotificationReceived:(NSNotification *) notification
{ if ([[notification name] isEqualToString:APSLOCALNOTIFICATION_GIFTCARD_RECOGNIZED]){
        NSString *code = [APSGenericFunctionManager refineNSString:[notification.userInfo objectForKey:@"_CODE"]];
        //  NSString *type = [APSGenericFunctionManager refineNSString:[notification.userInfo objectForKey:@"_TYPE"]];
    NSLog(@"CODE %@", code);
    NSString * removeString = @"shopify-giftcard-v1-";
    code = [code substringFromIndex:removeString.length];
    NSLog(@"CODE %@", code);

    [self applyGiftCard:code];
    }
}
- (void) reloadAmountViews{
    self.m_lblGiftAmount.text = [APSGenericFunctionManager beautifyPrice:self.giftCardsAmount];
    self.m_lblTotalPrice.text = [APSGenericFunctionManager beautifyPrice:[self.checkout.paymentDue floatValue]];
    self.m_lblTotal.text = NSLocalizedString(@"Order Total", nil);
    self.m_lblGiftApplied.text = NSLocalizedString(@"Gift Card(s) Applied", nil);
}

- (IBAction)didFinishEditing:(id)sender {
    UITextView * textView = (UITextView *) sender;
    [self applyGiftCard:textView.text];
    textView.text = @"";
    
}
//C5AH A2AE A8FE C44D
- (void) applyGiftCard: (NSString *) giftCardPin{
    if ([giftCardPin isEqualToString:@""])
        return;
    float totalBeforeGift = [self.checkout.paymentDue floatValue];
    [[APSShopifyBuyManager sharedInstance].m_client applyGiftCardCode:giftCardPin toCheckout:self.checkout completion:^(BUYCheckout *checkout, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (error == nil && checkout) {
            
            NSLog(@"Successfully added gift card");
            
            self.giftCardsAmount = self.giftCardsAmount + (totalBeforeGift - [checkout.paymentDue floatValue]);
            NSLog(@"Gift cards %@", ((BUYGiftCard *)[checkout.giftCards objectAtIndex:0]).lastCharacters );
            self.giftCards = [NSString stringWithFormat:@"%@GiftCard: %@ ",self.giftCards,giftCardPin ];
            self.checkout = checkout;
            NSLog(@"gift cards parent %@", self.giftCards);
            [self reloadAmountViews];
            if (_delegate && [_delegate respondsToSelector:@selector(APSGiftCardDismissWithData:)])
            {
                NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
                [data setObject:self.giftCards forKey:@"GiftCards"];
                [data setObject:[NSDecimalNumber numberWithFloat: self.giftCardsAmount] forKey:@"GiftAmount"];
                [_delegate APSGiftCardDismissWithData:data];
            }

            //self.validGiftCard = [alertController.textFields[0] text];
         //   [self.tableView reloadData];
          //  self.didApplyGiftCard = YES;
            
        }
        else {
            [APSGenericFunctionManager showAlertWithMessage:@"Invalid Gift Card"];
            NSLog(@"Error applying gift card: %@", error);
        }
    }];


}
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 66;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return NSLocalizedString(@"ADD A NEW GIFT CARD", nil);
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    APSMobilePayInfoTVC * cell = [tableView dequeueReusableCellWithIdentifier:@"GiftCell"];
    if (cell == nil)
        cell = [[APSMobilePayInfoTVC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GiftCell"];
    
    cell.m_label.text = NSLocalizedString(@"PIN", nil);
    cell.m_textField.placeholder = NSLocalizedString(@"Required", nil);
    
    
    return cell;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
if (indexPath.row == 2)
{
    if (![self.m_txtPin isFirstResponder])
    {
        [self.m_txtPin becomeFirstResponder];
    }
}
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    view.tintColor = [UIColor colorWithWhite:0.93 alpha:1.0];
}

@end
