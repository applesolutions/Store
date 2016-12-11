//
//  APSProductDetailsVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 11/17/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSProductDetailsVC.h"
#import "APSShopProductListItemTVC.h"
#import "APSShopProductPreviewView.h"
#import "APSShopifyBuyManager.h"
#import "Global.h"
#import "APSGenericFunctionManager.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>

@interface APSProductDetailsVC () <UIScrollViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollviewPreview;
@property (weak, nonatomic) IBOutlet UIView *m_viewPreview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintPreviewWidth;
@property (weak, nonatomic) IBOutlet UIPageControl *m_pager;
@property (weak, nonatomic) IBOutlet UIWebView *m_webview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_constraintWebviewHeight;

@property (strong, nonatomic) BUYProduct *m_product;

@end

@implementation APSProductDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.m_webview.delegate = self;
    
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
    
    UIBarButtonItem *useItem = [[UIBarButtonItem alloc] initWithCustomView:btnBuyNow];
    [self.navigationItem setRightBarButtonItems:@[useItem]];
    
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

    [self refreshFields];
    [self refreshPreviewScrollView];
}

- (void) refreshFields{
    [self.m_webview setScalesPageToFit:YES];
    self.m_webview.backgroundColor = [UIColor clearColor];
    [self.m_webview loadHTMLString:self.m_product.htmlDescription baseURL:nil];
    self.m_webview.hidden = YES;
}

- (void) dealloc{
    NSLog(@"ProductDetailsVC >>>> dealloc fired!");
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) refreshPreviewScrollView{
    int count = (int) [self.m_product.images count];
    float fWidth = self.view.frame.size.width;
    float fHeight = self.m_scrollviewPreview.frame.size.height;
    
    self.m_scrollviewPreview.translatesAutoresizingMaskIntoConstraints = NO;
    self.m_viewPreview.translatesAutoresizingMaskIntoConstraints = NO;
    self.m_constraintPreviewWidth.constant = fWidth * count;
    [self.m_scrollviewPreview layoutIfNeeded];
    
    for (int i = 0; i < (int) [self.m_product.images count]; i++){
        BUYImageLink *image = [self.m_product.images objectAtIndex:i];
        NSString *szImage = image.sourceURL.absoluteString;
        APSShopProductPreviewView *view =  [[[NSBundle mainBundle] loadNibNamed:@"ShopProductPreview" owner:self options:nil] objectAtIndex:0];
        
        view.m_lblTitle.hidden = YES;
        [self setUIImageView:view.m_imgPreview WithUrl:szImage DefaultImage:nil];
        
        [self.m_viewPreview addSubview:view];
        
        NSArray *arrConstraintsV = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[view(%d)]", (int) fHeight]
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(view)];
        
        NSArray *arrConstraintsH = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-offsetLeft-[view(%d)]", (int) fWidth]
                                                                           options:0
                                                                           metrics:@{@"offsetLeft": @(fWidth * i)}
                                                                             views:NSDictionaryOfVariableBindings(view)];
        
        [self.m_viewPreview addConstraints:arrConstraintsV];
        [self.m_viewPreview addConstraints:arrConstraintsH];
        
    }
    [self.view layoutIfNeeded];
    
    self.m_pager.numberOfPages = count;
    self.m_pager.currentPage = 0;
    if (count == 1){
        self.m_pager.hidden = YES;
    }
    else {
        self.m_pager.hidden = NO;
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

#pragma mark -scrollview delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentPage = scrollView.contentOffset.x/scrollView.frame.size.width;
    [self.m_pager setCurrentPage:currentPage];
}

#pragma mark -UIWebview Event Listeners

- (void) webViewDidFinishLoad:(UIWebView *)aWebView {
    [self.m_webview stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 1.0;"];
    [self.m_webview setScalesPageToFit:NO];
    
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    aWebView.frame = frame;
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    aWebView.frame = frame;
  
    self.m_constraintWebviewHeight.constant = frame.size.height;
    [self.view layoutIfNeeded];
    
    self.m_webview.hidden = NO;
    self.m_webview.alpha = 0;
    [UIView animateWithDuration:1.0f animations:^{
        self.m_webview.alpha = 1;
    }];
}

#pragma mark -Button Event Listener

- (IBAction)onBtnAddClick:(id)sender {
    [self performSegueWithIdentifier:@"SEGUE_FROM_SHOP_PRODUCT_TO_ADD" sender:nil];
}

@end
