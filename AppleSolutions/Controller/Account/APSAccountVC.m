//
//  APSAccountVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 12/16/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSAccountVC.h"
#import "APSAccountOrderTVC.h"

@interface APSAccountVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *m_tableview;
@property (weak, nonatomic) IBOutlet UINavigationItem *m_titleLbl;

@property (strong, nonatomic) NSArray *m_arrItems;

@end

@implementation APSAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.m_tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.m_arrItems = @[@[@{@"_ID": @"_FAVOURITE",
                            @"_ICON": @"account-favourite.png",
                            @"_TITLE": @"Favourite",
                            @"_COUNT": @"1",
                            },
                          
                          @{@"_ID": @"_ORDER",
                            @"_ICON": @"account-order.png",
                            @"_TITLE": @"Order",
                            @"_COUNT": @"",
                            },
                          
                          @{@"_ID": @"_RESERVATION",
                            @"_ICON": @"account-reservation.png",
                            @"_TITLE": @"My Reservation",
                            @"_COUNT": @"",
                            },
                          
                          @{@"_ID": @"_SETTINGS",
                            @"_ICON": @"account-settings.png",
                            @"_TITLE": @"Account Settings",
                            @"_COUNT": @"",
                            },
                            ],
                        ];
    [self.m_titleLbl setTitle:NSLocalizedString(@"My Account", nil)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -Tableview Event Listeners



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Order (Favourite, Order, My Reservation, Account Settings)
    // Settings (Log out)
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        NSArray *arr = [self.m_arrItems objectAtIndex:0];
        return [arr count];
    }
    else if (section == 1){
        return 1;
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TVC_ACCOUNT_HEADER_EMPTY"];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int section = (int) indexPath.section;
    int row = (int) indexPath.row;
    
    if (section == 0){
        NSArray *arr0 = [self.m_arrItems objectAtIndex:0];
        NSDictionary *dict = [arr0 objectAtIndex:row];
        
        NSString *szIcon = [dict objectForKey:@"_ICON"];
        NSString *szTitle = [dict objectForKey:@"_TITLE"];
        NSString *szCount = [dict objectForKey:@"_COUNT"];
        
        APSAccountOrderTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_ACCOUNT_ORDER_BODY"];
        cell.m_imgIcon.image = [UIImage imageNamed:szIcon];
        cell.m_lblTiitle.text = szTitle;
        cell.m_lblCount.text = szCount;
        
        return cell;
    }
    else if (section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_ACCOUNT_SIGNOUT_BODY"];
        return cell;
    }
    return nil;
}

@end
