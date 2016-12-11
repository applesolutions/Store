//
//  APSBusinessTypeVC.m
//  AppleSolutions
//
//  Created on 8/23/16.
//  Copyright © 2016 AppleSolutions. All rights reserved.

// time for 3rd sept: 30 minutes
// time for 4th sept: 50 minutes
//time for 5th : 5:07 hours - 307 minutes
// 6th: 324
// 7th: 310
//810-
// 5th sept timelog:
//1:16 - 2:09 : 54 minutes
// 2:32 - 3:44: 72 minutes
// 4:10-4:53 : 33 minutes
// 1159 pm - 2:08 am : 129 minutes
//---- Time for 6th :

//2:32 - 4:05 - 1:33: 93 minutes
//530 - 554 - 24 minutes
//556 - 7:15 - 1-19 minutes: 79 minutes
//9-10:08 - 1 - 8 minutes: 68 minutes
//11:16 -  12:16 - 1 hour: 60 minutes
// time for 7th

//2:48 - 4:17 : 89 minutes
//454 - 515: 21 minutes
//10:38 - 11:51: 1: 17, 77 minutes -- 1 hour 13 minutes: 73 minutes
//1159- 12:24: 25 minutes
//12:51 - 229: 1: 38, 98 minutes
//------time for 8th
//5:06-5:55 : 49 minutes
//7:18-724: 6 minutes
//726- 8:05: 39 minutes
//834- 8 47: 13 minutes
//10:15 - 10:42: 27 minutes
//12:03 - 1:35: 1: 32 - 92 minutes
//1:51 - 2:16: 25 minutes
//2:21 - 226: 5 minutes
//2:59 - 3:52: 53 minutes
//time for 9th.

//421- 4:51 - 30 minutes

//5:01-539 - 38 minutes
//543- 619 - 36 minutes
//624 - 7:31: 1 hour 7 minutes : 67 minutes
//935 - 10:19: 44 minutes
//10:30- 1:30am: 3 hours  = 180 minutes

//country issue in Mobilepayinfo? (done)
//review setneedslayout etc in CheckoutVC (done)

//Review barcode implementation giftcard vc (done)
//review hid/show description, checkoutvc (done)
//review hid/show description - implementation, checkoutvc (done)
//review barcode for product search (done)
//add base strings (done)
//move the barcode keys to global.h (done)


#import "APSUserTypeVC.h"
#import "APSMobilePayInfoVC.h"


 


// payment info:
@interface APSUserTypeVC ()
@property (nonatomic,assign) BOOL isBusinessUser;
@end
@implementation APSUserTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    [self initBusinessTypeView];
}

- (UIColor *) normalizeColor: (UIColor *) color{
    return nil;
    
}
- (void) initBusinessTypeView{
    
   // UIView * m_UserTypeView = self.view;
    
   // m_UserTypeView.backgroundColor = [UIColor redColor];
 /*   UILayoutGuide * margins = self.view.layoutMarginsGuide;
    
    m_UserTypeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [m_UserTypeView.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor].active = YES;
    [m_UserTypeView.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor].active = NO;
    [m_UserTypeView.topAnchor constraintEqualToAnchor:margins.topAnchor].active = YES;
    [m_UserTypeView.bottomAnchor constraintEqualToAnchor:margins.bottomAnchor].active = YES;*/
    
    self.title =@"";
    
    UIButton * btnPrivateUser = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPrivateUser.backgroundColor = [UIColor colorWithRed:0.89 green:0.37 blue:0.236 alpha:1.0];
    
    [self.view addSubview:btnPrivateUser];
   // self.view.translatesAutoresizingMaskIntoConstraints = NO;
    btnPrivateUser.translatesAutoresizingMaskIntoConstraints = NO;
    
    btnPrivateUser.layer.cornerRadius = 2;
    [btnPrivateUser addTarget:self action:@selector(btnPrivateUserClick) forControlEvents:UIControlEventTouchUpInside];
    [btnPrivateUser.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [btnPrivateUser.heightAnchor constraintEqualToConstant:44.0].active = YES;
    [btnPrivateUser.centerYAnchor constraintLessThanOrEqualToAnchor:self.view.centerYAnchor].active = YES;
    [btnPrivateUser.widthAnchor constraintEqualToAnchor :self.view.widthAnchor multiplier:0.65].active = YES;
    
    btnPrivateUser.titleLabel.textColor = [UIColor whiteColor];
    
    [btnPrivateUser setTitle:NSLocalizedString(@"Private",nil) forState:UIControlStateNormal];
    [btnPrivateUser setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnPrivateUser.titleLabel.font = [UIFont fontWithDescriptor:[btnPrivateUser.titleLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size: 17.0];
    
    UIButton * btnBusinessUser = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBusinessUser.backgroundColor = [UIColor colorWithRed:0 green:0.466 blue:0.745 alpha:1.0];
    
    [self.view addSubview:btnBusinessUser];
    btnBusinessUser.translatesAutoresizingMaskIntoConstraints = NO;
    btnBusinessUser.layer.cornerRadius = 2;
    [btnBusinessUser addTarget:self action:@selector(btnBusinessUserClick) forControlEvents:UIControlEventTouchUpInside];
    [btnBusinessUser.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [btnBusinessUser.centerYAnchor constraintGreaterThanOrEqualToAnchor:btnPrivateUser.centerYAnchor constant:100].active= YES;
    [btnBusinessUser.heightAnchor constraintEqualToConstant:44.0].active = YES;
    [btnBusinessUser.widthAnchor constraintEqualToAnchor :self.view.widthAnchor multiplier:0.65].active = YES;
   
    [btnBusinessUser setTitle:NSLocalizedString(@"Business",nil) forState:UIControlStateNormal];
    [btnBusinessUser setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnBusinessUser.titleLabel.font = [UIFont fontWithDescriptor:[btnBusinessUser.titleLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:17.0];
    UILabel * headingLabel = [[UILabel alloc] init];
    [headingLabel setText:NSLocalizedString(@"Please Select", nil)];
    headingLabel.font = [UIFont fontWithDescriptor:[headingLabel.font.fontDescriptor  fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold ] size:20.0];
    [self.view addSubview:headingLabel];
    headingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headingLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [headingLabel.centerYAnchor constraintEqualToAnchor:btnPrivateUser.centerYAnchor constant:-100].active = YES;
    
    
}
- (void) goToUserInfoVC{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    if (self.isBusinessUser)
        [prefs setObject:@"Business" forKey:@"UserType"];
    else
        [prefs setObject:@"Private" forKey:@"UserType"];

    [self.navigationController popViewControllerAnimated:YES];
    
    /*
    NSString * storyboardName = @"Main";

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    APSMobilePayInfoVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"APSMobilePayUserInfo"];
    vc.isBusinessUser= self.isBusinessUser;
    [self.navigationController pushViewController:vc animated:YES];*/
    
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (void) btnBusinessUserClick{
    self.isBusinessUser = YES;
    [self goToUserInfoVC];
    NSLog(@"User Type Business");
    
    // [m_UserTypeView removeFromSuperview];
}
- (void) btnPrivateUserClick{
    self.isBusinessUser= NO;
    [self goToUserInfoVC];
    // [m_UserTypeView removeFromSuperview];
    NSLog(@"User type Private");
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

@end
