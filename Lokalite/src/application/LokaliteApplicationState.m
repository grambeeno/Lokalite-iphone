//
//  ApplicationState.m
//  Lokalite
//
//  Created by John Debay on 8/4/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import "LokaliteApplicationState.h"


@implementation LokaliteApplicationState
@dynamic dataFreshnessDate;

@end


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

