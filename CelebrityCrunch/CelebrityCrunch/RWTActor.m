//
//  RWTActor.m
//  CookieCrunch
//
//  Created by DJIBRIL KEITA on 10/8/14.
//  Copyright (c) 2014 DJIBRILKEITA. All rights reserved.
//

#import "RWTActor.h"

// Define NumActors based on the count from JSON, or keep it fixed if JSON is guaranteed to have this many.
// For now, we'll keep the extern declaration and define it after loading.
const NSUInteger NumActors = 70; // Default, will be updated if JSON loading is successful and count differs.

@interface RWTActor ()

@end

// Static variables to hold loaded actor data
static NSArray *_actorDefinitions = nil;
static NSDictionary *_actorDefinitionsByName = nil;
static dispatch_once_t _loadActorsOnceToken;


@implementation RWTActor

+ (void)loadActorDefinitions {
    dispatch_once(&_loadActorsOnceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Actors" ofType:@"json"];
        if (path == nil) {
            NSLog(@"Could not find Actors.json");
            _actorDefinitions = @[]; // Empty array to prevent further load attempts
            _actorDefinitionsByName = @{};
            return;
        }
        
        NSError *error;
        NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
        if (data == nil) {
            NSLog(@"Could not load data from Actors.json: %@", error.localizedDescription);
            _actorDefinitions = @[];
            _actorDefinitionsByName = @{};
            return;
        }
        
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (jsonArray == nil || ![jsonArray isKindOfClass:[NSArray class]]) {
            NSLog(@"Could not parse Actors.json: %@", error.localizedDescription);
            _actorDefinitions = @[];
            _actorDefinitionsByName = @{};
            return;
        }
        
        _actorDefinitions = jsonArray;
        NSMutableDictionary *byName = [NSMutableDictionary dictionaryWithCapacity:[_actorDefinitions count]];
        for (NSDictionary *actorDict in _actorDefinitions) {
            NSString *name = actorDict[@"name"];
            if (name) {
                [byName setObject:actorDict forKey:name];
            }
        }
        _actorDefinitionsByName = [byName copy];
        
        // Optionally update NumActors if it should be dynamic
        // NumActors = [_actorDefinitions count]; // Uncomment if NumActors should reflect actual loaded count
        if ([_actorDefinitions count] != NumActors) {
             NSLog(@"Warning: NumActors constant (%lu) does not match loaded actor definitions count (%lu).", (unsigned long)NumActors, (unsigned long)[_actorDefinitions count]);
        }
    });
}

+ (NSDictionary *)actorDataForIndex:(NSInteger)index { // index is 1-based
    [RWTActor loadActorDefinitions];
    if (index > 0 && index <= [_actorDefinitions count]) {
        return _actorDefinitions[index - 1]; // Convert 1-based to 0-based for array access
    }
    NSLog(@"Error: actorDataForIndex: index %ld out of bounds (1-%lu).", (long)index, (unsigned long)[_actorDefinitions count]);
    return nil;
}

+ (NSInteger)actorIndexForName:(NSString *)name { // returns 1-based index
    [RWTActor loadActorDefinitions];
    NSDictionary *actorDict = _actorDefinitionsByName[name];
    if (actorDict) {
        return [actorDict[@"id"] integerValue];
    }
    return NSNotFound; // Or 0 if that's the convention for not found
}

-(NSString *)spriteName {
    NSDictionary *data = [RWTActor actorDataForIndex:self.actorIndex];
    return data[@"spriteBase"]; // Assuming spriteBase is the direct name for SKTexture
}

-(NSString *)highlightedSpriteName {
    NSDictionary *data = [RWTActor actorDataForIndex:self.actorIndex];
    if (data && data[@"spriteBase"] && data[@"highlightedSuffix"]) {
        return [NSString stringWithFormat:@"%@%@", data[@"spriteBase"], data[@"highlightedSuffix"]];
    }
    return nil; // Or a default/error sprite name
}

// Corrected typo from blueHilightedSpriteNames to blueHighlightedSpriteName
-(NSString *)blueHighlightedSpriteName {
    NSDictionary *data = [RWTActor actorDataForIndex:self.actorIndex];
     if (data && data[@"spriteBase"] && data[@"blueSuffix"]) {
        return [NSString stringWithFormat:@"%@%@", data[@"spriteBase"], data[@"blueSuffix"]];
    }
    return nil; // Or a default/error sprite name
}

// Instance method uses the new class method
-(NSUInteger)actorIndex:(NSString *)actorName {
    NSInteger index = [RWTActor actorIndexForName:actorName];
    if (index == NSNotFound) {
        // Handle NSNotFound appropriately, perhaps return 0 or a specific error value
        // For now, returning 0 to match previous behavior if actorName was not in the static array.
        // However, the original returned index (0 to 69). actorIndexForName returns 1-70 or NSNotFound.
        // The caller in RWTLevel expects 0-based index from this method.
        // Let's adjust to return 0-based index or NSNotFound (which is a large unsigned value).
        // If a 0-based index is strictly required by the caller, this needs careful mapping.
        // The problem description mentions: "NSUInteger actorSpriteIndex = [tempActorForIndex actorIndex:selectedActorName];"
        // and "index = actorSpriteIndex + 1;"
        // This means the original actorIndex: method returned a 0-based index.
        // So, if [RWTActor actorIndexForName:actorName] returns 1-based ID, we subtract 1.
        
        // If actorIndexForName returns 1-based ID (e.g., 1 for Robert-Redford)
        // and the old system returned 0 for "Robert-Redford", then we need to return id-1.
        // If NSNotFound, return NSNotFound or handle as error.
        return NSNotFound; // Or some other error indicator if 0 is a valid index
    }
    return index -1; // Convert 1-based ID from JSON to 0-based index
}


-(NSArray *)getMovieListForActor:(RWTActor*)actor withMap:(NSDictionary *)map{
    // This method might need to get the actor's name using the new system
    // if actor.actorName is not reliably set from outside.
    // Assuming actor.actorIndex is set, we can get the name:
    NSDictionary *actorData = [RWTActor actorDataForIndex:actor.actorIndex];
    NSString *actorNameFromData = actorData[@"name"];
    
    if (actorNameFromData) {
        return [map objectForKey:actorNameFromData];
    }
    // Fallback or error if name isn't found, though spriteName would also fail.
    // Original used [actor spriteName] which now uses the new system too.
    return [map objectForKey:[actor spriteName]]; // This should still work
}

@end
