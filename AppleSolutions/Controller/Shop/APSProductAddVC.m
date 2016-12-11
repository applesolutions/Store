//
//  APSProductAddVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/18/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSProductAddVC.h"
#import "APSProductAddVariantTVC.h"
#import "APSBagManager.h"
#import "APSShopifyBuyManager.h"
#import "Global.h"
#import "APSGenericFunctionManager.h"
#import <AFNetworking.h>

@interface APSProductAddVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollview;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgPreview;
@property (weak, nonatomic) IBOutlet UILabel *m_lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *m_lblPriceToCompare;
@property (weak, nonatomic) IBOutlet UILabel *m_lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *m_lblShipping;
@property (weak, nonatomic) IBOutlet UITableView *m_tableviewVariants;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintTableviewVariantsHeight;
@property (weak, nonatomic) IBOutlet UILabel *m_lblInStock;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintPriceToCompareTrail;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *m_btnBuyNow;

@property (strong, nonatomic) BUYProduct *m_product;

@end

@implementation APSProductAddVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.m_tableviewVariants.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.m_tableviewVariants.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIButton *btnBuyNow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBuyNow.frame = CGRectMake(0, 0, 60, 25);
    btnBuyNow.layer.masksToBounds = NO;
    btnBuyNow.layer.cornerRadius = 3;
    btnBuyNow.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    btnBuyNow.layer.borderWidth = 1;
    [btnBuyNow setTitle:NSLocalizedString(@"Buy Now", nil) forState:UIControlStateNormal];
    [btnBuyNow setTitleColor:APSUICOLOR_BLUE forState:UIControlStateNormal];
    btnBuyNow.backgroundColor = [UIColor clearColor];
    [btnBuyNow.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]];
    
    [self.m_btnBuyNow setCustomView:btnBuyNow];
    
    [btnBuyNow addTarget:self action:@selector(onBtnAddClick:) forControlEvents:UIControlEventTouchUpInside];
    
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    BUYCollection *collection = [managerBuy.m_arrCollection objectAtIndex:managerBuy.m_indexCollectionSelected];
    self.m_product = [collection.m_products objectAtIndex:managerBuy.m_indexProductSelected];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.m_constraintTableviewVariantsHeight.constant = 70.0f * ((int) [self.m_product.variants count]);
    BUYImageLink *image0 = [self.m_product.images objectAtIndex:0];
    
    NSString *szImage = image0.sourceURL.absoluteString;
    [self setUIImageView:self.m_imgPreview WithUrl:szImage DefaultImage:nil];
    
    [self refreshFields];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    float scrollHeight = self.m_scrollview.frame.size.height;
    float contentHeight = self.m_scrollview.contentSize.height;
    
    if (contentHeight > scrollHeight){
        [self.m_scrollview setContentOffset:CGPointMake(0, 70.0f * self.m_indexVariant) animated:YES];
    }
}

- (void) refreshFields{
    BUYProductVariant *variant = [self.m_product.variants objectAtIndex:self.m_indexVariant];
    self.m_lblTitle.text = [NSString stringWithFormat:@"%@ %@", self.m_product.title, variant.title];
    self.m_lblPrice.text = [APSGenericFunctionManager beautifyPrice: [variant.price floatValue]];
    
    if ([variant.compareAtPrice isKindOfClass:[NSNull class]] == NO && variant.compareAtPrice != nil && [variant.compareAtPrice floatValue] > 1){
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString: [APSGenericFunctionManager beautifyPrice: [variant.compareAtPrice floatValue]]];
        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                value:@1
                                range:NSMakeRange(0, [attributeString length])];
        self.m_lblPriceToCompare.attributedText = attributeString;
    }
    else {
        self.m_lblPriceToCompare.attributedText = nil;
        self.m_lblPriceToCompare.text = @"";
        self.m_constraintPriceToCompareTrail.constant = 0;
    }
    
    if ([variant.requiresShipping boolValue] == YES){
        self.m_lblShipping.text = NSLocalizedString(@"Shipping", nil);
    }
    else {
        self.m_lblShipping.text = NSLocalizedString(@"No shipping", nil);
    }
    
//    self.m_lblInStock.text = [NSString stringWithFormat:@"In Stock: %@", (variant.available == YES) ? @"YES" : @"NO"];
    self.m_lblInStock.text = NSLocalizedString(@"In stock", nil);
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

#pragma mark -Biz Logic

- (void) configureCell: (APSProductAddVariantTVC *) cell AtIndex: (int) index{
    BUYProductVariant *variant = [self.m_product.variants objectAtIndex:index];
    cell.m_lblTitle.text = variant.title;
    cell.m_lblPrice.text = [NSString stringWithFormat:@"%@", [APSGenericFunctionManager beautifyPrice: [variant.price floatValue]]];
    cell.m_btnView.layer.cornerRadius = 3;
    cell.m_btnView.layer.borderWidth = 1;
    cell.m_btnView.tag = index;
    if (self.m_indexVariant == index){
        cell.m_btnView.layer.borderColor = APSUICOLOR_BLUE.CGColor;
    }
    else {
        cell.m_btnView.layer.borderColor = APSUICOLOR_GRAY.CGColor;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) shareToSocial{
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:self.m_imgPreview.image];
    [sharingItems addObject:self.m_lblTitle.text];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void) addToBag{
    APSShopifyBuyManager *managerBuy = [APSShopifyBuyManager sharedInstance];
    APSBagManager *managerBag = [APSBagManager sharedInstance];
   
    [managerBag addProductToBagWithCollectionIndex:managerBuy.m_indexCollectionSelected
                                      ProductIndex:managerBuy.m_indexProductSelected
                                      VariantIndex:self.m_indexVariant];
    
    self.tabBarController.selectedIndex = 4;
    //gift card id 9068986700
}

#pragma mark -UITableView Event Listeners

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (int) ([self.m_product.variants count]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    APSProductAddVariantTVC *cell = (APSProductAddVariantTVC *) [tableView dequeueReusableCellWithIdentifier:@"TVC_PRODUCT_VARIANT"];
    [self configureCell:(APSProductAddVariantTVC *)cell AtIndex:(int) indexPath.row];
    return cell;
}

#pragma mark -UIButton Event Listeners

- (IBAction)onBtnViewClick:(id)sender {
    UIButton *button = (UIButton *) sender;
    self.m_indexVariant = (int) button.tag;
    [self.m_tableviewVariants reloadData];
    [self refreshFields];
}

- (IBAction)onBtnShareClick:(id)sender {
    [self shareToSocial];
}

- (IBAction)onBtnAddClick:(id)sender {
    [self addToBag];
}

@end
