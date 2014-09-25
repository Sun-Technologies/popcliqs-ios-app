//
//  PageControlViewController.h
//  DrawYourStories
//
//  Created by Rahul Borawar on 30/05/13.
//  Copyright (c) 2013 Shalu Chouhan. All rights reserved.
//

//---------------------------------------------------------------------------------
#pragma mark – SDKImports
//---------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class PageControlView;

@protocol PageControlViewDelegate <NSObject>

- (NSInteger)numberOfPagesInPageControlViewController:(PageControlView*)lobjPCVC;
- (UIView*)pageViewForPageControlViewController:(PageControlView*)lobjPCVC atIndex:(NSInteger)lintPageIndex;

@optional

- (BOOL)reachedBeginning;
- (BOOL)reachedEnd;

@end

//---------------------------------------------------------------------------------
#pragma mark – Interface
//---------------------------------------------------------------------------------

@interface PageControlView : UIView

//---------------------------------------------------------------------------------
#pragma mark – Properties
//---------------------------------------------------------------------------------

@property (weak, nonatomic) IBOutlet UIScrollView*     objScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl*    objPageControl;
@property (weak, nonatomic) id<PageControlViewDelegate>  objDelegate;

//---------------------------------------------------------------------------------
#pragma mark – init
//---------------------------------------------------------------------------------

- (void)setDelegate:(id<PageControlViewDelegate>)lobjDelegate;
- (void)load;
- (void)next;
- (void)previous;

//---------------------------------------------------------------------------------
@end
//---------------------------------------------------------------------------------


