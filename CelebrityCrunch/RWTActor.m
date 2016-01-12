//
//  RWTActor.m
//  CookieCrunch
//
//  Created by DJIBRIL KEITA on 10/8/14.
//  Copyright (c) 2014 DJIBRILKEITA. All rights reserved.
//

#import "RWTActor.h"

@interface RWTActor ()

@end

@implementation RWTActor



-(NSString *)spriteName{
    
    static NSString *const spriteNames[] ={
        
        @"Robert-Redford",
        
        @"Drew-Barrymore",
        
        @"Robert-Downey-Jr",
       
        @"Al-Pacino",
        
        @"Dustin-Hoffman",
        
        @"Jennifer-Aniston",
        
        @"Kate-Hudson",
        
        @"Robin-Williams",
        
        @"Jodie-Foster",
        
        @"Christian-Bale",
        
        @"Anne-Hathaway",
        
        @"Eddie-Murphy",
        
        @"Angelina-Jolie",
        
        @"Matthew-McConaughey",
        
        @"Michael-Keaton",
        
        @"Hugh-Jackman",
        
        @"Nicolas-Cage",
        
        @"George-Clooney",
        
        @"Meryl-Streep",
        
        @"Cate-Blanchett",
        
        @"Tom-Cruise",
        
        @"Will-Smith",
        
        @"Jack-Black",
        
        @"Adam-Sandler",
        
        @"Jackie-Chan",
        
        @"Clive-Owen",
        
        @"Hugh-Grant",
        
        @"Jack-Nicholson",
        
        @"Nicole-Kidman",
        
        @"Robert-De-Niro",
        
        @"Steve-Carell",
        
        @"Jake-Gyllenhaal",
        
        @"Ben-Stiller",
        
        @"Keira-Knightley",
        
        @"Daniel-Craig",
        
        @"Gwyneth-Paltrow",
        
        @"Russell-Crowe",
        
        @"Sean-Penn",
        
        @"Anthony-Hopkins",
        
        @"Clint-Eastwood",
        
        @"Edward-Norton",
        
        @"Keanu-Reeves",
        
        @"Richard-Gere",
        
        @"Mel-Gibson",
        
        @"Sacha-Baron-Cohen",
        
        @"Charlize-Theron",
        
        @"Halle-Berry",
        
        @"Bruce-Willis",
        
        @"Penelope-Cruz",
        
        @"Sandra-Bullock",
        
        @"Daniel-Day-Lewis",
        
        @"Brad-Pitt",
        
        @"Will-Ferrell",
        
        @"Natalie-Portman",
        
        @"Johnny-Depp",
        
        @"Cameron-Diaz",
        
        @"Matt-Damon",
        
        @"Kate-Winslet",
        
        @"Renee-Zellweger",
        
        @"Scarlett-Johansson",
        
        @"Catherine-Zeta-Jones",
        
        @"Denzel-Washington",
        
        @"Harrison-Ford",
        
        @"Julia-Roberts",
        
        @"Reese-Witherspoon",
        
        @"Tom-Hanks",
        
        @"Jim-Carrey",
        
        @"Leonardo-DiCaprio",
        
        @"Hilary-Swank",
        
        @"Mark-Wahlberg"
        
        

    
    };
    
    return spriteNames[self.actorIndex-1];
    
}


