//
//  APSMobilePayInfoVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 8/18/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSMobilePayInfoVC.h"
#import "APSGenericFunctionManager.h"
#import "APSShippingRatesViewController.h"
#import "APSShopifyBuyManager.h"
#import <Buy/Buy.h>
@import MapKit;
#import "APSCheckBoxTVC.h"
#import "Global.h"

typedef NS_ENUM (NSInteger, UITableViewSections){
    UITableViewEmailSection,
    UITableViewBillingSection
};
@interface APSMobilePayInfoVC () <UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate>
@property (strong, nonatomic) UIView * m_UserTypeView;
@property (assign, nonatomic) BOOL sameShippingAddress;
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) NSMutableDictionary* location;
@property (strong, nonatomic) NSString * userCountry;
@property (strong, nonatomic) NSDictionary * DK_CountryDictionary;
@property (strong, nonatomic) NSDictionary * EN_CountryDictionary;
@end

int TOTAL_FIELDS = 9;
int SECTION_TWO_COUNT = 7;
int INDEX_FOR_SWITCH = 8;

const float TABLEHEADER_HEIGHT = 55.0;
const float HEIGHT_FOR_SECTIONHEADER = 75.0;
const int SECTION_ONE_COUNT = 2;
const int TOTAL_SECTIONS = 2;
@implementation APSMobilePayInfoVC



- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO];
    // [self findUserLocation];
    self.title = @"";

    self.userData = [[NSMutableDictionary alloc] init];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"GotoNextPageCell"];
    [self fillUserCountry];
    self.tableView.allowsSelection = NO;
    self.clearsSelectionOnViewWillAppear = NO;
    
    // [self initFields];
    
    // self.m_UserTypeView.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true;
    
    // self.tableView.contentInset = UIEdgeInsetsMake(dummyViewHeight, 0, 0, 0);
    //   self.tableView.contentInset = UIEdgeInsetsMake(150, 0, 0, 0);
    
    
    
    /*    self.sections = [[self.fields allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];*/
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// this delegate is called when the app successfully finds your current location

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       NSLog(@"placemark.addressDictionary %@", placemark.addressDictionary);
                       NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                       NSLog(@"placemark.country %@",placemark.country);
                       NSLog(@"placemark.postalCode %@",placemark.postalCode);
                       NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
                       NSLog(@"placemark.locality %@",placemark.locality);
                       NSLog(@"placemark.subLocality %@",placemark.subLocality);
                       NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
                       if (placemark.country!=nil)

                       [self.location setObject:placemark.country forKey:@"country"];
                       if (placemark.postalCode!=nil)
                       [self.location setObject:placemark.postalCode forKey:@"zip"];
                       if (placemark.locality!=nil)

                       [self.location setObject:placemark.locality forKey:@"address"];
                       if (placemark.administrativeArea!=nil)

                       [self.location setObject:placemark.administrativeArea forKey:@"city"];
                       
                   }];
    

}
- (void) findUserLocation{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }else{
        [self.locationManager startUpdatingLocation];
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            NSLog(@"Location Authorization Denied");
            // do some error handling
        }
            break;
        default:{
            [manager startUpdatingLocation];
        }
            break;
    }
}

- (void) fillUserCountry{
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    self.userCountry = [currentLocale displayNameForKey: NSLocaleCountryCode value: countryCode];
    NSLog(@"country %@ %@", self.userCountry, countryCode);
    if (self.userCountry != nil)
    [self.userData setObject:self.userCountry forKey:NSLocalizedString(@"Country", nil)];
    else
        [self.userData setObject:@"Danmark" forKey:NSLocalizedString(@"Country", nil)];
    [self initFields];
    [self initCountryDictionary];
}

