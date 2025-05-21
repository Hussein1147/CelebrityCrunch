//
//  RWTActor.h
//  CookieCrunch
//
//  Created by DJIBRIL KEITA on 10/8/14.
//  Copyright (c) 2014 DJIBRILKEITA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWTMovie.h"
@import SpriteKit;

extern const NSUInteger NumActors; // Declare as extern, will be defined in .m

@interface RWTActor : NSObject

@property (strong,nonatomic) NSString *actorName; // This might become redundant if name is primarily looked up via index
@property (strong, nonatomic) NSArray *movieList;
@property (assign,nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSInteger actorIndex; // This is the 1-based ID from JSON
@property (strong ,nonatomic) SKSpriteNode *sprite;
@property (strong,nonatomic) NSDictionary *map; // This seems unrelated to actor definitions, probably for movie mapping
@property (nonatomic) BOOL machted; // Typo: matched

// Class methods for loading and accessing actor data
+ (void)loadActorDefinitions;
+ (NSDictionary *)actorDataForIndex:(NSInteger)index; // index is 1-based
+ (NSInteger)actorIndexForName:(NSString *)name;     // returns 1-based index or NSNotFound

// Instance methods to get sprite names
-(NSString *)spriteName;
-(NSString *)highlightedSpriteName;
-(NSString *)blueHighlightedSpriteName; // Corrected typo

// Instance method (now uses class method)
-(NSUInteger)actorIndex:(NSString *)actorName; // Kept as NSUInteger for compatibility with RWTLevel

// This method seems to be about movie data related to an actor, not actor definition itself.
// It might need actor's name, which can be derived from actorIndex via new data source.
-(NSArray *)getMovieListForActor:(RWTActor*)actor withMap:(NSDictionary*)map;

@end
