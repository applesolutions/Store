//
//  APSAccountHomeVC.m
//  AppleSolutions
//
//  Created AppleSolutions.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSAccountHomeVC.h"
#import "APSAccountManagerTVC.h"
#import "Global.h"
#import "APSGenericFunctionManager.h"
#import "Intercom/intercom.h"
#import <AFNetworking.h>
#import "APSTrackingListVC.h"
@interface APSAccountHomeVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *m_tableviewCategory;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintTableviewHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollview;
@property (weak, nonatomic) IBOutlet UITableView *m_tableviewSearchResults;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintTableviewSearchResultHeight;
@property (weak, nonatomic) IBOutlet UINavigationItem *m_titleLbl;
@property BOOL m_shouldRefreshViews;

@end

@implementation APSAccountHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
     self.m_tableviewCategory.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.m_tableviewCategory.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableviewCategory.separatorColor = [UIColor clearColor];
    [self.m_titleLbl setTitle:NSLocalizedString(@"Account", nil)];
    self.m_shouldRefreshViews = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc{
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.m_shouldRefreshViews == YES){
        [self refreshViewsWithAnimation:NO];
        self.m_shouldRefreshViews = NO;
    }
}

- (void) refreshViewsWithAnimation: (BOOL) animated{
    
    
        int rows = (int) [self tableView:self.m_tableviewCategory numberOfRowsInSection:0];
        float heightForRow = (rows > 0) ? [self tableView:self.m_tableviewCategory heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] : 0;
        float heightForTable = rows * heightForRow;
        self.m_constraintTableviewHeight.constant = heightForTable;
        [self.m_scrollview setContentOffset:CGPointMake(0,0) animated:animated];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void) setUIImageForView: (UIImageView *) imageView WithFileName: (NSString *) imgName DefaultImage: (NSString *) imageDefault{
    if (imageDefault != nil){
        [imageView setImage:[UIImage imageNamed:imageDefault]];
    }
    else{
        [imageView setImage:nil];
    }
     [UIView transitionWithView:imageView duration:TRANSITION_IMAGEVIEW_FADEIN options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [imageView setImage: [UIImage imageNamed:imgName]];
           } completion:nil];
    
}





#pragma mark -Biz Logic

- (void) configureCategoryCell: (APSAccountManagerTVC *) cell forRow: (int) rowIndex{
    
    

    if (rowIndex == 0)
    {    cell.m_lblTitle0.text = NSLocalizedString(@"My Account", nil);
        [self setUIImageForView:cell.m_imgCategory0 WithFileName:@"account-login" DefaultImage:nil];
        cell.m_btnCategory1.hidden = NO;
        cell.m_imgCategory1.hidden = NO;
        cell.m_btnCategory0.tag = 0;
        cell.m_lblTitle1.text = @"Track n' Trace";
        [self setUIImageForView:cell.m_imgCategory1 WithFileName:@"account-track" DefaultImage:nil];
        cell.m_btnCategory1.tag = 1;


    }else if (rowIndex == 1)
    {[self setUIImageForView:cell.m_imgCategory0 WithFileName:@"account-chat" DefaultImage:nil];
        cell.m_lblTitle0.text = @"Chat";
        cell.m_btnCategory0.tag = 2;
        cell.m_btnCategory1.tag = 3;

        cell.m_btnCategory1.hidden = NO;
        cell.m_imgCategory1.hidden = NO;
        cell.m_lblTitle1.text = @"Click & Collect";
        [self setUIImageForView:cell.m_imgCategory1 WithFileName:@"account-ticketstore" DefaultImage:nil];
    }

    if (rowIndex == 0){
        cell.m_lblSeparatorH0.hidden = NO;
    }
    else {
        cell.m_lblSeparatorH0.hidden = YES;
    }
    
    [cell layoutIfNeeded];
}



- (void) onCategoryClickAtIndex: (int) index{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setInteger:index forKey:@"PageSelected"];
    NSLog(@" Selected Page %d", index);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    if ( index == 0 )
    {
        storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
        
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"accountViewController"];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:vc animated:YES];}
    else if (index == 1){
        APSTrackingListVC * vc = [[APSTrackingListVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (index == 3) {
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_ACCOUNTWEBVIEW"];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (index == 2)
    {
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

}



#pragma mark -UITableView Event Listeners

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return tableView.bounds.size.width / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.m_tableviewCategory){
        APSAccountManagerTVC *cell = (APSAccountManagerTVC *) [tableView dequeueReusableCellWithIdentifier:@"TVC_ACCOUNT_MANAGER"];
        [self configureCategoryCell:cell forRow:(int) indexPath.row];
        return cell;
    }
    return nil;
}

- (IBAction)onBtnCategoryClick:(id)sender {
    UIButton *button = sender;
    int index = (int) button.tag;
    [self onCategoryClickAtIndex:index];
}

@end
