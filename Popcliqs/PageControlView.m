//
//  PageControlViewController.m
//  DrawYourStories
//
//  Created by Rahul Borawar on 30/05/13.
//  Copyright (c) 2013 Shalu Chouhan. All rights reserved.
//

//---------------------------------------------------------------------------------
#pragma mark - HashDefines
//---------------------------------------------------------------------------------

#define DONE_TOOLBAR_BUTTON_TEXT                    @"Done"
#define PREVIOUS_TOOLBAR_BUTTON_TEXT                @"Prev"
#define NEXT_TOOLBAR_BUTTON_TEXT                    @"Next"

#define PAGE_CONTROL_SCROLL_VIEW_NIB_NAME           @"PageControlScrollView"

#define PAGE_VIEW_INSET                             5

#define SUBVIEW_TAG(__X__)                          (2 + __X__)

//---------------------------------------------------------------------------------
#pragma mark - SDKImports
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
#pragma mark - ProjectImports
//---------------------------------------------------------------------------------

#import "PageControlView.h"

//---------------------------------------------------------------------------------
#pragma mark – Private Interface
//---------------------------------------------------------------------------------

@interface PageControlView () <UIScrollViewDelegate>

//---------------------------------------------------------------------------------
#pragma mark – Properties
//---------------------------------------------------------------------------------

@property (assign , nonatomic) NSInteger intTotalPages;
@property (assign , nonatomic) NSInteger intCurrentPageIndex;

//---------------------------------------------------------------------------------
#pragma mark – Private Methods
//---------------------------------------------------------------------------------

- (void)loadVisiblePages;
- (void)addPageViewAtIndex:(NSInteger)lintPageIndex;
- (void)purgePageViewAtIndex:(NSInteger)lintPageIndex;

//---------------------------------------------------------------------------------
@end
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
#pragma mark – Implementation
//---------------------------------------------------------------------------------

@implementation PageControlView;

//---------------------------------------------------------------------------------
#pragma mark – init
//---------------------------------------------------------------------------------

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.objDelegate = nil;
        self.intTotalPages = 1;
        self.intCurrentPageIndex = 0;
    }
    
    return self;
}

- (id)initWithDelegate:(id<PageControlViewDelegate>)lobjPVCDelegate
{
    self = [super init];
    
    if (self)
    {
        self.objDelegate = lobjPVCDelegate;
        self.intTotalPages = 1;
        self.intCurrentPageIndex = 0;
    }
    
    return self;
}

- (void)setIntCurrentPageIndex:(NSInteger)intCurrentPageIndex
{
    _intCurrentPageIndex = intCurrentPageIndex;
    
    self.objPageControl.currentPage = intCurrentPageIndex;
}

- (void)setDelegate:(id<PageControlViewDelegate>)lobjDelegate
{
    self.objDelegate = lobjDelegate;
    self.intTotalPages = 1;
    self.intCurrentPageIndex = 0;
}

- (void)load
{
    self.intTotalPages = [self.objDelegate numberOfPagesInPageControlViewController:self];
    
    if (self.objPageControl)
    {
        self.objPageControl.numberOfPages = self.intTotalPages;
    }
    else
    {
        SLog(@"ERROR : PageControl is nil");
    }
    
    if (self.objScrollView)
    {
        self.objScrollView.backgroundColor = [UIColor yellowColor];
        
        CGSize lstructScrollViewSize = self.objScrollView.bounds.size;
        self.objScrollView.contentSize = CGSizeMake(lstructScrollViewSize.width * self.intTotalPages,
                                                    lstructScrollViewSize.height);
        
        self.objScrollView.contentOffset = CGPointMake(self.objScrollView.bounds.size.width * self.intCurrentPageIndex, 0);
    }
    else
    {
        SLog(@"ERROR : ScrollView is nil");
    }
    
    [self loadVisiblePages];
}

//---------------------------------------------------------------------------------
#pragma mark – Instance Methods
//---------------------------------------------------------------------------------

- (void)loadPageAtIndex:(NSInteger)lintPageIndex
{
    self.intCurrentPageIndex = lintPageIndex;
    
    NSInteger lintPreviousPageIndex = lintPageIndex - 1;
    NSInteger lintNextPageIndex = lintPageIndex + 1;
    
    for (NSInteger i = 0; i < lintPreviousPageIndex; i++)
    {
        [self purgePageViewAtIndex:i];
    }
    for (NSInteger i=lintPreviousPageIndex; i <= lintNextPageIndex; i++)
    {
        [self addPageViewAtIndex:i];
    }
    for (NSInteger i = lintNextPageIndex+1; i < self.intTotalPages; i++)
    {
        [self purgePageViewAtIndex:i];
    }
}

