//
//  RWTLevel.m
//  CelebrityCrunch
//
//  Created by DJIBRIL KEITA on 11/1/14.
//  Copyright (c) 2014 DJIBRILKEITA. All rights reserved.
//

#import "RWTLevel.h"
@interface RWTLevel()
@property (nonatomic, strong) NSMutableArray *currentChosenActor;
@property (nonatomic, strong) NSMutableArray *currentChosenActorNames;
@property (nonatomic, strong) NSMutableArray *chosenActorNames;
@property (nonatomic,strong)  NSArray *levelMovies;
@property (nonatomic,strong)  NSEnumerator *enumerator;
@property(nonatomic,readwrite) NSInteger score;
@property (nonatomic) NSInteger matchScore;
@end

@implementation RWTLevel


{

    RWTActor *_actors[NumColumns][NumRows];
    RWTTile *_tiles[NumColumns][NumRows];
}


#pragma mark - initializations

-(RWTMovie *)movie{

    if(!_movie)_movie = [[RWTMovie alloc]init];
    return _movie;
}
- (NSMutableArray *)chosenActorNames{
    if (!_chosenActorNames)_chosenActorNames = [[NSMutableArray alloc]init];
    return _chosenActorNames;
        
}
- (NSMutableArray *)currentChosenActor{
    
    if(!_currentChosenActor)_currentChosenActor = [[NSMutableArray alloc]init];
    return _currentChosenActor;
}
-(NSMutableArray *)currentChosenActorNames{

    if(!_currentChosenActorNames)_currentChosenActorNames = [[NSMutableArray alloc]init];
    return _currentChosenActorNames;
    
}
-(NSEnumerator *)enumerator{
    if (!_enumerator)_enumerator = [[NSEnumerator alloc]init];
        return _enumerator;
}


-(instancetype)initWithFiles:(NSString *)firstFilename secondFile:(NSString *)secondFilename thirdFile:(NSString *)thirdFilename{
    
    self= [super init];
    
    if (self !=nil) {
        //creates 3 NSDictionaries for ActorMap MoviesMap and tiles
        
        NSDictionary *myDict1 =[self loadJSON:firstFilename];
        NSDictionary *myDict2 = [self loadJSON:secondFilename];
  //    NSDictionary *tilesDict= [self loadJSON:thirdFilename];
        NSDictionary *dictionary = [self loadJSON:thirdFilename];
        
     // Loop through the rows
        [dictionary[@"tiles"] enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
            
          // Loop through the columns in the current row
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
                
              // Note: In Sprite Kit (0,0) is at the bottom of the screen,
                   // so we need to read this file upside down.
                NSInteger tileRow = NumRows - row - 1;
                
                  // If the value is 1, create a tile object.
                if ([value integerValue] == 1) {
                    _tiles[column][tileRow] = [[RWTTile alloc] init];
                    _tiles[column][tileRow].tileColumn = column;
                    _tiles[column][tileRow].tileRow = row;
                    
                }
            }];
        }];

        
        
        _actorMap = myDict1;
        _movieMap = myDict2;
        _levelMovies = [myDict2 allKeys];
        NSMutableSet *set=[NSMutableSet setWithArray:_levelMovies];
        self.enumerator = [set objectEnumerator];
        
    }  
    return self;
}
#pragma mark - Levels
-(NSString *)nextLevel{
    NSInteger count = [self.levelMovies count];
    int interger = (uint32_t) count;
    NSString *string = [self.levelMovies objectAtIndex:arc4random_uniform(interger)];
    return string;

}
#pragma mark - matching actors
static const int MATCH_BONUS =4;
static const int UNMATCHE_PENALTY =1;

-(void)chooseActorAtColumn:(NSInteger)column row:(NSInteger)row{


    RWTActor *actor =  _actors[column][row];
    self.currentChosenActor = [NSMutableArray array];
    self.currentChosenActorNames = [NSMutableArray array];
        [self.currentChosenActor addObject:actor];
    self.matchScore = 0;
    if ([self.currentChosenActor count]) {
        for (RWTActor *actor in self.currentChosenActor) {
            
            if ([self.chosenActorNames containsObject:[actor spriteName]]) {
                return;
            }else{
                [self.currentChosenActorNames addObject:[actor spriteName]];
                [self.chosenActorNames addObject:[actor spriteName]];
            }
            self.matchScore = [self.movie match:self.currentChosenActorNames withMovie:self.movie.movieName];
            if (self.matchScore) {
                self.score += self.matchScore * MATCH_BONUS;
                actor.machted = YES;                
            }else{
                self.score = self.score - UNMATCHE_PENALTY ;
            }

        }
    }
        NSLog(@"%ld, %ld, %ld",(long)self.score, (unsigned long)[self.currentChosenActor count],(long)self.matchScore);
        NSLog(@"%ld, %ld, %ld,%@",(long)actor.column,(long)actor.row, (long)actor.actorIndex, [actor spriteName]);
    }