-(NSString *)highlightedSpriteName{

    static NSString * const hilightedSpriteNames [] = {
    
        @"Robert-Redford-hilighted",
        
        @"Drew-Barrymore-hilighted",
        
        @"Robert-Downey-Jr-hilighted",
        
        @"Al-Pacino-hilighted",
        
        @"Dustin-Hoffman-hilighted",
        
        @"Jennifer-Aniston-hilighted",
        
        @"Kate-Hudson-hilighted",
        
        @"Robin-Williams-hilighted",
        
        @"Jodie-Foster-hilighted",
        
        @"Christian-Bale-hilighted",
        
        @"Anne-Hathaway-hilighted",
        
        @"Eddie-Murphy-hilighted",
        
        @"Angelina-Jolie-hilighted",
        
        @"Matthew-McConaughey-hilighted",
        
        @"Michael-Keaton-hilighted",
        
        @"Hugh-Jackman-hilighted",
        
        @"Nicolas-Cage-hilighted",
        
        @"George-Clooney-hilighted",
        
        @"Meryl-Streep-hilighted",
        
        @"Cate-Blanchett-hilighted",
        
        @"Tom-Cruise-hilighted",
        
        @"Will-Smith-hilighted",
        
        @"Jack-Black-hilighted",
        
        @"Adam-Sandler-hilighted",
        
        @"Jackie-Chan-hilighted",
        
        @"Clive-Owen-hilighted",
        
        @"Hugh-Grant-hilighted",
        
        @"Jack-Nicholson-hilighted",
        
        @"Nicole-Kidman-hilighted",
        
        @"Robert-De-Niro-hilighted",
        
        @"Steve-Carell-hilighted",
        
        @"Jake-Gyllenhaal-hilighted",
        
        @"Ben-Stiller-hilighted",
        
        @"Keira-Knightley-hilighted",
        
        @"Daniel-Craig-hilighted",
        
        @"Gwyneth-Paltrow-hilighted",
        
        @"Russell-Crowe-hilighted",
        
        @"Sean-Penn-hilighted",
        
        @"Anthony-Hopkins-hilighted",
        
        @"Clint-Eastwood-hilighted",
        
        @"Edward-Norton-hilighted",
        
        @"Keanu-Reeves-hilighted",
        
        @"Richard-Gere-hilighted",
        
        @"Mel-Gibson-hilighted",
        
        @"Sacha-Baron-Cohen-hilighted",
        
        @"Charlize-Theron-hilighted",
        
        @"Halle-Berry-hilighted",
        
        @"Bruce-Willis-hilighted",
        
        @"Penelope-Cruz-hilighted",
        
        @"Sandra-Bullock-hilighted",
        
        @"Daniel-Day-Lewis-hilighted",
        
        @"Brad-Pitt-hilighted",
        
        @"Will-Ferrell-hilighted",
        
        @"Natalie-Portman-hilighted",
        
        @"Johnny-Depp-hilighted",
        
        @"Cameron-Diaz-hilighted",
        
        @"Matt-Damon-hilighted",
        
        @"Kate-Winslet-hilighted",
        
        @"Renee-Zellweger-hilighted",
        
        @"Scarlett-Johansson-hilighted",
        
        @"Catherine-Zeta-Jones-hilighted",
        
        @"Denzel-Washington-hilighted",
        
        @"Harrison-Ford-hilighted",
        
        @"Julia-Roberts-hilighted",
        
        @"Reese-Witherspoon-hilighted",
        
        @"Tom-Hanks-hilighted",
        
        @"Jim-Carrey-hilighted",
        
        @"Leonardo-DiCaprio-hilighted",
        
        @"Hilary-Swank-hilighted",
        
        @"Mark-Wahlberg-hilighted" ,
    
    
    
    };

    return hilightedSpriteNames[self.actorIndex-1];
}
-(NSUInteger)actorIndex:(NSString *)actorName{
    NSArray *array = @[
        @"Robert-Redford",
        
        @"Drew-Barrymore",
    
        @"Robert-Downey-Jr",
        
        @"Al-Pacino",
        
        @"Dustin-Hoffman",
        
        @"Jennifer-Aniston",
        
        @"Kate-Hudson",
        
        @"Robin-Williams",
        
        @"Jodie-Foster",
        
        @"Christian-Bale",
        
        @"Anne-Hathaway",
        
        @"Eddie-Murphy",
        
        @"Angelina-Jolie",
        
        @"Matthew-McConaughey",
        
        @"Michael-Keaton",
        
        @"Hugh-Jackman",
        
        @"Nicolas-Cage",
        
        @"George-Clooney",
        
        @"Meryl-Streep",
        
        @"Cate-Blanchett",
        
        @"Tom-Cruise",
        
        @"Will-Smith",
        
        @"Jack-Black",
        
        @"Adam-Sandler",
        
        @"Jackie-Chan",
        
        @"Clive-Owen",
        
        @"Hugh-Grant",
        
        @"Jack-Nicholson",
        
        @"Nicole-Kidman",
        
        @"Robert-De-Niro",
        
        @"Steve-Carell",
        
        @"Jake-Gyllenhaal",
        
        @"Ben-Stiller",
        
        @"Keira-Knightley",
        
        @"Daniel-Craig",
        
        @"Gwyneth-Paltrow",
        
        @"Russell-Crowe",
        
        @"Sean-Penn",
        
        @"Anthony-Hopkins",
        
        @"Clint-Eastwood",
        
        @"Edward-Norton",
        
        @"Keanu-Reeves",
        
        @"Richard-Gere",
        
        @"Mel-Gibson",
        
        @"Sacha-Baron-Cohen",
        
        @"Charlize-Theron",
        
        @"Halle-Berry",
        
        @"Bruce-Willis",
        
        @"Penelope-Cruz",
        
        @"Sandra-Bullock",
        
        @"Daniel-Day-Lewis",
        
        @"Brad-Pitt",
        
        @"Will-Ferrell",
        
        @"Natalie-Portman",
        
        @"Johnny-Depp",
        
        @"Cameron-Diaz",
        
        @"Matt-Damon",
        
        @"Kate-Winslet",
        
        @"Renee-Zellweger",
        
        @"Scarlett-Johansson",
        
        @"Catherine-Zeta-Jones",
        
        @"Denzel-Washington",
        
        @"Harrison-Ford",
        
        @"Julia-Roberts",
        
        @"Reese-Witherspoon",
        
        @"Tom-Hanks",
        
        @"Jim-Carrey",
        
        @"Leonardo-DiCaprio",
        
        @"Hilary-Swank",
        
        @"Mark-Wahlberg"];
    
    NSUInteger index =  [array indexOfObject:actorName];

    return index;
}

