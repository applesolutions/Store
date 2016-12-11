//
//  APSShopProductListVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/14/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSShopProductListVC.h"
#import "APSShopProductListItemTVC.h"
#import "APSGenericFunctionManager.h"
#import "APSShopProductPreviewView.h"
#import "APSShopifyBuyManager.h"
#import "Global.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>

@interface APSShopProductListVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *m_tableviewList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintListHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollviewPreview;
@property (weak, nonatomic) IBOutlet UIView *m_viewPreviewContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintPreviewContentViewWidth;
@property (weak, nonatomic) IBOutlet UIPageControl *m_pager;

@property (strong, nonatomic) BUYCollection *m_collection;
@end

@implementation APSShopProductListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.m_tableviewList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    
    NSLog(@"m_indexCollectionSelected = %d" , managerBuy.m_indexCollectionSelected);
    
    
    self.m_collection = [[BUYCollection alloc] init];
    self.m_collection = [managerBuy.m_arrCollection objectAtIndex:managerBuy.m_indexCollectionSelected];
    
    NSLog(@"self.m_collection = %lu", (unsigned long) [self.m_collection.m_products count]);
    
    if ([self.m_collection.m_products count] == 0){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Please wait...";
        [managerBuy requestProductWithCollectionIndex:managerBuy.m_indexCollectionSelected Callback:^(int status) {
            [hud hideAnimated:YES];
            [self.m_tableviewList reloadData];
            [self refreshFields];
            [self refreshPreviewScrollView];
        }];
    }
    else {
        //crash
        [self.m_tableviewList reloadData];
        [self refreshFields];
        [self refreshPreviewScrollView];
    }
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.navigationItem.title = self.m_collection.title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshFields];
    
    [self refreshPreviewScrollView];
}

- (void) refreshFields{
    int count = (int) [self.m_collection.m_products count];
    self.m_constraintListHeight.constant = 44.0 * count;
//    [self.view layoutIfNeeded];
}

- (void) dealloc{
    NSLog(@"ProductListVC >>>> dealloc fired!");
}

- (void) refreshPreviewScrollView{
    int count = (int) [self.m_collection.m_products count];
    float fWidth = self.m_scrollviewPreview.frame.size.width;
    float fHeight = self.m_scrollviewPreview.frame.size.height;
    
    self.m_scrollviewPreview.translatesAutoresizingMaskIntoConstraints = NO;
    self.m_viewPreviewContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_constraintPreviewContentViewWidth.constant = fWidth * count;

    for (int i = 0; i < (int) [self.m_collection.m_products count]; i++){
        NSLog(@"self.m_collection.m_products = %@", [self.m_collection.m_products objectAtIndex:i]);
        BUYProduct *product = [self.m_collection.m_products objectAtIndex:i];
        
        
        APSShopProductPreviewView *view =  [[[NSBundle mainBundle] loadNibNamed:@"ShopProductPreview" owner:self options:nil] objectAtIndex:0];
        if ([product.images count] > 0) {
        BUYImageLink *image0 = [product.images objectAtIndex:0];
        view.m_lblTitle.text = product.title;
        if (image0 != nil)
            [self setUIImageView:view.m_imgPreview WithUrl:[image0.sourceURL absoluteString] DefaultImage:nil];
        }
        [self.m_viewPreviewContentView addSubview:view];
        
        NSArray *arrConstraintsV = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[view(%d)]", (int) fHeight]
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(view)];
        
        NSArray *arrConstraintsH = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-offsetLeft-[view(%d)]", (int) fWidth]
                                                                               options:0
                                                                               metrics:@{@"offsetLeft": @(fWidth * i)}
                                                                                 views:NSDictionaryOfVariableBindings(view)];
        
        [self.m_viewPreviewContentView addConstraints:arrConstraintsV];
        [self.m_viewPreviewContentView addConstraints:arrConstraintsH];
        
    }
    [self.view layoutIfNeeded];
    
    self.m_pager.numberOfPages = count;
    self.m_pager.currentPage = 0;
    if (count == 0){
    }
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

- (void) configureCell: (APSShopProductListItemTVC *) cell Index: (int) index{
    BUYProduct *product = [self.m_collection.m_products objectAtIndex:index];
    if ([product.images count] > 0)
    {
        BUYImageLink *image0 = [product.images objectAtIndex:0];
        cell.m_lblTitle.text = product.title;

            [self setUIImageView:cell.m_imgPhoto WithUrl:[image0.sourceURL absoluteString] DefaultImage:nil];
    }
}

#pragma mark -UITableview Event Listener

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int count = (int) [self.m_collection.m_products count];
    NSLog(@"[self.m_collection.m_products count] = %lu" , [self.m_collection.m_products count]);
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    APSShopProductListItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_SHOP_PRODUCTLIST"];
    [self configureCell:cell Index:index];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int index = (int) indexPath.row;
    [APSShopifyBuyManager sharedInstance].m_indexProductSelected = index;
    
    [self performSegueWithIdentifier:@"SEGUE_FROM_SHOP_PRODUCTLIST_TO_DETAILS" sender:nil];
}

#pragma mark - scrollview delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentPage = scrollView.contentOffset.x/scrollView.frame.size.width;
    [self.m_pager setCurrentPage:currentPage];
}

@end
