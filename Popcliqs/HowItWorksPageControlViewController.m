//
//  HowItWorksPageControlViewController.m
//  Popcliqs
//
//  Created by Praveen Kansara on 19/08/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import "HowItWorksPageControlViewController.h"

@interface HowItWorksPageControlViewController ()

@end

@implementation HowItWorksPageControlViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.objWebView)
    {
        NSURL* lobjURL = [NSURL URLWithString:@"http://popcliqs.com/beta/about.php"];
        NSURLRequest* lobjUrlRequest = [[NSURLRequest alloc] initWithURL:lobjURL];
        [self.objWebView loadRequest:lobjUrlRequest];
    }
    else
    {
        SLog(@"ERROR : self.objWebView is nil");
    }
    
    self.navigationItem.title = @"How It Works";
}

@end
