//
//  APSStoreVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/9/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSStoreVC.h"
#import "APSStoreMenuTVC.h"
#import "APSGenericFunctionManager.h"
#import "Global.h"

@interface APSStoreVC () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *m_tableviewMenu;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgStore;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintMenuHeight;

@property (strong, nonatomic) NSArray *m_arrMenuIcon;
@property (strong, nonatomic) NSArray *m_arrMenuTitle;

#define APSUIALERTVIEWTAG_STORE_ONETOONE                    1000

@end

@implementation APSStoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.m_arrMenuIcon = @[@"stores-findstore.png", @"stores-workshops.png", @"stores-onetoone.png"];
    self.m_arrMenuTitle = @[NSLocalizedString(@"Find nearest store", nil), NSLocalizedString(@"Workshops and Events", nil), NSLocalizedString(@"One to One", nil)];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.m_tableviewMenu.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self refreshFields];
}

- (void) refreshFields{
    CGFloat height = 44 * [self.m_arrMenuTitle count];
    self.m_constraintMenuHeight.constant = height;
    [self.view layoutIfNeeded];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -UITableview Event Listeners

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.m_arrMenuIcon count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    APSStoreMenuTVC *cell = (APSStoreMenuTVC *) [tableView dequeueReusableCellWithIdentifier:@"TVC_STORE_MENU"];
    NSString *szIcon = [self.m_arrMenuIcon objectAtIndex:indexPath.row];
    NSString *szTitle = [self.m_arrMenuTitle objectAtIndex:indexPath.row];
    
    [cell.m_imgIcon setImage: [UIImage imageNamed:szIcon]];
    cell.m_lblTitle.text = szTitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int row = (int) indexPath.row;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Store" bundle:[NSBundle mainBundle]];
    UIViewController *vc;
    
    if (row == 0){
        // Find a store
        vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_STORE_FIND"];
    }
    else if(row == 1) {
        // Workshops and Events
        vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_STORE_WORKSHOP"];
    }
    else if(row == 2) {
        // One to One
        NSString *szPhoneNumber = [APSGenericFunctionManager stripNonnumericsFromNSString:APS_PHONENUMBER_ONETOONE];
        NSURL *phoneUrl = [NSURL URLWithString:[[NSString  stringWithFormat:@"tel:%@",szPhoneNumber] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", nil)
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"Please click YES to call %@", nil), APS_PHONENUMBER_ONETOONE]
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
            
            alert.tag = APSUIALERTVIEWTAG_STORE_ONETOONE;
            [alert show];
        }
        else {
            [APSGenericFunctionManager showAlertWithMessage:NSLocalizedString(@"Phone call is not available on your device.", nil)];
        }
        return;
    }
    else{
        return;
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == APSUIALERTVIEWTAG_STORE_ONETOONE){
        // the user clicked OK
        if (buttonIndex == 1) {
            NSString *szPhoneNumber = [APSGenericFunctionManager stripNonnumericsFromNSString:APS_PHONENUMBER_ONETOONE];
            NSURL *phoneUrl = [NSURL URLWithString:[[NSString  stringWithFormat:@"tel:%@",szPhoneNumber] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            [[UIApplication sharedApplication] openURL:phoneUrl];
        }
    }
}

@end