- (void) initCountryDictionary{
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    NSMutableArray *countries = [NSMutableArray arrayWithCapacity:[countryCodes count]];
    NSMutableArray *countriesDK = [NSMutableArray arrayWithCapacity:[countryCodes count]];

    for (NSString *countryCode in countryCodes)
    {
        NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
        NSString *country = [[[[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"] displayNameForKey: NSLocaleIdentifier value: identifier] lowercaseString];
         NSString *countryDK = [[[[NSLocale alloc] initWithLocaleIdentifier:@"da_DK"] displayNameForKey: NSLocaleIdentifier value: identifier] lowercaseString];
        
        [countries addObject: country];
        [countriesDK addObject: countryDK];

    }
    
    self.EN_CountryDictionary = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countries];
    self.DK_CountryDictionary = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countriesDK];
    
}
- (void) initFields{
  //  [self.m_titleLbl setTitle:NSLocalizedString(@"MobilePay Info",nil)];
    self.sameShippingAddress = YES;
    self.location = [[NSMutableDictionary alloc] init];
    if (self.isBusinessUser)
    {self.fields = @[
                     @[NSLocalizedString(@"Email", nil),NSLocalizedString(@"Enter your email", nil)],
                    @[NSLocalizedString(@"Phone No", nil),NSLocalizedString(@"Enter your Phone No", nil)],
                    @[NSLocalizedString(@"Company Name", nil),NSLocalizedString(@"Enter your company", nil)],
                    @[NSLocalizedString(@"First Name",nil),@"John"],
                    @[NSLocalizedString(@"Last Name",nil),@"AppleSeed"],
                    @[NSLocalizedString(@"City",nil),@"Copenhagen"],
                    @[NSLocalizedString(@"Address",nil),@"Åboulevard 60"],
                     @[NSLocalizedString(@"Shipping Address", nil),@"Åboulevard 62"],
                     @[@"Checkbox",@"checkbox"],
                    @[NSLocalizedString(@"ZIP",nil),@"2200"],
                    @[NSLocalizedString(@"Country",nil),@"Denmark"]
                         ];
  
    }
    else
    { self.fields =  @[
                       @[NSLocalizedString(@"Email", nil),NSLocalizedString(@"Enter your email", nil)],
                         @[NSLocalizedString(@"Phone No", nil),NSLocalizedString(@"Enter your Phone No", nil)],
                         @[NSLocalizedString(@"First Name",nil),@"John"],
                         @[NSLocalizedString(@"Last Name",nil),@"AppleSeed"],
                         @[NSLocalizedString(@"City",nil),@"Copenhagen"],
                         @[NSLocalizedString(@"Address",nil),@"Åboulevard 60"],
                         @[NSLocalizedString(@"Shipping Address", nil),@"Åboulevard 62"],
                         @[@"Checkbox",@"checkbox"],
                         @[NSLocalizedString(@"ZIP",nil),@"2200"],
                         @[NSLocalizedString(@"Country",nil),@"Denmark"]
                       ];
    }
    
    TOTAL_FIELDS = (int)self.fields.count;
    INDEX_FOR_SWITCH = TOTAL_FIELDS -3;
    SECTION_TWO_COUNT = TOTAL_FIELDS - (SECTION_ONE_COUNT);

    UIButton *btnBuyNow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBuyNow.frame = CGRectMake(0, 0, 60, 25);
    btnBuyNow.layer.masksToBounds = NO;
    btnBuyNow.layer.cornerRadius = 3;
    btnBuyNow.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    btnBuyNow.layer.borderWidth = 1;
    [btnBuyNow setTitle:NSLocalizedString(@"SAVE", nil) forState:UIControlStateNormal];
    [btnBuyNow.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]];

    [btnBuyNow setTitleColor:APSUICOLOR_BLUE forState:UIControlStateNormal];
    [btnBuyNow addTarget:self action:@selector(nextView:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *buyNowItem = [[UIBarButtonItem alloc] initWithCustomView:btnBuyNow];

     self.m_titleLbl.rightBarButtonItem=buyNowItem;
    
 
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, TABLEHEADER_HEIGHT)];
    dummyView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
    self.tableView.tableHeaderView = dummyView;
    [self.tableView registerClass:[APSCheckBoxTVC class] forCellReuseIdentifier:@"switchCell"];
    
    
}



-(IBAction)nextView : (id) sender{
    NSLog(@"nextView");
    [self.view endEditing:YES];
    
    if (self.sameShippingAddress == YES)
    {if ([self.userData objectForKey:NSLocalizedString(@"Address",nil)])
        [self.userData setObject:[self.userData objectForKey:NSLocalizedString(@"Address", nil)] forKey:NSLocalizedString(@"Shipping Address", nil)];
    }
    
    

    if ([self.EN_CountryDictionary objectForKey:[self.userData objectForKey:NSLocalizedString(@"Country", nil)]] != nil)
    {
        [self.userData setObject:[self.EN_CountryDictionary objectForKey:[self.userData objectForKey:NSLocalizedString(@"Country", nil)]] forKey:@"CountryCode"];
        
    }
    else if ([self.DK_CountryDictionary objectForKey:[self.userData objectForKey:NSLocalizedString(@"Country", nil)]] != nil)
    {[self.userData setObject:[self.DK_CountryDictionary objectForKey:[self.userData objectForKey:NSLocalizedString(@"Country", nil)]] forKey:@"CountryCode"];
    }
    else
    {[APSGenericFunctionManager showAlertWithMessage:@"Invalid Country"];
    return;}
    
    if ([self.userData allKeys].count < TOTAL_FIELDS) // Subtracting 1 to make up for the checkbox entry in fields array BUT adding 1 again to make up for CountryCode,
    {  [APSGenericFunctionManager showAlertWithMessage:@"Please fill all fields before proceeding."];
        return;
    }/*
    UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    APSShippingRatesViewController * vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"APS_ShippingRates"];
    vc.shippingAddress = [self getAddress];
    vc.isBusinessUser = self.isBusinessUser;
    vc.userData = self.userData;
    [self.navigationController pushViewController:vc animated:YES];*/
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];

    [prefs setObject:self.userData forKey:@"user_pay_dictionary"];
   // [prefs setObject:[self getAddress] forKey:@"user_ship_address"];
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TOTAL_SECTIONS;
}
/*
- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{

    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

        [self nextView];
    }
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
     
        case UITableViewEmailSection:
            return SECTION_ONE_COUNT;
            break;
       
        case UITableViewBillingSection:
            return SECTION_TWO_COUNT;
            break;
        default:
            break;
    }
    return 0;

}
- (void) configureCell:(APSMobilePayInfoTVC *)infoCell AtIndexPath:(NSIndexPath *)indexPath{
    int index = 0;
    
    switch (indexPath.section) {
        case UITableViewEmailSection:
            index = (int)indexPath.row;
            break;
 
        case UITableViewBillingSection:
            index = (int) (indexPath.row + SECTION_ONE_COUNT * indexPath.section);
            

            break;
        
        default:
            break;
    }
    /*if ([fieldName containsString:NSLocalizedString(@"Country", nil)])
     {
     if ([self.location objectForKey:@"country"] != nil)
     {    infoCell.m_textField.text = [self.location objectForKey:@"country"];
     [self.userData setObject:[self.location objectForKey:@"country"] forKey:NSLocalizedString(@"Country", nil)];}
     }
     else if ([fieldName containsString:NSLocalizedString(@"City", nil)])
     {
     if ([self.location objectForKey:@"city"] != nil)
     { infoCell.m_textField.text = [self.location objectForKey:@"city"];
     [self.userData setObject:[self.location objectForKey:@"city"] forKey:NSLocalizedString(@"City", nil)];
     
     }
     }
     else if ([fieldName isEqualToString:NSLocalizedString(@"Address", nil)])
     {
     if ([self.location objectForKey:@"address"] != nil)
     {    infoCell.m_textField.text = [self.location objectForKey:@"address"];
     [self.userData setObject:[self.location objectForKey:@"address"] forKey:NSLocalizedString(@"Address", nil)];
     
     }
     }
     else if ([fieldName containsString:NSLocalizedString(@"ZIP", nil)])
     {
     if ([self.location objectForKey:@"zip"] != nil)
     {infoCell.m_textField.text = [self.location objectForKey:@"zip"];
     [self.userData setObject:[self.location objectForKey:@"zip"] forKey:NSLocalizedString(@"ZIP", nil)];
     
     }
     }*/

    infoCell.m_label.text = self.fields[index][0];
    infoCell.m_textField.placeholder = self.fields[index][1];
    NSString * fieldName = (NSString *) self.fields[index][0];
    
    if (index == 1 || index == TOTAL_FIELDS -2)
        [infoCell.m_textField setKeyboardType:UIKeyboardTypeNumberPad];
    else
        [infoCell.m_textField setKeyboardType:UIKeyboardTypeDefault];
    
     if ([fieldName containsString:NSLocalizedString(@"Country",nil)])
    {
        if (self.userCountry !=nil)
        {infoCell.m_textField.text = self.userCountry;
            [self.userData setObject:[self.userCountry lowercaseString] forKey:NSLocalizedString(@"Country", nil)];

        
        }
        else
        { infoCell.m_textField.text = @"Danmark";
            [self.userData setObject:@"danmark" forKey:NSLocalizedString(@"Country", nil)];
        }

        
    }
    infoCell.m_textField.tag = index;
    infoCell.tag = index;
    if (infoCell.tag == TOTAL_FIELDS -1)
    {
        [infoCell.m_textField setReturnKeyType:UIReturnKeyDone];
    }
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row  == (INDEX_FOR_SWITCH-SECTION_ONE_COUNT -1) && self.sameShippingAddress == YES)
        return 0;
    
    return 44.0;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   if (section == 0)
       return 0.1;
    return HEIGHT_FOR_SECTIONHEADER;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
   
    return @"";
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{   if (section == 0)
    return nil;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 75)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 37, self.tableView.bounds.size.width, 38)];
    UIColor * temp = [UIColor colorWithWhite:0.93 alpha:1.0];
    label.backgroundColor = temp;
    view.backgroundColor = temp;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont fontWithDescriptor:[label.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:17.0];
    switch (section) {
     
        case UITableViewBillingSection:
            label.text= NSLocalizedString(@"Billing Address",nil);
            break;
        
        default:
            break;
    }

    [view addSubview:label];
    return view;
    
 }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
