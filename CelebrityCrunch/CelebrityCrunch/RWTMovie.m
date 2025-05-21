//
//  RWTMovie.m
//  CookieCrunch
//
//  Created by DJIBRIL KEITA on 10/8/14.
//  Copyright (c) 2014 DJIBRILKEITA. All rights reserved.
//

#import "RWTMovie.h"

@implementation RWTMovie


-(NSString *)movieName{

    if (!_movieName) _movieName = [[NSString alloc]init];
    return _movieName;
        
}

-(NSArray *)actorList {

    if(!_actorList) _actorList = [[NSArray alloc]init];
    return _actorList;
}
-(NSArray *)getActorListforMovie:(NSString *)movieNameInput{
        return [self.map objectForKey:movieNameInput];

}

-(int)match:(NSArray *)actors withMovie:(NSString *)name{
    int score = 0;
    self.actorList = [self getActorListforMovie:name];
    NSMutableSet *set = [NSMutableSet setWithArray:self.actorList];
    
    [set intersectSet:[NSSet setWithArray:actors]];
    
    score = (int)set.count;
    return score;
}




@end
