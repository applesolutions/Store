//
//  APSShopCategoryVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/11/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSShopCategoryVC.h"
#import "APSShopCategoryTVC.h"
#import "Global.h"
#import "APSGenericFunctionManager.h"
#import "APSCollectionDataModel.h"
#import <AFNetworking.h>
#import "APSShopifyBuyManager.h"
#import "APSSearchResultsTVC.h"
#import "APSProductAddVC.h"
#import "APSBagManager.h"
#import "APSBarcodeScannerVC.h"


@interface APSShopCategoryVC () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *m_tableviewCategory;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintTableviewHeight;
@property (weak, nonatomic) IBOutlet UISearchBar *m_barSearch;
@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollview;
@property (weak, nonatomic) IBOutlet UITableView *m_tableviewSearchResults;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintTableviewSearchResultHeight;

@property BOOL m_isSearchResultShown;
@property BOOL m_shouldRefreshViews;

@end

@implementation APSShopCategoryVC

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
    
    self.m_isSearchResultShown = NO;
    self.m_shouldRefreshViews = YES;
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

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.m_shouldRefreshViews == YES){
        [self refreshViewsWithAnimation:NO];
        self.m_shouldRefreshViews = NO;
    }
}

- (void) refreshViewsWithAnimation: (BOOL) animated{
    float heightForSearchPanel = self.m_barSearch.frame.size.height;
    float heightForScrollview = self.m_scrollview.frame.size.height;
    
    self.m_tableviewSearchResults.hidden = !self.m_isSearchResultShown;
    if (self.m_isSearchResultShown == YES){
        self.m_constraintTableviewHeight.constant = heightForScrollview - heightForSearchPanel;
//        self.m_scrollview.contentOffset = CGPointMake(0,0);
        [self.m_scrollview setContentOffset:CGPointMake(0,0) animated:animated];
    }
    else {
        int rows = (int) [self tableView:self.m_tableviewCategory numberOfRowsInSection:0];
        float heightForRow = (rows > 0) ? [self tableView:self.m_tableviewCategory heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] : 0;
        float heightForTable = rows * heightForRow;
        self.m_constraintTableviewHeight.constant = heightForTable;
//        self.m_scrollview.contentOffset = CGPointMake(0,heightForSearchPanel);
        [self.m_scrollview setContentOffset:CGPointMake(0,heightForSearchPanel) animated:animated];
    }
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

- (void) scanBarcode{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    APSBarcodeScannerVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_BARCODE"];
    vc.isRequestFrom = ProductCategoryVC;
    [self presentViewController:vc animated:YES completion:^{
//        [self searchBarCancelButtonClicked:self.m_barSearch];
        self.m_barSearch.text = @"";
        [self.m_barSearch endEditing:YES];
        [[APSShopifyBuyManager sharedInstance] searchProductsByKeywords:@""];
        [self.m_tableviewSearchResults reloadData];
        self.m_isSearchResultShown = NO;
        [self refreshViewsWithAnimation:NO];

    }];
}

- (void) gotoProductWithBarcode: (NSString *) barCode{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    
    NSDictionary *dict = [managerBuy getProductPathWithBarcode:barCode];
    if (dict != nil){
        int collectionIndex = [[dict objectForKey:@"_COLLECTION"] intValue];
        int productIndex = [[dict objectForKey:@"_PRODUCT"] intValue];
        int variantIndex = [[dict objectForKey:@"_VARIANT"] intValue];
        
        managerBuy.m_indexCollectionSelected = collectionIndex;
        managerBuy.m_indexProductSelected = productIndex;

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Shop" bundle:[NSBundle mainBundle]];
        APSProductAddVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_SHOP_PRODUCT_ADD"];
        vc.m_indexVariant = variantIndex;
        
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else {
        [APSGenericFunctionManager showAlertWithMessage: NSLocalizedString(@"Sorry! This product is not registered.", nil)];
    }
}

#pragma mark -Biz Logic

- (void) configureCategoryCell: (APSShopCategoryTVC *) cell IndexNonFeatured: (int) indexNonFeatured{
    
    NSLog(@"indexNonFeatured = %d" , indexNonFeatured);
    
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    int index0 = [managerBuy getIndexFromNonFeaturedIndex:(indexNonFeatured * 2)];
    int index1 = [managerBuy getIndexFromNonFeaturedIndex:(indexNonFeatured * 2 + 1)];
    
    if (index0 == -1) return;
    
    BUYCollection *collection0 = [managerBuy.m_arrCollection objectAtIndex:index0];
    BUYCollection *collection1 = nil;
    if (index1 > 0){
        collection1 = [managerBuy.m_arrCollection objectAtIndex:index1];
    }

    cell.m_lblTitle0.text = collection0.title;
    [self setUIImageView:cell.m_imgCategory0 WithUrl:[collection0.image.sourceURL absoluteString] DefaultImage:nil];
    
    if (collection1 != nil){
        cell.m_btnCategory1.hidden = NO;
        cell.m_imgCategory1.hidden = NO;
        cell.m_lblTitle1.text = collection1.title;
        
        [self setUIImageView:cell.m_imgCategory1 WithUrl:[collection1.image.sourceURL absoluteString] DefaultImage:nil];
    }
    else{
        cell.m_imgCategory1.hidden = YES;
        cell.m_btnCategory1.hidden = YES;
        cell.m_lblTitle1.text = @"";
    }
    
    if (indexNonFeatured == 0){
        cell.m_lblSeparatorH0.hidden = NO;
    }
    else {
        cell.m_lblSeparatorH0.hidden = YES;
    }
    
    cell.m_btnCategory0.tag = index0;
    cell.m_btnCategory1.tag = index1;
    
    NSLog(@"cell.m_btnCategory0.tag  = %ld" , (long)cell.m_btnCategory0.tag );
    NSLog(@"cell.m_btnCategory1.tag  = %ld" , (long)cell.m_btnCategory1.tag );
    
    [cell layoutIfNeeded];
}


- (void) configureSearchResultCell: (APSSearchResultsTVC *) cell AtIndex: (int) index{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    NSDictionary *dict = [managerBuy.m_arrSearchResult objectAtIndex:index];
    int indexCollection = [[dict objectForKey:@"_COLLECTION"] intValue];
    int indexProduct = [[dict objectForKey:@"_PRODUCT"] intValue];
    
    BUYCollection *collection = [managerBuy.m_arrCollection objectAtIndex:indexCollection];
    BUYProduct *product = [collection.m_products objectAtIndex:indexProduct];
    
    cell.m_lblTitle.text = product.title;
}

- (void) onCategoryClickAtIndex: (int) index{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    if (index >= [managerBuy.m_arrCollection count]) return;
    managerBuy.m_indexCollectionSelected = index;
    
    NSLog(@"managerBuy.m_indexCollectionSelected = %d" , index);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Shop" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_SHOP_PRODUCTLIST"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:vc animated:YES];

}

- (void) onSearchResultClickAtIndex: (int) index{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    NSDictionary *dict = [managerBuy.m_arrSearchResult objectAtIndex:index];
    int indexCollection = [[dict objectForKey:@"_COLLECTION"] intValue];
    int indexProduct = [[dict objectForKey:@"_PRODUCT"] intValue];
    
    managerBuy.m_indexCollectionSelected = indexCollection;
    managerBuy.m_indexProductSelected = indexProduct;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Shop" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_SHOP_PRODUCT_ADD"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -UITableView Event Listeners

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.m_tableviewSearchResults){
        return [[APSShopifyBuyManager sharedInstance].m_arrSearchResult count];
    }
    
    int count = (int) [[APSShopifyBuyManager sharedInstance] getNumberOfNonFeatured];
    return (int) (count + 1) / 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.m_tableviewSearchResults){
        return 44.0f;
        
    }
    return tableView.bounds.size.width / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.m_tableviewSearchResults){
        APSSearchResultsTVC *cell = (APSSearchResultsTVC *) [tableView dequeueReusableCellWithIdentifier:@"TVC_SHOP_SEARCHRESULT"];
        [self configureSearchResultCell:cell AtIndex:(int) indexPath.row];
        return cell;
    }
    else if (tableView == self.m_tableviewCategory){
        APSShopCategoryTVC *cell = (APSShopCategoryTVC *) [tableView dequeueReusableCellWithIdentifier:@"TVC_SHOP_CATEGORY"];
        [self configureCategoryCell:cell IndexNonFeatured:(int) indexPath.row];
        return cell;
    }
    return nil;
}

