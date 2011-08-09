//
//  CategoryFilterView.h
//  Lokalite
//
//  Created by John Debay on 8/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryFilter;

typedef void(^CFVCategoryChangedHandler)(CategoryFilter *filter);

@interface CategoryFilterView : UIScrollView

@property (nonatomic, copy) NSArray *categoryFilters;
@property (nonatomic, copy) CFVCategoryChangedHandler categoryChangedHandler;

@end