-(NSSet *)detectMatches{
    NSMutableSet *set = [NSMutableSet set];
    for (NSInteger column = 0; column<NumColumns; column++) {
        for (NSInteger row = 0; row <NumRows; row++) {
            if (_actors[column][row].machted == 1) {
                [set addObject:_actors[column][row]];
            }
        }
    }
    return set;
}

-(NSSet *)removeMatches{
    NSSet *maches = [self detectMatches];
    for (RWTActor *actor in maches) {
        _actors[actor.column][actor.row] = nil;
    }
    return maches;

}
-(NSUInteger)updateScore{
    return self.score;
}


#pragma mark - fillholes

- (RWTActor*)fillHoles {
    // 1
    RWTActor *actor;
    for (NSInteger column = 0; column < NumColumns; column++) {
        
        for (NSInteger row = 0; row < NumRows; row++) {
            // 2
            if (_tiles[column][row] != nil && _actors[column][row] == nil) {
                NSUInteger actorIndex = arc4random_uniform(NumActors)+1;
                actor = [self createActorsAtColumn:column row:row withIndex:actorIndex];
                _actors[column][row] =actor;
                
                }
            }
        }
    return actor;
}

#pragma mark - creating actors
-(NSSet *)getTiles{
    NSMutableSet *set = [NSMutableSet set];
    for (NSInteger column = 0; column<NumColumns; column++) {
        for (NSInteger row = 0; row <NumRows; row++) {
            if (_tiles[column][row]!=nil) {
                NSNumber *columnNumber = [NSNumber numberWithInteger:_tiles[column][row].tileColumn];
                NSNumber *rowNumber = [NSNumber numberWithInteger:_tiles[column][row].tileRow];
                [set addObject:@[columnNumber,rowNumber]];
                                          
            }
        }
    }
    //check if set row and columns are consistent.
//    NSLog(@"Tiles: %@", set);
    return set;

}
-(NSSet *)getActors{
    NSMutableSet *set = [NSMutableSet set];
    for (NSInteger column = 0; column<NumColumns; column++) {
        for (NSInteger row = 0; row <NumRows; row++) {
            if (_actors[column][row]) {
                [set addObject:_actors[column][row]];
            }
        }
    }
    return set;

}
-(NSSet *)reShuffle{
    NSSet *set = [self getActors];
    for (RWTActor *actor in set) {
        _actors[actor.column][actor.row] = nil;
    }
    return set;
}

-(NSSet *)shuffle{
    return [self createInitialActors];
}
-(NSSet *)createInitialActors{
    NSMutableSet *set = [NSMutableSet set];
    NSMutableSet *newset = [NSMutableSet set];
    NSMutableSet *dict = [[NSMutableSet alloc]init];
   RWTActor *movieActor=  [self createCurrentMovieActors];
    
    
    [set addObject:movieActor];
    //This is why it is not working set size is 25 but only 9 actors are displayed so movieactor may not be created.
        do{
        NSInteger index = arc4random_uniform(NumActors)+1;
        NSNumber *numb = [NSNumber numberWithLong:index];
        [newset addObject:numb];
    
    }while ([newset count]< NumColumns*NumRows);
    NSEnumerator *enumerator = [newset objectEnumerator];
    
        for (NSInteger row = 0; row < NumRows; row++) {
            for (NSInteger column = 0; column < NumColumns; column++) {
        
                if (_tiles[column][row] !=nil &&  _actors[column][row] == nil){
                   
                    RWTActor *actor = [self createActorsAtColumn:column row:row withIndex:[[enumerator nextObject]integerValue]];
                    [set addObject:actor];
                }
            }
        }
    
    return set;
}
// Edit this method below, it is probably braking.

