//
//  Business.m
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import "Business.h"
#import "Category.h"
#import "Event.h"


@implementation Business
@dynamic address;
@dynamic phone;
@dynamic status;
@dynamic summary;
@dynamic name;
@dynamic imageUrl;
@dynamic email;
@dynamic identifier;
@dynamic imageData;
@dynamic url;
@dynamic events;
@dynamic category;

#pragma mark - LokaliteObject implementation

- (UIImage *)image
{
    NSData *data = [self imageData];
    return data ? [UIImage imageWithData:data] : nil;
}

- (id<MKAnnotation>)mapAnnotation
{
    return nil;
}

@end
