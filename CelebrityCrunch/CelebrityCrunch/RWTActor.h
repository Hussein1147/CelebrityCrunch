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

static const NSUInteger NumActors = 70;

@interface RWTActor : NSObject

@property (strong,nonatomic) NSString *actorName;
@property (strong, nonatomic) NSArray *movieList;
@property (assign,nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSInteger actorIndex;
@property (strong ,nonatomic) SKSpriteNode *sprite;
@property (strong,nonatomic) NSDictionary *map;
@property (nonatomic) BOOL machted;
-(NSString *)spriteName;
-(NSString *)highlightedSpriteName;
-(NSString*)blueHilightedSpriteNames;
-(NSArray *)getMovieListForActor:(RWTActor*)actor withMap:(NSDictionary*)map;
-(NSUInteger)actorIndex:(NSString *)actorName;
@end
