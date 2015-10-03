//
//  GameViewController.h
//  CelebrityCrunch
//

//  Copyright (c) 2014 DJIBRILKEITA. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GameViewDelegate <NSObject>
-(NSUInteger)updateScore;
@end
#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"
@protocol GameViewDelegate;

@interface GameViewController : UIViewController<SKSceneDelegate, GameSceneDelegate>

@property(nonatomic,weak)id <GameViewDelegate> scoreDelegate;


@end






