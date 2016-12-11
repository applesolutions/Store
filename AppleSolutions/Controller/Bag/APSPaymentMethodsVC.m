//
//  APSPaymentMethodsVC.m
//  AppleSolutions
//
//  Created by Dennis Persson on 9/22/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.
//

#import "APSPaymentMethodsVC.h"

@interface APSPaymentMethodsVC ()

@end

typedef NS_ENUM(int, PaymentMethodCells){
PayViaMobilePay,
PayViaCreditCard,
PayInStore,
PayViaInvoice
};


@implementation APSPaymentMethodsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = NSLocalizedString(@"Payment Method", nil);
    [self.tableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
   // [self.tableView setContentOffset:CGPointMake(0, 80)];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void) configureCell: (UITableViewCell *) cell  AtIndex: (int) index{
    
    UIImageView *selBGView;

    switch (index) {
        case PayViaMobilePay:
            selBGView=[[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
            [selBGView setImage:[UIImage imageNamed:@"imgMobilePay.png" ]];
            selBGView.contentMode = UIViewContentModeScaleAspectFit;
            
            //cell.backgroundColor = [UIColor colorWithPatternImage: selBGView.image];
            cell.backgroundView = selBGView;
            //[cell setClipsToBounds:NO];
            break;
        case PayViaCreditCard:
            selBGView=[[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
            [selBGView setImage:[UIImage imageNamed:@"imgPayCC.png" ]];
            selBGView.contentMode = UIViewContentModeScaleAspectFit;
            
            //cell.backgroundColor = [UIColor colorWithPatternImage: selBGView.image];
            cell.backgroundView = selBGView;
            break;
        case PayInStore:
            selBGView=[[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
            [selBGView setImage:[UIImage imageNamed:@"imgPayInStore.png" ]];
            selBGView.contentMode = UIViewContentModeScaleAspectFit;
            
            //cell.backgroundColor = [UIColor colorWithPatternImage: selBGView.image];
            cell.backgroundView = selBGView;
            break;
        case PayViaInvoice:
            selBGView=[[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
            [selBGView setImage:[UIImage imageNamed:@"imgPayInvoice.png" ]];
            selBGView.contentMode = UIViewContentModeScaleAspectFit;
            
            //cell.backgroundColor = [UIColor colorWithPatternImage: selBGView.image];
            cell.backgroundView = selBGView;
            break;
            
        default:
            break;
    }
    [cell.layer setCornerRadius:10.0f];
    [cell.layer setMasksToBounds:YES];

    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [self configureCell:cell AtIndex:(int)indexPath.section];
    
    
    
    // Configure the cell...
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
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
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor colorWithWhite:0.93 alpha:1.0];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSUserDefaults standardUserDefaults] setInteger:(indexPath.section +1) forKey:@"PaymentMethod"];
    [self.navigationController popViewControllerAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
