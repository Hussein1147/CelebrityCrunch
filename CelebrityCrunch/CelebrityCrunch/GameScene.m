//
//  GameScene.m
//  CelebrityCrunch
//
//  Created by DJIBRIL KEITA on 10/30/14.
//  Copyright (c) 2014 DJIBRILKEITA. All rights reserved.
//

#import "GameScene.h"
#import "RWTActor.h"
#import "RWTLevel.h"
static const CGFloat TileWidth = 64.0;
static const CGFloat TileHeight = 95.0;

@interface  GameScene()
@property (strong,nonatomic) SKNode *gameLayer;
@property (strong,nonatomic) SKNode *actorLayer;
@property (strong, nonatomic) SKNode *tilesLayer;
@property (strong, nonatomic) SKSpriteNode *selectionSprite;
@property (strong,nonatomic) SKSpriteNode *chosenSprite;
@end

@implementation GameScene

-(id)initWithSize:(CGSize)size{

    if ((self = [super initWithSize:size])) {
        
        self.anchorPoint = CGPointMake(0.5, 0.5);

        SKSpriteNode *background = [[SKSpriteNode alloc] initWithColor:[self colorWithHexString:@"FF6666"] size:[UIScreen mainScreen].bounds.size];
        [self addChild:background];

        self.gameLayer = [SKNode node];
        self.gameLayer.hidden = YES;

        [self addChild:self.gameLayer];
        CGPoint layerPosition = CGPointMake(-TileWidth * NumColumns/2, -TileHeight*NumRows + self.size.height/4 + (TileWidth/10));
        self.actorLayer= [SKNode node];
        self.actorLayer.position = layerPosition;
        self.tilesLayer = [SKNode node];
        self.tilesLayer.position = layerPosition;
        [self.gameLayer addChild:self.tilesLayer];
        [self.gameLayer addChild:self.actorLayer];
        self.chosenSprite = [SKSpriteNode node];
        self.selectionSprite = [SKSpriteNode node];
        
    }
    return self;
}
-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

    if ([cString length] != 6) return  [UIColor grayColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
#pragma mark - show/hide actor selection
-(void)showSelectionIndicatorsForactor:(RWTActor*)actor{
    
    if (self.selectionSprite.parent != nil) {
        [self.selectionSprite removeFromParent];
    }
    
    SKTexture *texture= [SKTexture textureWithImageNamed:[actor highlightedSpriteName]];
    self.selectionSprite.size = texture.size;
    [self.selectionSprite runAction:[SKAction setTexture:texture]];
    [actor.sprite addChild:self.selectionSprite];
    self.selectionSprite.alpha =1.0;
}

-(void)showBlueSelection:(RWTActor*)actor{
    
    [actor.sprite runAction:[SKAction sequence:@[[SKAction fadeOutWithDuration:0.1],[SKAction
                                                                                             removeFromParent]]]];
    SKSpriteNode *blueSprite = [SKSpriteNode spriteNodeWithImageNamed:[actor blueHilightedSpriteNames]];
    blueSprite.position = [self pointForColumn:actor.column row:actor.row];
    [self.actorLayer addChild:blueSprite];
    actor.sprite = blueSprite;

    [actor.sprite runAction:[SKAction sequence:@[
                                                  [SKAction waitForDuration:0.1 withRange:0.3],
                                                  [SKAction group:@[
                                                                    [SKAction fadeInWithDuration:0.2],
                                                                    [SKAction scaleTo:1.0 duration:0.10]
                                                                    ]]]]];
}

-(void)hideSelectionIndicator{
    
    [self.selectionSprite runAction:[SKAction sequence:@[[SKAction fadeOutWithDuration:0.3],[SKAction
                                                                                             removeFromParent]]]];
}
#pragma mark - touch and selection handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.actorLayer];
    NSInteger column,row;
    
    if ([self convertPoint:location toColumn:&column row:&row]) {
        RWTActor *actor = [self.level actorAtColumn:column row:row];
        self.actorColumn = column;
        self.actorRow = row;
        if (actor !=nil) {
                        //delegte the event to view controller
            [self showBlueSelection:actor];
            if ([self.delegate respondsToSelector:@selector(startMatching)]) {
                [self.delegate startMatching];
            }
         }
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.selectionSprite.parent !=nil) {
        [self hideSelectionIndicator];
    }
    
}
#pragma mark - add Sprite for Actor/Tiles
- (void)addTiles {
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            if ([self.level tileAtColumn:column row:row] != nil) {
                SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:@"Tile"];
                tileNode.position = [self pointForColumn:column row:row];
                [self.tilesLayer addChild:tileNode];
            }
        }
    }
}