-(NSString *)blueHilightedSpriteNames{

    static NSString *const bluespriteName []  ={
     @"Robert-Redford-blue", @"Drew-Barrymore-blue", @"Robert-Downey-Jr-blue", @"Al-Pacino-blue", @"Dustin-Hoffman-blue", @"Jennifer-Aniston-blue", @"Kate-Hudson-blue", @"Robin-Williams-blue", @"Jodie-Foster-blue", @"Christian-Bale-blue", @"Anne-Hathaway-blue", @"Eddie-Murphy-blue", @"Angelina-Jolie-blue", @"Matthew-McConaughey-blue", @"Michael-Keaton-blue", @"Hugh-Jackman-blue", @"Nicolas-Cage-blue", @"George-Clooney-blue", @"Meryl-Streep-blue", @"Cate-Blanchett-blue", @"Tom-Cruise-blue", @"Will-Smith-blue", @"Jack-Black-blue", @"Adam-Sandler-blue", @"Jackie-Chan-blue", @"Clive-Owen-blue", @"Hugh-Grant-blue", @"Jack-Nicholson-blue", @"Nicole-Kidman-blue", @"Robert-De-Niro-blue", @"Steve-Carell-blue", @"Jake-Gyllenhaal-blue", @"Ben-Stiller-blue", @"Keira-Knightley-blue", @"Daniel-Craig-blue", @"Gwyneth-Paltrow-blue", @"Russell-Crowe-blue", @"Sean-Penn-blue", @"Anthony-Hopkins-blue", @"Clint-Eastwood-blue", @"Edward-Norton-blue", @"Keanu-Reeves-blue", @"Richard-Gere-blue", @"Mel-Gibson-blue", @"Sacha-Baron-Cohen-blue", @"Charlize-Theron-blue", @"Halle-Berry-blue", @"Bruce-Willis-blue", @"Penelope-Cruz-blue", @"Sandra-Bullock-blue", @"Daniel-Day-Lewis-blue", @"Brad-Pitt-blue", @"Will-Ferrell-blue", @"Natalie-Portman-blue", @"Johnny-Depp-blue", @"Cameron-Diaz-blue", @"Matt-Damon-blue", @"Kate-Winslet-blue", @"Renee-Zellweger-blue", @"Scarlett-Johansson-blue", @"Catherine-Zeta-Jones-blue", @"Denzel-Washington-blue", @"Harrison-Ford-blue", @"Julia-Roberts-blue", @"Reese-Witherspoon-blue", @"Tom-Hanks-blue", @"Jim-Carrey-blue", @"Leonardo-DiCaprio-blue", @"Hilary-Swank-blue", @"Mark-Wahlberg-blue"
    
    };
    return bluespriteName[self.actorIndex-1];

}

-(NSArray *)getMovieListForActor:(RWTActor*)actor withMap:(NSDictionary *)map{
    NSString *actorName = [actor spriteName];
    return [map objectForKey:actorName];

}

@end
