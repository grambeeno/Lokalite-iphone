//
//  GroupedMapAnnotation.m
//  Lokalite
//
//  Created by John Debay on 9/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "GroupedMapAnnotation.h"

#import "LokaliteObjectMapAnnotation.h"
#import "MappableLokaliteObject.h"

@interface GroupedMapAnnotation ()
@property (nonatomic, copy) NSArray *annotations;
@end


@implementation GroupedMapAnnotation

@synthesize annotations = annotations_;

#pragma mark - Memory management

- (void)dealloc
{
    [annotations_ release];
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
{
    return [self initWithAnnotations:[NSArray arrayWithObject:annotation]];
}

- (id)initWithAnnotations:(NSArray *)annotations
{
    self = [super init];
    if (self) {
        if (annotations)
            annotations_ = [annotations copy];
        else
            annotations_ = [[NSArray alloc] init];
    }

    return self;
}

#pragma mark - Public implementation

- (void)addAnnotation:(id<MKAnnotation>)annotation
{
    NSArray *annotations = [[self annotations] arrayByAddingObject:annotation];
    [self setAnnotations:annotations];
}

- (void)removeAnnotation:(id<MKAnnotation>)annotation
{
    NSMutableArray *a = [[self annotations] mutableCopy];
    [a removeObject:annotation];
    NSArray *annotations = [[NSArray alloc] initWithArray:a];
    [self setAnnotations:annotations];
    [annotations release], annotations = nil;
    [a release], a = nil;
}

#pragma mark - MKAnnotation implementation

- (CLLocationCoordinate2D)coordinate
{
    return [[[self annotations] objectAtIndex:0] coordinate];
}

- (NSString *)title
{
    //return [[[self annotations] objectAtIndex:0] title];
    NSString *title = nil;
    NSInteger count = [[self annotations] count];
    if (count == 1)
        title = [[[self annotations] objectAtIndex:0] title];
    else {
        NSString *format =
            NSLocalizedString(@"annotation.grouped.title.format", nil);

        //
        //
        // TODO: make it say "2 events at boulder theater"
        //
        //

        LokaliteObjectMapAnnotation *annotation =
            [[self annotations] lastObject];
        id<MappableLokaliteObject> obj = [annotation lokaliteObject];
        NSString *pluralTitle = [obj pluralTitle];

        title = [NSString stringWithFormat:format, count, pluralTitle];
    }

    return title;
}

- (NSString *)subtitle
{
    NSString *subtitle = nil;
    if ([[self annotations] count] == 1)
        subtitle = [[[self annotations] objectAtIndex:0] subtitle];

    return subtitle;
}

@end