//---------------------------------------------------------------------------------
#pragma mark – Private Methods
//---------------------------------------------------------------------------------

- (void)loadVisiblePages
{
    CGFloat lfloatPageWidth = self.objScrollView.bounds.size.width;
    
    CGFloat lfloatXContentOffset = self.objScrollView.contentOffset.x;
    
    NSInteger lintPageIndex = (NSInteger)floor(lfloatXContentOffset /
                                               lfloatPageWidth);
    
    [self loadPageAtIndex:lintPageIndex];
}

- (void)addPageViewAtIndex:(NSInteger)lintPageIndex
{
    if (lintPageIndex >= 0 && lintPageIndex < self.intTotalPages)
    {
        UIView* lobjPreviousViewAtIndex = [self.objScrollView viewWithTag:SUBVIEW_TAG(lintPageIndex)];
        
        if (lobjPreviousViewAtIndex)
        {
            [lobjPreviousViewAtIndex removeFromSuperview];
        }
    
        UIView *lobjCurrentViewAtIndex = [self.objDelegate pageViewForPageControlViewController:self atIndex:lintPageIndex];
        lobjCurrentViewAtIndex.tag = SUBVIEW_TAG(lintPageIndex);
        
        CGRect lstructPageViewFrame = self.objScrollView.bounds;
        lstructPageViewFrame.origin.x = floorf(lstructPageViewFrame.size.width * lintPageIndex);
        lstructPageViewFrame.origin.y = 0.0f;
        lobjCurrentViewAtIndex.frame = lstructPageViewFrame;
        
        [self.objScrollView addSubview:lobjCurrentViewAtIndex];
    }
    else
    {
        SLog(@"ERROR : lintPageIndex(%ld) out of bound",(long)lintPageIndex);
    }
}

- (void)purgePageViewAtIndex:(NSInteger)lintPageIndex
{
    if (lintPageIndex >= 0 && lintPageIndex < self.intTotalPages)
    {
        UIView* lobjPreviousViewAtIndex = [self.objScrollView viewWithTag:SUBVIEW_TAG(lintPageIndex)];
        
        if (lobjPreviousViewAtIndex)
        {
            [lobjPreviousViewAtIndex removeFromSuperview];
        }
        else
        {
            
        }
    }
}

//---------------------------------------------------------------------------------
#pragma mark – ScrollView Delegate Methods
//---------------------------------------------------------------------------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self loadVisiblePages];
}

//---------------------------------------------------------------------------------
#pragma mark – ButtonActions
//---------------------------------------------------------------------------------

- (void)previous
{
    if (self.intCurrentPageIndex > 0)
    {
        self.intCurrentPageIndex -= 1;
    }

    if (self.intCurrentPageIndex >= 0 && self.intCurrentPageIndex < self.intTotalPages)
    {
        [self loadPageAtIndex:self.intCurrentPageIndex];
        
        CGFloat lfloatXContentOffset = floorf(self.objScrollView.bounds.size.width * self.intCurrentPageIndex) ;
        
        [self.objScrollView setContentOffset:CGPointMake(lfloatXContentOffset, 0.0f)
                                    animated:YES];
    }
    else
    {
        SLog(@"PrevButtonAction:self.arrayPageViews out of Bound");
    }
}

- (void)next
{
    if (self.intCurrentPageIndex < self.intTotalPages - 1)
    {
        self.intCurrentPageIndex += 1;
    }

    if (self.intCurrentPageIndex >= 0 && self.intCurrentPageIndex < self.intTotalPages)
    {
        [self loadPageAtIndex:self.intCurrentPageIndex];
        
        CGFloat lfloatXContentOffset = self.objScrollView.bounds.size.width * self.intCurrentPageIndex;
        
        [self.objScrollView setContentOffset:CGPointMake(lfloatXContentOffset, 0.0f)
                                    animated:YES];
    }
    else
    {
        SLog(@"NextButtonAction:self.arrayPageViews out of Bound");
    }
}

//---------------------------------------------------------------------------------
@end
//---------------------------------------------------------------------------------


