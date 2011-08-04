//
//  LokaliteApplicationState+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 8/4/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteApplicationState.h"

@interface LokaliteApplicationState (GeneralHelpers)

+ (id)currentState:(NSManagedObjectContext *)context;

@end
