//
//  APSBarcodeScannerVC.m
//  AppleSolutions
//
//  Created by Chris Lin on 12/27/15.
//  Copyright © 2015 AppleSolutions. All rights reserved.
//

#import "APSBarcodeScannerVC.h"
#import "MTBBarcodeScanner.h"
#import "Global.h"

@interface APSBarcodeScannerVC ()

@property (weak, nonatomic) IBOutlet UIView *m_viewPreview;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (weak, nonatomic) IBOutlet UIView *m_viewFocusPanel;

@property BOOL m_isScanning;

@end

@implementation APSBarcodeScannerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.m_isScanning = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.m_isScanning == NO){
        self.m_isScanning = YES;
        [self startScanning];
    }
}

#pragma mark - Scanner

- (MTBBarcodeScanner *)scanner {
    if (!_scanner) {
        _scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.m_viewPreview];
        [_scanner setScanRect:self.m_viewFocusPanel.frame];
    }
    return _scanner;
}

#pragma mark - Scanning

- (void)startScanning {
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
            if (code.stringValue){
                [self stopScanning];
                
                NSLog(@"Barcode Accepted: %@", code.stringValue);
                NSLog(@"Code %@", code);
                // Vibrate
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                if (self.isRequestFrom == GiftCardsVC)
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:YES completion:^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_GIFTCARD_RECOGNIZED object:nil userInfo:@{@"_CODE": code.stringValue, @"_TYPE": code.type}];
                        }];
                    });
                }
                else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:APSLOCALNOTIFICATION_BARCODE_RECOGNIZED object:nil userInfo:@{@"_CODE": code.stringValue, @"_TYPE": code.type}];
                    }];
                });}
            }
        }
    }];
}

- (void)stopScanning {
    [self.scanner stopScanning];
}


#pragma mark -Button Event Listeners

- (IBAction)onBtnCancelClick:(id)sender {
    [self stopScanning];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