/*    if (indexPath.section == 0 && indexPath.row == 0)
    {
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GotoNextPageCell"];
        cell.textLabel.text = NSLocalizedString(@"Buy Now",nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        return cell;
    }*/
     if (indexPath.row == INDEX_FOR_SWITCH - SECTION_ONE_COUNT)
    {
        APSCheckBoxTVC * cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell"];
        if (cell == nil)
        {
            cell = [[APSCheckBoxTVC alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"switchCell"];
        }
        [cell.m_switch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.sameShippingAddress = cell.m_switch.on;
        cell.m_label.text = NSLocalizedString(@"Shipping address is same as Billing Address", nil);
        cell.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
        cell.m_label.textColor = [UIColor grayColor];
       cell.m_label.font = [UIFont fontWithDescriptor:[cell.m_label.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitCondensed] size:15.0];
        cell.tag = -1;
      //  cell.m_label.backgroundColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    else
    {
        APSMobilePayInfoTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"PayInfo_TVC"];

    if (cell == nil){
        
            cell = [[APSMobilePayInfoTVC alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PayInfo_TVC"];
    }
    
    [self configureCell:cell AtIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;

        return cell;

    }
    return nil;
}
- (void) switchValueChanged: (id) sender{
    UISwitch * shipAddressSwitch = (UISwitch *) sender;
    self.sameShippingAddress = shipAddressSwitch.on;
    NSLog(shipAddressSwitch.on ? @"Yes":@"No");
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
}
- (BOOL) validateCellText: (APSMobilePayInfoTVC *) cell{
 NSString * fieldText = cell.m_textField.text;
    if (cell.tag == 0){
        if ([APSGenericFunctionManager isValidEmailAddress:fieldText] == NO){
            cell.m_textField.textColor = [UIColor redColor];
            [APSGenericFunctionManager showAlertWithMessage:@"Invalid email address."];
            if ([self.userData objectForKey:cell.m_label.text])
                [self.userData removeObjectForKey:cell.m_label.text];
            return NO ;
        }
        else
        {
            [self.userData setObject:cell.m_textField.text forKey:cell.m_label.text];
        }
    }
    else
    {
        if ([APSGenericFunctionManager isValidString:fieldText] == NO){
            cell.m_textField.textColor = [UIColor redColor];
            if ([cell.m_label.text containsString:NSLocalizedString(@"Country", nil)])
                if ([self.userData objectForKey:@"CountryCode"])
                    [self.userData removeObjectForKey:@"CountryCode"];


            if ([self.userData objectForKey:cell.m_label.text])
            [self.userData removeObjectForKey:cell.m_label.text];
            return NO;
        }
        else
        {
            if ([cell.m_label.text containsString:NSLocalizedString(@"Country", nil)])
            [self.userData setObject:[cell.m_textField.text lowercaseString] forKey:cell.m_label.text];
            else
            [self.userData setObject: cell.m_textField.text forKey:cell.m_label.text];
    
        }
        
    }

    return YES;
}

- (IBAction) didFinishEditingText:(id)sender{
    APSMobilePayInfoTVC * cell = (APSMobilePayInfoTVC *)[ [sender superview] superview];

    if (![self validateCellText:cell])
        return;
}
- (IBAction)didPerformPrimaryAction:(id)sender{
    APSMobilePayInfoTVC * cell = (APSMobilePayInfoTVC *)[ [sender superview] superview];
    if (![self validateCellText:cell])
        return;
    
        if (cell.tag == TOTAL_FIELDS -1){
        if ([cell.m_textField isFirstResponder])
        [cell.m_textField resignFirstResponder];
        
       }
    else{
    UITableView *table = (UITableView *)[cell superview];
        [cell.m_textField resignFirstResponder];

        APSMobilePayInfoTVC * newCell;
        if (cell.tag == INDEX_FOR_SWITCH-2 && self.sameShippingAddress == YES)
            newCell = (APSMobilePayInfoTVC *) [table viewWithTag:cell.tag + 3]; // Skip 2 cells, one for check box and one for hidden address.
        else if (self.sameShippingAddress == NO && cell.tag == INDEX_FOR_SWITCH-1)
            newCell = (APSMobilePayInfoTVC *) [table viewWithTag:cell.tag + 2]; //just skip the check box cell.
        else
        newCell = (APSMobilePayInfoTVC*) [table viewWithTag:cell.tag+1];
       
        
        if (![newCell.m_textField isFirstResponder])
        [newCell.m_textField becomeFirstResponder];
    }
    //REFER THIS LINK
    //http://stackoverflow.com/questions/29845747/ios-keyboard-hangs-when-changing-input-mode-from-dictation-to-handwriting-very-f
    //FOR THIS ISSUE : AppleSolutions[786:165689] requesting caretRectForPosition: with a position beyond the NSTextStorage (8)
    
}
- (IBAction)textDidChange:(id)sender {
    UITextField * textField = (UITextField *) sender;
    textField.textColor = [UIColor colorWithWhite:0.22 alpha:1.0];
    
}

// Override to support conditional editing of the table view.
/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


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