-(void)addSpritesForActors:(NSSet *)actors {
    for (RWTActor *actor in actors) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[actor spriteName]];
        sprite.position = [self pointForColumn:actor.column row:actor.row];
        [self.actorLayer addChild:sprite];
        actor.sprite = sprite;
        actor.sprite.alpha = 0;
        actor.sprite.xScale = actor.sprite.yScale = 0.5;
        [actor.sprite runAction:[SKAction sequence:@[
                                                      [SKAction waitForDuration:0.25 withRange:0.5],
                                                      [SKAction group:@[
                                                                        [SKAction fadeInWithDuration:0.25],
                                                                        [SKAction scaleTo:1.0 duration:0.25]
                                                                        ]]]]];
    }
}
-(void)shuffleActorsSprites:(NSSet *)actors completion:(dispatch_block_t)completion{

    for (RWTActor *actor in actors) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[actor spriteName]];
        sprite.position = [self pointForColumn:actor.column row:actor.row];
        [self.actorLayer addChild:sprite];
        actor.sprite = sprite;
        actor.sprite.alpha = 0;
        actor.sprite.xScale = actor.sprite.yScale = 0.5;
        [actor.sprite runAction:[SKAction sequence:@[
                                                     [SKAction waitForDuration:0.25 withRange:0.5],
                                                     [SKAction group:@[
                                                                       [SKAction fadeInWithDuration:0.25],
                                                                       [SKAction scaleTo:1.0 duration:0.25],[SKAction runBlock:completion]
                                                                       ]]]]];
    }


}

#pragma mark - animation

- (void)animateActorLayer {
    self.gameLayer.hidden = NO;
    self.gameLayer.position = CGPointMake(0, self.size.height);
    SKAction *action = [SKAction moveBy:CGVectorMake(0, -self.size.height) duration:0.7];
    action.timingMode = SKActionTimingEaseOut;
    [self.gameLayer runAction:action];
}

- (void)animateMatchedActors:(NSSet *)chains completion:(dispatch_block_t)completion {
    
        for (RWTActor *actor in chains) {
            
            // 1
            if (actor.sprite != nil) {
                
                // 2
                SKAction *scaleAction = [SKAction scaleTo:0.1 duration:0.3];
                scaleAction.timingMode = SKActionTimingEaseOut;
                [actor.sprite runAction:[SKAction sequence:@[scaleAction, [SKAction removeFromParent]]]];
                
                // 3
                actor.sprite = nil;
            }
        }
    
    
    // 4
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:0.4],
                                         [SKAction runBlock:completion]
                                         ]]];
}

-(void)animateFallingActors:(RWTActor *)actor completion:(dispatch_block_t)completion {
    
    NSSet *set = [NSSet setWithObject:actor];
    if ([set count] == 0) {
        return;
    }else{
    [self addSpritesForActors:set];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL,300,300);
    CGPathAddLineToPoint(path, NULL,actor.column,actor.row);
        SKAction *followline = [SKAction followPath:path asOffset:YES orientToPath:NO duration:0.5];    [actor.sprite runAction:[SKAction sequence:@[followline, [SKAction runBlock:completion]]]];
    }
}

#pragma mark - point conversion
- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
    return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight/2);
}
-(BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row{
    NSParameterAssert(column);
    NSParameterAssert(row);
    
    
    if (point.x >=0 && point.x < NumColumns
        *TileWidth && point.y >=0 && point.y < NumRows * TileHeight) {
        *column =point.x/TileWidth;
        *row = point.y/TileHeight;
        return YES;
    }else{
        *column = NSNotFound;
        *row = NSNotFound;
        return NO;
    }
}

@end
