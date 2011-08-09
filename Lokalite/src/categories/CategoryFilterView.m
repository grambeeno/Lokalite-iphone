//
//  CategoryFilterView.m
//  Lokalite
//
//  Created by John Debay on 8/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "CategoryFilterView.h"

#import "CategoryFilter.h"

#import "UIButton+GeneralHelpers.h"


static const NSInteger CATEGORY_FILTER_TAG_INDEX_OFFSET = 100;

@implementation CategoryFilterView

@synthesize categoryFilters = categoryFilters_;
@synthesize categoryChangedHandler = categoryChangedHandler_;

#pragma mark - Memory management

- (void)dealloc
{
    [categoryFilters_ release];
    [categoryChangedHandler_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        [self setPagingEnabled:YES];
    }

    return self;
}

#pragma mark - UI events

- (void)didChangeCategoryFilter:(UIButton *)button
{
    const NSInteger indexOffset = CATEGORY_FILTER_TAG_INDEX_OFFSET;

    NSInteger filterButtonTag = [button tag];
    NSInteger filterIndex = filterButtonTag - indexOffset;
    CategoryFilter *filter = [[self categoryFilters] objectAtIndex:filterIndex];

    if ([self categoryChangedHandler])
        [self categoryChangedHandler](filter);
}

#pragma mark - View configuration

- (void)configureForCategoryFilters:(NSArray *)filters
{
    NSInteger selectedFilterIndex = 0;

    static const CGFloat buttonHeight = 50, buttonWidth = 50;
    CGRect frame = [self frame];
    CGFloat margin = round((frame.size.height - buttonHeight) / 2);
    __block CGPoint point = CGPointMake(margin, 8);

    // margin of 30 gives us 15 points of space on the left or right of the
    // scroll view, and 30 points between buttons per page
    margin = 30;

    [filters enumerateObjectsUsingBlock:
     ^(CategoryFilter *filter, NSUInteger idx, BOOL *stop) {
         BOOL isSelectedFilter = selectedFilterIndex == idx;

         CGRect buttonFrame =
            CGRectMake(point.x, point.y, buttonWidth, buttonHeight);
         UIButton *button =
            [UIButton lokaliteCategoryButtonWithFrame:buttonFrame];

         UIImage *buttonImage =
            isSelectedFilter ?
            [filter selectedButtonImage] : [filter buttonImage];
         [button setImage:buttonImage forState:UIControlStateNormal];

         [button addTarget:self
                    action:@selector(didChangeCategoryFilter:)
          forControlEvents:UIControlEventTouchUpInside];

         [button setTag:idx + CATEGORY_FILTER_TAG_INDEX_OFFSET];

         [self addSubview:button];

         static const CGFloat LABEL_MARGIN = 13;
         CGRect labelFrame =
            CGRectMake(buttonFrame.origin.x - LABEL_MARGIN,
                       buttonFrame.origin.y + buttonFrame.size.height + 3,
                       buttonFrame.size.width + LABEL_MARGIN * 2,
                       14);
         UILabel *nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
         [nameLabel setBackgroundColor:[UIColor whiteColor]];
         [nameLabel setFont:[UIFont systemFontOfSize:12]];
         [nameLabel setText:[filter shortName]];
         [nameLabel setTextAlignment:UITextAlignmentCenter];
         [self addSubview:nameLabel];
         [nameLabel release], nameLabel = nil;

         point.x += buttonWidth + margin;
     }];

    // set the content size to an even number of pages
    CGFloat totalButtonWidths = point.x + margin;
    NSInteger npages = ceil(totalButtonWidths / frame.size.width);
    CGSize contentSize =
        CGSizeMake(frame.size.width * npages, frame.size.height);
    [self setContentSize:contentSize];
}

#pragma mark - Accessors

- (void)setCategoryFilters:(NSArray *)categoryFilters
{
    if (categoryFilters != categoryFilters_) {
        [categoryFilters_ release];

        [self configureForCategoryFilters:categoryFilters];
    }
}

@end