- (IBAction)onBtnCategoryClick:(id)sender {
    UIButton *button = sender;
    int index = (int) button.tag;
    [self onCategoryClickAtIndex:index];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    if (tableView == self.m_tableviewSearchResults){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self onSearchResultClickAtIndex:(int) indexPath.row];
    }
}

#pragma mark -UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self.m_barSearch setShowsCancelButton:YES animated:YES];
    self.m_isSearchResultShown = YES;
    [self refreshViewsWithAnimation:YES];
    
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self.m_barSearch setShowsCancelButton:NO animated:YES];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSString *keyword = self.m_barSearch.text;
    [[APSShopifyBuyManager sharedInstance] searchProductsByKeywords:keyword];
    [self.m_tableviewSearchResults reloadData];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.m_barSearch.text = @"";
    [self.m_barSearch endEditing:YES];
    [[APSShopifyBuyManager sharedInstance] searchProductsByKeywords:@""];

    self.m_isSearchResultShown = NO;
    [self.m_tableviewSearchResults reloadData];

    [self refreshViewsWithAnimation:YES];
   
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.m_barSearch endEditing:YES];
}

- (IBAction)onBtnBarcodeScanClick:(id)sender {
    [self.m_barSearch endEditing:YES];
    [self scanBarcode];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:APSLOCALNOTIFICATION_COLLECTION_UPDATED]){
        [self.m_tableviewCategory reloadData];
        [self refreshViewsWithAnimation:YES];
    }
    else if ([[notification name] isEqualToString:APSLOCALNOTIFICATION_BARCODE_RECOGNIZED]){
        NSString *code = [APSGenericFunctionManager refineNSString:[notification.userInfo objectForKey:@"_CODE"]];
      //  NSString *type = [APSGenericFunctionManager refineNSString:[notification.userInfo objectForKey:@"_TYPE"]];
        [self gotoProductWithBarcode:code];
    }
}

@end
