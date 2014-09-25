//
//  UIButton+Network.m
//  Popcliqs
//
//  Created by Praveen Kansara on 05/12/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import "UIButton+Network.h"

@implementation UIButton (Network)

- (void)addActivityIndicator
{
    UIActivityIndicatorView* lobjActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect lstructActivityViewFrame = self.titleLabel.frame;
    lstructActivityViewFrame.origin.x = lstructActivityViewFrame.origin.x - lobjActivityView.bounds.size.width - 20.0f;
    lstructActivityViewFrame.size.width = lobjActivityView.bounds.size.width;
    lstructActivityViewFrame.size.height = lobjActivityView.bounds.size.height;
    lobjActivityView.frame = lstructActivityViewFrame;
    [self addSubview:lobjActivityView];
    [lobjActivityView startAnimating];
}

- (void)removeActivityIndicator
{
    NSArray* larraySubviews = [self subviews];
    
    UIView* lobjAIV = nil;
    
    for (UIView* lobjView in larraySubviews)
    {
        if ([lobjView isKindOfClass:[UIActivityIndicatorView class]])
        {
            lobjAIV = lobjView;
            break;
        }
    }
    
    [lobjAIV removeFromSuperview];
}

@end
