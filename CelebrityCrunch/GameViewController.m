//
//  GameViewController.m
//  CelebrityCrunch
//
//  Created by DJIBRIL KEITA on 10/30/14.
//  Copyright (c) 2014 DJIBRILKEITA. All rights reserved.O
//

#import "GameViewController.h"
#import "GameScene.h"
#import "RWTActor.h"
#import "RWTLevel.h"
#import "Canvas.h"
@interface GameViewController()
@property (assign,nonatomic) NSUInteger score;
@property (weak,nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) IBOutlet UIImageView *moviePanel;
@property (strong, nonatomic) IBOutlet UITextView *movieLabel;

@property (strong, nonatomic) GameScene *scene;
@property (strong, nonatomic) RWTActor *actor;
@property (strong,nonatomic) RWTLevel *level;
@end


@implementation GameViewController


- (IBAction)shuffleButtonPressed:(id)sender {
    [self reShufle];
}
-(void)showActorLayer{
    [self.scene animateActorLayer];

}
-(void)startMatching{
    [self.level chooseActorAtColumn:[self.scene actorColumn] row:[self.scene actorRow]];
    [self updateScoreLabel];
    [self handleMatches];
}
-(void)handleMatches{
    NSSet *set = [self.level removeMatches];
    //do something with matches
    if ([set count] != 0) {
        [self.scene animateMatchedActors:set completion:^{
            self.view.userInteractionEnabled = NO;
            RWTActor *colums = [self.level fillHoles];
            if (colums) {
                [self.scene animateFallingActors:colums completion:^{
                    self.view.userInteractionEnabled =YES;
                }];
                
            }
        }];
    }

}
-(void)updateScoreLabel{
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld",[self getScore]];
}
-(void)updateMovieLabel{
    self.movieLabel.text = [self stringCleanser:self.level.movie.movieName];
}
-(void)animateMoviePanel{
    CSAnimationView *animationView = [[CSAnimationView alloc] initWithFrame:CGRectMake(self.moviePanel.frame.origin.x, self.moviePanel.frame.origin.y, self.moviePanel.frame.size.width, self.moviePanel.frame.size.height)];
    animationView.backgroundColor = [UIColor clearColor];
    animationView.duration = 0.9;
    animationView.delay    = 0;
    animationView.type    = CSAnimationTypeBounceLeft;
    [self.view addSubview:animationView];
    [animationView addSubview:self.moviePanel];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateMoviePanel)];
    self.level.movie.movieName =[self.level nextLevel];
    [self updateMovieLabel];
    [self reShufle];
    [animationView setUserInteractionEnabled:YES];
    [animationView addGestureRecognizer:self.tapGestureRecognizer];
    [animationView startCanvasAnimation];


}
-(NSString *)stringCleanser:(NSString *)inString{
    NSCharacterSet *dash = [NSCharacterSet characterSetWithCharactersInString:@"-"];
    NSArray *array= [inString componentsSeparatedByCharactersInSet:dash];
    NSString *outString =[array componentsJoinedByString:@" "];
    return outString;

}
-(NSUInteger)getScore{
    NSUInteger Score =[self.scoreDelegate updateScore];
    return Score;

}


-(void)beginGame{
    UIImage *btnImg = [UIImage imageNamed:@"moviePanel"];
    [self.moviePanel setImage:btnImg];
    [self.moviePanel addSubview:self.movieLabel];
    self.movieLabel.text = [self stringCleanser:self.level.movie.movieName];
    [self animateMoviePanel];
     [self showActorLayer];
    [self shuffle];


}
-(void)reShufle{
    NSSet *actors = [self.level reShuffle];
    self.view.userInteractionEnabled = NO;
    [self.scene animateMatchedActors:actors completion:^{
        NSSet *newActors = [self.level shuffle];
        [self.scene shuffleActorsSprites:newActors completion:^{
         self.view.userInteractionEnabled =YES;
        }];
    }];
}
-(void)shuffle{

   NSSet *newActors = [self.level shuffle];
   [self.scene addSpritesForActors:newActors];
    
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    
    SKView * skView = (SKView *)self.view;
    skView.multipleTouchEnabled = NO;
   /* Sprite Kit applies additional optimizations to improve rendering performance */
    
    // Create and configure the scene.
    self.scene =[GameScene sceneWithSize:skView.bounds.size];
    // Present the scene.
    self.scene.scaleMode =SKSceneScaleModeAspectFill;
    self.level = [[RWTLevel alloc]initWithFiles:@"actorTomovie" secondFile:@"movieToActor" thirdFile:@"Level_0"];
    self.scene.level =self.level;
    self.level.movie.map = self.level.movieMap;
    self.scoreDelegate =self.level;
    self.scene.delegate =self;
    [self.scene addTiles];
    [skView presentScene:self.scene];
    
    [self beginGame];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
