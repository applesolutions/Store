//
//  APSFeaturedCategoryVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/14/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSFeaturedCategoryVC.h"
#import "APSFeaturedCategoryTVC.h"
#import "Global.h"
#import "APSCollectionManager.h"
#import "APSGenericFunctionManager.h"
#import "APSCollectionDataModel.h"
#import "APSShopifyBuyManager.h"
#import <AFNetworking.h>

@interface APSFeaturedCategoryVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *m_tableviewCategory;

@end

@implementation APSFeaturedCategoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
    
    self.m_tableviewCategory.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.m_tableviewCategory.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableviewCategory.separatorColor = [UIColor clearColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark -Biz Logic

- (void) configureCell: (APSFeaturedCategoryTVC *) cell ProductIndex: (int) indexProduct{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    int index = [managerBuy getIndexFromFeaturedIndex:0];
    if (index == -1) return;
    
    BUYCollection *collection = [managerBuy.m_arrCollection objectAtIndex:index];
    BUYProduct *product = [collection.m_products objectAtIndex:indexProduct];
    BUYImageLink *image0 = [product.images objectAtIndex:0];
    if (image0 == nil || [image0.sourceURL absoluteString] == nil || [image0.sourceURL absoluteString].length==0) {
        [cell.m_imgPhoto setImage:nil];
    }
    else {
        [self setUIImageView:cell.m_imgPhoto WithUrl:[image0.sourceURL absoluteString] DefaultImage:nil];
    }
    
    [cell layoutIfNeeded];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) onFeaturedProductClickAtIndex: (int) indexProduct{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    int index = [managerBuy getIndexFromFeaturedIndex:0];
    if (index == -1) return;
    
    managerBuy.m_indexCollectionSelected = index;
    managerBuy.m_indexProductSelected = indexProduct;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Shop" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_SHOP_PRODUCT_ADD"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark -UITableView Event Listeners

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    int index = [managerBuy getIndexFromFeaturedIndex:0];
    if (index == -1) return 0;
    
    BUYCollection *collection = [managerBuy.m_arrCollection objectAtIndex:index];
    return [collection.m_products count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 320.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    APSFeaturedCategoryTVC *cell = (APSFeaturedCategoryTVC *) [tableView dequeueReusableCellWithIdentifier:@"TVC_FEATURED_CATEGORY"];
    [self configureCell:cell ProductIndex:(int) indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self onFeaturedProductClickAtIndex:(int) indexPath.row];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:APSLOCALNOTIFICATION_COLLECTION_FEATURED_UPDATED]){
        [self.m_tableviewCategory reloadData];
    }
}
@end
