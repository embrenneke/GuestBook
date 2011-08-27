//
//  Event.m
//  GuestBook
//
//  Created by Emily Brenneke on 8/26/11.
//  Copyright (c) 2011 UnspunProductions. All rights reserved.
//

#import "Event.h"
#import "Signature.h"


@implementation Event
@dynamic name;
@dynamic time;
@dynamic uuid;
@dynamic signatures;

- (void)addSignaturesObject:(Signature *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"signatures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"signatures"] addObject:value];
    [self didChangeValueForKey:@"signatures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeSignaturesObject:(Signature *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"signatures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"signatures"] removeObject:value];
    [self didChangeValueForKey:@"signatures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addSignatures:(NSSet *)value {    
    [self willChangeValueForKey:@"signatures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"signatures"] unionSet:value];
    [self didChangeValueForKey:@"signatures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeSignatures:(NSSet *)value {
    [self willChangeValueForKey:@"signatures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"signatures"] minusSet:value];
    [self didChangeValueForKey:@"signatures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
