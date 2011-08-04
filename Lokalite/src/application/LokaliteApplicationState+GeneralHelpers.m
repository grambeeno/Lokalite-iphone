//
//  LokaliteApplicationState+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 8/4/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteApplicationState+GeneralHelpers.h"
#import "NSManagedObject+GeneralHelpers.h"


@implementation LokaliteApplicationState (GeneralHelpers)

+ (id)currentState:(NSManagedObjectContext *)context
{
    LokaliteApplicationState *state = [self findFirstInContext:context];
    if (!state)
        state = [LokaliteApplicationState createInstanceInContext:context];

    return state;
}

@end