-(RWTActor *)createCurrentMovieActors{
    NSInteger index;
    NSArray *arrayWithTile;
    NSInteger colum;
    NSInteger row;
    RWTActor *actor = nil; // Initialize actor to nil
    NSArray *movieActorNames = [self.movie getActorListforMovie:self.movie.movieName];

    if (movieActorNames != nil && [movieActorNames count] > 0) {
        NSLog(@"MovieActorNames: %@", movieActorNames);

        // Select a random actor name from the list
        NSUInteger randomIndexInMovie = arc4random_uniform((uint32_t)[movieActorNames count]);
        NSString *selectedActorName = [movieActorNames objectAtIndex:randomIndexInMovie];

        // Get the 0-based sprite index for this actor name using the new class method
        // RWTActor's actorIndexForName: returns 1-based ID or NSNotFound.
        // The instance method actorIndex: (if it were still used) was updated to return 0-based or NSNotFound.
        // For direct call to class method, we get 1-based ID.
        NSInteger actorIdFromName = [RWTActor actorIndexForName:selectedActorName];

        if (actorIdFromName == NSNotFound) {
            NSLog(@"Error: Actor name %@ not found in definitions.", selectedActorName);
            actor = nil; // Ensure actor is nil and skip further processing for this actor
        } else {
            // actorIdFromName is 1-based. For actor.actorIndex, which is used by spriteName etc.
            // methods that expect 1-based index from JSON.
            index = actorIdFromName; 

            NSSet *tileSet = [self getTiles];
            if ([tileSet count] > 0) { // Ensure there are tiles to place the actor on
                arrayWithTile = [self randomObject:tileSet];
                colum = [arrayWithTile[0] integerValue];
                row = [arrayWithTile[1] integerValue];
                // 'index' here is the 1-based actorId, which is what createActorsAtColumn expects for actor.actorIndex
                actor = [self createActorsAtColumn:colum row:row withIndex:index]; 
                
                NSLog(@"Placed actor %@ (ID: %ld) at column: %ld, row: %ld for movie: %@", selectedActorName, (long)index, (long)colum, (long)row, self.movie.movieName);
            } else {
                NSLog(@"No tiles available to place actor for movie: %@", self.movie.movieName);
                actor = nil; // Ensure actor is nil if not placed
            }
        }
    } else {
        NSLog(@"No actors found for movie: %@", self.movie.movieName);
        actor = nil; // Ensure actor is nil if no movie actor names
    }
    return actor;
}
-(RWTActor *)createActorsAtColumn:(NSInteger)column row:(NSInteger)row withIndex:(NSInteger)actorIndex{
    RWTActor *actor = [[RWTActor alloc]init];
    actor.actorIndex = actorIndex;
    actor.column = column;
    actor.row =  row;
    _actors[column][row] = actor;
    return actor;

}

#pragma mark - loadJSON

-(NSDictionary *)loadJSON:(NSString *)filename{
    NSString *path =[[NSBundle mainBundle]pathForResource:filename ofType:@"json"];
    if (path ==nil) {
        NSLog(@"Could not find the level file:%@",filename);
    }
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    
    if (data == nil){
        NSLog(@"Could not load data from file:%@", filename);
        
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Could not load dictionary from file:%@",filename);
    }
    return  dictionary;
    
}

#pragma mark - tilesandActorsPointsConversion

-(RWTTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row{
    NSAssert1(column >= 0 && column < NumColumns, @"invalid column:%ld", (long)column);
    NSAssert1(row >=0 && row <NumRows, @"invalid row:%ld", (long)row);
    return _tiles[column][row];
    
}


#pragma mark - actor at column/row

-(RWTActor *)actorAtColumn:(NSInteger)column row:(NSInteger)row{
    
    NSAssert1(column >= 0 && column < NumColumns, @"invalid column:%ld", (long)column);
    NSAssert1(row >=0 && row <NumRows, @"invalid row:%ld", (long)row);
    
    //Gets actor at specific index in the 9X9 grid
    return _actors[column][row];
}
#pragma mark - private methods
-(id)randomObject:(NSSet *)set{
    int randomIndex = arc4random() % [set count];
    __block int currentIndex = 0;
    __block id selectedObj = nil;
    [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if (randomIndex == currentIndex) { selectedObj = obj; *stop = YES; }
        else currentIndex++;
    }];
    return selectedObj;
}
@end
