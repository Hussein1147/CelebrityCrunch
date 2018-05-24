//
//  GameScene.h
//  CelebrityCrunch
//

//  Copyright (c) 2014 DJIBRILKEITA. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@protocol GameSceneDelegate <NSObject>
-(void)startMatching;
@end
@class RWTLevel;
#import "RWTLevel.h"
#import "RWTActor.h"

@interface GameScene :SKScene
@property (nonatomic, strong) RWTLevel *level;
@property (nonatomic,weak) id <SKSceneDelegate, GameSceneDelegate> delegate;
@property (nonatomic) NSInteger actorColumn;
@property (nonatomic) NSInteger actorRow;

-(void)addSpritesForActors:(NSSet *)actors;
-(void)addTiles;
- (void)animateMatchedActors:(NSSet *)chains completion:(dispatch_block_t)completion;
- (void)animateFallingActors:(RWTActor *)actor completion:(dispatch_block_t)completion;
-(void)shuffleActorsSprites:(NSSet *)actors completion:(dispatch_block_t)completion;
- (void)animateActorLayer;
@end

