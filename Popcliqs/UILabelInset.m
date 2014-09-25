//
//  UILabelInset.m
//  Popcliqs
//
//  Created by Praveen Kansara on 30/06/14.
//  Copyright (c) 2014 PaniPuri Soft Limited. All rights reserved.
//

#import "UILabelInset.h"

@implementation UILabelInset

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {0, 10, 0, 10};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}


@end
