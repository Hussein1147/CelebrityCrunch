//
//  RWTLevel.h
//  CelebrityCrunch
//
//  Created by DJIBRIL KEITA on 11/1/14.
//  Copyright (c) 2014 DJIBRILKEITA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameViewController.h"
#import "RWTMovie.h"
#import "RWTTile.h"
#import "RWTActor.h"
@class GameScene;
static const NSInteger NumColumns = 5;
static const NSInteger NumRows = 5;

@interface RWTLevel : NSObject  <GameViewDelegate>
@property (strong,nonatomic) NSDictionary *actorMap;
@property (strong,nonatomic) NSDictionary *movieMap;
@property (strong,nonatomic) RWTMovie *movie;
@property (nonatomic, readonly) NSInteger score;

-(NSSet *)shuffle;
-(NSSet *)reShuffle;

-(RWTActor *)actorAtColumn:(NSInteger)colum row:(NSInteger)row;
-(instancetype)initWithFiles:(NSString *)firstFilename secondFile:(NSString *)secondFilename thirdFile:(NSString *)thirdFilename;
- (RWTTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;
-(void)chooseActorAtColumn:(NSInteger)column row:(NSInteger)row;
-(NSSet *)removeMatches;
-(RWTActor*)fillHoles;
-(NSString *)nextLevel;
@end



